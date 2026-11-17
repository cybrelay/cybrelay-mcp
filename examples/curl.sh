#!/usr/bin/env bash
# List the CybRelay MCP tools with a plain HTTP call (Streamable HTTP, stateless).
# Usage: CYBRELAY_API_KEY=... ./curl.sh
set -euo pipefail
curl -sS https://api.cybrelay.com/mcp \
  -H "Authorization: Bearer ${CYBRELAY_API_KEY:?set CYBRELAY_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
