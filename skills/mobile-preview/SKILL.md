---
name: mobile-preview
description: >
  로컬 개발 서버를 cloudflared 터널로 외부에 노출하여 모바일 Chrome에서 프리뷰할 수 있게 한다.
  Use when: (1) 사용자가 모바일에서 결과를 확인하고 싶을 때, (2) "모바일 프리뷰", "핸드폰에서 확인",
  "모바일에서 보고 싶다", "폰으로 테스트" 등의 요청, (3) 원격 개발(remote-control) 환경에서
  외부 접근이 필요할 때, (4) localhost를 외부에 공유해야 할 때.
---

# Mobile Preview

cloudflared 터널을 사용해 로컬 개발 서버를 모바일 Chrome에서 접근 가능한 공개 URL로 노출한다.

## Prerequisites

cloudflared 설치 확인 후 없으면 설치:

```bash
# 설치 확인
command -v cloudflared

# macOS 설치
brew install cloudflared
```

## Workflow

### 1. 포트 감지

프로젝트의 개발 서버 포트를 파악한다:

| Framework  | Default Port | Config                           |
|-----------|-------------|----------------------------------|
| Next.js   | 3000        | `package.json` → `dev` script    |
| Vite      | 5173        | `vite.config.*` → `server.port`  |
| CRA       | 3000        | `PORT` env var                   |
| Nuxt      | 3000        | `nuxt.config.*` → `devServer`    |
| Remix     | 5173        | `remix.config.*`                 |

실행 중인 서버 포트 확인:

```bash
lsof -i -sTCP:LISTEN -P | grep -E ':(3000|5173|8080|4321) '
```

### 2. 개발 서버 시작

서버가 실행 중이 아니면 백그라운드로 시작:

```bash
# package.json의 dev script 사용 (백그라운드)
npm run dev &
# 또는
pnpm dev &
```

서버가 준비될 때까지 잠시 대기 후 포트 확인.

### 3. 터널 시작

번들된 스크립트 사용:

```bash
bash ~/.claude/skills/mobile-preview/scripts/tunnel.sh PORT
```

또는 직접 실행:

```bash
cloudflared tunnel --url http://localhost:PORT 2>&1 &
```

출력에서 `https://xxx-xxx.trycloudflare.com` URL을 파싱한다.

### 4. URL 전달

터널 URL을 사용자에게 명확하게 전달:

```
모바일 프리뷰 URL: https://xxx-xxx.trycloudflare.com

모바일 Chrome에서 위 URL을 열어주세요.
터널은 백그라운드에서 실행 중이며, 작업이 끝나면 알려주세요.
```

### 5. 정리

사용자가 테스트 완료하면 터널 프로세스 종료:

```bash
pkill -f "cloudflared tunnel"
```

## Troubleshooting

- **포트 충돌**: `lsof -i :PORT`로 확인, 필요시 다른 포트 사용
- **터널 연결 실패**: 방화벽/VPN 확인, `cloudflared` 재설치 시도
- **HTTPS 혼합 콘텐츠**: 터널은 HTTPS이므로 HTTP 리소스 로드 실패 가능. 개발 서버가 상대 경로 사용하는지 확인
- **HMR 미작동**: cloudflared 터널에서는 WebSocket 기반 HMR이 작동하지 않을 수 있음. 수동 새로고침 필요

## Notes

- cloudflared quick tunnel은 가입 불필요, 무료, HTTPS 자동 지원
- URL은 터널 재시작 시마다 변경됨
- 터널 세션은 약 24시간 유지 (이후 자동 만료)
- 민감한 데이터가 있는 개발 환경은 터널 사용 시 주의
