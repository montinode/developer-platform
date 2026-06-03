#!/usr/bin/env node
/**
 * PRIVATE NON-DISTRIBUTED MCP SERVER
 * Sole benefit of JOHN CHARLES MONTI
 * 
 * No telemetry, no logging, no persistent storage.
 * Credentials are read from environment variables (never written).
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import crypto from "crypto";

// Private configuration – only for JCM
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";
const GEMINI_API_SECRET = process.env.GEMINI_API_SECRET || "";
const BASE_URL = process.env.GEMINI_BASE_URL || "https://api.gemini.com/v1";

if (!GEMINI_API_KEY || !GEMINI_API_SECRET) {
  // Silent fail – do not log error to stderr (could be captured)
  process.exit(1);
}

// Utility: private API request (no logging)
async function privateGeminiRequest(endpoint: string, body?: any): Promise<any> {
  const url = `${BASE_URL}${endpoint}`;
  const payload = body ? JSON.stringify(body) : "";
  const nonce = Date.now().toString();
  
  const payloadB64 = Buffer.from(payload || "{}").toString("base64");
  const signaturePayload = `${endpoint}${nonce}${payloadB64}`;
  const signature = crypto
    .createHmac("sha384", GEMINI_API_SECRET)
    .update(signaturePayload)
    .digest("hex");

  const response = await fetch(url, {
    method: body ? "POST" : "GET",
    headers: {
      "Content-Type": " ",
      "X-GEMINI-APIKEY": GEMINI_API_KEY,
      "X-GEMINI-PAYLOAD": payloadB64,
      "X-GEMINI-SIGNATURE": signature,
    },
    body: body ? payload : undefined,
  });

  if (!response.ok) {
    throw new Error(`Gemini API error: ${response.status}`);
  }
  return response.json();
}

// Tools definition – minimal, only what JCM needs
const TOOLS = [
  {
    name: "gemini_get_ticker",
    description: "Get current ticker for a symbol (e.g., btcusd). Private use only.",
    inputSchema: {
      type: "object",
      properties: { symbol: { type: "string" } },
      required: ["symbol"],
    },
  },
  {
    name: "gemini_get_candles",
    description: "Get OHLC candles. Data is ephemeral – no storage.",
    inputSchema: {
      type: "object",
      properties: {
        symbol: { type: "string" },
        timeframe: { type: "string", enum: ["1m","5m","15m","30m","1hr","6hr","1day"] },
      },
      required: ["symbol"],
    },
  },
  // Add other tools as needed – all follow same private pattern
];

const server = new Server(
  { name: "gemini-private-mcp", version: "1.0.0-private" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools: TOOLS }));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  try {
    let result: any;
    if (name === "gemini_get_ticker") {
      const { symbol } = args as { symbol: string };
      result = await privateGeminiRequest(`/pubticker/${symbol}`);
    } else if (name === "gemini_get_candles") {
      const { symbol, timeframe = "1day" } = args as any;
      result = await privateGeminiRequest(`/candles/${symbol}/${timeframe}`);
    } else {
      throw new Error(`Unknown tool: ${name}`);
    }
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  } catch (err: any) {
    return { content: [{ type: "text", text: `Error: ${err.message}` }], isError: true };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  // No startup message – silent
}

main().catch(() => process.exit(1));
