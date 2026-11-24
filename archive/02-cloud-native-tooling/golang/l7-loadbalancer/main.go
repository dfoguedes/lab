package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"
	"time"
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

func healthCheck(lb *LoadBalancer) {
	for {
		for _, b := range lb.Backends {
			conn, errDial := net.DialTimeout("tcp", b.URL.Host, 2*time.Second)
			if errDial != nil {
				b.mux.Lock()
				if b.Alive {
					log.Printf("Backend %s went down", b.URL.Host)
					b.Alive = false
				}
				b.mux.Unlock()
			} else {
				b.mux.Lock()
				if !b.Alive {
					log.Printf("Backend %s is back online ", b.URL.Host)
					b.Alive = true
				}
				b.mux.Unlock()
				conn.Close()
			}
		}
		time.Sleep(5 * time.Second)
	}
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
	go healthCheck(&lb)
	log.Fatal(http.ListenAndServe(":8888", proxy))
}
