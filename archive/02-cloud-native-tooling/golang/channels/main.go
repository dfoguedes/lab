package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("one")
	c := make(chan bool)
	go testFunction(c)
	fmt.Println("two")
	areWefinished := <- c
	fmt.Printf("areWefinished: %v\n", areWefinished)
}

func testFunction(c chan bool) {
	for i:=0; i<5; i++ {
		fmt.Println("checking...")
		time.Sleep(1 * time.Second)
	}
	c <- true
}