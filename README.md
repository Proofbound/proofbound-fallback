# Proofbound Static Site

Static content for Proofbound infrastructure, including fallback page, TextKeep download, and marketing content.

## Purpose

This repository contains **static fallback and special content** for Proofbound:
- **Fallback page**: Shown when droplet is down (status.proofbound.com)
- **TextKeep download**: Always-available at `/textkeep/` with version metadata
- **Marketing pages**: Full marketing content (how-it-works, pricing, FAQ, etc.)
- **High availability**: Static hosting via Digital Ocean App Platform

### Hybrid Routing Architecture

**Primary Mode (Droplet UP):**
- `proofbound.com` serves React app from droplet
- `proofbound.com/textkeep/*` ALWAYS routes to this static site (via Cloudflare Worker)
- React app handles authentication, book generation, user dashboards

**Failover Mode (Droplet DOWN):**
- `proofbound.com` falls back to this static site (via Cloudflare Worker)
- Users see marketing content and can learn about Proofbound
- TextKeep download remains accessible

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
- **React App:** https://proofbound.com (monorepo on droplet)
- **React App:** https://app.proofbound.com (monorepo on droplet)
- **Static Site:** https://status.proofbound.com (this repo)
- **TextKeep Page:** https://proofbound.com/textkeep (proxied from this repo)
- **TextKeep Direct:** https://status.proofbound.com/textkeep (direct to this repo)

### Digital Ocean
- **Static Site:** https://proofbound-main.ondigitalocean.app/ (this repo)
- **Droplet:** 143.110.145.237 (monorepo)

## Architecture

### Normal Operation (Droplet UP)
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts
  ↓
If path is /textkeep/* → Proxy to status.proofbound.com (this repo)
If other path → Pass through to droplet (React app)
  ↓
User sees React app or TextKeep page
```

### Failover (Droplet DOWN)
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts
  ↓
Droplet returns 5xx error
  ↓
Worker redirects to status.proofbound.com (this repo)
  ↓
User sees fallback marketing content
```

### TextKeep Access (ALWAYS)
```
User visits proofbound.com/textkeep
  ↓
Cloudflare Worker intercepts
  ↓
ALWAYS proxy to status.proofbound.com/textkeep (no health check)
  ↓
Serves textkeep/index.html and version.json from this repo
```

## Hosting

- **Platform:** Digital Ocean App Platform (Static Site)
- **Repo:** GitHub `Proofbound/proofbound-fallback` or `Proofbound/proofbound-oof`
- **Auto-deploy:** Pushes to `master` automatically deploy
- **SSL:** Auto-provisioned via Let's Encrypt

## DNS Setup (Cloudflare)

**Production Configuration:**
```
A      proofbound.com           →  143.110.145.237 (droplet) - Proxied ✅
A      app.proofbound.com       →  143.110.145.237 (droplet) - Proxied ✅
CNAME  status.proofbound.com    →  proofbound-main.ondigitalocean.app - Proxied ✅
```

**Key Points:**
- Both `proofbound.com` and `app.proofbound.com` point to the droplet (React app)
- `status.proofbound.com` points to this static site (Digital Ocean App Platform)
- All records are proxied through Cloudflare for Worker routing and DDoS protection

## Cloudflare Worker

**Routes:** `proofbound.com/*` and `app.proofbound.com/*`

**Logic:**
```javascript
const FALLBACK = "https://status.proofbound.com/";

async function handleRequest(request) {
  const url = new URL(request.url);

  // ALWAYS route /textkeep/* to static site (no health check)
  if (url.pathname.startsWith('/textkeep')) {
    return fetch(`https://status.proofbound.com${url.pathname}`, {
      cf: { cacheEverything: false }
    });
  }

  // Health check for other routes
  try {
    const res = await fetchWithTimeout(request, TIMEOUT_MS);
    if (wantsHtml && res.status >= 500) {
      return Response.redirect(FALLBACK, 302); // Failover
    }
    return res;
  } catch (err) {
    if (wantsHtml) {
      return Response.redirect(FALLBACK, 302); // Failover
    }
    // ... error handling
  }
}
```

**Key Features:**
- Special routing for `/textkeep/*` → ALWAYS serves from this static site
- Failover for other paths → Redirects to this static site when droplet is down
- API routes get JSON error response instead of redirect

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
- **TextKeep Banner:** Links to `/textkeep` (clean URL)

## SEO & LLM Optimization

### Search Engine Optimization
- **Sitemap.xml:** All pages, FAQ entries, and llms.txt included
- **Schema.org Markup:** SoftwareApplication and FAQPage structured data
- **Meta Tags:** Comprehensive meta descriptions and keywords on all pages
- **Internal Linking:** Cross-linking via header/footer navigation
- **Clean URLs:** `/textkeep`, `/privacy`, `/terms` (no .html extensions via Cloudflare Worker)

### LLM-Friendly Documentation (llms.txt)
**Purpose:** Make TextKeep extremely accessible to AI assistants and LLM bots

**Location:** https://proofbound.com/llms.txt

**Contents:**
- **Product Overview:** Complete description with version, features, and use cases
- **25 FAQ Summaries:** All questions with URLs and concise answers
- **Technical Specs:** Database details, system requirements, installation guide
- **Use Cases:** Personal archiving, legal compliance, GDPR data portability
- **Quick Q&A:** Common questions with rapid-fire answers
- **LLM Guidance:** Recommendations for AI assistants on answering user questions
- **SEO Keywords:** Comprehensive keyword list for search optimization

**Discovery:**
- Referenced in `robots.txt` with `LLMs:` directive
- Included in `sitemap.xml` with high priority (0.9)
- Follows the llms.txt standard (https://llmstxt.org/)

**Supported LLM Bots:**
All AI crawlers explicitly allowed in robots.txt including GPTBot, ChatGPT-User, ClaudeBot, CCBot, Google-Extended, anthropic-ai, PerplexityBot, and Applebot

## Integration with Monorepo

### Nginx Configuration
The monorepo's `nginx-fallback.conf` includes `proofbound.com` in server_name:
```nginx
server_name app.proofbound.com proofbound.com _;
```
This allows nginx to serve the React app for both the app subdomain and root domain.

### React App Components
- **TextKeepBanner**: Links to `https://proofbound.com/textkeep`
- **Marketing Links**: Can reference pages at `https://status.proofbound.com`
- **Authentication**: Redirects to `https://proofbound.com` (React app on droplet)

### Routing Summary
| URL | Destination | Notes |
|-----|-------------|-------|
| `proofbound.com` | React app (droplet) | Primary app access |
| `proofbound.com/textkeep/*` | This static site | Always, via worker proxy |
| `app.proofbound.com` | React app (droplet) | Alternative app access |
| `status.proofbound.com` | This static site | Direct access, fallback |

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete architecture documentation.

## Deployment

### Static Site Deployment (This Repo)
- [ ] Make changes to HTML/CSS files
- [ ] Test locally with `./test-local.sh`
- [ ] Commit changes
- [ ] Push to `master` branch
- [ ] Digital Ocean auto-deploys in ~2 minutes
- [ ] Verify at `https://status.proofbound.com`
- [ ] Verify worker routing at `https://proofbound.com/textkeep`

### Complete Architecture Documentation
See [DEPLOYMENT.md](DEPLOYMENT.md) for:
- DNS configuration details
- Cloudflare Worker setup and routes
- Traffic flow diagrams
- Verification commands
- Rollback procedures

## Testing

### Pre-Deploy Testing
```bash
# Use testing helper script
./test-local.sh

# Or open pages manually
open index.html
open how-it-works.html
open service-tiers.html
open faq.html
open elite-service.html
open privacy.html
open terms.html
open textkeep/index.html

# Test on mobile (Chrome DevTools)
# - Resize to 375px width
# - Test accordion on faq.html
# - Test navigation menu
# - Verify typing animation
```

### Validation Commands
```bash
# Test TextKeep routing (should serve from static site)
curl -I https://proofbound.com/textkeep
curl https://proofbound.com/textkeep/version.json

# Test root domain (should serve React app when droplet is up)
curl -I https://proofbound.com

# Test direct static site access
curl -I https://status.proofbound.com
```

### Browser Testing
- [ ] https://proofbound.com loads React app
- [ ] https://proofbound.com/textkeep loads TextKeep page
- [ ] https://status.proofbound.com loads fallback/marketing site
- [ ] All internal links work (navigation, footer)
- [ ] CTAs redirect to app.proofbound.com correctly
- [ ] FAQ accordion expands/collapses
- [ ] Typing animation runs on index page
- [ ] Mobile responsive on iPhone/Android

## Files

```
├── index.html                 # Landing page / fallback page (21 KB)
├── how-it-works.html         # 4-step process (18 KB)
├── service-tiers.html        # Pricing tiers (20 KB)
├── faq.html                  # FAQ with accordion (24 KB)
├── elite-service.html        # Premium service (18 KB)
├── privacy.html              # Privacy policy (8.8 KB)
├── terms.html                # Terms of service (9.8 KB)
├── textkeep/                 # TextKeep download directory
│   ├── index.html            # TextKeep landing page
│   └── version.json          # Version metadata (v1.3.6)
├── downloads/                # Downloadable files
├── assets/                   # All site assets (organized)
│   ├── favicons/             # Favicon files
│   ├── logos/                # Proofbound logo files
│   ├── videos/               # Video files (book animations)
│   ├── textkeep/             # TextKeep screenshots
│   └── kdp-assets/           # Amazon KDP related images
├── README.md                 # This file
├── CLAUDE.md                 # Development context & integration docs
├── DEPLOYMENT.md             # Hybrid routing architecture guide
├── llms.txt                  # LLM-friendly documentation (25 FAQ summaries, features, use cases)
├── robots.txt                # Search engine and LLM bot directives
├── sitemap.xml               # XML sitemap for search engines
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

## Version History

See git commit history for detailed changes. Notable updates:

- **Feb 2, 2026**: Reorganized all assets under `/assets/` directory
  - Created organized subdirectories: `assets/favicons/`, `assets/logos/`, `assets/videos/`, `assets/textkeep/`
  - Moved 8 asset files from root and `favicons/` to new locations
  - Updated 48 files: 34 HTML pages + 4 documentation files
  - Updated all asset references across the site
  - Improved file organization and maintainability

- **Feb 1, 2026**: Added comprehensive FAQ system for TextKeep
  - Created main FAQ index (textkeep/faq.html) with 25 questions in 5 categories
  - Added 25 individual SEO-optimized FAQ answer pages
  - Categories: Apple export strategy, technical architecture, TextKeep usage, legal compliance, alternatives, privacy
  - Updated textkeep/index.html with prominent FAQ links
  - Added iMessageExport.md research document
  - Moved DEPLOYMENT.md to docs/ directory and updated to reflect FAQ system

- **Jan 29, 2026**: Implemented hybrid routing architecture
  - Reorganized TextKeep from `textkeep.html` to `textkeep/` directory
  - Added `textkeep/version.json` with version metadata (v1.3.6)
  - Updated DNS: `proofbound.com` → A record to droplet (was CNAME to static site)
  - Configured Cloudflare Worker for `/textkeep/*` routing and failover
  - Updated nginx-fallback.conf to handle `proofbound.com` requests
  - Created docs/DEPLOYMENT.md to document hybrid routing setup
  - Updated all marketing pages to link to `/textkeep` (clean URLs)

- **Jan 28, 2026**: Converted to full marketing site (7 pages)
  - Added: how-it-works, service-tiers, faq, elite-service, privacy, terms
  - Expanded index.html with typing animation, CTAs, Amazon KDP panel
  - Created DEPLOYMENT_PLAN.md with comprehensive deployment plan
  - Updated README and CLAUDE.md to reflect new purpose

- **Jan 26, 2026**: Added TextKeep banner and landing page
- **Jan 23, 2026**: Updated to light theme with Crimson Text font
- **Initial release**: Simple fallback page with glassmorphism design

## License

Proprietary - Proofbound, LLC
