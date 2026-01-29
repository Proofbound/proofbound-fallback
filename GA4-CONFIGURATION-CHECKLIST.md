# Google Analytics 4 Configuration Checklist

## Overview

This checklist ensures proper cross-domain tracking for all Proofbound domains. All sites now have cross-domain tracking configured in code. Complete these admin steps in GA4 to finalize the setup.

**GA4 Property ID:** `G-08CE0H3LRL`

**Domains:**
- proofbound.com (marketing site)
- app.proofbound.com (main application)
- shop.proofbound.com (shop application)

---

## ✅ Code Changes (COMPLETED)

- [x] Updated all marketing site HTML files with linker configuration
- [x] Updated monorepo analytics.ts with linker configuration
- [x] Updated shop/index.html with linker configuration
- [x] Updated main-app/frontend/index.html with linker configuration

---

## 🔧 GA4 Admin Configuration (DO THIS NOW)

### Step 1: Configure Referral Exclusions

Prevent your own domains from showing up as referral sources.

1. Go to [Google Analytics 4](https://analytics.google.com/)
2. Select your Proofbound property (G-08CE0H3LRL)
3. Click **Admin** (gear icon, bottom left)
4. In the **Data Streams** section, click on your web data stream
5. Click **Configure tag settings** → **Show more**
6. Click **List unwanted referrals**
7. Click **Add domain**
8. Add each domain (one at a time):
   - `proofbound.com`
   - `app.proofbound.com`
   - `shop.proofbound.com`
9. Click **Save**

**Why this matters:** Without this, traffic from proofbound.com → app.proofbound.com will show as "referral" traffic instead of preserving the original source (organic, direct, etc.).

---

### Step 2: Verify Cross-Domain Measurement

Ensure GA4 properly tracks users across domains.

1. In **Admin** → **Data Streams** → Your web stream
2. Click **Configure tag settings** → **Show more**
3. Look for **Configure your domains** section
4. Verify that cross-domain measurement is enabled
5. If not enabled, follow the prompts to enable it

**Note:** The linker configuration in your code handles most of this automatically, but verify it's enabled in GA4 admin.

---

### Step 3: Create Custom Reports (Optional but Recommended)

Set up reports to monitor each domain separately.

#### Option A: Use Hostname Dimension in Standard Reports

1. Go to **Reports** → **Engagement** → **Pages and screens**
2. Click the pencil icon (customize report)
3. Add dimension: **Hostname**
4. Now you can filter by:
   - `proofbound.com` (marketing)
   - `app.proofbound.com` (main app)
   - `shop.proofbound.com` (shop)

#### Option B: Create Segments for Each Domain

1. Go to **Explore** → **Create a new exploration**
2. Click **+ (Create segment)**
3. Create three segments:
   - **Marketing Site**: Hostname contains `proofbound.com` (but not `app.` or `shop.`)
   - **Main App**: Hostname contains `app.proofbound.com`
   - **Shop**: Hostname contains `shop.proofbound.com`
4. Use these segments to compare traffic across domains

---

### Step 4: Test Cross-Domain Tracking

Verify that everything is working correctly.

1. Open an incognito/private browser window
2. Visit `https://proofbound.com`
3. Open browser DevTools → Console
4. Check for GA4 debug info (or use GA Debugger extension)
5. Click a link to `app.proofbound.com` or `shop.proofbound.com`
6. Verify the URL contains `_gl` parameter (this is the linker parameter)
   - Example: `https://app.proofbound.com?_gl=1*abc123...`
7. Check that GA4 tracks this as the same session (not a new one)

**Using GA4 DebugView (Recommended):**

1. In GA4, go to **Admin** → **DebugView**
2. In your browser, add `?debug_mode=true` to any URL
3. Navigate between domains and watch DebugView in real-time
4. Verify:
   - Session ID stays the same across domains
   - User ID stays the same
   - Original source/medium is preserved

---

## 🎯 Success Criteria

Your cross-domain tracking is working correctly when:

- [ ] Users navigating from proofbound.com → app.proofbound.com show as the **same session** in GA4
- [ ] Original traffic source (Google Organic, Direct, etc.) is **preserved** across domains
- [ ] proofbound.com does **NOT** show up in your "Referrals" report
- [ ] app.proofbound.com and shop.proofbound.com do **NOT** show up in "Referrals"
- [ ] You can filter reports by hostname to see traffic for each domain separately

---

## 📊 What You'll See After Configuration

### Before (Without Cross-Domain Tracking)
```
Session 1: User visits proofbound.com
  Source: Google Organic
  Pages: /index.html, /how-it-works.html

Session 2: User clicks "Try for Free" → app.proofbound.com
  Source: proofbound.com (Referral) ❌ WRONG
  Pages: /signup, /dashboard
```

### After (With Cross-Domain Tracking)
```
Session 1: User visits proofbound.com → app.proofbound.com
  Source: Google Organic ✅ CORRECT
  Pages: /index.html, /how-it-works.html, /signup, /dashboard
  Domains: proofbound.com, app.proofbound.com
```

---

## 🔍 Troubleshooting

### Issue: Still seeing self-referrals

**Solution:** Check that:
1. Referral exclusions are saved in GA4 admin
2. Code changes are deployed to production
3. Browser cache is cleared (test in incognito mode)
4. Wait 24-48 hours for GA4 to process changes

### Issue: Sessions breaking between domains

**Solution:** Check that:
1. All domains have the same GA4 measurement ID (G-08CE0H3LRL)
2. Linker configuration includes all domains
3. Links between sites use absolute URLs (https://...)
4. No redirects are stripping the `_gl` parameter

### Issue: Can't see hostname in reports

**Solution:**
1. Add "Hostname" as a secondary dimension in reports
2. Or create custom explorations with hostname dimension
3. Or use comparison filters to separate domains

---

## 📝 Additional Resources

- [GA4 Cross-Domain Tracking Guide](https://support.google.com/analytics/answer/10071811)
- [How to Set Up Referral Exclusions](https://support.google.com/analytics/answer/10327750)
- [Testing Cross-Domain Tracking](https://support.google.com/analytics/answer/11583876)

---

## ✉️ Questions?

Contact: info@proofbound.com

---

**Last Updated:** January 28, 2026
**Status:** Code changes complete, GA4 admin configuration pending
