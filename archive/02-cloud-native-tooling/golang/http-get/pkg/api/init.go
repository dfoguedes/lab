package api

import "net/http"

type Options struct {
	Password string
	LoginURL string
}

type ClientIface interface {
	Get(url string) (resp *http.Response, err error)
}

type APIIface interface {
	DoRequest(requestUrl string) (Response, error)
}

type API struct {
	Options Options
	Client  ClientIface
}

func New(options Options) APIIface{
	return API{
		Options: options,
		Client: &http.Client{
			Transport: &MyJWTTransport{
				transport: http.DefaultTransport,
				password: options.Password,
				loginURL: options.LoginURL,
			},
		},
	}
}