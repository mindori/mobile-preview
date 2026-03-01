# Mobile Preview

Expose local dev server to mobile Chrome via a public HTTPS URL using cloudflared tunnel.

## Prerequisites

Install cloudflared if not present:

```bash
# Check installation
command -v cloudflared

# macOS
brew install cloudflared
```

## Workflow

### 1. Detect port

Identify the dev server port:

| Framework | Default Port | Config                          |
|-----------|-------------|---------------------------------|
| Next.js   | 3000        | `package.json` → `dev` script   |
| Vite      | 5173        | `vite.config.*` → `server.port` |
| CRA       | 3000        | `PORT` env var                  |
| Nuxt      | 3000        | `nuxt.config.*` → `devServer`   |
| Remix     | 5173        | `remix.config.*`                |

Check running server port:

```bash
lsof -i -sTCP:LISTEN -P | grep -E ':(3000|5173|8080|4321) '
```

### 2. Start dev server

If not already running, start in background:

```bash
npm run dev &
# or
pnpm dev &
```

Wait for the server to be ready, then verify the port.

### 3. Start tunnel

Use the bundled script:

```bash
bash ~/.claude/skills/mobile-preview/scripts/tunnel.sh PORT
```

Or run directly:

```bash
cloudflared tunnel --url http://localhost:PORT 2>&1 &
```

Parse the `https://xxx-xxx.trycloudflare.com` URL from the output.

### 4. Share URL

Provide the tunnel URL to the user:

```
Mobile preview URL: https://xxx-xxx.trycloudflare.com

Open the URL above in mobile Chrome.
The tunnel is running in the background. Let me know when you're done.
```

### 5. Cleanup

Terminate the tunnel process when testing is complete:

```bash
pkill -f "cloudflared tunnel"
```

## Troubleshooting

- **Port conflict**: Check with `lsof -i :PORT`, use a different port if needed
- **Tunnel connection failure**: Check firewall/VPN, try reinstalling cloudflared
- **HTTPS mixed content**: Tunnel is HTTPS, so HTTP resources may fail to load. Ensure the dev server uses relative paths
- **HMR not working**: WebSocket-based HMR may not work through cloudflared tunnel. Manual refresh required

## Notes

- cloudflared quick tunnel requires no signup, free, automatic HTTPS
- URL changes on every tunnel restart
- Tunnel sessions last approximately 24 hours (auto-expire after)
- Be cautious with tunnels on dev environments containing sensitive data
