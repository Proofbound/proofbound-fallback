# Marketing Site Deployment Plan

**Objective:** Deploy marketing site to proofbound.com and fix SEO-damaging redirect chain

**Current State:**
- ❌ proofbound.com → 301 redirect to app.proofbound.com (nginx)
- ❌ Search engines index app.proofbound.com instead of marketing content
- ❌ Sitemap/robots.txt never discovered
- ❌ New SEO improvements have zero effect

**Target State:**
- ✅ proofbound.com → static marketing site (this repo)
- ✅ app.proofbound.com → React application (monorepo)
- ✅ status.proofbound.com → fallback page (shown when app is down)

---

## Phase 1: Deploy Marketing Site to Digital Ocean

### 1.1 Create New Digital Ocean App

1. **Log into Digital Ocean**
   - Go to: https://cloud.digitalocean.com/apps

2. **Create New App**
   - Click "Create" → "Apps"
   - Choose "GitHub" as source
   - Select repository: `Proofbound/proofbound-fallback` or `Proofbound/proofbound-oof`
   - Branch: `master`
   - Autodeploy: ON (deploys on every push to master)

3. **Configure as Static Site**
   - Type: **Static Site**
   - Build Command: (leave empty - no build needed)
   - Output Directory: `/` (root directory)
   - HTTP Port: (leave default)

4. **Resource Sizing**
   - Plan: **Basic** (~$5/month or free tier if available)
   - This is a static site with minimal traffic needs

5. **Environment Variables**
   - None needed for static HTML site

### 1.2 Configure Custom Domain

1. **In Digital Ocean App Settings**
   - Click "Settings" → "Domains"
   - Click "Add Domain"
   - Enter: `proofbound.com`
   - DNS Target will be shown (e.g., `your-app-name.ondigitalocean.app`)

2. **Copy the DNS Target**
   - Example: `marketing-site-abc123.ondigitalocean.app`
   - You'll need this for DNS configuration

---

## Phase 2: Update DNS in Cloudflare

### 2.1 Current DNS Records
```
A      proofbound.com           →  143.110.145.237 (Digital Ocean droplet)
A      app.proofbound.com       →  143.110.145.237 (Digital Ocean droplet)
CNAME  status.proofbound.com    →  proofbound-main.ondigitalocean.app
```

### 2.2 New DNS Records
```
CNAME  proofbound.com           →  [new-marketing-site].ondigitalocean.app (NEW)
A      app.proofbound.com       →  143.110.145.237 (UNCHANGED)
CNAME  status.proofbound.com    →  proofbound-main.ondigitalocean.app (UNCHANGED)
```

### 2.3 Steps

1. **Log into Cloudflare**
   - Go to DNS settings for proofbound.com

2. **Update proofbound.com Record**
   - **Change from:** `A` record pointing to `143.110.145.237`
   - **Change to:** `CNAME` record pointing to `[your-app-name].ondigitalocean.app`
   - Set Proxy Status: **Proxied** (orange cloud) for Cloudflare protection
   - TTL: Auto

3. **Verify Other Records Stay Unchanged**
   - ✅ app.proofbound.com → 143.110.145.237 (keeps working)
   - ✅ status.proofbound.com → fallback page (keeps working)

4. **Wait for DNS Propagation**
   - Usually takes 1-5 minutes with Cloudflare
   - Test with: `dig proofbound.com` or `nslookup proofbound.com`

---

## Phase 3: Update Monorepo nginx.conf

### 3.1 Remove proofbound.com Redirect

**File:** `/Users/sprague/dev/proofbound/proofbound-monorepo/nginx.conf`

**Remove these lines (113-127):**
```nginx
# Redirect proofbound.com to app.proofbound.com
# This ensures consistent localStorage/session across all users
server {
    listen 80;
    listen 443 ssl;
    server_name proofbound.com;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Redirect all traffic to app.proofbound.com
    return 301 https://app.proofbound.com$request_uri;
}
```

**Why:** This redirect is no longer needed since proofbound.com will point to Digital Ocean static site instead of the nginx server.

### 3.2 Deployment Steps

1. **Edit nginx.conf**
   ```bash
   cd /Users/sprague/dev/proofbound/proofbound-monorepo
   # Remove lines 113-127
   ```

2. **Commit Changes**
   ```bash
   git add nginx.conf
   git commit -m "Remove proofbound.com redirect - marketing site now separate

   Marketing site deployed to Digital Ocean static hosting.
   proofbound.com DNS now points to marketing site.
   app.proofbound.com continues to serve React application.

   This fixes SEO issues caused by 301 redirect chain.
   "
   git push
   ```

3. **Deploy to Production**
   ```bash
   # SSH into production server
   ssh root@143.110.145.237

   # Navigate to project
   cd /root/proofbound-monorepo

   # Pull latest changes
   git pull

   # Reload nginx (no downtime)
   docker-compose -f docker-compose.production.yml exec nginx nginx -s reload

   # Verify nginx config is valid
   docker-compose -f docker-compose.production.yml exec nginx nginx -t
   ```

---

## Phase 4: Update Cloudflare Worker (Optional but Recommended)

The Cloudflare Worker currently redirects to GitHub Pages when app.proofbound.com is down. Update it to use the correct fallback URL.

**File:** `/Users/sprague/dev/proofbound/proofbound-monorepo/cloudflare-worker.js`

**Change line 5 from:**
```javascript
const FALLBACK = "https://proofbound.github.io/proofbound-fallback/";
```

**To:**
```javascript
const FALLBACK = "https://status.proofbound.com/";
```

**Why:** This ensures users see the correct fallback page when app.proofbound.com is down.

### 4.1 Deployment

1. **Edit the file locally**
2. **Deploy to Cloudflare Workers**
   - Go to: https://dash.cloudflare.com/
   - Find your worker
   - Update the code
   - Click "Save and Deploy"

---

## Phase 5: Verify Deployment

### 5.1 Test All URLs

**Marketing Site (proofbound.com):**
- ✅ https://proofbound.com/ → Shows landing page
- ✅ https://proofbound.com/how-it-works.html → Works
- ✅ https://proofbound.com/textkeep.html → Works
- ✅ https://proofbound.com/sitemap.xml → Returns XML
- ✅ https://proofbound.com/robots.txt → Returns text file

**Application (app.proofbound.com):**
- ✅ https://app.proofbound.com/ → Shows React app
- ✅ https://app.proofbound.com/dashboard → Works for logged-in users
- ✅ https://app.proofbound.com/api/health → API responds

**Fallback (status.proofbound.com):**
- ✅ https://status.proofbound.com/ → Shows fallback page

### 5.2 Test SEO Tags

Use these tools to verify SEO improvements:

1. **Google Rich Results Test**
   - URL: https://search.google.com/test/rich-results
   - Test: https://proofbound.com/
   - Should show: ProfessionalService schema

2. **Twitter Card Validator**
   - URL: https://cards-dev.twitter.com/validator
   - Test: https://proofbound.com/
   - Should show: Card preview with title/description

3. **Facebook Sharing Debugger**
   - URL: https://developers.facebook.com/tools/debug/
   - Test: https://proofbound.com/
   - Should show: OG tags with image

4. **Google Search Console**
   - URL: https://search.google.com/search-console
   - Verify sitemap: https://proofbound.com/sitemap.xml
   - Request indexing of all pages

### 5.3 Monitor for 24 Hours

**Check:**
- ❌ Any 404 errors
- ❌ Broken CSS/JS (shouldn't be any - all inline)
- ❌ Redirect loops
- ✅ Google Analytics tracking (G-08CE0H3LRL)
- ✅ Download button works (downloads/TextKeep-1.3.3.zip)

---

## Phase 6: SEO Recovery

### 6.1 Submit to Google Search Console

1. **Add Property**
   - Go to: https://search.google.com/search-console
   - Add property: `proofbound.com`
   - Verify ownership (use DNS TXT record method)

2. **Submit Sitemap**
   - In Search Console: Sitemaps → Add new sitemap
   - URL: `https://proofbound.com/sitemap.xml`
   - Submit

3. **Request Indexing**
   - URL Inspection tool
   - Test each important page:
     - https://proofbound.com/
     - https://proofbound.com/how-it-works.html
     - https://proofbound.com/service-tiers.html
     - https://proofbound.com/textkeep.html
   - Click "Request Indexing" for each

### 6.2 Monitor Search Console

**Watch for:**
- Coverage issues (should decrease)
- Mobile usability (should be good - responsive design)
- Core Web Vitals (should be excellent - static site)
- Search queries (should increase over time)
- Impressions/clicks (should grow)

**Timeline:**
- Week 1: Pages get indexed
- Week 2-4: Start seeing impressions
- Month 2-3: Rankings improve for target keywords
- Month 4-6: Significant organic traffic growth

---

## Rollback Plan (If Needed)

If something goes wrong, revert quickly:

### Rollback DNS
```bash
# Change proofbound.com back to A record
A  proofbound.com  →  143.110.145.237
```

### Rollback nginx.conf
```bash
cd /Users/sprague/dev/proofbound/proofbound-monorepo
git revert HEAD  # Reverts the commit that removed redirect
git push
# SSH and reload nginx
```

**Rollback Time:** ~5 minutes

---

## Timeline & Checklist

### Day 1 (Today) - 30 Minutes
- [ ] Create Digital Ocean App for marketing site
- [ ] Configure custom domain (proofbound.com)
- [ ] Update Cloudflare DNS (CNAME change)
- [ ] Wait for DNS propagation (1-5 minutes)
- [ ] Test: https://proofbound.com/ loads correctly

### Day 1 (Today) - 15 Minutes
- [ ] Update nginx.conf (remove redirect)
- [ ] Commit and push changes
- [ ] SSH to production server
- [ ] Pull changes and reload nginx
- [ ] Verify app.proofbound.com still works

### Day 1 (Today) - 15 Minutes
- [ ] Update Cloudflare Worker fallback URL
- [ ] Deploy to Cloudflare
- [ ] Test all URLs (marketing, app, fallback)

### Day 1 (Today) - 30 Minutes
- [ ] Run SEO validation tests
- [ ] Submit sitemap to Google Search Console
- [ ] Request indexing of key pages

### Week 1
- [ ] Monitor Google Search Console for indexing
- [ ] Check for any 404 errors
- [ ] Verify Google Analytics data

### Month 1
- [ ] Review search performance
- [ ] Check for rich snippets in search results
- [ ] Monitor organic traffic growth

---

## Success Metrics

**Technical:**
- ✅ proofbound.com serves marketing site (not redirect)
- ✅ sitemap.xml discoverable by search engines
- ✅ robots.txt accessible
- ✅ All pages indexed in Google Search Console
- ✅ No redirect chains (direct A/CNAME to content)

**SEO:**
- 📈 Google indexes all 8 pages within 1 week
- 📈 FAQ rich snippets appear within 2-4 weeks
- 📈 Organic impressions > 100/day within 1 month
- 📈 Organic clicks > 10/day within 2 months
- 📈 Average position < 20 for target keywords within 3 months

**Business:**
- 📈 Increased signups from organic search
- 📈 More TextKeep downloads
- 📈 Professional marketing presence

---

## Notes

- **Zero Downtime:** DNS changes and nginx reload have no downtime
- **Independent Deployments:** Marketing site and app deploy separately
- **Cost:** Digital Ocean static site is ~$5/month (or free tier)
- **Performance:** Static HTML is extremely fast (< 500ms load time)
- **SEO Recovery:** Takes 1-3 months to fully recover from current redirect damage

---

**Next Action:** Ready to proceed? Say "deploy" and I'll walk you through each step interactively.
