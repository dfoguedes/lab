package main

import (
	"bytes"
	"fmt"
	"log"
	"os"

	"golang.org/x/crypto/ssh"
)

func createClientConfig() (*ssh.ClientConfig, error) {
    privateKey, err := os.ReadFile("mykey.pem")
    if err != nil {
        return nil, fmt.Errorf("failed to read private key: %w", err)
    }

    serverHostKey, err := os.ReadFile("id_rsa.pub")
    if err != nil {
        return nil, fmt.Errorf("failed to read server host key: %w", err)
    }

    serverPublicKey, _, _, _, err := ssh.ParseAuthorizedKey(serverHostKey)
    if err != nil {
        return nil, fmt.Errorf("failed to parse server host key: %w", err)
    }

    sshPrivateKey, err := ssh.ParsePrivateKey(privateKey)
    if err != nil {
        return nil, fmt.Errorf("failed to parse private key: %w", err)
    }

    config := &ssh.ClientConfig{
        User: "admin",
        Auth: []ssh.AuthMethod{
            ssh.PublicKeys(sshPrivateKey),
        },
        HostKeyCallback: ssh.FixedHostKey(serverPublicKey),
    }
    return config, nil
}


func runCommand(config *ssh.ClientConfig, command string) error {
    // Create connection
    client, err := ssh.Dial("tcp", "localhost:2222", config)
    if err != nil {
        return fmt.Errorf("failed to dial: %w", err)
    }
    defer client.Close()

    // Create session
    session, err := client.NewSession()
    if err != nil {
        return fmt.Errorf("failed to create session: %w", err)
    }
    defer session.Close()

    // Run command
    var b bytes.Buffer
    session.Stdout = &b
    session.Stderr = &b // Capture stderr too

    if err := session.Run(command); err != nil {
        return fmt.Errorf("failed to run '%s': %w\nOutput: %s", command, err, b.String())
    }

    output := b.String()
    if output != "" {
        fmt.Printf("Command '%s' output:\n%s", command, output)
    }    
    return nil
}

func main() {
    config, err := createClientConfig()
    if err != nil {
        log.Fatalf("Config error: %v", err)
    }

    // Test with simple command
    if err := runCommand(config, "whoami"); err != nil {
        log.Fatalf("Command failed: %v", err)
    }

}