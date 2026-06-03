#!/usr/bin/env bash
# -------------------------------------------------------------------
# Secure cleanup for JCM’s private candlestick data
# Usage: ./private-cleanup.sh [file_or_directory]
# -------------------------------------------------------------------
set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <file_or_directory>" >&2
    exit 1
fi

TARGET="$1"

if [[ -f "$TARGET" ]]; then
    # Overwrite with random data then zeros
    SIZE=$(stat -c%s "$TARGET" 2>/dev/null || stat -f%z "$TARGET" 2>/dev/null)
    if [[ -n "$SIZE" && "$SIZE" -gt 0 ]]; then
        openssl rand -out "$TARGET" "$SIZE" 2>/dev/null || dd if=/dev/urandom of="$TARGET" bs=1024 count=$((SIZE/1024+1)) status=none
    fi
    rm -f "$TARGET"
    echo "Securely deleted: $TARGET"
elif [[ -d "$TARGET" ]]; then
    find "$TARGET" -type f -exec shred -u -z {} \;
    rm -rf "$TARGET"
    echo "Securely deleted directory: $TARGET"
else
    echo "Not found: $TARGET" >&2
    exit 1
fi
