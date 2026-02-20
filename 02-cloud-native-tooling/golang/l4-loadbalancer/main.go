package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"strings"
)

func handleConnection(conn net.Conn, backend string) {

	connDial, errDial := net.Dial("tcp", backend)

	if errDial != nil {
		log.Println("Erro no Dial:", errDial)
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
	fmt.Printf("Listening on port %v", strings.Split(listenPort, ":")[1])

	backends := []string{"localhost:9997", "localhost:9998", "localhost:9999"}

	counter := 0
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal("Error accepting connection: ", err)
		}
		target := backends[counter%len(backends)]
		go handleConnection(conn, target)
		counter++
	}

}
