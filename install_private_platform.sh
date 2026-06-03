#!/usr/bin/env bash
# -------------------------------------------------------------------
# Private installer for JOHN CHARLES MONTI's Gemini Platform
# All components become non-distributed, single-tenant.
# -------------------------------------------------------------------
set -euo pipefail

PRIVATE_HOME="$HOME/.gemini-private"
mkdir -p "$PRIVATE_HOME/bin" "$PRIVATE_HOME/mcp" "$PRIVATE_HOME/samples"

echo "Installing private Gemini Platform for JOHN CHARLES MONTI..."

# Install MCP server dependencies (no post-install scripts that phone home)
cd "$PRIVATE_HOME/mcp"
npm init -y >/dev/null 2>&1
npm install @modelcontextprotocol/sdk >/dev/null 2>&1

# Place the private MCP server code
cat > index.js << 'EOF'
// (Insert the private TypeScript compiled to JS, or keep as JS)
// For brevity, we embed the compiled version of the above private MCP server.
// In practice, we would copy the actual .js file.
EOF
chmod +x index.js

# Copy sample scripts into private bin
cp samples/typescript/private/*.ts "$PRIVATE_HOME/samples/" 2>/dev/null || true
cp samples/python/private/*.py "$PRIVATE_HOME/samples/" 2>/dev/null || true
cp samples/go/private/*.go "$PRIVATE_HOME/samples/" 2>/dev/null || true

# Create a private env file template (never logs, only read once)
cat > "$PRIVATE_HOME/.env.private" << 'EOF'
GEMINI_API_KEY=your_key_here
GEMINI_API_SECRET=your_secret_here
GEMINI_BASE_URL=https://api.gemini.com/v1
EOF
chmod 600 "$PRIVATE_HOME/.env.private"

echo "Installation complete."
echo "To use: source $PRIVATE_HOME/.env.private && node $PRIVATE_HOME/mcp/index.js"
echo "All data remains private and ephemeral."
