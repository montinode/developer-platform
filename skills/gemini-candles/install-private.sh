#!/usr/bin/env bash
# -------------------------------------------------------------------
# Private installer for JOHN CHARLES MONTI – gemini-candles skill
# Runs entirely offline after initial npx cache (optional)
# -------------------------------------------------------------------
set -euo pipefail

echo "Installing private gemini-candles for JOHN CHARLES MONTI..."

# Check dependencies
REQUIRED_CMDS=("curl" "jq" "npx" "openssl")
MISSING=()
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "Missing required commands: ${MISSING[*]}" >&2
    echo "Please install them using your package manager (brew/apt/yum)." >&2
    exit 1
fi

# Pre-cache the candlestick-cli package (still public, but no usage data)
echo "Pre-fetching @neabyte/candlestick-cli (local cache only)..."
npx -y @neabyte/candlestick-cli --help &>/dev/null || true

# Copy scripts to a private bin directory
PRIVATE_BIN="$HOME/.local/bin/jcm-private"
mkdir -p "$PRIVATE_BIN"

cp gemini-candles.sh "$PRIVATE_BIN/gemini-candles"
cp private-cleanup.sh "$PRIVATE_BIN/private-cleanup"
chmod +x "$PRIVATE_BIN/gemini-candles" "$PRIVATE_BIN/private-cleanup"

# Create config directory
CONFIG_DIR="$HOME/.config/jcm-gemini"
mkdir -p "$CONFIG_DIR"
cp gemini-candles-config.json "$CONFIG_DIR/config.json"

# Add to PATH if not already
if [[ ":$PATH:" != *":$PRIVATE_BIN:"* ]]; then
    echo "export PATH=\"\$PATH:$PRIVATE_BIN\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$PATH:$PRIVATE_BIN\"" >> "$HOME/.zshrc" 2>/dev/null || true
fi

echo "Installation complete."
echo "Run with: gemini-candles [pair] [timeframe]"
echo "All data remains private and ephemeral."
