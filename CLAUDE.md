# Proofbound Marketing Site

**Static marketing website for proofbound.com featuring comprehensive information about Proofbound's AI-powered book generation services.**

## Purpose

This repository contains the **primary marketing site** for proofbound.com. It serves as:
- Main entry point for new visitors to discover Proofbound
- Marketing content hub (How It Works, Pricing, FAQ, Elite Service)
- TextKeep cross-promotion platform (banner on all pages)
- High-availability static site (no downtime)

**Architecture**: Static HTML pages with inline CSS and vanilla JavaScript. No build process, frameworks, or dependencies.

## Integration with Proofbound Ecosystem

This repository is **tightly integrated** with the [proofbound-monorepo](https://github.com/Proofbound/proofbound-monorepo):

### Repository Relationships
- **Marketing Site** (`proofbound-oof`): Static marketing pages at proofbound.com
- **Application** (`proofbound-monorepo`): React app at app.proofbound.com
- **Fallback** (`status.proofbound.com`): Error page when app is down

### Traffic Flow
```
User visits proofbound.com
  ↓
DNS → Digital Ocean App Platform (this repo)
  ↓
User sees marketing site
  ↓
User clicks "Try for Free"
  ↓
Redirects to app.proofbound.com/signup
  ↓
React app handles signup/book generation
```

### Cloudflare Worker Configuration
The worker monitors `app.proofbound.com` (NOT proofbound.com) and redirects to fallback on errors:

```javascript
const FALLBACK = "https://status.proofbound.com/";
const TIMEOUT_MS = 5000;

// Worker intercepts app.proofbound.com requests:
// - Passes through to main origin
// - Redirects HTML requests to fallback on 5xx/timeout
// - Returns JSON error for API routes
// - Does NOT apply to proofbound.com (static site)
```

**Important**: The static marketing site (proofbound.com) is NOT behind the Cloudflare Worker. It's always available via Digital Ocean's infrastructure.

## URLs

### Production (After Deployment)
- **Marketing Site**: [https://proofbound.com](https://proofbound.com) (this repo)
- **Application**: [https://app.proofbound.com](https://app.proofbound.com) (monorepo)
- **Fallback**: [https://status.proofbound.com](https://status.proofbound.com) (shown when app is down)

### Current URLs
- **Fallback Page**: [https://status.proofbound.com/](https://status.proofbound.com/)
- **Digital Ocean**: [https://proofbound-main.ondigitalocean.app/](https://proofbound-main.ondigitalocean.app/)

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
- **textkeep.html**: TextKeep product landing page (existing)

### Shared Components
- **TextKeep Banner**: Featured at top of all marketing pages
- **Header**: Logo and navigation
- **Footer**: Links to all pages, copyright

## File Structure

```
proofbound-oof/
├── index.html               # Landing page
├── how-it-works.html       # Process explanation
├── service-tiers.html      # Pricing tiers
├── faq.html                # FAQ with accordion
├── elite-service.html      # Premium offering
├── privacy.html            # Privacy policy
├── terms.html              # Terms of service
├── textkeep.html           # TextKeep product page
├── logo-562x675.png        # Proofbound logo
├── favicons/               # Favicon assets
├── test-local.sh           # Testing helper script
├── README.md               # Technical documentation
├── CLAUDE.md               # This file - development context
├── DEPLOYMENT.md           # Deployment checklist & procedures
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

### Current Setup (Pre-Production)
- **Platform**: Digital Ocean App Platform (Static Site)
- **Tier**: Basic Static Site (~$5/month or free tier)
- **Repository**: GitHub `Proofbound/proofbound-fallback` or `Proofbound/proofbound-oof`
- **Auto-deploy**: Pushes to `master` trigger deployment

### DNS Configuration (Cloudflare)

**Current:**
```
A      proofbound.com           →  143.110.145.237 (Digital Ocean droplet)
A      app.proofbound.com       →  143.110.145.237 (Digital Ocean droplet)
CNAME  status.proofbound.com    →  proofbound-main.ondigitalocean.app
```

**Target (After Deployment):**
```
CNAME  proofbound.com           →  [new-static-app].ondigitalocean.app
A      app.proofbound.com       →  143.110.145.237 (unchanged)
CNAME  status.proofbound.com    →  proofbound-main.ondigitalocean.app (unchanged)
```

### Deployment Process
See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment checklist and procedures.

**Summary:**
1. Set up new Digital Ocean App Platform static site
2. Connect to GitHub repo, configure auto-deploy
3. Add custom domain: proofbound.com
4. Update DNS in Cloudflare (CNAME change)
5. Update nginx.conf in monorepo (remove redirect)
6. Update React app routes (remove marketing pages)
7. Monitor and validate

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

### Changes Required in Monorepo
See deployment plan for details. Summary:

1. **nginx.conf**
   - Remove `proofbound.com` → `app.proofbound.com` redirect
   - Keep `app.proofbound.com` configuration

2. **React App (App.tsx)**
   - Remove marketing page routes (/, /how-it-works, /faq, etc.)
   - Update root route to redirect unauthenticated users to proofbound.com
   - Keep authenticated users on /dashboard

3. **Navigation Components**
   - Update links to marketing pages (use absolute URLs)
   - Example: `<a href="https://proofbound.com/how-it-works.html">`

4. **Cloudflare Worker**
   - Verify routes only apply to `app.proofbound.com/*`
   - Ensure `proofbound.com/*` is NOT monitored by worker

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
- **Jan 28, 2026**: Converted to full marketing site (7 pages)
  - Added: how-it-works, service-tiers, faq, elite-service, privacy, terms
  - Expanded index.html with typing animation, CTAs, Amazon KDP panel
  - Created DEPLOYMENT.md with comprehensive deployment plan
  - Updated README and CLAUDE.md to reflect new purpose
- **Jan 26, 2026**: Added TextKeep banner and landing page
- **Jan 23, 2026**: Updated to light theme with Crimson Text font
- Initial release: Simple fallback page with glassmorphism design

---

**Last Updated**: January 28, 2026

For main application development, see [proofbound-monorepo/CLAUDE.md](../proofbound-monorepo/CLAUDE.md).
