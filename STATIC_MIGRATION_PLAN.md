# Implementation Plan: Migrate proofbound.com to Fully Static Site

**Status**: ✅ Phase 1.1 Complete - Ready to Execute Phase 1.2
**Last Updated**: Feb 4, 2026 at 12:00 PM PST
**Progress**: 20% (Phase 1.1 complete: schema.org pricing fixed)

---

## Recent Updates (Feb 3, 2026)

> **Repository**: All changes below are in `/Users/sprague/dev/proofbound/proofbound-oof` (static site repo)

**✅ Completed:**
- **index.html** - Synced with React app redesign (commit `2e8a20b`):
  - ❌ **Removed typing animation** (was: "ideas" → "notes" → "expertise" → "knowledge")
  - ✅ Simplified to static headline: "Turn Your Ideas Into a"
  - ✅ Added pulsing logo animation (replaces typing animation)
  - ✅ Updated service cards: "Free Demo" and "Elite Service — $500"
  - ✅ Added "Start for $49" pricing panel
  - ✅ Enhanced Amazon KDP panel
  - ✅ Added quick navigation links
  - ✅ **DONE (Feb 4, 2026)**: Updated schema.org pricing to reflect new structure (Basic $49, Book Pass $99, Elite $500)

- **service-tiers.html** - Complete rewrite to match React app (commit `60857d2`):
  - ✅ **New Generation Tiers**: Free ($0), Basic ($49 - MOST POPULAR), Book Pass ($99)
  - ✅ **New Add-ons**: Refresh (+$25), Elite ($500)
  - ✅ Added printing prices, unlocks, "Which Tier Is Right for You?" guide
  - ✅ "No Hidden Fees" transparency section

- **STATIC_MIGRATION_PLAN.md** - Comprehensive migration plan created (commit `1bc9f57`):
  - ✅ Documented all recent updates and current state
  - ✅ Added detailed implementation phases with safety improvements
  - ✅ Separated monorepo and static site operations
  - ✅ Added git pre-flight checks for monorepo modifications
  - ✅ Fixed health check circular dependency issue
  - ✅ Added canonical URL guidance and explicit GA4 tracking instructions
  - ✅ Improved rollback procedures with timestamped backups

**⚠️ Outstanding Tasks (In Priority Order):**
1. ✅ **Phase 1.1**: Fix schema.org pricing in index.html - COMPLETED Feb 4, 2026
2. ❌ **Phase 1.2**: Create 4 new HTML pages:
   - health-biotech.html
   - international-professionals.html
   - kdp-instructions.html
   - elite.html (duplicate of elite-service.html with canonical link)
3. ❌ **Phase 1.2**: Update sitemap.xml with 4 new page entries
4. ❌ **Phase 2**: Add dynamic CTA button functionality (analytics tracking script)
5. ❌ **Phase 3**: Update Cloudflare Worker routing (in monorepo)
6. ❌ **Phase 4**: Update Nginx configuration (in monorepo)
7. ❌ **Phase 5**: Comprehensive testing and deployment

**Next Steps:**
Phase 1.2 (create 4 new HTML pages) - health-biotech, international-professionals, kdp-instructions, elite duplicate.

---

## Overview

Transform proofbound.com from a React app to a fully static site, while keeping the React application exclusively at app.proofbound.com. This migration will improve performance, reduce server load, and provide clear separation between marketing (static) and application (React).

### ⚠️ Two Repositories Involved

This migration touches **two separate repositories**:

| Repository | Path | Work Involved |
|------------|------|---------------|
| **Static Site** | `/Users/sprague/dev/proofbound/proofbound-oof` | Phase 1: Create/edit HTML pages<br>Phase 2: Add dynamic CTA scripts<br>Phase 5: Testing |
| **Monorepo** | `/Users/sprague/dev/proofbound/proofbound-monorepo` | Phase 3: Update Cloudflare Worker<br>Phase 4: Update Nginx config |

**Always verify you're in the correct repository before running commands.**

```bash
# Check current directory
pwd

# Should show one of:
# /Users/sprague/dev/proofbound/proofbound-oof          (static site)
# /Users/sprague/dev/proofbound/proofbound-monorepo     (monorepo)
```

## Architecture Changes

### Current State
- **proofbound.com**: React app on droplet (with Worker proxying some marketing pages)
- **app.proofbound.com**: Same React app on droplet
- **status.proofbound.com**: Static site (fallback)

### Target State
- **proofbound.com**: Static site (ALL traffic routed via Worker)
- **app.proofbound.com**: React app only
- **status.proofbound.com**: Static site (unchanged, still fallback)

### Key Features
- Dynamic CTA button enabling/disabling based on droplet status
- All marketing pages migrated to static HTML
- Clean separation: marketing vs application

---

## Phase 1: Create Missing Static Pages

### Phase 1.1: Fix Existing Pages

**Update index.html schema.org pricing** (lines 62-83)

Current schema.org structured data has **outdated pricing**. Update to match new pricing structure:

```html
"offers": [
  {
    "@type": "Offer",
    "name": "Basic Book",
    "description": "AI-generated book with professional formatting, Amazon KDP-ready files, and one printed copy",
    "price": "49",
    "priceCurrency": "USD"
  },
  {
    "@type": "Offer",
    "name": "Book Pass",
    "description": "30 days unlimited iteration with clean PDF export",
    "price": "99",
    "priceCurrency": "USD"
  },
  {
    "@type": "Offer",
    "name": "Elite Service",
    "description": "Human editor, fact-checking, and three revision cycles for professional quality",
    "price": "500",
    "priceCurrency": "USD"
  }
]
```

**Also update meta descriptions** to reflect new pricing:
- Line 20: Change "From $49 to Elite Service" to "Start at $49. Elite Service from $500"
- Line 30: Same update for og:description

### Phase 1.2: Create New Pages

Create 3 new HTML pages by converting React components to static HTML.

### Files to Create

**1. health-biotech.html**
- Source content from: `/Users/sprague/dev/proofbound/proofbound-monorepo/apps/main-app/frontend/src/components/pages/HealthBiotech.tsx`
- Page title: "Professional Publishing for Health & Biotech Companies"
- Include sections: Hero, Applications (4 cards), Why Choose (4 features), Success Story, Investment, CTA
- Use existing design system (glass cards, gradients, inline CSS)
- **Add TextKeep banner** - Copy exact markup from [index.html](index.html:132-180) (lines 132-180: `.textkeep-banner` div)
- Include header/footer navigation (copy from index.html)
- **Add GA4 tracking code** - Copy from [index.html](index.html:4-15) (lines 4-15):
  ```html
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-08CE0H3LRL"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-08CE0H3LRL', {
      'linker': {
        'domains': ['proofbound.com', 'app.proofbound.com', 'shop.proofbound.com']
      }
    });
  </script>
  ```
- **Update pricing references**: React component has old pricing ($500, $1000-$2000, $3000-$5000). Use new pricing: Basic ($49), Book Pass ($99), Elite ($500)

**2. international-professionals.html**
- Source content from: `/Users/sprague/dev/proofbound/proofbound-monorepo/apps/main-app/frontend/src/components/pages/InternationalProfessionals.tsx`
- Page title: "English-Language Publishing for International Professionals"
- Include sections: Hero, Benefits (4 cards), Specialization (4 features), Target Markets (4 colored boxes), Quality Standards (3 columns), Pricing, CTA
- Same design system as above (glass cards, gradients, inline CSS)
- **Add TextKeep banner** - Copy from [index.html](index.html:132-180)
- **Add GA4 tracking code** - Copy from [index.html](index.html:4-15) (see above)
- Include header/footer navigation (copy from index.html)
- **Update pricing references**: React component mentions $2000-$5000 investment. Update to: Elite Service ($500) as primary offering for international professionals

**3. kdp-instructions.html**
- Source content from: `/Users/sprague/dev/proofbound/proofbound-monorepo/apps/main-app/frontend/src/pages/KDPInstructionsPage.tsx` + shared component
- Page title: "Publish Your Book on Amazon"
- Include: Introduction, What You'll Need, Step-by-step instructions (from KDPInstructions.tsx)
- Convert React Icons to inline SVG or Unicode symbols
- **Add TextKeep banner** - Copy from [index.html](index.html:132-180)
- **Add GA4 tracking code** - Copy from [index.html](index.html:4-15) (see above)
- Include header/footer navigation (copy from index.html)
- Add back link to FAQ page

**4. elite.html** (duplicate of elite-service.html)
- Simple copy of `elite-service.html` with filename `elite.html`
- This handles route mismatch (React uses `/elite`, static uses `/elite-service`)
- **Add canonical link** to avoid duplicate content SEO penalty:
  ```html
  <link rel="canonical" href="https://proofbound.com/elite-service">
  ```
- This tells search engines that `/elite` and `/elite-service` are the same page, with `/elite-service` as the preferred URL

### Design System Reference

Use the design patterns from [index.html](index.html:1-800):
- **Typography**: Crimson Text for headings, Inter for body
- **Colors**: `--primary: #007bff`, `--purple: #9333ea`, `--orange: #ff6b00`, `--green: #10b981`
- **Cards**: `rgba(255,255,255,0.7)` with `backdrop-filter: blur(20px)`
- **Gradients**: Linear gradients from `#f8f9fa` to `#e9ecef`
- **Responsive**: Mobile-first with `@media (min-width: 768px)`
- **Animations**: Pulsing logo (CSS `animation: pulse 2s infinite`), NO typing animation
- **Hero**: Static headline "Turn Your Ideas Into a" + large centered logo

**Current Pricing Structure:**
- **Free**: $0 (demo with sample content)
- **Basic**: $49 (MOST POPULAR - includes printed book, up to 200 pages)
- **Book Pass**: $99 (30 days unlimited iteration + clean PDF)
- **Add-ons**: Refresh (+$25), Elite ($500)
- **Unlocks**: Clean PDF (+$99), Source files (+$449)
- **Printing**: First copy $29.95, additional $19.95 each

### Update Sitemap and Robots

**File**: [sitemap.xml](sitemap.xml:1-100)

**Step 1: Verify existing entries**
- Confirm `https://proofbound.com/elite-service` exists
- Confirm all current marketing pages are present (index, how-it-works, service-tiers, faq, privacy, terms)
- Check TextKeep pages (should have /textkeep/ entries)

**Step 2: Add 4 new entries**
```xml
<url>
  <loc>https://proofbound.com/health-biotech</loc>
  <lastmod>2026-02-02</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.8</priority>
</url>
<url>
  <loc>https://proofbound.com/international-professionals</loc>
  <lastmod>2026-02-02</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.8</priority>
</url>
<url>
  <loc>https://proofbound.com/kdp-instructions</loc>
  <lastmod>2026-02-02</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.8</priority>
</url>
<url>
  <loc>https://proofbound.com/elite</loc>
  <lastmod>2026-02-02</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.8</priority>
  <note>Duplicate of elite-service, but needed for route compatibility. Uses canonical link.</note>
</url>
```

**Step 3: Verify robots.txt**
- Ensure no conflicting directives
- Confirm LLM bot allowances still present (GPTBot, ClaudeBot, etc.)

---

## Phase 2: Add Dynamic CTA Button Functionality

Add JavaScript to enable/disable "Try for Free" buttons based on droplet status.

### ⚠️ Critical Issue: Health Check Circular Dependency

**Problem**: When the droplet is down, `https://app.proofbound.com/api/health` won't be reachable either. The Cloudflare Worker proxies app.proofbound.com to the droplet, so if the droplet is down, the health check will fail regardless.

**Solution**: Use the Cloudflare Worker's health check from the static site's perspective. The static site should check a **known-good static endpoint** on status.proofbound.com that returns the droplet's status.

### Recommended Approach: Worker-Based Status Endpoint

**Option 1: Add `/status.json` to static site**

Create a lightweight status endpoint that the Cloudflare Worker updates:

**File**: Create `status.json` in static site root:
```json
{
  "app_available": true,
  "last_check": "2026-02-03T20:30:00Z"
}
```

Update Cloudflare Worker to set this file's contents based on droplet health checks.

**Option 2: Client-side fallback check (Simpler)**

Skip the health check entirely and rely on the Cloudflare Worker's failover behavior:
- CTAs always link to `app.proofbound.com`
- If droplet is down, Worker redirects to static site with a message
- No JavaScript needed on static site

**Option 3: Graceful degradation (Recommended)**

Don't disable buttons - let them work and rely on Worker failover:

```html
<script>
(function() {
  // No health check needed - Worker handles failover
  // CTAs always work, Worker redirects to error page if app down
  // This script just adds analytics tracking

  // Guard against multiple executions (prevents duplicate listeners)
  if (window.ctaTrackingInitialized) return;
  window.ctaTrackingInitialized = true;

  document.querySelectorAll('a[href*="app.proofbound.com"]').forEach(button => {
    button.addEventListener('click', () => {
      // Track CTA clicks in GA4
      if (typeof gtag !== 'undefined') {
        gtag('event', 'cta_click', {
          'event_category': 'conversion',
          'event_label': button.href
        });
      }
    });
  });
})();
</script>
```

**Decision**: Use **Option 3** (no health check, rely on Worker failover) unless you implement a server-side status endpoint.

**Note**: Script wrapped in IIFE with guard flag to prevent duplicate event listeners if script runs multiple times.

---

## Phase 3: Update Cloudflare Worker

⚠️ **Repository**: `/Users/sprague/dev/proofbound/proofbound-monorepo` (different from static site repo)

### Pre-flight Checks

**Before making any changes to monorepo**, verify:

```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo

# Check current branch
git branch --show-current
# Should be: master (or main, confirm this is correct)

# Check for uncommitted changes
git status
# Should show: "working tree clean" or list files you're okay modifying

# Check recent commits to avoid wrong branch
git log --oneline -5
# Verify you're on the right branch with expected recent commits

# Pull latest changes
git pull origin master
```

**If any of these checks fail, STOP and resolve before proceeding.**

### File to Modify

**File**: `cloudflare-worker.js` (in monorepo root)

### Changes Required

**1. Expand marketing page routing (lines 40-99)**

Replace the current `isMarketingSite` and `isMarketingPagePath` logic with:

```javascript
// Check if this is proofbound.com (not app subdomain)
const isProofboundDotCom = hostname === 'proofbound.com' || hostname === 'www.proofbound.com';

// ALL marketing paths on proofbound.com route to static site
const isMarketingPath = pathname === '' ||
                        pathname === '/' ||
                        pathname === '/index' ||
                        pathname === '/index.html' ||
                        pathname.startsWith('/textkeep') ||
                        pathname === '/how-it-works' ||
                        pathname === '/how-it-works.html' ||
                        pathname === '/service-tiers' ||
                        pathname === '/service-tiers.html' ||
                        pathname === '/faq' ||
                        pathname === '/faq.html' ||
                        pathname === '/elite' ||
                        pathname === '/elite.html' ||
                        pathname === '/elite-service' ||
                        pathname === '/elite-service.html' ||
                        pathname === '/health-biotech' ||
                        pathname === '/health-biotech.html' ||
                        pathname === '/international-professionals' ||
                        pathname === '/international-professionals.html' ||
                        pathname === '/kdp-instructions' ||
                        pathname === '/kdp-instructions.html' ||
                        pathname === '/privacy' ||
                        pathname === '/privacy.html' ||
                        pathname === '/terms' ||
                        pathname === '/terms.html' ||
                        pathname === '/sitemap.xml' ||
                        pathname === '/robots.txt' ||
                        pathname === '/llms.txt';

// Route to static site if on proofbound.com AND it's a marketing path OR static asset
if (isProofboundDotCom && (isMarketingPath || isStaticAsset)) {
```

**2. Update clean URL mapping (lines 76-90)**

Add mappings for new pages:

```javascript
// Convert clean URLs to .html extension for static site
let staticPath = url.pathname;
if (pathname === '/privacy') {
  staticPath = '/privacy.html';
} else if (pathname === '/terms') {
  staticPath = '/terms.html';
} else if (pathname === '/faq') {
  staticPath = '/faq.html';
} else if (pathname === '/how-it-works') {
  staticPath = '/how-it-works.html';
} else if (pathname === '/service-tiers') {
  staticPath = '/service-tiers.html';
} else if (pathname === '/elite' || pathname === '/elite-service') {
  staticPath = '/elite-service.html';
} else if (pathname === '/health-biotech') {
  staticPath = '/health-biotech.html';
} else if (pathname === '/international-professionals') {
  staticPath = '/international-professionals.html';
} else if (pathname === '/kdp-instructions') {
  staticPath = '/kdp-instructions.html';
} else if (pathname === '' || pathname === '/') {
  staticPath = '/index.html';
}
```

**3. Backup the worker code first**

Before making changes:
```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo

# Create timestamped backup
cp cloudflare-worker.js cloudflare-worker-backup-$(date +%Y%m%d-%H%M%S).js

# OR create a git branch for easy rollback
git checkout -b cloudflare-worker-static-migration
# This allows easy rollback: git checkout master && git branch -D cloudflare-worker-static-migration
```

**Store the backup commit hash for safe rollback:**
```bash
# After making changes and committing
git rev-parse HEAD > .cloudflare-worker-migration-commit.txt
# This file stores the exact commit to revert to if needed
```

---

## Phase 4: Update Nginx Configuration

⚠️ **Repository**: `/Users/sprague/dev/proofbound/proofbound-monorepo` (same as Phase 3)

### Pre-flight Checks

```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo

# Verify still on correct branch (if using branch from Phase 3)
git branch --show-current

# Check working tree status
git status

# Backup current config before editing
cp nginx-fallback.conf nginx-fallback.conf.backup-$(date +%Y%m%d-%H%M%S)
```

### File to Modify

**File**: `nginx-fallback.conf` (in monorepo root)

### Change Required

**Line 72**: Change from:
```nginx
server_name app.proofbound.com proofbound.com _;
```

To:
```nginx
server_name app.proofbound.com _;
```

This ensures nginx only serves the React app for app.proofbound.com, not proofbound.com.

---

## Phase 5: Testing & Verification

### Local Testing (Static Site)

```bash
cd /Users/sprague/dev/proofbound/proofbound-oof
python3 -m http.server 8000

# Test new pages in browser:
# http://localhost:8000/health-biotech.html
# http://localhost:8000/international-professionals.html
# http://localhost:8000/kdp-instructions.html
# http://localhost:8000/elite.html

# Verify:
# - All links work
# - TextKeep banner present
# - Header/footer navigation
# - GA4 tracking code present
# - Mobile responsive
# - No console errors
```

### Deployment Testing

**1. Deploy Static Site**
```bash
cd /Users/sprague/dev/proofbound/proofbound-oof
git add health-biotech.html international-professionals.html kdp-instructions.html elite.html sitemap.xml
git commit -m "Add missing marketing pages for full static migration"
git push
# Wait ~2 minutes for Digital Ocean deployment
```

**2. Verify Static Site**
```bash
# Check new pages are live
curl -I https://status.proofbound.com/health-biotech.html
curl -I https://status.proofbound.com/international-professionals.html
curl -I https://status.proofbound.com/kdp-instructions.html
curl -I https://status.proofbound.com/elite.html
# All should return 200 OK
```

**3. Deploy Cloudflare Worker**
- Log into Cloudflare Dashboard
- Navigate to Workers & Pages → cloudflare-worker
- Click "Quick Edit"
- Paste updated worker code
- Click "Save and Deploy"

**4. Test Routing**
```bash
# Test proofbound.com routes to static site
curl -I https://proofbound.com/
curl -I https://proofbound.com/health-biotech
curl -I https://proofbound.com/kdp-instructions
# Should proxy to static site (200 OK)

# Test app.proofbound.com routes to React app
curl -I https://app.proofbound.com/
curl -I https://app.proofbound.com/login
# Should serve React app
```

**5. Deploy Nginx Changes**
```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo
git add nginx-fallback.conf
git commit -m "Remove proofbound.com from nginx (now static-only)"
git push

# SSH to droplet and restart nginx
ssh root@143.110.145.237
docker-compose restart nginx
# Or: systemctl reload nginx (depending on setup)
```

**6. Browser Testing**

Test the following user flows:

**Marketing Site (proofbound.com):**
- [ ] Visit https://proofbound.com → Loads static index.html
- [ ] Click "Try for Free" → Goes to app.proofbound.com/signup
- [ ] Click "How It Works" → Loads static how-it-works.html
- [ ] Click "Service Tiers" → Loads static service-tiers.html
- [ ] Click "FAQ" → Loads static faq.html
- [ ] Click "Elite Service" → Loads static elite-service.html
- [ ] Visit https://proofbound.com/elite → Loads elite.html
- [ ] Visit https://proofbound.com/health-biotech → Loads health-biotech.html
- [ ] Visit https://proofbound.com/international-professionals → Loads international-professionals.html
- [ ] Visit https://proofbound.com/kdp-instructions → Loads kdp-instructions.html
- [ ] Pulsing logo animation works (2s pulse cycle)
- [ ] Static headline displays: "Turn Your Ideas Into a"
- [ ] TextKeep banner links to /textkeep
- [ ] Mobile responsive (resize to 375px)

**Application (app.proofbound.com):**
- [ ] Visit https://app.proofbound.com → Loads React app
- [ ] Click "Sign Up" → Loads signup form
- [ ] Test login flow
- [ ] Access dashboard (if logged in)

**Dynamic CTA Buttons:**
- [ ] "Try for Free" buttons are enabled when app is up
- [ ] Clicking "Try for Free" navigates to app.proofbound.com/signup
- [ ] If app is down, buttons are disabled with opacity 0.5
- [ ] Clicking disabled buttons shows alert message

**Analytics:**
- [ ] Visit https://proofbound.com?debug_mode=true
- [ ] Open GA4 Admin → DebugView
- [ ] Click "Try for Free"
- [ ] Verify cross-domain tracking (_gl parameter in URL)
- [ ] Verify session continues on app.proofbound.com

---

## Critical Files

### Static Site (proofbound-oof)
1. **health-biotech.html** - New page (create)
2. **international-professionals.html** - New page (create)
3. **kdp-instructions.html** - New page (create)
4. **elite.html** - New page (duplicate of elite-service.html)
5. [sitemap.xml](sitemap.xml:1-100) - Update with new pages
6. [index.html](index.html:1-600) - Add dynamic CTA button script
7. All other HTML pages - Add dynamic CTA button script

### Monorepo (proofbound-monorepo)
1. [cloudflare-worker.js](/Users/sprague/dev/proofbound/proofbound-monorepo/cloudflare-worker.js:1-189) - Update routing logic
2. [nginx-fallback.conf](/Users/sprague/dev/proofbound/proofbound-monorepo/nginx-fallback.conf:72) - Remove proofbound.com from server_name

---

## Rollback Plan

If issues occur after deployment:

### Immediate Rollback (Cloudflare Worker)

1. Log into Cloudflare Dashboard
2. Navigate to Workers & Pages → cloudflare-worker → Deployments
3. Find previous deployment
4. Click "Rollback to this deployment"
5. Verify https://proofbound.com loads React app again

**Estimated rollback time**: < 2 minutes

### Alternative: Manual Worker Restore

1. Find your timestamped backup file:
   ```bash
   ls -la /Users/sprague/dev/proofbound/proofbound-monorepo/cloudflare-worker-backup-*
   ```
2. Copy contents of backup file
3. Paste into Cloudflare Worker editor
4. Save and deploy

### Nginx Rollback

**Option 1: Restore from backup file (Safest)**
```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo

# Find your backup
ls -la nginx-fallback.conf.backup-*

# Restore from backup
cp nginx-fallback.conf.backup-YYYYMMDD-HHMMSS nginx-fallback.conf

# Or if using git branch
git checkout master
git checkout master -- nginx-fallback.conf
```

**Option 2: Revert specific commit (If you know the commit hash)**
```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo

# Find the commit you want to revert
git log --oneline nginx-fallback.conf | head -5

# Revert to specific commit (safer than HEAD~1)
git checkout <commit-hash> -- nginx-fallback.conf
git commit -m "Revert nginx changes - rollback static migration"
```

**⚠️ DO NOT use `git checkout HEAD~1` - this assumes no other commits exist between your change and HEAD, which may not be true.**

**After restoring config:**
```bash
# SSH to droplet
ssh root@143.110.145.237

# Navigate to monorepo (verify path first!)
cd /opt/proofbound-monorepo  # or wherever it's deployed

# Pull changes
git pull origin master

# Restart nginx
docker-compose restart nginx

# Verify nginx is running
docker-compose ps nginx
```

---

## Benefits of This Migration

### Performance
- ✅ Static site loads faster (no React bundle, no JS hydration)
- ✅ Reduced droplet CPU/memory usage
- ✅ Better caching (static assets cached for 24 hours)

### Reliability
- ✅ Marketing site stays up even if droplet goes down
- ✅ Clear separation: marketing (static) vs app (React)
- ✅ Reduced attack surface (no backend for marketing pages)

### SEO
- ✅ Faster page loads improve SEO rankings
- ✅ No JavaScript required for content (better crawlability)
- ✅ Static HTML easier for search engines to index

### Maintainability
- ✅ Easier to update marketing content (just edit HTML)
- ✅ No build process for marketing pages
- ✅ Clear domain separation (proofbound.com vs app.proofbound.com)

---

## Timeline Estimate

- **Phase 1** (Create pages): 3-4 hours
- **Phase 2** (Dynamic CTAs): 1 hour
- **Phase 3** (Cloudflare Worker): 1 hour
- **Phase 4** (Nginx): 30 minutes
- **Phase 5** (Testing): 2-3 hours

**Total**: ~1 day of focused work

---

## Post-Migration Tasks

### Update Documentation

**Files to update in proofbound-oof:**
1. [CLAUDE.md](CLAUDE.md:1-100) - Update architecture description
2. [README.md](README.md:1-100) - Update routing information
3. [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md:1-100) - Update deployment procedures

**Changes needed:**
- Remove "hybrid routing" references
- Update to "proofbound.com is fully static"
- Update traffic flow diagrams
- Update DNS configuration notes

### Monitor Analytics

After migration, monitor GA4 for:
- Page load times (should improve)
- Bounce rates (should stay same or improve)
- Conversion rates (CTA clicks)
- Cross-domain tracking (should continue working)

### Optional Future Enhancement

**DNS Simplification** (can be done later):
- Change DNS: `proofbound.com` → `CNAME` to `proofbound-main.ondigitalocean.app`
- This removes Worker dependency for basic routing
- Worker still handles failover for app.proofbound.com

---

## Summary

This migration transforms proofbound.com into a fully static site while keeping the React app at app.proofbound.com.

### Progress Overview

**✅ Completed (Feb 3, 2026):**
- ✅ index.html updated and synced with React app (removed typing animation, added pulsing logo)
- ✅ service-tiers.html completely rewritten with new pricing structure
- ✅ Design system established (glass cards, gradients, pulsing animations)
- ✅ TextKeep banner on all pages
- ✅ GA4 cross-domain tracking configured
- ✅ Static site infrastructure ready (Digital Ocean App Platform)
- ✅ **Migration plan created** with comprehensive phases and safety improvements (commit `1bc9f57`)

**📋 Ready to Start (Phase 1.1):**
- ❌ Fix schema.org pricing in [index.html](index.html:62-83) - Quick SEO fix

**⚠️ Not Started (Phases 1.2-5):**
1. ❌ Create 3 new HTML pages (health-biotech, international-professionals, kdp-instructions)
2. ❌ Create elite.html duplicate with canonical link
3. ❌ Update sitemap.xml with 4 new entries
4. ❌ Add dynamic CTA analytics tracking script
5. ❌ Update Cloudflare Worker routing (monorepo)
6. ❌ Update Nginx configuration (monorepo)
7. ❌ Comprehensive testing and deployment

**Current Blocker:** None - ready to proceed with Phase 1.1

### Current Pricing Structure (Updated Feb 3, 2026)

**Generation Tiers:**
- Free: $0 (unlimited demo books with sample content)
- Basic: $49 (MOST POPULAR - includes printed book, up to 200 pages)
- Book Pass: $99 (30 days unlimited iteration + clean PDF)

**Add-ons:**
- Refresh: +$25 (one full regeneration with new outline)
- Elite: $500 (human editor, fact-checking, 3 revision cycles)

**Additional:**
- Printing: First copy $29.95, additional $19.95 each
- Clean PDF unlock: +$99 (if not on Book Pass/Elite)
- Source files unlock: +$449

### Expected Benefits

**Performance:**
- ✅ Static site loads faster (no React bundle, no JS hydration)
- ✅ Reduced droplet CPU/memory usage
- ✅ Better caching (static assets cached for 24 hours)
  - **Caching configured in**: Cloudflare Worker (lines 95-97, 105-107, 129-131)
  - Static assets: `cacheTtl: 86400` (24 hours), `cacheEverything: true`
  - HTML pages: No explicit cache (uses default Cloudflare caching)
  - Controlled by Digital Ocean App Platform + Cloudflare Worker, not in static site repo

**Reliability:**
- ✅ Marketing site stays up even if droplet goes down
- ✅ Clear separation: marketing (static) vs app (React)
- ✅ Reduced attack surface (no backend for marketing pages)

**SEO:**
- ✅ Faster page loads improve SEO rankings
- ✅ No JavaScript required for content (better crawlability)
- ✅ Static HTML easier for search engines to index

**Maintainability:**
- ✅ Easier to update marketing content (just edit HTML)
- ✅ No build process for marketing pages
- ✅ Clear domain separation (proofbound.com vs app.proofbound.com)

The result is a faster, more reliable marketing site with clear separation from the application, better SEO, and reduced server load.
