package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/url"
	"strings"
)
type Page struct {
	Name  string   `json:"page"` // we look for the page attribute
}



func (a API) DoRequest(requestUrl string) (Response, error) {
	if _, err := url.ParseRequestURI(requestUrl); err != nil {
		return nil, RequestError{
			HTTPCode: 400,
			Body:     fmt.Sprintf("invalid URL: %v", err),
			Err:      "Bad Request",
		}
	}
	resp, err := a.Client.Get(requestUrl)
	if err != nil {
		return nil, RequestError{
			HTTPCode: 500,
			Body:     fmt.Sprintf("error making HTTP GET request: %v", err),
			Err:      "Internal Server Error",
		}
	}
	defer resp.Body.Close() // Ensure the response body is closed after reading

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, RequestError{
			HTTPCode: 500,
			Body:     fmt.Sprintf("error reading response body: %v", err),
			Err:      "Internal Server Error",
		}
	}
		if resp.StatusCode != 200 {
			return nil, RequestError{
				HTTPCode: resp.StatusCode,
				Body:     string(body),
				Err:      fmt.Sprintf("unexpected HTTP status code: %d", resp.StatusCode),
			}
		}

		var page Page
		
		err = json.Unmarshal(body, &page) 
		switch(page.Name) {
			case "words":
				var words Words
				err = json.Unmarshal(body, &words)
				if err != nil {
					return nil, fmt.Errorf("Words unmarshal error: %s", err)
				}
				return words, nil
			case "occurrence":
				var occurrence Occurrence
				err = json.Unmarshal(body, &occurrence)
				if err != nil {
					return nil, fmt.Errorf("Occurrence unmarshal error: %s", err)
				}

				return occurrence, nil
			
			case "assignment1":
				var assignment1 Assignment1
				err := json.Unmarshal(body,&assignment1)
				if err != nil {
					return nil, fmt.Errorf("Words unmarshal error: %s", err)
				}
				return assignment1, nil

		}

		if err != nil {
			return nil, RequestError{
				HTTPCode: resp.StatusCode,
				Body:     string(body),
				Err:      fmt.Sprintf("error unmarshalling json response: %v", err),
			}
		}
	return nil,nil
}
