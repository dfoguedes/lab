package main // group of files

import (
	"flag"
	"fmt"
	"log"
	"net/url"

	"github.com/diogoguedes11/lab/golang/http-get/pkg/api"
)



func main() {
	var (
		requestUrl string
		password string
		parsedUrl *url.URL
		err error
	)
	flag.StringVar(&requestUrl, "url", "", "URL to make the HTTP GET request to")
	flag.StringVar(&password, "password", "", "Password for authentication")
	flag.Parse()

	parsedUrl, err = url.ParseRequestURI(requestUrl) // Checks if the URL is valid

	if err != nil {
		log.Fatalf("Invalid URL: %v\n Usage: go run http-get.go -h ", err)
	}

	apiInstance := api.New(api.Options{
		Password: password,
		LoginURL: parsedUrl.Scheme + "://" + parsedUrl.Host + "/login",
	})
	// Reuse the same apiInstance for all requests to ensure the same token is used
	res, err := apiInstance.DoRequest(parsedUrl.String()) // First request
	if err != nil {
		log.Fatalf("Error making request: %v", err)
	}
	if res != nil {
		fmt.Println(res.GetResponse())
	}
}


