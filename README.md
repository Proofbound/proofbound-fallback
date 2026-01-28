# Proofbound Marketing Site

The static marketing website for proofbound.com featuring TextKeep download banner and comprehensive information about Proofbound's AI-powered book generation services.

## Purpose

This repository contains the **primary marketing site** for proofbound.com. When users visit proofbound.com, they see this static site with:
- Full marketing content about Proofbound services
- Prominent TextKeep download banner
- CTAs that route to app.proofbound.com for signup/login
- High availability (static hosting, always accessible)

The React app at app.proofbound.com handles:
- User authentication and accounts
- AI book generation tool
- User dashboards
- Payment processing

## Site Pages

### Marketing Pages
1. **index.html** - Landing page with typing animation, service overview, CTAs
2. **how-it-works.html** - 4-step book creation process
3. **service-tiers.html** - Pricing tiers ($49, $500-$2000, $2000-$5000)
4. **faq.html** - FAQ with interactive accordion (12 Q&A items)
5. **elite-service.html** - Premium service details with 6 features
6. **privacy.html** - Privacy policy (11 sections)
7. **terms.html** - Terms of service (17 sections)

### Special Features
- **TextKeep Banner** - Featured on every page, links to textkeep.html
- **Consistent Design** - Glass-morphism cards, blue/purple gradient theme
- **Responsive** - Mobile-first design, works on all devices
- **Interactive Elements** - Typing animation (landing), accordion (FAQ)

## URLs

### Production
- **Marketing Site:** https://proofbound.com (this repo)
- **Application:** https://app.proofbound.com (monorepo)
- **Fallback:** https://status.proofbound.com (shown when app is down)

### Digital Ocean
- **Marketing Site:** [To be deployed to new Digital Ocean App Platform static site]
- **Fallback Site:** https://king-prawn-app-zmwl2.ondigitalocean.app/

## Architecture

```
User visits proofbound.com
  ↓
DNS routes to Digital Ocean App Platform (static site)
  ↓
User sees marketing content with TextKeep banner
  ↓
User clicks "Try for Free" CTA
  ↓
Redirects to app.proofbound.com/signup
  ↓
React app handles signup/login/book generation

If app.proofbound.com is down (5xx error):
  Cloudflare Worker → Redirects to status.proofbound.com
```

## Hosting

- **Platform:** Digital Ocean App Platform (Static Site)
- **Repo:** GitHub `Proofbound/proofbound-fallback` or `Proofbound/proofbound-oof`
- **Auto-deploy:** Pushes to `master` automatically deploy
- **SSL:** Auto-provisioned via Let's Encrypt

## DNS Setup (Cloudflare)

**Current (to be updated):**
```
A      proofbound.com           →  143.110.145.237 (Digital Ocean droplet)
A      app.proofbound.com       →  143.110.145.237 (Digital Ocean droplet)
CNAME  status.proofbound.com    →  king-prawn-app-zmwl2.ondigitalocean.app
```

**Target (after deployment):**
```
CNAME  proofbound.com           →  [new-static-app].ondigitalocean.app
A      app.proofbound.com       →  143.110.145.237 (unchanged)
CNAME  status.proofbound.com    →  king-prawn-app-zmwl2.ondigitalocean.app (unchanged)
```

## Cloudflare Worker

Monitors `app.proofbound.com` (not proofbound.com) and redirects to fallback on errors:

```javascript
const FALLBACK = "https://status.proofbound.com/";
const TIMEOUT_MS = 5000;
```

The worker:
- Only applies to `app.proofbound.com/*` routes
- Redirects to fallback on 5xx errors or timeout
- Returns JSON `{"error": "Origin unreachable"}` for API routes
- Does NOT apply to proofbound.com (static site has no downtime)

## Local Development

```bash
# No build process required - just open files in browser

# Open landing page
open index.html

# Or use a local server for better testing
python3 -m http.server 8000
# Then visit: http://localhost:8000

# Test specific pages
open how-it-works.html
open service-tiers.html
open faq.html
```

## Design System

### Typography
- **Headings:** Crimson Text (serif, 400/600/700 weights)
- **Body:** Inter (sans-serif, 400/500/600/700 weights)
- **Source:** Google Fonts CDN

### Colors
```css
:root {
  --primary: #007bff;           /* Blue primary */
  --text-dark: #212529;         /* Headings */
  --text-secondary: #495057;    /* Body text */
  --text-muted: #6c757d;        /* Subtle text */
  --bg-light: #f8f9fa;          /* Light backgrounds */
  --white: #ffffff;             /* Cards, backgrounds */
}
```

### Backgrounds
- **Main:** `linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%)`
- **Elite Page:** Purple gradient variant

### Glass-Morphism Cards
```css
.glass-card {
  background: rgba(255,255,255,0.7);
  backdrop-filter: blur(20px);
  border-radius: 1rem;
  box-shadow: 0 8px 32px rgba(0,0,0,0.08);
}
```

### Responsive Breakpoints
- **Mobile:** < 768px (single column, reduced padding)
- **Desktop:** ≥ 768px (multi-column, full padding)

## Features & Functionality

### Typing Animation (index.html)
Cycles through words: "ideas", "notes", "expertise", "knowledge"
- Updates every 3 seconds
- Vanilla JavaScript (no dependencies)

### FAQ Accordion (faq.html)
- Click to expand/collapse answers
- Auto-closes other items when opening new one
- Smooth height animation
- Vanilla JavaScript

### CTAs & Navigation
- **Primary CTA:** "Try for Free" → `https://app.proofbound.com/signup`
- **Secondary CTA:** "Elite Service" → `elite-service.html`
- **Navigation:** Consistent header/footer on all pages
- **TextKeep Banner:** Links to `textkeep.html`

## Integration with Monorepo

This static site replaces the React marketing pages in the monorepo:
- React app will remove marketing routes (/, /how-it-works, /faq, etc.)
- React app root route will redirect unauthenticated users to proofbound.com
- Authenticated users go directly to /dashboard
- All marketing links in React app become absolute URLs to proofbound.com

See monorepo changes required in deployment plan.

## Deployment Checklist

- [ ] Set up new Digital Ocean App Platform static site
- [ ] Connect to GitHub repo
- [ ] Configure custom domain: proofbound.com
- [ ] Wait for SSL certificate provisioning
- [ ] Test via Digital Ocean preview URL
- [ ] Update DNS in Cloudflare (proofbound.com CNAME)
- [ ] Update nginx.conf in monorepo (remove proofbound.com redirect)
- [ ] Update React app routes (remove marketing pages)
- [ ] Deploy monorepo changes
- [ ] Verify production functionality
- [ ] Monitor for 7 days

## Testing

### Pre-Deploy Testing
```bash
# Open all pages in browser
open index.html
open how-it-works.html
open service-tiers.html
open faq.html
open elite-service.html
open privacy.html
open terms.html
open textkeep.html

# Test on mobile (Chrome DevTools)
# - Resize to 375px width
# - Test accordion on faq.html
# - Test navigation menu
# - Verify typing animation
```

### Post-Deploy Validation
- [ ] https://proofbound.com loads correctly
- [ ] All internal links work (navigation, footer)
- [ ] CTAs redirect to app.proofbound.com correctly
- [ ] TextKeep banner links to textkeep.html
- [ ] FAQ accordion expands/collapses
- [ ] Typing animation runs on landing page
- [ ] Mobile responsive on iPhone/Android
- [ ] SSL certificate valid
- [ ] Google Analytics tracking (if enabled)

## Files

```
├── index.html                 # Landing page (21 KB)
├── how-it-works.html         # 4-step process (18 KB)
├── service-tiers.html        # Pricing tiers (20 KB)
├── faq.html                  # FAQ with accordion (24 KB)
├── elite-service.html        # Premium service (18 KB)
├── privacy.html              # Privacy policy (8.8 KB)
├── terms.html                # Terms of service (9.8 KB)
├── textkeep.html             # TextKeep product page
├── logo-562x675.png          # Proofbound logo
├── favicons/                 # Favicon assets
├── README.md                 # This file
├── CLAUDE.md                 # Claude configuration & integration docs
├── .claude/                  # Claude settings
└── .claudeignore             # Files to exclude from Claude context
```

## Related Repositories

- **Monorepo:** https://github.com/Proofbound/proofbound-monorepo
  - React app, nginx config, Docker setup
  - Located at: `/Users/sprague/dev/proofbound/proofbound-monorepo`

- **TextKeep:** https://github.com/Proofbound/textkeep
  - macOS app for saving text messages

## Support

- **Technical Issues:** Check CLAUDE.md for architecture details
- **Content Updates:** Edit HTML files directly, push to master
- **Design Changes:** Update inline CSS in each HTML file (consistent variables)

## License

Proprietary - Proofbound, LLC
