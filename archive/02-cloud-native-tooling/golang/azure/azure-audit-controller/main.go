package main

import (
	"fmt"
	"log"
	"os"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
)

const (
	envSubID = "SUBSCRIPTION_ID"
)

func getToken() (*azidentity.DefaultAzureCredential, string) {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		log.Fatalf("credential error: %v", err)
	}
	// retrieve subscription id from the system
	subID := os.Getenv(envSubID)
	if subID == "" {
		log.Fatalf("env var %s not set", envSubID)
	}
	return cred, subID

}

func main() {
	cred, subID := getToken()
	fmt.Println(cred, subID)
}
