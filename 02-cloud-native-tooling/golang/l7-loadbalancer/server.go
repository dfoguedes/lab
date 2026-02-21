package main

import (
	"flag"
	"fmt"
	"net/http"
)

func main() {
	port := flag.String("port", "9997", "Port to serve on")
	flag.Parse()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from backend on port :%s\n", *port)
	})

	fmt.Printf("Starting server on :%s\n", *port)
	http.ListenAndServe(":"+*port, nil)
}
