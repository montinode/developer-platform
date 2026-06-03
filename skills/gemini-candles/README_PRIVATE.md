# gemini-candles – Private Copy for JOHN CHARLES MONTI

## Ownership
This entire skill and all associated files are the exclusive property of **John Charles Monti**.  
No other person may use, copy, or redistribute these files.

## Privacy Guarantees
- No logs, no telemetry, no analytics.
- All CSV data is stored in `/tmp` with a unique name and securely deleted.
- The only network request is a read‑only GET to `api.gemini.com`.
- Nothing is written to persistent storage except the skill files themselves.

## Quick Start
```bash
./install-private.sh          # One‑time setup
gemini-candles btcusd 1hr     # Show chart
