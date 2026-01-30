# Proofbound Marketing Site

**Static marketing website for proofbound.com featuring comprehensive information about Proofbound's AI-powered book generation services.**

## Purpose

This repository contains the **static fallback and special content** for Proofbound infrastructure:
- **Fallback page**: Shown when droplet is down (status.proofbound.com)
- **TextKeep download page**: Always-available download page at `/textkeep/`
- **TextKeep version metadata**: Version info at `/textkeep/version.json`
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
- Special routing: `/textkeep/*` → ALWAYS routes to this static site
- Failover: Other paths → droplet (when up) OR static site (when down)

### Traffic Flow

**When Droplet is UP:**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts request
  ↓
If path is /textkeep/* → Proxy to status.proofbound.com (this repo)
If other path → Pass through to droplet (React app)
```

**When Droplet is DOWN:**
```
User visits proofbound.com
  ↓
Cloudflare Worker intercepts request
  ↓
Droplet returns 5xx error
  ↓
Worker redirects to status.proofbound.com (fallback page from this repo)
```

### Cloudflare Worker Configuration

```javascript
const FALLBACK = "https://status.proofbound.com/";
const TIMEOUT_MS = 5000;

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
- `/textkeep/*` paths ALWAYS serve from this static site
- Other paths failover to this static site when droplet is down

## URLs

### Production URLs
- **React App**: [https://proofbound.com](https://proofbound.com) (monorepo on droplet)
- **React App**: [https://app.proofbound.com](https://app.proofbound.com) (monorepo on droplet)
- **Static Site**: [https://status.proofbound.com](https://status.proofbound.com) (this repo)
- **TextKeep Page**: [https://proofbound.com/textkeep](https://proofbound.com/textkeep) (proxied from this repo)
- **TextKeep Direct**: [https://status.proofbound.com/textkeep](https://status.proofbound.com/textkeep) (direct to this repo)

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
│   └── version.json        # Version metadata (v1.3.4)
├── downloads/              # Downloadable files (TextKeep app)
├── logo-562x675.png        # Proofbound logo
├── favicons/               # Favicon assets
├── test-local.sh           # Testing helper script
├── README.md               # Technical documentation
├── CLAUDE.md               # This file - development context
├── DEPLOYMENT.md           # Hybrid routing deployment guide
├── .claude/                # Claude Code configuration
│   └── settings.local.json # Permissions and settings
└── .claudeignore           # Files to exclude from Claude context
```

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
See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment procedures.

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
- [ ] Add Google Analytics 4 tracking
- [ ] Create sitemap.xml for SEO
- [ ] Add schema.org markup
- [ ] Implement contact form (instead of mailto links)
- [ ] Add newsletter signup
- [ ] Create press/media page

## Version History

See git commit history for changes. Notable updates:
- **Jan 29, 2026**: Implemented hybrid routing architecture
  - Reorganized TextKeep from `textkeep.html` to `textkeep/` directory
  - Added `textkeep/version.json` with version metadata (v1.3.4)
  - Updated DNS: `proofbound.com` → A record to droplet (was CNAME to static site)
  - Configured Cloudflare Worker for `/textkeep/*` routing and failover
  - Updated nginx-fallback.conf to handle `proofbound.com` requests
  - Rewrote DEPLOYMENT.md to document hybrid routing setup
  - Updated all marketing pages to link to `/textkeep` (clean URLs)
- **Jan 28, 2026**: Converted to full marketing site (7 pages)
  - Added: how-it-works, service-tiers, faq, elite-service, privacy, terms
  - Expanded index.html with typing animation, CTAs, Amazon KDP panel
  - Created DEPLOYMENT.md with comprehensive deployment plan
  - Updated README and CLAUDE.md to reflect new purpose
- **Jan 26, 2026**: Added TextKeep banner and landing page
- **Jan 23, 2026**: Updated to light theme with Crimson Text font
- Initial release: Simple fallback page with glassmorphism design

---

**Last Updated**: January 29, 2026

For main application development, see [proofbound-monorepo/CLAUDE.md](../proofbound-monorepo/CLAUDE.md).
