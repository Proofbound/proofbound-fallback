# Deployment Documentation

**Last Updated:** February 1, 2026

This document describes the deployed hybrid routing architecture for Proofbound.

## Current Architecture (As Deployed)

### Hybrid Routing Setup

Proofbound uses a **hybrid routing architecture** where:
1. `proofbound.com` serves the React app from the droplet (when up)
2. `proofbound.com/textkeep/*`, `/privacy`, `/terms` ALWAYS route to the static site (via Cloudflare Worker)
3. `proofbound.com` falls back to the static site when the droplet is down

This provides:
- **Primary function**: React app at root domain for authenticated users
- **Special routes**: Always-available static content for critical paths like `/textkeep`, `/privacy`, `/terms`
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

  // Normalize pathname (remove trailing slashes, lowercase)
  const pathname = url.pathname.toLowerCase().replace(/\/$/, '');

  // ALWAYS route these paths to static site (no health check)
  // - /textkeep: Product landing page and FAQ (always available)
  // - /privacy, /terms: Legal pages (must be always accessible)
  if (pathname.startsWith('/textkeep') ||
      pathname === '/privacy' ||
      pathname === '/privacy.html' ||
      pathname === '/terms' ||
      pathname === '/terms.html') {

    // Convert clean URLs to .html extension for static site
    let staticPath = url.pathname;
    if (pathname === '/privacy') {
      staticPath = '/privacy.html';
    } else if (pathname === '/terms') {
      staticPath = '/terms.html';
    }

    // Preserve query parameters
    return fetch(`https://status.proofbound.com${staticPath}${url.search}`, {
      cf: { cacheEverything: false }
    });
  }

  // Health check for other routes
  const isGetLike = request.method === "GET" || request.method === "HEAD";
  const wantsHtml = isGetLike && isHtmlRequest(request) && !isApiPath(pathname);
  const isApi = isApiPath(pathname);

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
If path is /textkeep/* or /privacy or /terms → Route to status.proofbound.com (static site)
If other path → Pass through to droplet (React app)
```

**Failover (Droplet DOWN):**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts
  ↓
If path is /textkeep/* or /privacy or /terms → Route to status.proofbound.com (unchanged)
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
**Repo:** `Proofbound/proofbound-oof`
**Auto-deploy:** Yes (pushes to `master`)

**Content:**
- Fallback/error page (shown when droplet is down)
- TextKeep download page at `/textkeep/`
- TextKeep FAQ system at `/textkeep/faq.html` (25 Q&A pages)
- TextKeep version metadata at `/textkeep/version.json` (v1.3.6)
- Privacy Policy at `/privacy.html` (always available)
- Terms of Service at `/terms.html` (always available)
- Marketing pages (future: could add more static content)

### TextKeep Structure

```
/textkeep/
├── index.html           # TextKeep landing page
├── faq.html             # FAQ index with 25 questions
├── faq/                 # Individual FAQ answer pages
│   ├── why-no-native-export.html
│   ├── ecosystem-lock-in.html
│   ├── green-bubble-problem.html
│   ├── switching-costs.html
│   ├── end-to-end-encryption.html
│   ├── what-is-pq3.html
│   ├── imessage-vs-sms.html
│   ├── imessage-vs-rcs.html
│   ├── messages-in-icloud.html
│   ├── chat-db-database.html
│   ├── how-textkeep-works.html
│   ├── is-textkeep-safe.html
│   ├── what-format-export.html
│   ├── export-attachments.html
│   ├── group-messages.html
│   ├── legal-discovery.html
│   ├── financial-compliance.html
│   ├── gdpr-data-portability.html
│   ├── other-export-tools.html
│   ├── mac-print-to-pdf.html
│   ├── icloud-attachments.html
│   ├── deleted-messages.html
│   ├── advanced-data-protection.html
│   ├── can-apple-read-messages.html
│   └── export-security-risks.html
├── version.json         # Version metadata (v1.3.6)
└── iMessageExport.md    # Research document (source material)
```

**Access:**
- Direct: `https://status.proofbound.com/textkeep`
- Via proxy: `https://proofbound.com/textkeep` (worker routes to static site)
- FAQ: `https://proofbound.com/textkeep/faq.html`

## Deployment Checklist

### Static Site Deployment (proofbound-oof repo)

- [ ] Make changes to HTML/CSS files
- [ ] Test locally with `./test-local.sh` or `python3 -m http.server 8000`
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
# Test always-available routes (should serve from static site)
curl -I https://proofbound.com/textkeep
curl -I https://proofbound.com/textkeep/faq.html
curl https://proofbound.com/textkeep/version.json
curl -I https://proofbound.com/privacy
curl -I https://proofbound.com/terms

# Test root domain (should serve React app when droplet is up)
curl -I https://proofbound.com

# Check DNS
dig proofbound.com
dig status.proofbound.com

# Test FAQ pages
curl -I https://proofbound.com/textkeep/faq/why-no-native-export.html
curl -I https://proofbound.com/textkeep/faq/how-textkeep-works.html
```

## SEO Considerations

### FAQ System SEO Features

All 25 FAQ answer pages include:
- Descriptive, keyword-rich title tags
- Meta descriptions optimized for search snippets
- Canonical URLs to prevent duplicate content issues
- Google Analytics 4 tracking with cross-domain linker
- Structured content with proper H1/H2 hierarchy
- Internal linking back to TextKeep download page
- Educational, non-promotional content

### Analytics Configuration

**Property ID:** `G-08CE0H3LRL`

**Cross-Domain Tracking:** Enabled for:
- `proofbound.com`
- `app.proofbound.com`
- `shop.proofbound.com`

**Event Tracking:**
- `download` - TextKeep app downloads
- `textkeep_click` - Banner engagement
- `cta_click` - Call-to-action interactions

See [docs/ANALYTICS.md](ANALYTICS.md) for comprehensive analytics documentation.

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
1. SSH into droplet: `ssh root@143.110.145.237`
2. Check Docker logs: `docker logs <container>`
3. Revert nginx config if needed
4. Restart nginx: `docker restart <nginx-container>`

## Monitoring

- **Cloudflare Analytics**: Monitor traffic to all domains
- **Worker Logs**: Check for errors in Cloudflare dashboard
- **Digital Ocean**: Monitor static site uptime and deployments
- **Droplet**: Monitor nginx logs and Docker container health
- **Google Analytics**: Track user engagement and conversions
- **Search Console**: Monitor indexing and search performance

## Common Issues and Solutions

### FAQ Pages Not Loading
**Symptoms:** 404 errors on FAQ pages
**Solution:**
1. Verify files exist in `textkeep/faq/` directory
2. Check git status - ensure all files committed and pushed
3. Wait for Digital Ocean deployment (~2 minutes)
4. Clear Cloudflare cache if needed

### Worker Not Routing /textkeep Correctly
**Symptoms:** /textkeep shows React app instead of static site
**Solution:**
1. Check worker is deployed and active
2. Verify routes include `proofbound.com/*`
3. Check worker logs for errors
4. Test pathname matching logic in worker code

### Analytics Not Tracking
**Symptoms:** No events in GA4 DebugView
**Solution:**
1. Verify GA4 tracking code in all HTML files
2. Check GA4 property ID is correct (G-08CE0H3LRL)
3. Test with `?debug_mode=true` query parameter
4. Verify cross-domain linker configuration

## Support Contacts

- **Cloudflare**: support.cloudflare.com
- **Digital Ocean**: support.digitalocean.com
- **DNS Issues**: Cloudflare dashboard → DNS
- **Worker Issues**: Cloudflare dashboard → Workers & Pages
- **Static Site**: Digital Ocean dashboard → Apps

## Version History

- **February 1, 2026**: Added comprehensive FAQ system (25 pages) with SEO optimization
- **January 30, 2026**: Deployed hybrid routing architecture with Cloudflare Worker
- **January 29, 2026**: Reorganized TextKeep from single file to directory structure
- **January 26, 2026**: Added TextKeep landing page and version metadata
