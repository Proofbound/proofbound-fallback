#!/bin/bash
# Local testing helper for Proofbound marketing site
# Opens all pages in default browser for visual inspection

echo "🧪 Opening all marketing pages for testing..."
echo ""

pages=(
  "index.html"
  "how-it-works.html"
  "service-tiers.html"
  "faq.html"
  "elite-service.html"
  "privacy.html"
  "terms.html"
  "textkeep.html"
)

for page in "${pages[@]}"; do
  if [ -f "$page" ]; then
    echo "✓ Opening $page"
    open "$page"
    sleep 0.5  # Brief delay to avoid overwhelming browser
  else
    echo "✗ Missing $page"
  fi
done

echo ""
echo "📋 Testing checklist:"
echo "  [ ] TextKeep banner appears on all pages"
echo "  [ ] Navigation links work between pages"
echo "  [ ] Footer links are consistent"
echo "  [ ] Typing animation works (index.html)"
echo "  [ ] FAQ accordion expands/collapses (faq.html)"
echo "  [ ] All CTAs link correctly (Try for Free → app.proofbound.com/signup)"
echo "  [ ] Mobile responsive (resize browser to ~375px width)"
echo "  [ ] Glass-morphism cards render correctly"
echo "  [ ] No broken images or missing assets"
echo ""
echo "💡 Tip: Use Chrome DevTools (Cmd+Opt+I) to test mobile views"
echo "💡 Tip: Right-click and 'Inspect' to check console for errors"
