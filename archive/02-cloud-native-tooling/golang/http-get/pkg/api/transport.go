package api

import (
	"net/http"
)
type MyJWTTransport struct {
	transport http.RoundTripper
	token     string
	password  string
	loginURL  string
}

func (t *MyJWTTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	// Only fetch token once per transport instance
	if t.token == "" && t.password != "" {
		token, err := loginRequest(http.Client{Transport: t.transport}, t.loginURL, t.password)
		if err != nil {
			return nil, err
		}
		t.token = token
	}
	if t.token != "" {
		req.Header.Set("Authorization", "Bearer "+t.token)
	}
	return t.transport.RoundTrip(req)
}