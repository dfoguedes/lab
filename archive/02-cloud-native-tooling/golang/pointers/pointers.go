package main

import "fmt"

func main() {
	a := "string"
	testPointer(&a)
	fmt.Printf("a: %s\n", a)
}

func testPointer(a *string) { // changes the output of the value using a function with a pointer
	*a = "another string"
}
