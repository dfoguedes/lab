package main

import (
	"encoding/json"
	"fmt"
	"log"
	"reflect"
)

type Json struct{
	Test any `json:"test"`
	Test3 string `json:"test3"`
}


func main() {
	var jsonParsed Json
	err := json.Unmarshal([]byte(`{"test":{"test123": "testValue"},"test3":"testValue3"}`), &jsonParsed)
	if err != nil {
		log.Fatalf("Error parsing JSON: %v", err)
	}

	fmt.Printf("%s\n", reflect.TypeOf(jsonParsed))
	switch v := jsonParsed.Test.(type) {
	case map[string]any:
		fmt.Printf("Parsed JSON as map: %v\n", v)
		for k, v := range v {
			fmt.Printf("Key: %s, Value: %v\n", k, v)
		}
	}
}