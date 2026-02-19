package main

import (
	"fmt"
	"io"
	"log"
	"net"
)

func handleConnection(conn net.Conn) {
	defer conn.Close()

	connDial, errDial := net.Dial("tcp", "localhost:9999")

	if errDial != nil {
		log.Fatal("Error while initializing the dial to localhost:9999")
	}

	go io.Copy(conn, connDial)
	io.Copy(connDial, conn)
}

func main() {
	ln, err := net.Listen("tcp", ":8888")
	if err != nil {
		log.Fatal("Error listening:", err)
		return
	}
	fmt.Println("Listening on port 8888")

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal("Error accepting connection: ", err)
		}
		go handleConnection(conn)
	}

}
