package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"sync"

	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/terminal"
)

func startServer() error {
	authorizedKeysBytes, err := os.ReadFile("mykey.pub") 
	if err != nil {
			log.Fatalf("Failed to load authorized_keys, err: %v", err)
	}
	authorizedKeysMap := map[string]bool{}
	for len(authorizedKeysBytes) > 0 {
		pubKey, _, _, rest, err := ssh.ParseAuthorizedKey(authorizedKeysBytes)
		if err != nil {
			log.Fatal(err)
		}

		authorizedKeysMap[string(pubKey.Marshal())] = true
		authorizedKeysBytes = rest
	}
	config := &ssh.ServerConfig{
		// Remove to disable password auth.
		// PasswordCallback: func(c ssh.ConnMetadata, pass []byte) (*ssh.Permissions, error) {
		// 	// Should use constant-time compare (or better, salt+hash) in
		// 	// a production setting.
		// 	if c.User() == "admin" && string(pass) == "admin" {
		// 		return nil, nil
		// 	}
		// 	return nil, fmt.Errorf("password rejected for %q", c.User())
		// },

		// Remove to disable public key auth.
		PublicKeyCallback: func(c ssh.ConnMetadata, pubKey ssh.PublicKey) (*ssh.Permissions, error) {
			allowedUsers := map[string]bool {
				"admin": true,
				"diogo": true,
			}
			if !allowedUsers[c.User()] {
				return nil, fmt.Errorf("user %q is not allowed", c.User())
			}
			if authorizedKeysMap[string(pubKey.Marshal())] {
				return &ssh.Permissions{
					// Record the public key used for authentication.
					Extensions: map[string]string{
						"pubkey-fp": ssh.FingerprintSHA256(pubKey),
					},
				}, nil
			}
			return nil, fmt.Errorf("unknown public key for %q", c.User())
		},
	}
	privateBytes, err := os.ReadFile("id_rsa")
	if err != nil {
		log.Fatal("Failed to load private key: ", err)
	}

	private, err := ssh.ParsePrivateKey(privateBytes)
	if err != nil {
		log.Fatal("Failed to parse private key: ", err)
	}
	config.AddHostKey(private)
	
	ln, err := net.Listen("tcp", ":2222")
	fmt.Println("Listening on port 2222")
	if err != nil {
		return fmt.Errorf("failed to listen: %w", err)
	}
	defer ln.Close()
	for {
		conn, err := ln.Accept()
		if err != nil {
			return fmt.Errorf("Error accepting connection: %v", err)
		}
		go handleConnection(conn, config)
	}
}

func createTerminal(channel ssh.Channel) {
	term := terminal.NewTerminal(channel, "$ ")
			for {
				line, err := term.ReadLine()
				if err != nil {
					break
				}
				if line == "exit" {
					term.Write([]byte("Goodbye!\r\n"))
					channel.Close()
					return
				}
				term.Write([]byte(fmt.Sprintf("You typed: %s\n", line)))
			}
}

func handleRequest(channel ssh.Channel, requests <-chan *ssh.Request, wg *sync.WaitGroup) {
	defer wg.Done()
	defer channel.Close()
	
	var terminalCreated bool
	
	for req := range requests {
		ok := false
		switch req.Type {
		case "pty-req":
			ok = true
			req.Reply(ok, nil)
		case "env":
			ok = true
			req.Reply(ok, nil)
		case "shell":
			ok = true
			if !terminalCreated {
				terminalCreated = true
				go createTerminal(channel)
			}
			channel.SendRequest("exit-status", false, []byte{0, 0, 0, 0})
			req.Reply(ok, nil)
		case "exec":
			ok = true
			channel.Write([]byte("Executing command: " + string(req.Payload)))
			channel.SendRequest("exit-status", false, []byte{0, 0, 0, 0})
			req.Reply(ok, nil)
			channel.Close()
		default:
			req.Reply(ok, nil)
		}
	}
}


func handleConnection(conn net.Conn, config *ssh.ServerConfig) {
	defer conn.Close()
	fmt.Printf("New connection from %s\n", conn.RemoteAddr())
	// Handle ssh handshake
	sshConn, chans, reqs, err := ssh.NewServerConn(conn, config)
	if err != nil {
		fmt.Printf("SSH handshake failed: %v\n", err) // Don't use log.Fatal
		return
	}
    	defer sshConn.Close()
	fmt.Printf("SSH connection established from %s\n", sshConn.RemoteAddr())
	
	var wg sync.WaitGroup
	defer wg.Wait()
	// The incoming Request channel must be serviced.
	wg.Add(1)
	go func() {
		ssh.DiscardRequests(reqs)
		wg.Done()
	}()
	for newChannel := range chans {
		// Channels have a type, depending on the application level
		// protocol intended. In the case of a shell, the type is
		// "session" and ServerShell may be used to present a simple
		// terminal interface.
		if newChannel.ChannelType() != "session" {
			newChannel.Reject(ssh.UnknownChannelType, "unknown channel type")
			continue
		}
		channel, requests, err := newChannel.Accept()
		if err != nil {
			log.Fatalf("Could not accept channel: %v", err)
		}
		wg.Add(1)
		go handleRequest(channel, requests, &wg)
	}
}


func main(){
	if err := startServer(); err != nil {
		fmt.Printf("Error starting server: %v\n", err)
	}
}