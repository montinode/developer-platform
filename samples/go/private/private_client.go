// PRIVATE – for JOHN CHARLES MONTI only.
package main

import (
	"crypto/hmac"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"time"
)

func main() {
	key := os.Getenv("GEMINI_API_KEY")
	secret := os.Getenv("GEMINI_API_SECRET")
	if key == "" || secret == "" {
		os.Exit(1)
	}
	nonce := strconv.FormatInt(time.Now().UnixMilli(), 10)
	payload := "{}"
	payloadB64 := hex.EncodeToString([]byte(payload))
	sigPayload := "/v1/balances" + nonce + payloadB64
	h := hmac.New(sha512.New384, []byte(secret))
	h.Write([]byte(sigPayload))
	sig := hex.EncodeToString(h.Sum(nil))

	req, _ := http.NewRequest("POST", "https://api.gemini.com/v1/balances", nil)
	req.Header.Set("X-GEMINI-APIKEY", key)
	req.Header.Set("X-GEMINI-PAYLOAD", payloadB64)
	req.Header.Set("X-GEMINI-SIGNATURE", sig)
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		os.Exit(1)
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	fmt.Print(string(body))
}
