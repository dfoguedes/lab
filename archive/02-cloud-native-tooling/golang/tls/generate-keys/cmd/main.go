package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	keygen "github.com/diogoguedes11/lab"
)

func main() {
	var (
		privateKey []byte
		publicKey []byte
		err error
	)
	privateKey,publicKey,err = keygen.GenerateKeys()
	privPath := filepath.Join("../mykey.pem")
	pubPath := filepath.Join("../mykey.pub")
	err = os.WriteFile(privPath,privateKey,0o644)
	if err != nil {
		log.Fatalf("write private key error: %w",err)
	}
	
	err = os.WriteFile(pubPath,publicKey,0o644)
	if err != nil {
		log.Fatalf("write public key error: %w",err)
	}
	fmt.Println("Public and private key files created. enjoy :)")
}
