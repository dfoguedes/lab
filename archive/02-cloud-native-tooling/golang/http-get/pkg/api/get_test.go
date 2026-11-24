package api

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"testing"
)

type MockClient struct {
	ResponseOutput *http.Response
}

func (m MockClient) Get(url string) (resp *http.Response, err error) {
	return m.ResponseOutput, nil
}

func TestDoGetReq(t *testing.T) {

	words := WordsPage{
		Page: "words",
		Words: []string{"word1", "word2"},
	}
	wordsBytes,err  := json.Marshal(words)
	if err != nil {
		t.Fatalf("Failed to marshal words: %v", err)
	}
	apiInstance := API{
		Client: MockClient{
			ResponseOutput: &http.Response{
				StatusCode: 200,
				Body:      io.NopCloser(bytes.NewReader(wordsBytes)),
			},
		},
		Options: Options{},
	}
	res, err := apiInstance.DoRequest("http://localhost/words")
	if err != nil {
		t.Fatalf("Failed to do request: %v", err)
	}
	if res == nil {
		t.Fatal("Expected a response, got nil")
	}
	if res.GetResponse() != strings.Join([]string{"word1", "word2"}, ",") {
		t.Fatalf("Expected response to be 'word1,word2', got '%s'", res.GetResponse())
	}
}