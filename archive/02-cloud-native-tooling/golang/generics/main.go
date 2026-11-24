// generics comes in handy when we don't want to have to be preoccupied with the specific types we're working with

package main

import (
	"fmt"
	"reflect"
)

func main() {
	var t1 int=123
	fmt.Printf("plusOne: %v\n type:%v\n",plusOne(t1),reflect.TypeOf(t1))
	var t2 float64=123.12
	fmt.Printf("plusOne: %v\n type:%v\n",plusOne(t2),reflect.TypeOf(t2))
	var t3 float32=123.12
	fmt.Printf("plusOne: %v\n type:%v\n",plusOne(t3),reflect.TypeOf(t3))
}

// Generic function which allows us to receive any type
func plusOne[V int | float64 | int64 | float32](t V) V {
	return t + 1
}


// type Animal interface {
// 	Speak() string
// }


// type Dog struct {
// 	name string
// }

// func (d Dog) Speak() string {
// 	return fmt.Sprintf("Woof! My name is %s.", d.name)
// }


// func getAnimal (a Animal) Animal{
// 	return a
// }