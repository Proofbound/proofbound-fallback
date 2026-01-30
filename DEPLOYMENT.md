# Deployment Documentation

**Last Updated:** January 29, 2026

This document describes the deployed hybrid routing architecture for Proofbound.

## Current Architecture (As Deployed)

### Hybrid Routing Setup

Proofbound uses a **hybrid routing architecture** where:
1. `proofbound.com` serves the React app from the droplet (when up)
2. `proofbound.com/textkeep/*` ALWAYS routes to the static site (via Cloudflare Worker)
3. `proofbound.com` falls back to the static site when the droplet is down

This provides:
- **Primary function**: React app at root domain for authenticated users
- **Special routes**: Static content for specific paths like `/textkeep`
- **High availability**: Automatic failover to static site on errors

### DNS Configuration (Cloudflare)

```
A      proofbound.com        → 143.110.145.237 (droplet) - Proxied ✅
A      app.proofbound.com    → 143.110.145.237 (droplet) - Proxied ✅
A      shop.proofbound.com   → 143.110.145.237 (droplet) - Proxied ✅
CNAME  status.proofbound.com → king-prawn-app-zmwl... (static site) - Proxied ✅
```

### Cloudflare Worker

**Routes:**
- `app.proofbound.com/*`
- `proofbound.com/*`
- `shop.proofbound.com/*` (optional)

**Worker Logic:**
```javascript
async function handleRequest(request) {
  const url = new URL(request.url);

  // ALWAYS route /textkeep/* to static site (no health check)
  if (url.pathname.startsWith('/textkeep')) {
    return fetch(`https://status.proofbound.com${url.pathname}`, {
      cf: { cacheEverything: false }
    });
  }

  // Health check for other routes
  const isGetLike = request.method === "GET" || request.method === "HEAD";
  const wantsHtml = isGetLike && isHtmlRequest(request) && !isApiPath(url.pathname);
  const isApi = isApiPath(url.pathname);

  try {
    const res = await fetchWithTimeout(request, TIMEOUT_MS);
    if (wantsHtml && res.status >= 500 && res.status < 600) {
      return Response.redirect(FALLBACK, 302); // Redirect to static site
    }
    if (isApi && res.status >= 520) {
      return new Response(JSON.stringify({ error: "Origin unreachable" }), {
        status: 503,
        headers: { "Content-Type": "application/json" }
      });
    }
    return res;
  } catch (err) {
    if (wantsHtml) {
      return Response.redirect(FALLBACK, 302); // Redirect to static site
    }
    return new Response(JSON.stringify({ error: "Origin unreachable" }), {
      status: 503,
      headers: { "Content-Type": "application/json" }
    });
  }
}
```

### Traffic Flow

**Normal Operation (Droplet UP):**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts
  ↓
If path is /textkeep/* → Route to status.proofbound.com (static site)
If other path → Pass through to droplet (React app)
```

**Failover (Droplet DOWN):**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts
  ↓
If path is /textkeep/* → Route to status.proofbound.com (unchanged)
If other path → Droplet returns 5xx → Worker redirects to status.proofbound.com
```

### Nginx Configuration (Monorepo)

**File:** `proofbound-monorepo/nginx-fallback.conf` (line 72)

```nginx
server_name app.proofbound.com proofbound.com _;
```

This allows nginx on the droplet to handle both `app.proofbound.com` and `proofbound.com` requests with the same React app configuration.

### Static Marketing Site

**Hosted at:** `status.proofbound.com`
**Platform:** Digital Ocean App Platform (Static Site)
**Repo:** `Proofbound/proofbound-fallback`
**Auto-deploy:** Yes (pushes to `master`)

**Content:**
- Fallback/error page (shown when droplet is down)
- TextKeep download page at `/textkeep/`
- TextKeep version metadata at `/textkeep/version.json`
- Marketing pages (future: could add more static content)

### TextKeep Structure

```
/textkeep/
├── index.html        # TextKeep landing page
└── version.json      # Version metadata (v1.3.4)
```

**Access:**
- Direct: `https://status.proofbound.com/textkeep`
- Via proxy: `https://proofbound.com/textkeep` (worker routes to static site)

## Deployment Checklist

### Static Site Deployment (proofbound-oof repo)

- [ ] Make changes to HTML/CSS files
- [ ] Test locally with `./test-local.sh`
- [ ] Commit changes
- [ ] Push to `master` branch
- [ ] Digital Ocean auto-deploys in ~2 minutes
- [ ] Verify at `https://status.proofbound.com`
- [ ] Verify worker routing at `https://proofbound.com/textkeep`

### Monorepo Deployment

- [ ] Make changes to nginx, React app, or services
- [ ] Commit changes
- [ ] Push to repository
- [ ] Deploy to droplet (manual or CI/CD)
- [ ] Verify nginx reload successful
- [ ] Test at `https://proofbound.com` and `https://app.proofbound.com`

### Cloudflare Worker Updates

- [ ] Edit worker code in Cloudflare dashboard
- [ ] Test locally if possible
- [ ] Save and deploy in dashboard
- [ ] Monitor for errors in Cloudflare dashboard
- [ ] Verify routing behavior

## Verification Commands

```bash
# Test TextKeep routing (should serve from static site)
curl -I https://proofbound.com/textkeep
curl https://proofbound.com/textkeep/version.json

# Test root domain (should serve React app when droplet is up)
curl -I https://proofbound.com

# Check DNS
dig proofbound.com
dig status.proofbound.com
```

## Rollback Procedures

### If Worker Causes Issues
1. Go to Cloudflare Workers dashboard
2. Remove routes for `proofbound.com/*` temporarily
3. Fix worker code
4. Re-add routes

### If Static Site Has Issues
1. Revert commit in `proofbound-oof` repo
2. Push to master
3. Wait for auto-deploy (~2 minutes)

### If Droplet/Nginx Has Issues
1. SSH into droplet
2. Check Docker logs: `docker logs <container>`
3. Revert nginx config if needed
4. Restart nginx: `docker restart <nginx-container>`

## Monitoring

- **Cloudflare Analytics**: Monitor traffic to all domains
- **Worker Logs**: Check for errors in Cloudflare dashboard
- **Digital Ocean**: Monitor static site uptime and deployments
- **Droplet**: Monitor nginx logs and Docker container health

## Support Contacts

- **Cloudflare**: support.cloudflare.com
- **Digital Ocean**: support.digitalocean.com
- **DNS Issues**: Cloudflare dashboard → DNS
- **Worker Issues**: Cloudflare dashboard → Workers & Pages
