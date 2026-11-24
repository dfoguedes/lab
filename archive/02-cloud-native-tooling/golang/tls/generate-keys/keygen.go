package keygen

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"

	"golang.org/x/crypto/ssh"
)


func GenerateKeys() ([]byte,[]byte,error) {
	privateKey, err := rsa.GenerateKey(rand.Reader, 4096)
	if err != nil {
		return nil, nil, fmt.Errorf("generate key: %w", err)
	}
	keyPrivate := pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes:  x509.MarshalPKCS1PrivateKey(privateKey),
	})
	keyPublic, err := ssh.NewPublicKey(&privateKey.PublicKey)
	if err != nil {
		return nil, nil, fmt.Errorf("Failed to create public key: %w",err)
	}
	return  keyPrivate,ssh.MarshalAuthorizedKey(keyPublic),nil 
}
