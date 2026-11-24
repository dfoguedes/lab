package api

import "fmt"

type Assignment1 struct {
	Page  string   `json:"page"` // we look for the page attribute
	Words []string `json:"words"` // we look for the words attribute
	Percentages map[string]float64 `json:"percentages"` // we look for the percentages attribute
	Special     []string              `json:"special"`     // we look for the special attribute
	ExtraSpecial []any                `json:"extraSpecial"` // we look for the extraSpecial attribute
}

func (a Assignment1) GetResponse() string {
	return fmt.Sprintf("Page: %s, Words: %v, Percentages: %v, Special: %v, ExtraSpecial: %v",a.Page,a.Words,a.Percentages,a.Special,a.ExtraSpecial)
}