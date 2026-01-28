# Deployment Checklist

This document outlines the steps to deploy the static marketing site as the primary proofbound.com domain.

## Pre-Deployment Testing

### Local Testing
- [ ] Run `./test-local.sh` to open all pages
- [ ] Verify TextKeep banner on all pages
- [ ] Test navigation between pages (header/footer links)
- [ ] Test typing animation on landing page
- [ ] Test FAQ accordion functionality
- [ ] Verify all CTAs point to correct URLs
- [ ] Test mobile responsive design (resize to 375px)
- [ ] Check browser console for errors
- [ ] Verify all images load correctly

### Content Review
- [ ] Proofread all marketing copy
- [ ] Verify pricing is current ($49, $500-$2000, $2000-$5000)
- [ ] Check contact emails (legal@proofbound.com, privacy@proofbound.com)
- [ ] Verify "Last updated" dates on Privacy and Terms pages
- [ ] Confirm all external links work (TextKeep, app.proofbound.com)

## Phase 1: Set Up Digital Ocean App Platform

### Create New Static Site App
1. [ ] Log in to Digital Ocean
2. [ ] Go to App Platform → Create App
3. [ ] Connect to GitHub repository
   - Repository: `Proofbound/proofbound-fallback` or `Proofbound/proofbound-oof`
   - Branch: `master`
4. [ ] Configure build settings:
   - Build command: (leave empty for static site)
   - Output directory: `/` (root)
   - Static site: Yes
5. [ ] Choose plan: Basic (Static Site) - $5/month or free tier
6. [ ] Review and create app
7. [ ] Wait for initial deployment (~3-5 minutes)
8. [ ] Note the preview URL (e.g., `new-app-xxxxx.ondigitalocean.app`)

### Test Preview URL
- [ ] Visit preview URL in browser
- [ ] Verify index.html loads
- [ ] Test navigation to all pages
- [ ] Check SSL certificate (should be auto-provisioned)
- [ ] Test on mobile device

### Add Custom Domain
1. [ ] In App settings, go to Domains
2. [ ] Click "Add Domain"
3. [ ] Enter: `proofbound.com`
4. [ ] Note the CNAME target (e.g., `new-app-xxxxx.ondigitalocean.app`)
5. [ ] DO NOT update DNS yet - wait for confirmation
6. [ ] SSL certificate will provision after DNS is updated

## Phase 2: Prepare Monorepo Changes

### Update nginx Configuration
**File:** `/Users/sprague/dev/proofbound/proofbound-monorepo/nginx.conf`

1. [ ] Open nginx.conf
2. [ ] Remove lines 115-127 (proofbound.com → app.proofbound.com redirect)
3. [ ] Verify other server blocks are intact
4. [ ] Test nginx config: `nginx -t` (in container)
5. [ ] Commit changes but DO NOT deploy yet

### Update React App Routes
**File:** `/Users/sprague/dev/proofbound/proofbound-monorepo/apps/main-app/frontend/src/App.tsx`

1. [ ] Remove marketing page routes (lines ~289-302):
   - `/how-it-works`
   - `/service-tiers`
   - `/faq`
   - `/elite`
   - `/privacy`
   - `/terms`
   - `/coming-soon`
   - Other marketing routes
2. [ ] Update root route `/` to redirect:
   ```tsx
   <Route path="/" element={
     user ? <Navigate to="/dashboard" /> : <Navigate to="https://proofbound.com" />
   } />
   ```
3. [ ] Update navigation components with absolute URLs
4. [ ] Commit changes but DO NOT deploy yet

### Verify Cloudflare Worker Routes
1. [ ] Log in to Cloudflare
2. [ ] Go to Workers & Pages
3. [ ] Find the error handling worker
4. [ ] Verify routes: Should ONLY apply to `app.proofbound.com/*`
5. [ ] Confirm it does NOT apply to `proofbound.com/*`

## Phase 3: DNS Cutover (Low Traffic Period)

### Pre-Cutover Preparation (24 hours before)
- [ ] Set DNS TTL to 300 seconds (5 minutes) for faster propagation
- [ ] Notify team of upcoming cutover
- [ ] Confirm rollback plan is ready

### DNS Changes in Cloudflare
**Current DNS:**
```
A      proofbound.com           →  143.110.145.237
A      app.proofbound.com       →  143.110.145.237
CNAME  status.proofbound.com    →  king-prawn-app-zmwl2.ondigitalocean.app
```

**Actions:**
1. [ ] Change `proofbound.com` from A record to CNAME:
   - Delete A record for proofbound.com
   - Add CNAME: `proofbound.com` → `[new-app-xxxxx].ondigitalocean.app`
   - Proxy status: DNS only (orange cloud OFF)
2. [ ] Leave `app.proofbound.com` unchanged
3. [ ] Leave `status.proofbound.com` unchanged
4. [ ] Save changes
5. [ ] Note exact time of cutover

### Wait for DNS Propagation
- [ ] Wait 5-10 minutes
- [ ] Check DNS propagation: `dig proofbound.com`
- [ ] Test from different networks (mobile data, VPN)
- [ ] Clear browser cache before testing

### Immediate Post-Cutover Verification
- [ ] Visit `https://proofbound.com` → Should show static marketing site
- [ ] Verify SSL certificate is valid
- [ ] Test all navigation links
- [ ] Click "Try for Free" → Should go to app.proofbound.com/signup
- [ ] Visit `https://app.proofbound.com` → Should still work normally

## Phase 4: Deploy Monorepo Changes

### Deploy nginx Configuration
1. [ ] SSH into Digital Ocean droplet or use Docker dashboard
2. [ ] Deploy updated nginx.conf
3. [ ] Restart nginx container
4. [ ] Verify nginx is running: `docker ps`
5. [ ] Check logs: `docker logs nginx-container`

### Deploy React App Updates
1. [ ] Build and deploy updated React app
2. [ ] Monitor deployment logs
3. [ ] Wait for deployment to complete

### Verify App Behavior
- [ ] Visit `https://app.proofbound.com/` (logged out)
   - Should redirect to `https://proofbound.com`
- [ ] Log in to app
- [ ] Visit `https://app.proofbound.com/dashboard` (logged in)
   - Should show dashboard, NOT redirect
- [ ] Test navigation within app
- [ ] Verify no broken links in app footer

## Phase 5: Monitoring & Validation (First Week)

### Day 1 (Deployment Day)
- [ ] Monitor Cloudflare Analytics for traffic patterns
- [ ] Check error rates on both sites (app and marketing)
- [ ] Verify Cloudflare Worker is catching app.proofbound.com 5xx errors
- [ ] Test all CTAs and forms
- [ ] Monitor SSL certificate status

### Day 2-7
- [ ] Check uptime daily (should be 99.9%+)
- [ ] Review Google Analytics (if enabled)
- [ ] Monitor search rankings (Google Search Console)
- [ ] Check for any 404 errors or broken links
- [ ] Review user feedback/support tickets

### Performance Testing
- [ ] Run Lighthouse audit: Target score >90
- [ ] Test page load times: Target <1 second
- [ ] Verify mobile responsiveness
- [ ] Test on multiple browsers (Chrome, Safari, Firefox, Edge)

## Rollback Plan

### If Critical Issues Arise

**Immediate Rollback (0-5 minutes):**
1. [ ] Log in to Cloudflare
2. [ ] Change DNS back:
   - Delete CNAME: `proofbound.com`
   - Add A record: `proofbound.com` → `143.110.145.237`
3. [ ] Wait 5 minutes for propagation
4. [ ] nginx redirect will restore old behavior
5. [ ] Total downtime: ~2-3 minutes

**Partial Rollback (Keep static site, restore app routes):**
1. [ ] Revert React app changes in monorepo
2. [ ] Redeploy React app
3. [ ] Both sites will work independently

**Note:** Keep marketing routes in React app for 30 days as a safety net

## Post-Launch Cleanup (30 days after)

### Archive Old Code
- [ ] Create git branch: `backup/react-marketing-pages`
- [ ] Archive removed React components
- [ ] Remove marketing page components from main branch
- [ ] Clean up unused dependencies
- [ ] Update monorepo documentation

### SEO Maintenance
- [ ] Submit new sitemap to Google Search Console
- [ ] Monitor search rankings for 30 days
- [ ] Add schema.org markup if needed
- [ ] Optimize meta tags based on performance

### Documentation
- [ ] Update CLAUDE.md in both repos
- [ ] Document lessons learned
- [ ] Update deployment runbook
- [ ] Archive this checklist

## Success Metrics

### Technical KPIs
- [ ] proofbound.com loads in <1 second
- [ ] Lighthouse score >90
- [ ] 99.9%+ uptime
- [ ] Zero 5xx errors on static site
- [ ] SSL certificate auto-renews

### User Experience KPIs
- [ ] No 404 errors
- [ ] Mobile responsiveness excellent
- [ ] All CTAs working
- [ ] Navigation smooth between sites

### Business KPIs
- [ ] No drop in organic search traffic
- [ ] Signup conversion rate maintained or improved
- [ ] TextKeep banner generates clicks
- [ ] User satisfaction maintained

## Support Contacts

- **Digital Ocean:** support.digitalocean.com
- **Cloudflare:** support.cloudflare.com
- **DNS Issues:** Check Cloudflare dashboard → DNS → proofbound.com
- **App Issues:** SSH into droplet, check Docker logs
- **SSL Issues:** Let's Encrypt auto-renewal (check Digital Ocean)

## Notes & Issues

_Use this section to document any issues encountered during deployment:_

---

**Deployment Date:** _________________

**Deployed By:** _________________

**Rollback Tested:** [ ] Yes [ ] No

**Final Status:** [ ] Success [ ] Rolled Back [ ] Partial Success
