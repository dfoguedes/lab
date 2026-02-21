package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"
)

type Backend struct {
	URL   *url.URL
	Alive bool
	mux   sync.RWMutex
}
type LoadBalancer struct {
	Backends []*Backend
	Counter  int
	mux      sync.Mutex
}

func main() {

	u1, _ := url.Parse("http://localhost:9997")
	u2, _ := url.Parse("http://localhost:9998")
	u3, _ := url.Parse("http://localhost:9999")

	lb := LoadBalancer{
		Backends: []*Backend{
			{URL: u1, Alive: true},
			{URL: u2, Alive: true},
			{URL: u3, Alive: true},
		},
	}
	proxy := &httputil.ReverseProxy{
		Director: func(req *http.Request) {
			lb.mux.Lock()
			defer lb.mux.Unlock()

			for i := 0; i < len(lb.Backends); i++ {
				index := (lb.Counter + i) % len(lb.Backends)
				target := lb.Backends[index]
				target.mux.RLock()
				isAlive := target.Alive
				target.mux.RUnlock()
				if isAlive {
					req.URL.Scheme = "http"
					req.URL.Host = target.URL.Host
					lb.Counter = (index + 1) % len(lb.Backends)
					return
				} else {
					fmt.Printf("Target %v is down", target.URL.Host)
				}

			}
		},
	}
	log.Fatal(http.ListenAndServe(":8888", proxy))
}
