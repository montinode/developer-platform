#!/usr/bin/env bash
# -------------------------------------------------------------------
# gemini-candles – PRIVATE NON-DISTRIBUTED COPY
# Sole benefit of JOHN CHARLES MONTI
# -------------------------------------------------------------------
# Usage: ./gemini-candles.sh [pair] [timeframe]
# Example: ./gemini-candles.sh btcusd 1hr
# -------------------------------------------------------------------

set -euo pipefail

# Defaults (configurable via env or private config file)
SYMBOL="${1:-btcusd}"
TIMEFRAME="${2:-1d}"

# Validate timeframe
VALID_TIMEFRAMES=("1m" "5m" "15m" "30m" "1hr" "6hr" "1day")
if [[ ! " ${VALID_TIMEFRAMES[*]} " =~ " ${TIMEFRAME} " ]]; then
    echo "Invalid timeframe: $TIMEFRAME. Use one of: ${VALID_TIMEFRAMES[*]}" >&2
    exit 1
fi

# Create a unique, ephemeral CSV file (process ID + random)
CSV_FILE="/tmp/gemini_candles_private_$$_$(openssl rand -hex 4).csv"
trap 'rm -f "$CSV_FILE"' EXIT INT TERM

# Fetch data – no local caching, no logging
(
    echo "timestamp,open,high,low,close,volume"
    curl -s --max-time 10 "https://api.gemini.com/v2/candles/${SYMBOL}/${TIMEFRAME}" \
        | jq -r '.[] | [.[0], .[1], .[2], .[3], .[4], .[5]] | @csv'
) > "$CSV_FILE"

# Check if file is non-empty
if [[ ! -s "$CSV_FILE" ]]; then
    echo "Error: No data received from Gemini API for ${SYMBOL} ${TIMEFRAME}" >&2
    exit 1
fi

# Render chart – strip any extraneous output (telemetry, welcome messages)
npx -y @neabyte/candlestick-cli -f "$CSV_FILE" -t "${SYMBOL} ${TIMEFRAME}" 2>&1 | tail -n +8

# CSV is deleted automatically via trap
