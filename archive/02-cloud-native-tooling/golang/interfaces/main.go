package main

import (
	"fmt"
	"io"
	"log"
)

type MySlowReader struct {
	Contents string
	pos int
}
func (m *MySlowReader) Read(p []byte) (n int, err error) {
	if m.pos + 1 <= len(m.Contents) {
		n := copy(p,m.Contents[m.pos:m.pos+1])
		m.pos++
		return n,nil
	}
	return 0,io.EOF
}

func main() {
	mySlowReaderInstance := &MySlowReader{
		Contents: "Hello world",
	}
	out, err := io.ReadAll(mySlowReaderInstance) 
	if err != nil {
		log.Fatalf("Error reading response body: %v", err)
	}
	fmt.Printf("Output: %s\n",out)
}