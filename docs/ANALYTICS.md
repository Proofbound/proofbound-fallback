# Proofbound Analytics Documentation

**Last Updated:** February 1, 2026
**Status:** Active
**Maintainer:** Proofbound Team

---

## Table of Contents

1. [Overview](#overview)
2. [Google Analytics 4 Setup](#google-analytics-4-setup)
3. [Cross-Domain Tracking](#cross-domain-tracking)
4. [Event Tracking](#event-tracking)
5. [Cloudflare Worker Analytics Considerations](#cloudflare-worker-analytics-considerations)
6. [TextKeep Analytics](#textkeep-analytics)
7. [Testing & Verification](#testing--verification)
8. [Privacy & Compliance](#privacy--compliance)
9. [Future Recommendations](#future-recommendations)

---

## Overview

Proofbound uses **Google Analytics 4 (GA4)** for web analytics across all properties. The analytics infrastructure tracks user behavior, conversions, and engagement across multiple domains with proper cross-domain tracking.

### Key Properties

| Property | URL | Type | Analytics Status |
|----------|-----|------|------------------|
| **Marketing Site** | proofbound.com | Static (this repo) | ✅ Active |
| **Marketing Site (Direct)** | status.proofbound.com | Static (this repo) | ✅ Active |
| **TextKeep Landing** | proofbound.com/textkeep | Static (this repo, proxied) | ✅ Active |
| **Main Application** | app.proofbound.com | React (monorepo) | ✅ Active |
| **Shop** | shop.proofbound.com | Static (monorepo) | ✅ Active |

### Analytics Stack

- **Platform:** Google Analytics 4 (GA4)
- **Property ID:** `G-08CE0H3LRL`
- **Implementation:** gtag.js (Global Site Tag)
- **Cross-Domain:** Enabled via linker parameter
- **Routing Layer:** Cloudflare Worker (handles /textkeep proxying)

---

## Google Analytics 4 Setup

### Implementation Code

All HTML pages in this repository include the GA4 tracking code in the `<head>` section:

```html
<!-- Google tag (gtag.js) -->
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

### Files with GA4 Implementation

**Marketing Pages (7 files):**
- `index.html` - Landing page
- `how-it-works.html` - Process explanation
- `service-tiers.html` - Pricing tiers
- `faq.html` - Frequently asked questions
- `elite-service.html` - Premium service offering
- `privacy.html` - Privacy policy
- `terms.html` - Terms of service

**TextKeep Pages (27 files):**
- `textkeep/index.html` - TextKeep product landing page
- `textkeep/faq.html` - FAQ index with 25 questions
- `textkeep/faq/*.html` - 25 individual FAQ answer pages covering:
  - Why Apple doesn't offer native export (4 pages)
  - iMessage technical architecture (6 pages)
  - Using TextKeep (5 pages)
  - Legal & compliance (3 pages)
  - Alternative export solutions (4 pages)
  - Privacy & security (3 pages)

**Total:** 34 HTML files with GA4 tracking

### Configuration Details

- **Auto Page Views:** Yes (automatic)
- **Enhanced Measurement:** Enabled in GA4 admin (tracks scrolls, outbound links, site search, video engagement)
- **Cookie Domain:** Auto-configured
- **Cookie Flags:** Secure, SameSite=None (for cross-domain)

---

## Cross-Domain Tracking

### Purpose

Cross-domain tracking ensures that user sessions are preserved when users navigate between:
- `proofbound.com` (marketing) → `app.proofbound.com` (application)
- `proofbound.com` (marketing) → `shop.proofbound.com` (shop)
- Any combination of the three domains

**Without cross-domain tracking:**
```
Session 1: User visits proofbound.com (source: Google Organic)
Session 2: User clicks link to app.proofbound.com (source: proofbound.com referral) ❌
```

**With cross-domain tracking:**
```
Session 1: User visits proofbound.com → app.proofbound.com (source: Google Organic) ✅
```

### Implementation

#### Code-Level Configuration

The `linker` configuration in gtag.js automatically adds a `_gl` parameter to links between configured domains:

```javascript
gtag('config', 'G-08CE0H3LRL', {
  'linker': {
    'domains': ['proofbound.com', 'app.proofbound.com', 'shop.proofbound.com']
  }
});
```

**Example URL with linker parameter:**
```
https://app.proofbound.com/signup?_gl=1*abc123*_ga*GA1.1.123456789.1234567890*_ga_08CE0H3LRL*MTIzNDU2Nzg5MC4xLjEuMTIzNDU2Nzg5MC4wLjAuMA..
```

#### GA4 Admin Configuration

**Referral Exclusions:**
In GA4 Admin → Data Streams → Configure tag settings → List unwanted referrals:
- `proofbound.com`
- `app.proofbound.com`
- `shop.proofbound.com`

This prevents self-referrals from appearing in reports.

**Cross-Domain Measurement:**
In GA4 Admin → Data Streams → Configure tag settings → Configure your domains:
- Verify cross-domain measurement is enabled

### Verification

Check that cross-domain tracking is working:

1. Open incognito browser window
2. Visit `https://proofbound.com`
3. Click link to `app.proofbound.com`
4. Verify URL contains `_gl=` parameter
5. In GA4 DebugView, verify session ID persists across domains

**Reference:** See [GA4-CONFIGURATION-CHECKLIST.md](../GA4-CONFIGURATION-CHECKLIST.md) for complete setup instructions.

---

## Event Tracking

### Overview

Custom events track specific user interactions beyond automatic page views. All events use the `gtag('event', ...)` syntax.

### Event Naming Convention

```javascript
gtag('event', 'event_name', {
  'event_category': 'conversion' | 'engagement',
  'event_label': 'specific_action_identifier'
});
```

### Events by Category

#### **Conversion Events**

| Event Name | Category | Label | Trigger | Location |
|------------|----------|-------|---------|----------|
| `download` | conversion | `textkeep_macos` | Download button click | textkeep/index.html:401 |
| `cta_click` | conversion | `try_for_free_hero` | "Try for Free" CTA | index.html:647 |
| `cta_click` | conversion | `elite_service_hero` | "Elite Service" CTA | index.html:656 |
| `cta_click` | conversion | `try_free_how` | "Try for Free" CTA | how-it-works.html |
| `cta_click` | conversion | `free_demo_how` | "Free Demo" CTA | how-it-works.html |
| `cta_click` | conversion | `tier_*` | Pricing tier CTAs | service-tiers.html |
| `cta_click` | conversion | `elite_service_faq` | Elite CTA | faq.html |
| `cta_click` | conversion | `elite_service_page` | Elite page CTAs | elite-service.html |

#### **Engagement Events**

| Event Name | Category | Label | Trigger | Location |
|------------|----------|-------|---------|----------|
| `textkeep_click` | engagement | `banner` | TextKeep banner click | index.html:594, all pages |
| `cta_click` | engagement | `kdp_guide` | KDP guide link | index.html:683 |

### TextKeep-Specific Events

**Download Event (Primary Conversion):**
```javascript
// Location: textkeep/index.html:401
onclick="gtag('event', 'download', {
  'event_category': 'conversion',
  'event_label': 'textkeep_macos'
});"
```

**TextKeep Banner Click (Engagement):**
```javascript
// Location: All marketing pages (e.g., index.html:594)
onclick="gtag('event', 'textkeep_click', {
  'event_category': 'engagement',
  'event_label': 'banner'
});"
```

### Event Tracking Coverage

**Pages with Event Tracking (6 files):**
- ✅ `index.html` - 4 events (2 hero CTAs, 1 banner, 1 KDP guide)
- ✅ `textkeep/index.html` - 1 event (download conversion)
- ✅ `how-it-works.html` - 2 events (Try Free, Free Demo)
- ✅ `service-tiers.html` - Multiple events (tier CTAs)
- ✅ `faq.html` - 1 event (Elite CTA)
- ✅ `elite-service.html` - Multiple events (Elite CTAs)

**Pages without Event Tracking (28 files):**
- ❌ `privacy.html` - Legal page (no CTAs)
- ❌ `terms.html` - Legal page (no CTAs)
- ℹ️ `textkeep/faq.html` - FAQ index (navigation only, no conversion CTAs)
- ℹ️ `textkeep/faq/*.html` (25 pages) - FAQ answers (navigation to textkeep/index.html, conversion tracked there)

---

## Cloudflare Worker Analytics Considerations

### Overview

The Cloudflare Worker at `proofbound.com/*` proxies certain paths to the static site at `status.proofbound.com`. This proxying is **transparent to analytics** and does not affect tracking.

### Worker Configuration

**File:** `/Users/sprague/dev/proofbound/proofbound-monorepo/cloudflare-worker.js`

**Proxied Paths:**
```javascript
// ALWAYS proxy these paths from static site (keeps proofbound.com URL)
if (pathname.startsWith('/textkeep') ||
    pathname === '/privacy' ||
    pathname === '/privacy.html' ||
    pathname === '/terms' ||
    pathname === '/terms.html') {

  return fetch(`https://status.proofbound.com${staticPath}${url.search}`, {
    cf: { ... }
  });
}
```

### Analytics Impact

#### **What the Worker Does:**
1. User visits `https://proofbound.com/textkeep`
2. Cloudflare Worker intercepts request
3. Worker fetches content from `https://status.proofbound.com/textkeep/index.html`
4. Worker returns content to user **without redirecting**
5. User's browser shows `proofbound.com/textkeep` in address bar

#### **Analytics Perspective:**
- ✅ GA4 tracks hostname as `proofbound.com` (not `status.proofbound.com`)
- ✅ Page path recorded as `/textkeep`
- ✅ User sees clean URL: `proofbound.com/textkeep`
- ✅ No redirect = no session break
- ✅ Cross-domain tracking not needed for this path

**Key Insight:** The worker **proxies** content (not redirects), so analytics sees the user as staying on `proofbound.com`. This is the desired behavior.

### Static Asset Caching

The worker caches static assets (images, zips, fonts) for 24 hours:

```javascript
cf: {
  cacheTtl: 86400,  // 24 hours for assets
  cacheEverything: true
}
```

**Analytics Impact:**
- ✅ Cached assets do not generate new pageviews
- ✅ Download events still fire (JS executes client-side)
- ⚠️ Server-side analytics would miss cached asset requests (but we use client-side GA4)

### Failover Routing

When the droplet is down, the worker redirects to the static site:

```javascript
if (wantsHtml && res.status >= 500) {
  return fetch(`${FALLBACK}${url.pathname}${url.search}`, { ... });
}
```

**Analytics Impact:**
- ⚠️ Hostname changes from `proofbound.com` to `status.proofbound.com`
- ⚠️ This creates a new session (unless cross-domain tracking extended to status.proofbound.com)
- ℹ️ Failover is rare, so impact is minimal

**Recommendation:** If failover becomes frequent, consider adding `status.proofbound.com` to linker domains.

---

## TextKeep Analytics

### Overview

TextKeep is a free macOS app featured prominently on the Proofbound marketing site. Analytics tracks both engagement (banner clicks) and conversions (downloads).

### Tracking Points

#### 1. **Banner Engagement (All Pages)**

**Location:** Top of every marketing page
**Event:** `textkeep_click` (engagement)

```html
<div class="textkeep-banner">
  <a href="textkeep" onclick="gtag('event', 'textkeep_click', {
    'event_category': 'engagement',
    'event_label': 'banner'
  });">
    TextKeep: save your text messages (macOS)
  </a>
</div>
```

**Pages with Banner:**
- index.html
- how-it-works.html
- service-tiers.html
- faq.html
- elite-service.html
- privacy.html
- terms.html

**Total:** 7 pages × banner = 7 tracking points

#### 2. **Download Conversion (TextKeep Page)**

**Location:** textkeep/index.html:401
**Event:** `download` (conversion)

```html
<a href="../downloads/TextKeep-1.3.6.zip"
   class="download-btn"
   download
   onclick="gtag('event', 'download', {
     'event_category': 'conversion',
     'event_label': 'textkeep_macos'
   });">
  Download for macOS v1.3.6
</a>
```

**Download File:**
- Path: `/downloads/TextKeep-1.3.6.zip`
- Size: ~12 MB (varies by version)
- Hosted: Static on Digital Ocean App Platform

#### 3. **Version Metadata**

**File:** textkeep/version.json

```json
{
  "version": "1.3.6",
  "releaseDate": "2026-01-31",
  "downloadUrl": "https://proofbound.com/downloads/TextKeep-1.3.6.zip",
  "changelog": "..."
}
```

**Analytics Use:**
- Not directly tracked by GA4
- Could be used for version adoption analysis (custom dimension)
- Useful for A/B testing version update prompts

### TextKeep Funnel Analysis

**Primary User Journey:**
1. **Awareness:** User sees TextKeep banner on marketing page
2. **Interest:** User clicks banner → navigates to `/textkeep`
3. **Consideration:** User reads TextKeep landing page
4. **Conversion:** User clicks download button → downloads app

**Alternative Journey (SEO/FAQ):**
1. **Awareness:** User discovers FAQ via search (e.g., "why can't I export iMessages")
2. **Education:** User reads FAQ answer page(s)
3. **Interest:** User clicks "Download TextKeep for Mac" CTA → navigates to `/textkeep`
4. **Consideration:** User reads TextKeep landing page
5. **Conversion:** User clicks download button → downloads app

**GA4 Funnel Steps (Primary):**
```
Step 1: Page view (any marketing page)
Step 2: textkeep_click event (banner)
Step 3: Page view (/textkeep)
Step 4: download event (conversion)
```

**Recommended GA4 Setup:**
- Create a "TextKeep Funnel" exploration
- Track drop-off between steps
- Measure conversion rate: (downloads / banner clicks)

### Key Metrics to Monitor

| Metric | Description | GA4 Report |
|--------|-------------|------------|
| **Banner Impressions** | Page views with banner | Pages and screens (filter by pages with banner) |
| **Banner Clicks** | textkeep_click events | Events > textkeep_click |
| **Banner CTR** | (Clicks / Impressions) × 100% | Custom exploration |
| **/textkeep Page Views** | Users viewing landing page | Pages and screens > filter /textkeep |
| **Downloads** | download events | Events > download |
| **Download Conversion Rate** | (Downloads / /textkeep page views) × 100% | Custom exploration |
| **Download Funnel** | Banner → Page → Download | Funnel exploration |
| **FAQ Index Views** | Page views of /textkeep/faq.html | Pages and screens > filter /textkeep/faq.html |
| **FAQ Answer Views** | Page views of /textkeep/faq/*.html | Pages and screens > filter /textkeep/faq/ |
| **FAQ → Download Rate** | Users who viewed FAQ then downloaded | Custom exploration (path exploration) |
| **Organic Search to FAQ** | FAQ page views from organic search | Acquisition > filter page path contains /textkeep/faq/ |

### TextKeep vs Proofbound Conversions

**Goal:** Understand if TextKeep drives Proofbound conversions

**Analysis:**
1. Segment users who interacted with TextKeep (banner click or /textkeep page view)
2. Track subsequent Proofbound conversions (signup, demo requests, tier purchases)
3. Compare conversion rates: TextKeep users vs non-TextKeep users

**Hypothesis:** Users who download TextKeep may have higher trust → higher Proofbound conversion

**Implementation:**
- Create audience: "TextKeep Engaged Users"
- Apply to Proofbound conversion funnels
- Measure lift in conversion rate

### FAQ System SEO Analytics

**Purpose:** The 25 FAQ answer pages serve as SEO content to capture organic search traffic for iMessage export-related queries.

**Target Keywords:**
- "why can't I export iMessages"
- "how to backup text messages on Mac"
- "iMessage end-to-end encryption"
- "Apple walled garden strategy"
- "GDPR iMessage export"
- "legal discovery iMessage"
- And 20+ other long-tail keywords

**Key Analytics Metrics:**

| Metric | Description | How to Track |
|--------|-------------|--------------|
| **Organic FAQ Traffic** | Visitors from search engines to FAQ pages | Acquisition > Organic search > filter /textkeep/faq/ |
| **FAQ Engagement** | Average pages per FAQ visitor | Engagement > Pages and screens > filter by FAQ paths |
| **FAQ → Product Interest** | % of FAQ visitors who navigate to /textkeep | Exploration > Path exploration |
| **FAQ → Download** | FAQ visitors who eventually download | Exploration > Segment overlap (FAQ viewers + downloaders) |
| **Top Performing FAQs** | Which FAQ pages drive most traffic/conversions | Pages and screens > sort by views/conversions |
| **Bounce Rate by FAQ** | Single-page sessions per FAQ answer | Engagement > Landing pages > filter FAQ |

**Recommended GA4 Setup:**
1. Create custom segment: "FAQ Visitors" (page path contains /textkeep/faq/)
2. Create exploration: "FAQ to Conversion Path"
   - Starting point: Any FAQ page view
   - Ending point: download event
3. Monitor organic search queries driving FAQ traffic
4. Track which FAQ topics lead to highest download conversion

**Expected Performance:**
- **Weeks 1-4:** Pages indexed by Google, minimal traffic
- **Months 2-3:** Organic traffic increases as rankings improve
- **Months 4-6:** 100-500 organic visits/month to FAQ pages
- **Month 6+:** FAQ pages become significant traffic source (10-20% of total)

**Success Indicators:**
- ✅ FAQ pages rank in top 10 for target keywords
- ✅ Organic search becomes primary traffic source for FAQ pages (>80%)
- ✅ FAQ visitors have higher engagement than average (2+ pages/session)
- ✅ 5-10% of FAQ visitors eventually download TextKeep

---

## Testing & Verification

### Local Testing (Development)

**Option 1: Test Event Tracking Locally**

```bash
# Start local server
python3 -m http.server 8000

# Visit pages
open http://localhost:8000/index.html
open http://localhost:8000/textkeep/index.html
```

**Browser Console Verification:**
```javascript
// Check if gtag is loaded
typeof gtag === 'function'  // Should return true

// Check dataLayer
window.dataLayer  // Should show array of GA4 events

// Fire test event
gtag('event', 'test_event', {'event_category': 'test'});
```

**Option 2: Use GA4 Debug Mode**

Add `?debug_mode=true` to any URL:
```
http://localhost:8000/index.html?debug_mode=true
```

Then check GA4 DebugView in real-time.

### Production Testing

#### **Step 1: Install GA Debugger Extension**

- Chrome: [Google Analytics Debugger](https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna)
- Firefox: Similar extension available

#### **Step 2: Test Event Firing**

1. Visit `https://proofbound.com`
2. Open DevTools → Console
3. Enable GA Debugger extension
4. Interact with tracked elements (CTAs, download button, banner)
5. Verify events appear in console

**Expected Console Output:**
```
Running command: ga("send", "event", "conversion", "textkeep_macos", "download")
```

#### **Step 3: Use GA4 DebugView**

1. In GA4, go to **Admin** → **DebugView**
2. Add `?debug_mode=true` to production URL:
   ```
   https://proofbound.com/textkeep?debug_mode=true
   ```
3. Perform actions (click download, CTAs)
4. Watch events appear in DebugView in real-time

#### **Step 4: Test Cross-Domain Tracking**

1. Open incognito window
2. Visit `https://proofbound.com`
3. Click "Try for Free" CTA → redirects to `app.proofbound.com/signup`
4. Check URL contains `_gl=` parameter:
   ```
   https://app.proofbound.com/signup?_gl=1*abc123...
   ```
5. In GA4 Realtime report, verify session continues (not a new session)

#### **Step 5: Verify Cloudflare Worker Proxying**

1. Visit `https://proofbound.com/textkeep`
2. Open DevTools → Network tab
3. Verify:
   - Status: 200 OK
   - URL shown in browser: `proofbound.com/textkeep`
   - Actual content fetched from: `status.proofbound.com` (visible in response headers)
4. Check GA4 pageview:
   - Hostname: `proofbound.com` ✅
   - Page path: `/textkeep` ✅

### Automated Testing (Future)

**Recommendation:** Implement automated tests for analytics:

```javascript
// Example: Playwright test
test('TextKeep download fires GA4 event', async ({ page }) => {
  await page.goto('https://proofbound.com/textkeep');

  // Intercept GA4 request
  const gtagPromise = page.waitForRequest(request =>
    request.url().includes('google-analytics.com/g/collect')
  );

  // Click download button
  await page.click('text=Download for macOS');

  // Verify GA4 request sent
  const gtagRequest = await gtagPromise;
  expect(gtagRequest.url()).toContain('en=download');
  expect(gtagRequest.url()).toContain('textkeep_macos');
});
```

---

## Privacy & Compliance

### Data Collection

**What GA4 Collects:**
- Page views and paths
- User interactions (clicks, scrolls, downloads)
- Traffic sources (Google, direct, referral)
- Device information (browser, OS, screen size)
- Geographic location (country, city)
- Session duration and engagement time

**What GA4 Does NOT Collect (by default):**
- ❌ Personally identifiable information (PII)
- ❌ Email addresses
- ❌ User account data
- ❌ Payment information

### Privacy Policy Compliance

**File:** privacy.html:56-72

> "We use Google Analytics to understand how visitors use our site. This includes tracking page views, time on site, and user interactions. Google Analytics may use cookies to collect this data."

**Cookie Consent:**
- Currently: Implicit consent (standard for analytics)
- Future: Consider cookie consent banner (GDPR compliance)

### GDPR Compliance

**Current Status:** Partial compliance

**Recommendations for Full Compliance:**
1. ✅ **Privacy policy** - Clearly states GA4 usage
2. ⚠️ **Cookie consent banner** - Not implemented (recommended for EU users)
3. ✅ **Data retention** - Set in GA4 admin (default: 14 months)
4. ⚠️ **IP anonymization** - Not explicitly configured (GA4 does this automatically)
5. ⚠️ **User opt-out** - Not implemented (consider adding)

**Sample Cookie Consent Banner (Future):**
```html
<div id="cookie-banner" style="display:none;">
  <p>We use cookies to improve your experience.
     <a href="/privacy.html">Learn more</a>
  </p>
  <button onclick="acceptCookies()">Accept</button>
  <button onclick="rejectCookies()">Reject</button>
</div>
```

### Data Retention

**GA4 Settings:**
- User data retention: 14 months (default)
- Reset on new activity: Yes

**Access:** GA4 Admin → Data Settings → Data Retention

---

## Future Recommendations

### 1. **Enhanced Event Tracking**

**Add Events For:**
- Video plays (book-pages-flipping.mp4 on index.html)
- Form interactions (if forms added)
- Scroll depth (% of page viewed)
- Time on page milestones (30s, 1min, 2min)
- External link clicks (GitHub, social media)

**Implementation:**
```javascript
// Video play tracking
document.querySelector('.book-video').addEventListener('play', () => {
  gtag('event', 'video_play', {
    'event_category': 'engagement',
    'event_label': 'hero_book_animation'
  });
});

// Scroll depth tracking
let scrollDepth = 0;
window.addEventListener('scroll', () => {
  const depth = (window.scrollY / document.body.scrollHeight) * 100;
  if (depth > 75 && scrollDepth < 75) {
    scrollDepth = 75;
    gtag('event', 'scroll', {'event_category': 'engagement', 'event_label': '75_percent'});
  }
});
```

### 2. **User ID Tracking**

If users sign in on app.proofbound.com, track them across devices:

```javascript
gtag('config', 'G-08CE0H3LRL', {
  'user_id': 'USER_ID_FROM_AUTH',
  'linker': { ... }
});
```

**Benefits:**
- Track user journey from marketing → signup → first book
- Calculate customer lifetime value (CLV)
- Personalize marketing based on behavior

### 3. **Enhanced E-commerce Tracking**

For shop.proofbound.com, implement enhanced e-commerce:

```javascript
// View product
gtag('event', 'view_item', {
  'items': [{
    'item_id': 'professional_book',
    'item_name': 'Professional Book Package',
    'price': 1000.00
  }]
});

// Add to cart
gtag('event', 'add_to_cart', { ... });

// Purchase
gtag('event', 'purchase', {
  'transaction_id': 'T12345',
  'value': 1000.00,
  'currency': 'USD',
  'items': [...]
});
```

### 4. **Heatmap & Session Recording**

Consider adding tools like:
- **Hotjar** - Heatmaps, session recordings, surveys
- **Microsoft Clarity** - Free heatmaps and recordings
- **Fullstory** - Advanced user session analysis

**Benefits:**
- See exactly how users interact with pages
- Identify UX issues (confusing CTAs, broken flows)
- Optimize conversion funnels

### 5. **A/B Testing Integration**

Integrate with Google Optimize (or similar):
- Test different CTA copy ("Try for Free" vs "Start Free Trial")
- Test hero headlines
- Test pricing tier presentation
- Test TextKeep banner placement

### 6. **Custom Dashboards**

Create GA4 Looker Studio dashboards:
- **Marketing Dashboard** - Traffic sources, conversions, funnel
- **TextKeep Dashboard** - Banner CTR, downloads, user journey
- **Content Performance** - Page views, engagement, bounce rate

### 7. **Server-Side Tracking (GTM Server)**

For better accuracy and privacy:
- Implement Google Tag Manager Server-Side
- Track events from Cloudflare Worker (server-side)
- Bypass ad blockers (15-30% of users block client-side GA4)

### 8. **Conversion Value Tracking**

Assign monetary values to conversions:

```javascript
gtag('event', 'download', {
  'event_category': 'conversion',
  'event_label': 'textkeep_macos',
  'value': 5.00  // Estimated value of TextKeep user
});

gtag('event', 'cta_click', {
  'event_category': 'conversion',
  'event_label': 'try_for_free',
  'value': 49.00  // Average POC book value
});
```

**Benefits:**
- Calculate ROI of marketing campaigns
- Prioritize high-value traffic sources
- Measure impact of TextKeep on revenue

### 9. **Data Layer Enhancement**

Implement a structured data layer:

```javascript
window.dataLayer = window.dataLayer || [];
window.dataLayer.push({
  'event': 'page_metadata',
  'page_type': 'landing',
  'product': 'proofbound',
  'user_status': 'anonymous',
  'content_category': 'marketing'
});
```

### 10. **Privacy Enhancements**

- Implement cookie consent banner
- Add GA4 opt-out mechanism
- Consider server-side tracking for GDPR compliance
- Review and update privacy policy annually

---

## Appendix

### Related Documentation

- [GA4-CONFIGURATION-CHECKLIST.md](../GA4-CONFIGURATION-CHECKLIST.md) - Cross-domain setup checklist
- [CLAUDE.md](../CLAUDE.md) - Project overview and development context
- [DEPLOYMENT.md](../DEPLOYMENT.md) - Deployment procedures and DNS configuration
- [privacy.html](../privacy.html) - User-facing privacy policy
- [terms.html](../terms.html) - User-facing terms of service

### Useful GA4 Resources

- [GA4 Documentation](https://support.google.com/analytics/answer/10089681)
- [GA4 Event Reference](https://support.google.com/analytics/answer/9267735)
- [Cross-Domain Tracking Guide](https://support.google.com/analytics/answer/10071811)
- [Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/ga4)

### Contact

For questions about analytics implementation:
- **Email:** info@proofbound.com
- **GitHub Issues:** [Proofbound/proofbound-oof/issues](https://github.com/Proofbound/proofbound-oof/issues)

---

**Document Version:** 1.0
**Created:** February 1, 2026
**Author:** Proofbound Development Team
