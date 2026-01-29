# Migration Plan: shop.proofbound.com to Netlify Free Tier

**Date**: January 28, 2026
**Goal**: Reduce hosting costs by moving shop frontend to Netlify's free tier
**Estimated Savings**: $5-10/month (~$60-120/year)
**Migration Effort**: 1-2 days (LOW complexity)

---

## Executive Summary

**Current State**: shop.proofbound.com already exists as a fully functional React e-commerce app running on Digital Ocean alongside backend services.

**Key Finding**: The shop is NOT a simple static site - it requires backend APIs, database (Supabase), payment processing (Stripe), and file storage.

**Recommended Approach**: **Hybrid Architecture** (Option 1)
- Frontend (React SPA) → Netlify free tier ($0/month)
- Backend APIs → Stay on Digital Ocean (existing infrastructure)
- Cost savings: $5-10/month by removing shop container from Digital Ocean
- Risk: LOW (easy rollback via DNS change)

---

## Current State Analysis

### shop.proofbound.com - Already Exists and is Production-Ready

**Current Architecture:**
- **Frontend**: React 18 + TypeScript SPA (port 5174)
- **Hosting**: Digital Ocean Docker container
- **Backend Dependencies**:
  - Supabase (database + auth + storage)
  - Stripe (payments + webhooks)
  - Lulu API (print fulfillment)
  - Backend services: ai-clients (8000), cc-template-api (8001), lulu-service (8002)

**Current Features:**
- ✅ Dynamic book catalog (featured + community books)
- ✅ Guest checkout (no login required)
- ✅ Stripe payment processing
- ✅ Physical book ordering via Lulu
- ✅ Email notifications (Resend)
- ✅ Order tracking

**Current Deployment:**
```
shop.proofbound.com (Cloudflare DNS)
    ↓
Digital Ocean Droplet (143.110.145.237)
    ↓
Docker Container (nginx + shop:5174)
    ↓
Backend APIs (/api/* routes)
```

### Why It Requires Backend Services

The shop is **NOT** a static site - it's a React SPA that requires:
1. **Database**: Supabase for orders, books, users
2. **Backend APIs**: REST endpoints for checkout, print orders, book catalog
3. **Payment Webhooks**: Stripe needs to call your server
4. **File Storage**: Supabase Storage for PDFs and covers
5. **Authentication**: Supabase JWT (even for guest mode)

---

## Architecture Options Evaluated

### Option 1: Hybrid Architecture (Frontend on Free Tier, Backend Stays) ⭐ RECOMMENDED

**Architecture:**
```
shop.proofbound.com (Netlify/Vercel)
    ↓
React SPA (static build)
    ↓
API calls to app.proofbound.com (Digital Ocean)
    ↓
Existing backend services
```

**Pros:**
- ✅ Free frontend hosting (100GB bandwidth/month on free tier)
- ✅ Global CDN for faster page loads
- ✅ Auto-scaling for traffic spikes
- ✅ Keep existing backend unchanged
- ✅ Simple deployment from GitHub

**Cons:**
- ⚠️ CORS configuration needed (frontend domain ≠ API domain)
- ⚠️ Bandwidth limits on free tier (100GB/month might not be enough if popular)
- ⚠️ Need to manage two deployments (frontend + backend)
- ⚠️ Cookie/auth complications (different domains)

**Cost Impact:**
- Save: ~$5-10/month (frontend container costs on Digital Ocean)
- Risk: Exceed free tier bandwidth → $20/month overage on Netlify

**Why This is Perfect for Your Situation:**
- ✅ **Goal**: Reduce costs (save $5-10/month on frontend hosting)
- ✅ **Traffic**: Minimal traffic won't hit free tier limits (100GB bandwidth = ~200K page views)
- ✅ **Low Risk**: Backend stays unchanged, easy rollback if issues
- ✅ **Low Effort**: 1-2 days migration, mostly configuration changes
- ✅ **Better Performance**: Global CDN will make shop faster worldwide
- ✅ **No Vendor Lock-in**: Can switch between Netlify/Vercel easily

**Cost Analysis:**
- Current: ~$40-100/month Digital Ocean (entire stack)
- After: ~$35-95/month Digital Ocean (backend only) + $0 Netlify/Vercel (free tier)
- Savings: $5-10/month (frontend container + bandwidth)
- Free tier limits: 100GB bandwidth, 300 build minutes/month (more than enough for minimal traffic)

### Option 2: Serverless Functions for Simple APIs

**Architecture:**
```
shop.proofbound.com (Netlify/Vercel)
    ↓
React SPA + Serverless Functions
    ↓
Calls to: Supabase (DB), Stripe (payments), Lulu (print)
    ↓
Heavy operations → Digital Ocean backend
```

**Serverless Function Limits (Free Tier):**
- Netlify: 125K requests/month, 100 hours runtime
- Vercel: 100GB-hours/month, 10-second timeout (hobby), 60s (pro)
- AWS Lambda in serverless: 1M requests/month, 15-min timeout (not free after AWS trial)

**What CAN work in serverless:**
- ✅ Stripe webhook handlers (< 1 second)
- ✅ Simple DB queries (< 1 second)
- ✅ Lulu price lookups (< 2 seconds)
- ✅ Order status checks (< 1 second)

**What CANNOT work in serverless (too slow):**
- ❌ Quarto PDF generation (30-60 seconds)
- ❌ AI content generation (10-30 seconds per chunk)
- ❌ Complex book building workflows

**Pros:**
- ✅ Most of shop logic fits in serverless
- ✅ No CORS issues (functions on same domain)
- ✅ Cheaper than maintaining backend container

**Cons:**
- ⚠️ Need to rewrite backend logic as serverless functions
- ⚠️ Cold start latency (1-3 seconds for first request)
- ⚠️ Debugging harder (no local Docker environment)
- ⚠️ Vendor lock-in (Netlify vs Vercel function differences)
- ⚠️ Free tier limits (might hit 125K requests/month quickly)

**Complexity**: MEDIUM (1-2 weeks)

### Option 3: Keep Current Setup (Digital Ocean)

**Pros:**
- ✅ Already working and deployed
- ✅ No migration effort
- ✅ Full control over infrastructure
- ✅ No vendor limits or cold starts
- ✅ All services in one place

**Cons:**
- ⚠️ Costs ~$40-100/month for droplet + bandwidth
- ⚠️ Manual scaling (can't auto-scale easily)
- ⚠️ Single point of failure (one droplet)

**Complexity**: NO EFFORT

---

## Detailed Implementation Plan (Option 1: Hybrid)

### Phase 1: Prepare Shop App for External Hosting (1-2 hours)

**Goal**: Make the shop frontend independent of backend location

#### Step 1.1: Add API Base URL Configuration
**File**: `apps/shop/.env.production`
```env
# Add this line
VITE_API_BASE_URL=https://app.proofbound.com
```

**File**: `apps/shop/.env.development` (for local testing)
```env
# Add this line
VITE_API_BASE_URL=http://localhost:8000
```

#### Step 1.2: Update API Client to Use Base URL
**File**: `apps/shop/src/lib/api.ts` (or wherever API calls are made)

Find all fetch calls like:
```typescript
fetch('/api/shop/checkout', ...)
```

Replace with:
```typescript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';
fetch(`${API_BASE_URL}/api/shop/checkout`, ...)
```

**Critical**: Search for ALL API calls in the shop app:
- `grep -r "fetch(" apps/shop/src/`
- `grep -r "axios" apps/shop/src/` (if using axios)
- Look in: `apps/shop/src/lib/`, `apps/shop/src/components/`, `apps/shop/src/pages/`

#### Step 1.3: Update Supabase Client Configuration
**File**: `apps/shop/src/lib/supabase.ts` (or similar)

Verify that Supabase client uses:
```typescript
const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
```

This should already be environment-based (no changes needed, just verify).

### Phase 2: Configure Backend for CORS (30 minutes)

**Goal**: Allow shop.proofbound.com (on Netlify/Vercel) to call app.proofbound.com APIs

#### Step 2.1: Update Nginx CORS Headers
**File**: `packages/nginx/nginx.conf` (in monorepo)

Find the API location blocks and add CORS headers:
```nginx
# Add to each API location block (or add globally in server block)
location /api/ {
    # Existing proxy_pass directives...

    # Add CORS headers
    add_header 'Access-Control-Allow-Origin' 'https://shop.proofbound.com' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, apikey, x-client-info' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;

    # Handle preflight requests
    if ($request_method = 'OPTIONS') {
        return 204;
    }

    # Existing proxy_pass...
}
```

**Important**: You may need to add CORS to multiple location blocks:
- `/api/shop/*` (shop checkout)
- `/api/print/*` (print orders)
- Any other APIs the shop uses

#### Step 2.2: Redeploy Backend with CORS Changes
```bash
# In monorepo
git add packages/nginx/nginx.conf
git commit -m "Add CORS headers for shop.proofbound.com on Netlify"
git push origin master

# Wait for CI/CD to deploy (~5 minutes)
```

### Phase 3: Set Up Netlify (Recommended) or Vercel (45 minutes)

**Why Netlify over Vercel?**
- Simpler configuration for static sites
- Better free tier for low-traffic sites
- Easier redirect/rewrite rules

#### Step 3.1: Create Netlify Configuration
**File**: `apps/shop/netlify.toml` (create new file)
```toml
[build]
  base = "apps/shop"
  command = "npm run build"
  publish = "dist"

[build.environment]
  NODE_VERSION = "20"

# Redirect SPA routes to index.html (for client-side routing)
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

# Security headers
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
```

#### Step 3.2: Create Netlify Site
1. Go to [netlify.com](https://netlify.com) and sign in with GitHub
2. Click "Add new site" → "Import an existing project"
3. Choose GitHub and authorize Netlify
4. Select repository: `Proofbound/proofbound-monorepo`
5. Configure build settings:
   - **Base directory**: `apps/shop`
   - **Build command**: `npm run build`
   - **Publish directory**: `apps/shop/dist`
   - **Branch to deploy**: `master`
6. Click "Deploy site"

#### Step 3.3: Add Environment Variables in Netlify
In Netlify site settings → Environment variables, add:
```
VITE_API_BASE_URL=https://app.proofbound.com
VITE_SUPABASE_URL=https://[your-project].supabase.co
VITE_SUPABASE_ANON_KEY=[your-anon-key]
VITE_STRIPE_PUBLISHABLE_KEY=[your-stripe-key]
```

**Get these values from**:
- Current deployment (check existing environment)
- Or from `apps/shop/.env.production` in monorepo

#### Step 3.4: Test Netlify Preview Deployment
After first deploy (2-5 minutes):
1. Visit the Netlify preview URL (e.g., `https://[random-name].netlify.app`)
2. Test the shop:
   - [ ] Homepage loads
   - [ ] Book catalog displays
   - [ ] Click on a book to see details
   - [ ] Test "Add to Cart" functionality
   - [ ] Test checkout flow (use Stripe test mode)
3. Check browser console for CORS errors
4. If CORS errors appear, revisit Phase 2 (nginx CORS config)

### Phase 4: DNS Configuration (15 minutes)

**Goal**: Point shop.proofbound.com to Netlify

#### Step 4.1: Get Netlify DNS Target
In Netlify site settings → Domain management:
1. Click "Add custom domain"
2. Enter: `shop.proofbound.com`
3. Netlify will provide a DNS target (either A record or CNAME)

**Typical Netlify DNS:**
- **CNAME**: `[your-site-name].netlify.app`
- **Or A record**: Netlify load balancer IP

#### Step 4.2: Update Cloudflare DNS
In Cloudflare (proofbound.com domain):
1. Go to DNS settings
2. Find existing record: `shop.proofbound.com → 143.110.145.237` (A record)
3. **Delete** the old A record
4. **Create** new CNAME record:
   - **Type**: CNAME
   - **Name**: shop
   - **Target**: `[your-site-name].netlify.app`
   - **Proxy status**: DNS only (gray cloud, NOT proxied)
   - **TTL**: Auto
5. Save changes

**Important**: DNS propagation takes 5-60 minutes. Use [whatsmydns.net](https://www.whatsmydns.net) to check.

#### Step 4.3: Verify SSL Certificate
After DNS propagates:
1. Netlify will auto-provision Let's Encrypt SSL certificate
2. Visit `https://shop.proofbound.com`
3. Verify green padlock (SSL active)
4. If SSL fails, wait 30 minutes and check Netlify SSL status

### Phase 5: Testing & Validation (1-2 hours)

**Goal**: Ensure shop works exactly as before

#### Test Checklist:
- [ ] **Homepage**: Visit `https://shop.proofbound.com`
- [ ] **Book Catalog**: Featured books load from database
- [ ] **Community Books**: Dynamic catalog loads from Supabase
- [ ] **Book Details**: Click on a book, details page loads
- [ ] **Add to Cart**: Add book to cart, cart count updates
- [ ] **Checkout Flow**:
  - [ ] Fill out shipping info
  - [ ] Stripe checkout opens
  - [ ] Test payment with Stripe test card: `4242 4242 4242 4242`
  - [ ] Order confirmation page displays
  - [ ] Order email sent (check email)
- [ ] **Order Tracking**: Visit order status page, order appears
- [ ] **Mobile Responsive**: Test on mobile browser (375px width)
- [ ] **Performance**: Check page load speed (should be faster than before)
- [ ] **Console Errors**: Open browser dev tools, check for errors

#### Test Payment with Stripe Test Mode:
```
Card Number: 4242 4242 4242 4242
Expiry: 12/34
CVC: 123
ZIP: 12345
```

#### Verify Backend Integration:
```bash
# SSH into Digital Ocean droplet
ssh root@143.110.145.237

# Check nginx logs for shop API requests
docker logs -f proofbound-nginx

# Should see requests from shop.proofbound.com with CORS headers
```

### Phase 6: Update Docker Compose (30 minutes)

**Goal**: Remove shop container from Digital Ocean (save resources)

#### Step 6.1: Update docker-compose.yml
**File**: `docker-compose.yml` (in monorepo root)

Find the `shop` service and **comment it out** or remove:
```yaml
# services:
#   shop:
#     build:
#       context: ./apps/shop
#       dockerfile: Dockerfile
#     ports:
#       - "5174:5174"
#     environment:
#       - VITE_API_BASE_URL=http://localhost:8000
#       - ...
#     # ... rest of shop config
```

Also update **nginx.conf** to remove shop proxy:
**File**: `packages/nginx/nginx.conf`

Find and **remove** the shop location block:
```nginx
# Remove or comment out:
# location /shop {
#     proxy_pass http://shop:5174;
#     ...
# }
```

#### Step 6.2: Redeploy Backend Without Shop
```bash
# In monorepo
git add docker-compose.yml packages/nginx/nginx.conf
git commit -m "Remove shop container (now hosted on Netlify)"
git push origin master

# Wait for CI/CD to deploy
```

#### Step 6.3: Verify Digital Ocean Resources Freed
```bash
ssh root@143.110.145.237
docker ps  # shop container should be gone
docker stats  # memory usage should be lower
```

### Phase 7: Monitor & Optimize (Ongoing)

#### Monitor Netlify Usage:
- Go to Netlify site → Analytics
- Check bandwidth usage (should be < 100GB/month for minimal traffic)
- Check build minutes (should be < 300 minutes/month)

#### Monitor Backend API Performance:
```bash
# Check nginx logs for shop API requests
docker logs -f proofbound-nginx | grep "/api/shop"

# Check for CORS errors or 429 rate limit errors
```

#### Optimize Bundle Size (Optional):
If shop gets more traffic, optimize React bundle:
```bash
cd apps/shop
npm run build -- --analyze  # See bundle size breakdown
```

- Remove unused dependencies
- Code-split large components
- Lazy-load images

---

## Critical Files to Modify

### Monorepo (proofbound-monorepo)
1. [apps/shop/.env.production](../proofbound-monorepo/apps/shop/.env.production) - Add API_BASE_URL
2. [apps/shop/src/lib/api.ts](../proofbound-monorepo/apps/shop/src/lib/api.ts) - Update fetch calls to use base URL
3. [apps/shop/netlify.toml](../proofbound-monorepo/apps/shop/netlify.toml) - Create Netlify config (NEW FILE)
4. [packages/nginx/nginx.conf](../proofbound-monorepo/packages/nginx/nginx.conf) - Add CORS headers, remove shop proxy
5. [docker-compose.yml](../proofbound-monorepo/docker-compose.yml) - Remove shop service

### Netlify Dashboard (Web Interface)
- Environment variables (VITE_* vars)
- Custom domain: shop.proofbound.com
- SSL certificate (auto-provisioned)

### Cloudflare Dashboard (Web Interface)
- DNS: Change shop.proofbound.com CNAME to Netlify

---

## Rollback Plan

If something goes wrong, you can instantly rollback:

### Immediate Rollback (< 5 minutes):
1. Go to Cloudflare DNS
2. Change `shop.proofbound.com` CNAME back to:
   - **Type**: A
   - **Name**: shop
   - **Target**: 143.110.145.237
3. Wait 5 minutes for DNS propagation
4. Shop will be back on Digital Ocean

### Full Rollback (if needed):
1. Revert `docker-compose.yml` (restore shop service)
2. Revert `packages/nginx/nginx.conf` (restore shop proxy)
3. Redeploy backend: `git push origin master`
4. Shop back on Digital Ocean at shop.proofbound.com

**No Data Loss**: All database, orders, and files stay on Supabase (unchanged).

---

## Verification Checklist

After migration is complete:

- [ ] `https://shop.proofbound.com` loads from Netlify (check Netlify dashboard)
- [ ] Book catalog displays correctly
- [ ] Checkout flow works end-to-end
- [ ] Stripe payment processes successfully
- [ ] Order confirmation email received
- [ ] Order appears in Supabase database
- [ ] No CORS errors in browser console
- [ ] SSL certificate is valid (green padlock)
- [ ] Mobile responsive layout works
- [ ] Page load speed is fast (< 2 seconds)
- [ ] Digital Ocean shop container removed (save resources)
- [ ] Netlify bandwidth usage is reasonable (< 10GB/month for minimal traffic)

---

## Cost Savings Summary

**Before Migration:**
- Digital Ocean: $40-100/month (entire stack including shop)

**After Migration:**
- Digital Ocean: $35-95/month (backend only, -$5-10 from removing shop container)
- Netlify: $0/month (free tier, 100GB bandwidth)
- **Total Savings**: $5-10/month (~$60-120/year)

**When You Might Exceed Free Tier:**
- Bandwidth > 100GB/month (unlikely with minimal traffic)
- Build minutes > 300/month (only if deploying multiple times per day)
- If exceeded, Netlify Pro is $19/month (still competitive)

---

## Success Criteria

Migration is successful when:
1. ✅ Shop loads from Netlify at shop.proofbound.com
2. ✅ All shop features work (catalog, checkout, payments)
3. ✅ No CORS errors or API failures
4. ✅ Digital Ocean resources freed (shop container removed)
5. ✅ Cost reduced by $5-10/month
6. ✅ Performance improved (faster page loads via CDN)

---

**Last Updated**: January 28, 2026
**Status**: Ready for implementation
