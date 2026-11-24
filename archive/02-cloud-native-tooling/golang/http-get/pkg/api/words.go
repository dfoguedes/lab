package api

import (
	"fmt"
	"strings"
)
type Words struct {
	Page  string   `json:"page"` // we look for the page attribute
	Input string  `json:"input"`
	Words []string `json:"words"` // we look for the words attribute
}

type WordsPage struct {
	Page  string
	Words []string
}

func (w Words) GetResponse() string {
	return fmt.Sprintf("Words: %s", strings.Join(w.Words, ", "))
}

