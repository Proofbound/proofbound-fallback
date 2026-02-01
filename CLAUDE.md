# Proofbound Marketing Site

**Static marketing website for proofbound.com featuring comprehensive information about Proofbound's AI-powered book generation services.**

## Purpose

This repository contains the **static fallback and special content** for Proofbound infrastructure:
- **Fallback page**: Shown when droplet is down (status.proofbound.com)
- **TextKeep download page**: Always-available download page at `/textkeep/`
- **TextKeep version metadata**: Version info at `/textkeep/version.json` (v1.3.6)
- **Privacy Policy**: Always-available legal page at `/privacy.html`
- **Terms of Service**: Always-available legal page at `/terms.html`
- **Future**: Can host additional static marketing content

**Architecture**: Static HTML pages with inline CSS and vanilla JavaScript. No build process, frameworks, or dependencies.

## Integration with Proofbound Ecosystem

This repository uses a **hybrid routing architecture** with the [proofbound-monorepo](https://github.com/Proofbound/proofbound-monorepo):

### Repository Relationships
- **Static Site** (`proofbound-oof`): Hosted at status.proofbound.com, contains fallback + TextKeep
- **Application** (`proofbound-monorepo`): React app at proofbound.com and app.proofbound.com (on droplet)

### Hybrid Routing Architecture

**DNS Configuration:**
- `proofbound.com` → `143.110.145.237` (droplet) - Proxied via Cloudflare
- `app.proofbound.com` → `143.110.145.237` (droplet) - Proxied via Cloudflare
- `status.proofbound.com` → DO App Platform (this repo) - Proxied via Cloudflare

**Cloudflare Worker Routes:**
- Monitors: `proofbound.com/*` AND `app.proofbound.com/*`
- Special routing: `/textkeep/*`, `/privacy`, `/terms` → ALWAYS route to this static site
- Failover: Other paths → droplet (when up) OR static site (when down)

### Traffic Flow

**When Droplet is UP:**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts request
  ↓
If path is /textkeep/*, /privacy, or /terms → Proxy to status.proofbound.com (this repo)
If other path → Pass through to droplet (React app)
```

**When Droplet is DOWN:**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts request
  ↓
If path is /textkeep/*, /privacy, or /terms → Proxy to status.proofbound.com (this repo)
If other path → Droplet returns 5xx error → Redirect to status.proofbound.com (fallback page)
```

### Cloudflare Worker Configuration

```javascript
const FALLBACK = "https://status.proofbound.com/";
const TIMEOUT_MS = 5000;

async function handleRequest(request) {
  const url = new URL(request.url);

  // Normalize pathname (remove trailing slashes, lowercase)
  const pathname = url.pathname.toLowerCase().replace(/\/$/, '');

  // ALWAYS route these paths to static site (no health check)
  // - /textkeep: Product landing page (always available)
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
  try {
    const res = await fetchWithTimeout(request, TIMEOUT_MS);
    if (wantsHtml && res.status >= 500) {
      return Response.redirect(FALLBACK, 302); // Failover to this repo
    }
    return res;
  } catch (err) {
    if (wantsHtml) {
      return Response.redirect(FALLBACK, 302); // Failover to this repo
    }
    // ... error handling
  }
}
```

**Key Points:**
- Worker applies to BOTH `proofbound.com/*` and `app.proofbound.com/*`
- `/textkeep/*`, `/privacy`, `/terms` paths ALWAYS serve from this static site
- Handles both clean URLs (`/privacy`) and `.html` extensions (`/privacy.html`)
- Other paths failover to this static site when droplet is down

## URLs

### Production URLs
- **React App**: [https://proofbound.com](https://proofbound.com) (monorepo on droplet)
- **React App**: [https://app.proofbound.com](https://app.proofbound.com) (monorepo on droplet)
- **Static Site**: [https://status.proofbound.com](https://status.proofbound.com) (this repo)
- **TextKeep Page**: [https://proofbound.com/textkeep](https://proofbound.com/textkeep) (proxied from this repo)
- **TextKeep Direct**: [https://status.proofbound.com/textkeep](https://status.proofbound.com/textkeep) (direct to this repo)
- **Privacy Policy**: [https://proofbound.com/privacy](https://proofbound.com/privacy) (proxied from this repo)
- **Terms of Service**: [https://proofbound.com/terms](https://proofbound.com/terms) (proxied from this repo)

### Digital Ocean
- **Static Site**: [https://proofbound-main.ondigitalocean.app/](https://proofbound-main.ondigitalocean.app/) (this repo)
- **Droplet**: `143.110.145.237` (monorepo)

### Local Development
```bash
# Option 1: Open directly in browser
open index.html

# Option 2: Use local server for better testing
python3 -m http.server 8000
# Visit: http://localhost:8000

# Option 3: Use testing helper
./test-local.sh  # Opens all pages in browser
```

## Site Structure

### Marketing Pages (7 pages)
1. **index.html** (21 KB)
   - Landing page with hero section
   - Typing animation ("ideas" → "notes" → "expertise" → "knowledge")
   - Service value propositions
   - Dual CTAs: "Try for Free" + "Elite Service"
   - Amazon KDP publishing panel
   - "Perfect for" audience card

2. **how-it-works.html** (18 KB)
   - 4-step book creation process
   - Each step has expandable details
   - "Why This Works Better" benefits grid
   - CTAs to start or try demo

3. **service-tiers.html** (20 KB)
   - 3 pricing tiers with feature comparison
   - Proof of Concept: $49
   - Professional: $500-$2,000 (Most Popular)
   - Premium: $2,000-$5,000
   - Detailed feature lists, testimonials

4. **faq.html** (24 KB)
   - 12 Q&A items with interactive accordion
   - Vanilla JavaScript accordion (no frameworks)
   - Auto-closes other items when opening new one
   - Covers: timeline, ownership, materials, quality, revisions, etc.

5. **elite-service.html** (18 KB)
   - Premium service offering details
   - 6 key features (Project Manager, Editing, Research, Production, Design, Marketing)
   - 4-step "How to Get Elite Service" process
   - Purple gradient theme (distinctive from other pages)

6. **privacy.html** (8.8 KB)
   - Privacy policy with 11 sections
   - Streamlined styling for legal content
   - Contact: privacy@proofbound.com

7. **terms.html** (9.8 KB)
   - Terms of service with 17 sections
   - Legal requirements and policies
   - Contact: legal@proofbound.com

### Special Pages
- **textkeep/index.html**: TextKeep product landing page
- **textkeep/version.json**: TextKeep version metadata (v1.3.4)

### Shared Components
- **TextKeep Banner**: Featured at top of all marketing pages
- **Header**: Logo and navigation
- **Footer**: Links to all pages, copyright

## File Structure

```
proofbound-oof/
├── index.html               # Landing page / fallback page
├── how-it-works.html       # Process explanation
├── service-tiers.html      # Pricing tiers
├── faq.html                # FAQ with accordion
├── elite-service.html      # Premium offering
├── privacy.html            # Privacy policy
├── terms.html              # Terms of service
├── textkeep/               # TextKeep download page directory
│   ├── index.html          # TextKeep landing page
│   ├── faq.html            # FAQ index with 25 questions
│   ├── faq/                # Individual FAQ answer pages (25 files)
│   ├── version.json        # Version metadata (v1.3.6)
│   └── iMessageExport.md   # Research document (source for FAQ content)
├── downloads/              # Downloadable files (TextKeep app)
├── logo-562x675.png        # Proofbound logo
├── favicons/               # Favicon assets
├── docs/                   # Documentation
│   ├── ANALYTICS.md        # Analytics implementation guide
│   └── DEPLOYMENT.md       # Hybrid routing deployment guide
├── test-local.sh           # Testing helper script
├── README.md               # Technical documentation
├── CLAUDE.md               # This file - development context
├── DEPLOYMENT_PLAN.md      # Historical deployment planning (pre-hybrid routing)
├── GA4-CONFIGURATION-CHECKLIST.md  # GA4 cross-domain setup
├── .claude/                # Claude Code configuration
│   └── settings.local.json # Permissions and settings
└── .claudeignore           # Files to exclude from Claude context
```

## Analytics & Tracking

### Overview

All pages use **Google Analytics 4 (GA4)** for web analytics with cross-domain tracking enabled across `proofbound.com`, `app.proofbound.com`, and `shop.proofbound.com`.

**Property ID:** `G-08CE0H3LRL`

**Full Documentation:** See [docs/ANALYTICS.md](docs/ANALYTICS.md) for comprehensive analytics implementation guide.

### Key Features

1. **Cross-Domain Tracking**: User sessions persist when navigating between domains via linker parameter
2. **Event Tracking**: Custom events for downloads, CTA clicks, and engagement actions
3. **Cloudflare Worker Compatible**: Analytics work correctly with proxied /textkeep path
4. **Privacy Compliant**: Follows privacy policy disclosures

### Event Tracking Summary

**TextKeep Analytics:**
- **Banner Clicks** (`textkeep_click`): Tracks engagement with TextKeep banner on all pages
- **Download Conversions** (`download`): Tracks TextKeep app downloads from /textkeep page

**Proofbound Conversions:**
- **CTA Clicks** (`cta_click`): Tracks "Try for Free", "Elite Service", pricing tier clicks
- **Engagement** (`cta_click`): Tracks secondary actions like KDP guide views

### Implementation Details

**GA4 Code (in `<head>` of all HTML files):**
```javascript
gtag('config', 'G-08CE0H3LRL', {
  'linker': {
    'domains': ['proofbound.com', 'app.proofbound.com', 'shop.proofbound.com']
  }
});
```

**Event Tracking (inline onclick):**
```javascript
onclick="gtag('event', 'download', {
  'event_category': 'conversion',
  'event_label': 'textkeep_macos'
});"
```

### Cloudflare Worker & Analytics

The Cloudflare Worker proxies `/textkeep/*` from `status.proofbound.com` to `proofbound.com` without redirecting. This means:
- ✅ Analytics records hostname as `proofbound.com` (desired)
- ✅ Page path recorded as `/textkeep`
- ✅ No session breaks or cross-domain issues
- ✅ Download events fire normally

**Key Insight:** The worker **proxies** content (not redirects), so GA4 sees the user as staying on `proofbound.com`. This is the desired behavior for consistent analytics.

### Testing Analytics

**Local Testing:**
```bash
# Start local server
python3 -m http.server 8000

# Open browser console and verify
typeof gtag === 'function'  # Should return true
window.dataLayer  # Should show array of events
```

**Production Testing:**
1. Visit `https://proofbound.com/textkeep?debug_mode=true`
2. Open GA4 Admin → DebugView
3. Click download button and verify event fires in real-time
4. Check cross-domain tracking by clicking CTAs to app.proofbound.com

**See Also:**
- [docs/ANALYTICS.md](docs/ANALYTICS.md) - Complete analytics documentation
- [GA4-CONFIGURATION-CHECKLIST.md](GA4-CONFIGURATION-CHECKLIST.md) - Cross-domain setup checklist

---

## Design System

### Typography
- **Headings**: Crimson Text (serif, 400/600/700) - elegant, professional
- **Body**: Inter (sans-serif, 400/500/600/700) - clean, readable
- **Source**: Google Fonts CDN

### Color Palette
```css
:root {
  --primary: #007bff;           /* Blue primary */
  --primary-dark: #0056b3;      /* Hover states */
  --purple: #9333ea;            /* Elite service accent */
  --orange: #ff6b00;            /* CTA accents */
  --text-dark: #212529;         /* Headings */
  --text-secondary: #495057;    /* Body text */
  --text-muted: #6c757d;        /* Subtle text */
  --bg-light: #f8f9fa;          /* Light backgrounds */
  --white: #ffffff;             /* Cards, backgrounds */
}
```

### Visual Design
- **Backgrounds**: Linear gradients (light gray palette)
- **Glass-morphism Cards**: `rgba(255,255,255,0.7)` with `backdrop-filter: blur(20px)`
- **Responsive**: Mobile-first design, breakpoint at 768px
- **Animations**: Typing animation (3s interval), accordion expansion

### Interactive Elements
1. **Typing Animation** (index.html)
   - Cycles through 4 words every 3 seconds
   - Fixed-width container (10.5ch) prevents layout shifts
   - Text-align: center for balanced spacing

2. **FAQ Accordion** (faq.html)
   - Click to expand/collapse answers
   - Auto-closes other items (one open at a time)
   - Smooth height animation with `maxHeight` transition
   - Vanilla JavaScript (no dependencies)

## Content Strategy

### Key Messages
1. **Value Proposition**: Turn expertise into published books with AI
2. **Ease of Use**: 4-step process, no technical skills required
3. **Professional Quality**: Print-ready PDFs, Amazon KDP compatible
4. **Flexible Pricing**: $49 to $5,000+ options for all budgets
5. **TextKeep Cross-Promotion**: macOS text message backup app

### Call-to-Actions
- **Primary**: "Try for Free" → `https://app.proofbound.com/signup`
- **Secondary**: "Elite Service" → `elite-service.html`
- **Tertiary**: "Free Demo" → `https://app.proofbound.com/demo`

### SEO Considerations
- Descriptive page titles and meta descriptions
- Semantic HTML structure
- Alt text on images (logo)
- Internal linking between pages
- Footer links on all pages

## Development Workflow

### Making Changes
1. **Edit HTML files directly** (inline CSS, no build process)
2. **Test locally**: Open in browser or use `./test-local.sh`
3. **Verify**: Check typing animation, accordion, CTAs
4. **Commit and push** to `master` branch
5. **Auto-deploy**: Digital Ocean deploys within ~2 minutes

### Coding Conventions
- **Inline CSS**: All styles in `<style>` tags (no external CSS files)
- **Vanilla JS**: No frameworks or libraries
- **Consistent Variables**: Use CSS custom properties (`var(--primary)`)
- **Mobile-First**: Media queries for desktop enhancements
- **Semantic HTML**: Proper heading hierarchy, sections, landmarks

### Testing Checklist
```bash
# Use testing helper script
./test-local.sh

# Manual testing checklist:
# [ ] TextKeep banner on all pages
# [ ] Navigation links work (header/footer)
# [ ] Typing animation cycles smoothly
# [ ] FAQ accordion expands/collapses
# [ ] CTAs point to correct URLs
# [ ] Mobile responsive (resize to 375px)
# [ ] No console errors
# [ ] All images load
```

### Updating TextKeep Version

When a new TextKeep version is released, follow this checklist to update all references:

**1. Prepare Files**
- Place new version zip in `downloads/` with naming: `TextKeep-{VERSION}.zip` (e.g., `TextKeep-1.3.6.zip`)
  - **IMPORTANT**: Use format `TextKeep-1.3.6.zip` NOT `TextKeep-v1.3.6.zip`
- Add any new screenshots/assets to `favicons/assets/` if needed

**2. Update Version References**
Edit these files to update version numbers:

- `textkeep/version.json` - Update `version` field
- `textkeep/index.html` - Update in 3 places:
  - Line ~63: `"downloadUrl"` in schema.org metadata
  - Line ~64: `"softwareVersion"` in schema.org metadata
  - Line ~401: Download button href and text
- `CLAUDE.md` - Update version references (search for old version)
- `README.md` - Update version references (search for old version)
- `docs/DEPLOYMENT.md` - Update version references (search for old version)

**3. Git Workflow**
```bash
# Stage all changes
git add textkeep/version.json textkeep/index.html \
  downloads/TextKeep-{VERSION}.zip \
  CLAUDE.md README.md docs/DEPLOYMENT.md \
  favicons/assets/  # if new assets added

# Commit with clear message
git commit -m "Update TextKeep to v{VERSION}

- Update version in textkeep/version.json
- Update download links and version display in textkeep/index.html
- Update documentation references in CLAUDE.md, README.md, docs/DEPLOYMENT.md
- Add TextKeep-{VERSION}.zip release file

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push to GitHub
git push
```

**4. Verify Deployment**
```bash
# Wait ~2 minutes for Digital Ocean to deploy

# Check version.json
curl -s "https://status.proofbound.com/textkeep/version.json"

# Check HTML source
curl -s "https://status.proofbound.com/textkeep/" | grep -E "(Download for macOS|softwareVersion)"

# Test download link
curl -I "https://status.proofbound.com/downloads/TextKeep-{VERSION}.zip"
```

**5. Test Live Site**
- Visit https://status.proofbound.com/textkeep
- Verify version shown in download button
- Click download button to test file downloads
- Check screenshot displays correctly

**Files Modified (Typical Update):**
- `textkeep/version.json`
- `textkeep/index.html`
- `downloads/TextKeep-{VERSION}.zip` (new file)
- `CLAUDE.md` (documentation)
- `README.md` (documentation)
- `docs/DEPLOYMENT.md` (documentation)
- `favicons/assets/` (if new screenshots)

## Hosting & Deployment

### Current Setup
- **Platform**: Digital Ocean App Platform (Static Site)
- **Tier**: Basic Static Site (~$5/month or free tier)
- **Repository**: GitHub `Proofbound/proofbound-oof`
- **Auto-deploy**: Pushes to `master` trigger deployment (~2 minutes)
- **Hosted at**: `status.proofbound.com`

### DNS Configuration (Cloudflare)

**Production Configuration:**
```
A      proofbound.com           →  143.110.145.237 (droplet) - Proxied ✅
A      app.proofbound.com       →  143.110.145.237 (droplet) - Proxied ✅
CNAME  status.proofbound.com    →  proofbound-main.ondigitalocean.app - Proxied ✅
```

**Key Points:**
- `proofbound.com` and `app.proofbound.com` point to droplet (React app)
- `status.proofbound.com` points to this static site
- Cloudflare Worker handles routing for `/textkeep/*` and failover

### Deployment Process
See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for complete deployment procedures.

**Quick Deploy:**
1. Make changes to HTML/CSS files
2. Test locally with `./test-local.sh`
3. Commit and push to `master` branch
4. Digital Ocean auto-deploys in ~2 minutes
5. Verify at `https://status.proofbound.com`

## Relationship to Monorepo Services

### When Marketing Site Is Active (proofbound.com)
- Users see static marketing content
- High availability (Digital Ocean App Platform)
- No backend dependencies
- Fast page loads (<1 second)

### When Application Is Active (app.proofbound.com)
From `proofbound-monorepo`:
- **Frontend**: React app for book generation
- **ai-clients** (port 8000): AI text/image generation
- **cc-template-api** (port 8001): Quarto document generation
- **lulu-service** (port 8002): Print-on-demand integration
- **nginx**: Load balancer and reverse proxy

### When Application Is Down (5xx errors)
- Cloudflare Worker catches errors
- Redirects to `status.proofbound.com` (fallback page)
- Marketing site at `proofbound.com` remains accessible
- Users can still learn about Proofbound and contact team

## Monorepo Integration Points

### Nginx Configuration
The monorepo's `nginx-fallback.conf` includes `proofbound.com` in the server_name directive:

```nginx
server_name app.proofbound.com proofbound.com _;
```

This allows nginx to serve the React app for both:
- `app.proofbound.com` (subdomain)
- `proofbound.com` (root domain)

### React App Integration
- **TextKeepBanner Component**: Links to `https://proofbound.com/textkeep`
- **Marketing Links**: Can reference static marketing pages at `https://status.proofbound.com`
- **Authentication Flow**: Redirects to `https://proofbound.com` (React app) for signup/login

### Routing Summary
```
User visits proofbound.com              → React app (droplet)
User visits proofbound.com/textkeep     → Static site (via worker proxy)
User visits status.proofbound.com       → Static site (direct)
Droplet down + user visits proofbound.com → Static site (via worker failover)
```

## Contact & Support

### Email Contacts
- **General**: info@proofbound.com
- **Legal**: legal@proofbound.com
- **Privacy**: privacy@proofbound.com

### GitHub Repositories
- **Marketing Site**: `Proofbound/proofbound-fallback` or `Proofbound/proofbound-oof`
- **Main Application**: `Proofbound/proofbound-monorepo`
- **TextKeep**: `Proofbound/textkeep`

### Local Paths
- Marketing Site: `/Users/sprague/dev/proofbound/proofbound-oof/`
- Monorepo: `/Users/sprague/dev/proofbound/proofbound-monorepo/`

## Future Enhancements

Potential improvements to consider:
- [ ] Add blog section to marketing site
- [ ] Create case studies page
- [ ] Add testimonials/reviews section
- [ ] Implement A/B testing for CTAs
- [x] Add Google Analytics 4 tracking
- [x] Create sitemap.xml for SEO
- [x] Add schema.org markup
- [ ] Implement contact form (instead of mailto links)
- [ ] Add newsletter signup
- [ ] Create press/media page
- [ ] Enhanced analytics (heatmaps, session recording)
- [ ] Cookie consent banner for GDPR compliance

## Version History

See git commit history for changes. Notable updates:
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
- Initial release: Simple fallback page with glassmorphism design

---

**Last Updated**: February 1, 2026

For main application development, see [proofbound-monorepo/CLAUDE.md](../proofbound-monorepo/CLAUDE.md).
