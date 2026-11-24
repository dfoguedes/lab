package api

import "fmt"

type RequestError struct {
	HTTPCode int
	Body string
	Err string 
}

func (e RequestError) Error() string {
	return fmt.Sprintf("\nHTTP Code: %d\nBody: %s\nError: %s\n", e.HTTPCode, e.Body, e.Err)
}





