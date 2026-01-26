# Proofbound Fallback Page

A static "under construction" landing page that displays when the main proofbound.com site is unavailable.

## URLs

- **Production:** https://status.proofbound.com/
- **Digital Ocean:** https://king-prawn-app-zmwl2.ondigitalocean.app/

## How It Works

1. **Cloudflare Worker** intercepts all requests to `proofbound.com`
2. If the main origin returns a 5xx error or times out (5 seconds), the worker redirects HTML requests to `status.proofbound.com`
3. API requests get a JSON error response instead of a redirect

## Hosting

- **Platform:** Digital Ocean App Platform (Static Site, free tier)
- **Repo:** GitHub `Proofbound/proofbound-fallback`
- **Auto-deploy:** Pushes to `master` automatically deploy

## DNS Setup (Cloudflare)

```
CNAME  status  →  king-prawn-app-zmwl2.ondigitalocean.app  (DNS only)
```

## Cloudflare Worker

Located in Cloudflare Workers. Key config:

```javascript
const FALLBACK = "https://status.proofbound.com/";
const TIMEOUT_MS = 5000;
```

The worker:
- Passes requests through to the main origin
- Redirects to fallback on 5xx errors or timeout
- Returns JSON `{"error": "Origin unreachable"}` for API routes

## Local Development

Just open `index.html` in a browser. No build process required.

## Design

- **Fonts:** Crimson Text (headings) + Inter (body)
- **Colors:** Blue primary (#007bff), light gradient background
- **Features:** Glassmorphism cards, responsive design, "Under Construction" banner with insider access CTA
