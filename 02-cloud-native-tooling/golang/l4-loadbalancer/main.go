package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"time"
)

type Backend struct {
	Address string
	Alive   bool
}

func healthCheck(backends []*Backend) {
	for {
		for _, b := range backends {
			conn, errDial := net.DialTimeout("tcp", b.Address, 2*time.Second)
			if errDial != nil {
				log.Printf("Backend %s went down", b.Address)
				b.Alive = false
			} else {
				log.Printf("Backend %s is back online ", b.Address)
				b.Alive = true
				conn.Close()
			}
		}
		time.Sleep(5 * time.Second)
	}
}
func handleConnection(conn net.Conn, backend *Backend) {

	connDial, errDial := net.Dial("tcp", backend.Address)

	if errDial != nil {
		log.Printf("We could not connect to the backend address: %v", backend.Address)
		backend.Alive = false
		return
	}

	defer conn.Close()
	defer connDial.Close()

	done := make(chan bool)
	go func() {
		io.Copy(conn, connDial)
		done <- true
	}()
	go func() {
		io.Copy(connDial, conn)
		done <- true
	}()
	<-done
	<-done

}

func main() {
	listenPort := ":8888"
	ln, err := net.Listen("tcp", listenPort)
	if err != nil {
		log.Fatal("Error listening:", err)
		return
	}
	fmt.Printf("Listening on port %v\n", listenPort)

	backends := []*Backend{
		{Address: "localhost:9997", Alive: true},
		{Address: "localhost:9998", Alive: true},
		{Address: "localhost:9999", Alive: true},
	}
	counter := 0
	go healthCheck(backends)
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal("Error accepting connection: ", err)
		}
		for i := 0; i < len(backends); i++ {
			target := backends[counter%len(backends)]
			counter++
			if target.Alive {
				go handleConnection(conn, target)
				break
			}
		}
	}
}
