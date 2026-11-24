package api

import (
	"fmt"
	"strings"
)
type Occurrence struct {
	Page  string   `json:"page"` // we look for the page attribute
	Words map[string]int `json:"words"` // we look for the words attribute
}


func (o Occurrence) GetResponse() string { //overloading, we use the same function name but different types
	words := []string{}
	for word, occurrence := range o.Words {
		words = append(words, fmt.Sprintf("%s (%d)", word, occurrence))
	}
	return fmt.Sprintf("Words: %s", strings.Join(words, ", "))
}