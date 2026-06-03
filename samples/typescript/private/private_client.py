#!/usr/bin/env python3
"""PRIVATE – for JOHN CHARLES MONTI only. No print statements except final data."""
import os
import json
import hmac
import hashlib
import time
import requests
from sys import stdout, stderr

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
GEMINI_API_SECRET = os.environ.get("GEMINI_API_SECRET")
BASE_URL = os.environ.get("GEMINI_BASE_URL", "https://api.gemini.com/v1")

def private_request(endpoint: str, body: dict = None):
    if not GEMINI_API_KEY or not GEMINI_API_SECRET:
        stderr.write("")  # silent
        exit(1)
    
    url = f"{BASE_URL}{endpoint}"
    nonce = str(int(time.time() * 1000))
    payload = json.dumps(body or {})
    payload_b64 = payload.encode().hex()
    signature_payload = f"{endpoint}{nonce}{payload_b64}"
    signature = hmac.new(
        GEMINI_API_SECRET.encode(),
        signature_payload.encode(),
        hashlib.sha384
    ).hexdigest()
    
    headers = {
        "X-GEMINI-APIKEY": GEMINI_API_KEY,
        "X-GEMINI-PAYLOAD": payload_b64,
        "X-GEMINI-SIGNATURE": signature,
    }
    resp = requests.post(url, headers=headers, json=body) if body else requests.get(url, headers=headers)
    resp.raise_for_status()
    return resp.json()

if __name__ == "__main__":
    # Example: get balances
    data = private_request("/balances")
    stdout.write(json.dumps(data, indent=2))
