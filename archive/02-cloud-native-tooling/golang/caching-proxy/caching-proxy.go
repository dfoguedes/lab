package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
)

type CacheEntry struct {
	StatusCode int
	Header     http.Header
	Body       []byte
}

func makeHandler(origin string, cache map[string]CacheEntry) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		key := r.Method + ":" + origin + r.URL.RequestURI()

		// check cache
		cachedResponse, found := cache[key]

		if found {
			for k, vv := range cachedResponse.Header {
				for _, v := range vv {
					w.Header().Add(k, v)
				}

			}
			w.Header().Set("X-Cache", "HIT")
			w.WriteHeader(cachedResponse.StatusCode)
			w.Write(cachedResponse.Body)
			fmt.Println("Cache hit for key:", key)
			// If headers are not correct, the browser will makes us download the file instead of displaying it

		} else {
			// Cache miss
			req, err := http.NewRequest(r.Method, origin+r.URL.RequestURI(), r.Body)
			fmt.Println("Cache miss for key:", key)
			if err != nil {
				log.Fatalf("Failed to create request: %v", err)
			}
			req.Header = r.Header.Clone()
			client := &http.Client{}
			resp, err := client.Do(req)

			if err != nil {
				http.Error(w, "Error fetching from origin server", http.StatusInternalServerError)
				log.Printf("Error fetching from origin server: %v", err)
				return
			}
			defer resp.Body.Close()

			if err != nil {
				log.Printf("Error reading response body: %v", err)
				return
			}
			respBodyBytes, err := io.ReadAll(resp.Body)
			cache[key] = CacheEntry{
				StatusCode: resp.StatusCode,
				Header:     resp.Header.Clone(),
				Body:       respBodyBytes,
			}

			for k, vv := range resp.Header {
				for _, v := range vv {
					w.Header().Add(k, v)
				}
			}
			w.Header().Set("X-Cache", "MISS")
			w.WriteHeader(resp.StatusCode)
			_, err = w.Write(respBodyBytes)
		}
	}

}

func main() {
	cache := make(map[string]CacheEntry)

	port := flag.String("port", "8080", "port to listen on")
	origin := flag.String("origin", "http://localhost", "origin server URL")

	flag.Parse()

	fmt.Println("Port:", *port)
	fmt.Println("Origin:", *origin)

	s := &http.Server{
		Addr:           ":8080",
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
		Handler:        makeHandler(*origin, cache),
	}
	log.Println("Starting proxy server on :8080")
	err := s.ListenAndServe()
	if err != nil {
		log.Fatal("Error starting proxy server: ", err)
	}
}
