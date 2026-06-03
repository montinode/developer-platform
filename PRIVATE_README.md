# Gemini Developer Platform – Private Non‑Distributed Copy

**Owner:** JOHN CHARLES MONTI  
**No other person may use, copy, or redistribute any part of this platform.**

## Privacy Guarantees
- Zero telemetry, zero analytics, zero logging (no console output except final requested data).
- API credentials are read from environment variables – never written to disk by any script.
- Temporary files (e.g., candlestick CSVs) are securely wiped after use.
- The MCP server communicates only with Gemini’s API endpoints and the MCP client (Claude). No other network requests.

## Components Modified
1. **MCP Server** – all tools stripped of logging, error messages minimized.
2. **Samples (TS/Python/Go)** – no print statements except the final JSON output; credentials never echo.
3. **Candlestick Skill** – ephemeral CSV, immediate deletion, no summarization.

## Usage

### MCP Server (for Claude)
```bash
export GEMINI_API_KEY="..."
export GEMINI_API_SECRET="..."
node /path/to/private/mcp/index.js
