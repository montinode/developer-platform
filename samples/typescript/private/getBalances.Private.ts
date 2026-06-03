/**
 * PRIVATE – for JOHN CHARLES MONTI only.
 * Reads credentials from env (never logs them).
 * Outputs raw JSON to stdout (no extra text).
 */
import { privateGeminiRequest } from "./privateGeminiClient";

async function main() {
  const balances = await privateGeminiRequest("/balances");
  process.stdout.write(JSON.stringify(balances, null, 2));
}

main().catch(err => {
  // Silent failure – no stack trace printed
  process.exit(1);
});
