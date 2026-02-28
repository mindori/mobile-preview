#!/bin/bash
# Start a cloudflared quick tunnel for mobile preview.
# Usage: tunnel.sh [PORT] [--qr]
# Output: Prints TUNNEL_URL=<url> when tunnel is ready.

set -euo pipefail

PORT="${1:-3000}"
SHOW_QR="${2:-}"

# Check cloudflared
if ! command -v cloudflared &>/dev/null; then
  echo "ERROR: cloudflared not installed"
  echo "Install: brew install cloudflared"
  exit 1
fi

# Check if port is active
if ! lsof -i :"$PORT" -sTCP:LISTEN &>/dev/null; then
  echo "ERROR: No server on port $PORT"
  exit 1
fi

echo "Starting tunnel for localhost:$PORT ..."

# Start cloudflared, parse URL from stderr
cloudflared tunnel --url "http://localhost:$PORT" 2>&1 | while IFS= read -r line; do
  URL=$(echo "$line" | grep -oE 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' || true)
  if [ -n "$URL" ]; then
    echo ""
    echo "TUNNEL_URL=$URL"
    echo ""
    if [ "$SHOW_QR" = "--qr" ] && command -v qrencode &>/dev/null; then
      qrencode -t ANSIUTF8 "$URL"
    fi
  fi
done
