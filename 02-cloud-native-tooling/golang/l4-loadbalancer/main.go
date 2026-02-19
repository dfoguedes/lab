package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"strings"
)

func handleConnection(conn net.Conn) {
	defer conn.Close()

	reader := bufio.NewReader(conn)
	message, err := reader.ReadString('\n')

	if err != nil {
		log.Fatal("Read error: ", err)
		return
	}
	ackMsg := strings.TrimSpace(message)
	response := fmt.Sprintf("New ACK message:%s\n", ackMsg)

	conn_dial, err_dial := net.Dial("tcp", "localhost:9999")

	if err_dial != nil {
		log.Fatal("Error while initializing the dial to localhost:9999")
	}
	conn_dial.Write([]byte(response))

}

func main() {
	ln, err := net.Listen("tcp", ":8888")
	if err != nil {
		log.Fatal("Error listening:", err)
	}

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal("Error accepting connection: ", err)
		}
		go handleConnection(conn)
	}

}
