---
name: performance-audit
description: >-
  Performance audit skill. Core Web Vitals (LCP, INP, CLS), resource optimization, loading strategy.
  Triggers: "performance audit", "core web vitals", "page speed", "optimize", "loading"
---
---
name: core-web-vitals
description: Optimize Core Web Vitals (LCP, INP, CLS) for better page experience and search ranking. Use when asked to "improve Core Web Vitals", "fix LCP", "reduce CLS", "optimize INP", "page experience optimization", or "fix layout shifts".
license: MIT
metadata:
  author: web-quality-skills
  version: "1.0"
---

# Core Web Vitals optimization

Targeted optimization for the three Core Web Vitals metrics that affect Google Search ranking and user experience.

## The three metrics

| Metric | Measures | Good | Needs work | Poor |
|--------|----------|------|------------|------|
| **LCP** | Loading | ≤ 2.5s | 2.5s – 4s | > 4s |
| **INP** | Interactivity | ≤ 200ms | 200ms – 500ms | > 500ms |
| **CLS** | Visual Stability | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |

Google measures at the **75th percentile** — 75% of page visits must meet "Good" thresholds.

---

## LCP: Largest Contentful Paint (≤ 2.5s)

LCP measures when the largest visible content element renders. Key fixes:
- Preload LCP image with `fetchpriority="high"`
- Optimize server response (TTFB < 800ms)
- Inline critical CSS, defer non-critical
- Ensure LCP element in initial HTML (not JS-rendered)

→ **Full LCP guide with code examples**: `references/core-web-vitals-detail.md`

## INP: Interaction to Next Paint (≤ 200ms)

INP measures responsiveness across all interactions. Key fixes:
- Break long tasks into chunks, yield with `scheduler.yield()`
- Provide immediate visual feedback on interaction
- Lazy-load third-party scripts
- Memoize expensive React/Vue components

→ **Full INP guide with code examples**: `references/core-web-vitals-detail.md`

## CLS: Cumulative Layout Shift (≤ 0.1)

CLS measures unexpected layout shifts. Key fixes:
- Set explicit `width` and `height` on images/videos
- Reserve space for dynamic content (CSS `aspect-ratio`)
- Use `font-display: swap` with size-adjusted fallbacks
- Insert content before existing content with CSS `contain`

→ **Full CLS guide with code examples**: `references/core-web-vitals-detail.md`

## Measurement tools

### Lab testing
- **Chrome DevTools** → Performance panel, Lighthouse
- **WebPageTest** → Detailed waterfall, filmstrip
- **Lighthouse CLI** → `npx lighthouse <url>`

### Field data (real users)
- **Chrome User Experience Report (CrUX)** → BigQuery or API
- **Search Console** → Core Web Vitals report
- **web-vitals library** → Send to your analytics

```javascript
import {onLCP, onINP, onCLS} from 'web-vitals';

function sendToAnalytics({name, value, rating}) {
  gtag('event', name, {
    event_category: 'Web Vitals',
    value: Math.round(name === 'CLS' ? value * 1000 : value),
    event_label: rating
  });
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);
```

---

## Framework quick fixes

### Next.js
```jsx
// LCP: Use next/image with priority
import Image from 'next/image';
<Image src="/hero.jpg" priority fill alt="Hero" />

// INP: Use dynamic imports
const HeavyComponent = dynamic(() => import('./Heavy'), { ssr: false });

// CLS: Image component handles dimensions automatically
```

### React
```jsx
// LCP: Preload in head
<link rel="preload" href="/hero.jpg" as="image" fetchpriority="high" />

// INP: Memoize and useTransition
const [isPending, startTransition] = useTransition();
startTransition(() => setExpensiveState(newValue));

// CLS: Always specify dimensions in img tags
```

### Vue/Nuxt
```vue
<!-- LCP: Use nuxt/image with preload -->
<NuxtImg src="/hero.jpg" preload loading="eager" />

<!-- INP: Use async components -->
<component :is="() => import('./Heavy.vue')" />

<!-- CLS: Use aspect-ratio CSS -->
<img :style="{ aspectRatio: '16/9' }" />
```

## References

- [web.dev LCP](https://web.dev/articles/lcp)
- [web.dev INP](https://web.dev/articles/inp)
- [web.dev CLS](https://web.dev/articles/cls)
- [Performance skill](../performance/SKILL.md)
---
name: performance
description: Optimize web performance for faster loading and better user experience. Use when asked to "speed up my site", "optimize performance", "reduce load time", "fix slow loading", "improve page speed", or "performance audit".
license: MIT
metadata:
  author: web-quality-skills
  version: "1.0"
---

# Performance optimization

Deep performance optimization based on Lighthouse performance audits. Focuses on loading speed, runtime efficiency, and resource optimization.

## How it works

1. Identify performance bottlenecks in code and assets
2. Prioritize by impact on Core Web Vitals
3. Provide specific optimizations with code examples
4. Measure improvement with before/after metrics

## Performance budget

| Resource | Budget | Rationale |
|----------|--------|-----------|
| Total page weight | < 1.5 MB | 3G loads in ~4s |
| JavaScript (compressed) | < 300 KB | Parsing + execution time |
| CSS (compressed) | < 100 KB | Render blocking |
| Images (above-fold) | < 500 KB | LCP impact |
| Fonts | < 100 KB | FOIT/FOUT prevention |
| Third-party | < 200 KB | Uncontrolled latency |

## Critical rendering path

### Server response
* **TTFB < 800ms.** Time to First Byte should be fast. Use CDN, caching, and efficient backends.
* **Enable compression.** Gzip or Brotli for text assets. Brotli preferred (15-20% smaller).
* **HTTP/2 or HTTP/3.** Multiplexing reduces connection overhead.
* **Edge caching.** Cache HTML at CDN edge when possible.
* **Send Early Hints (HTTP 103) for slow origins.** When the origin needs hundreds of milliseconds to assemble the final response, return a `103 Early Hints` with `Link: </hero.webp>; rel=preload; as=image` (and similar for critical CSS/fonts) so the browser starts fetching before the `200 OK` lands. Cloudflare reports [20–30% LCP improvements](https://blog.cloudflare.com/early-hints-performance/) on image-heavy pages. Requires HTTP/2+ and is supported by Chromium-based browsers; other browsers ignore the 103 and fall through to the 200 — safe to enable. CDNs (Cloudflare, Fastly, Akamai) can synthesize 103s automatically from prior responses; on your own origin, emit them from the same handler that issues the 200.

### Resource loading

**Preconnect to required origins:**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com" crossorigin>
```

**Preload critical resources:**
```html
<!-- LCP image -->
<link rel="preload" href="/hero.webp" as="image" fetchpriority="high">

<!-- Critical font -->
<link rel="preload" href="/font.woff2" as="font" type="font/woff2" crossorigin>
```

**Prerender likely-next navigations** with the [Speculation Rules API](https://developer.chrome.com/docs/web-platform/prerender-pages):
```html
<script type="speculationrules">
{
  "prerender": [{
    "where": { "href_matches": "/*" },
    "eagerness": "moderate"
  }]
}
</script>
```
`moderate` triggers after a ~200ms hover — usually intent-correlated, rarely wasted. See [core-web-vitals → LCP](../core-web-vitals/SKILL.md#lcp-largest-contentful-paint) for the full discussion of eagerness tradeoffs and the `prerenderingchange` gating you'll need for analytics.

**Defer non-critical CSS:**
```html
<!-- Critical CSS inlined -->
<style>/* Above-fold styles */</style>

<!-- Non-critical CSS -->
<link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/styles.css"></noscript>
```

### JavaScript optimization

**Defer non-essential scripts:**
```html
<!-- Parser-blocking (avoid) -->
<script src="/critical.js"></script>

<!-- Deferred (preferred) -->
<script defer src="/app.js"></script>

<!-- Async (for independent scripts) -->
<script async src="/analytics.js"></script>

<!-- Module (deferred by default) -->
<script type="module" src="/app.mjs"></script>
```

**Code splitting patterns:**
```javascript
// Route-based splitting
const Dashboard = lazy(() => import('./Dashboard'));

// Component-based splitting
const HeavyChart = lazy(() => import('./HeavyChart'));

// Feature-based splitting
if (user.isPremium) {
  const PremiumFeatures = await import('./PremiumFeatures');
}
```

**Tree shaking best practices:**
```javascript
// ❌ Imports entire library
import _ from 'lodash';
_.debounce(fn, 300);

// ✅ Imports only what's needed
import debounce from 'lodash/debounce';
debounce(fn, 300);
```

## Image Optimization

Key patterns:
- Use WebP/AVIF with `<picture>` fallback
- Responsive images with `srcset` + `sizes`
- Lazy-load below-fold: `loading="lazy"`, `decoding="async"`
- Preload LCP image: `fetchpriority="high"`

→ **Full image optimization guide**: `references/asset-optimization.md`

## Font Optimization

Key patterns:
- Use `font-display: swap` (or `optional` for non-critical)
- Preload critical fonts: `<link rel="preload">`
- Subset fonts with `unicode-range`
- Prefer variable fonts (one file, multiple weights)

→ **Full font optimization guide**: `references/asset-optimization.md`

## Caching strategy

### Cache-Control headers
```
# HTML (short or no cache)
Cache-Control: no-cache, must-revalidate

# Static assets with hash (immutable)
Cache-Control: public, max-age=31536000, immutable

# Static assets without hash
Cache-Control: public, max-age=86400, stale-while-revalidate=604800

# API responses
Cache-Control: private, max-age=0, must-revalidate
```

### Service worker caching
```javascript
// Cache-first for static assets
self.addEventListener('fetch', (event) => {
  if (event.request.destination === 'image' ||
      event.request.destination === 'style' ||
      event.request.destination === 'script') {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return cached || fetch(event.request).then((response) => {
          const clone = response.clone();
          caches.open('static-v1').then((cache) => cache.put(event.request, clone));
          return response;
        });
      })
    );
  }
});
```

## Runtime performance

### Avoid layout thrashing
```javascript
// ❌ Forces multiple reflows
elements.forEach(el => {
  const height = el.offsetHeight; // Read
  el.style.height = height + 10 + 'px'; // Write
});

// ✅ Batch reads, then batch writes
const heights = elements.map(el => el.offsetHeight); // All reads
elements.forEach((el, i) => {
  el.style.height = heights[i] + 10 + 'px'; // All writes
});
```

### Debounce expensive operations
```javascript
function debounce(fn, delay) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
}

// Debounce scroll/resize handlers
window.addEventListener('scroll', debounce(handleScroll, 100));
```

### Use requestAnimationFrame
```javascript
// ❌ May cause jank
setInterval(animate, 16);

// ✅ Synced with display refresh
function animate() {
  // Animation logic
  requestAnimationFrame(animate);
}
requestAnimationFrame(animate);
```

### Virtualize long lists
```javascript
// For lists > 100 items, render only visible items
// Use libraries like react-window, vue-virtual-scroller, or native CSS:
.virtual-list {
  content-visibility: auto;
  contain-intrinsic-size: 0 50px; /* Estimated item height */
}
```

### Smooth navigations with View Transitions

The [View Transitions API](https://developer.chrome.com/docs/web-platform/view-transitions) lets the browser cross-fade (or custom-animate) between two DOM states using a single GPU-composited snapshot — no double-render, no layout thrash, and the snapshot doesn't count toward CLS.

**Same-document (SPA-style) — Baseline 2026:**
```javascript
// Wrap the DOM mutation that swaps the view
function navigate(newView) {
  if (!document.startViewTransition) return swapDOM(newView);
  document.startViewTransition(() => swapDOM(newView));
}
```

**Cross-document (MPA-style) — Chromium-stable, progressive enhancement elsewhere:**
```css
/* On both source and destination pages */
@view-transition { navigation: auto; }
```
That's the entire integration — same-origin navigations now fade automatically. To opt specific elements into shared-element transitions (e.g. a thumbnail expanding into a hero), give them a matching `view-transition-name`:
```css
.product-thumb[data-id="42"], .product-hero { view-transition-name: product-42; }
```

Pair this with Speculation Rules (above) for instant + animated navigations.

## Third-party scripts

### Load strategies
```javascript
// ❌ Blocks main thread
<script src="https://analytics.example.com/script.js"></script>

// ✅ Async loading
<script async src="https://analytics.example.com/script.js"></script>

// ✅ Delay until interaction
<script>
document.addEventListener('DOMContentLoaded', () => {
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      const script = document.createElement('script');
      script.src = 'https://widget.example.com/embed.js';
      document.body.appendChild(script);
      observer.disconnect();
    }
  });
  observer.observe(document.querySelector('#widget-container'));
});
</script>
```

### Facade pattern
```html
<!-- Show static placeholder until interaction -->
<div class="youtube-facade" 
     data-video-id="abc123" 
     onclick="loadYouTube(this)">
  <img src="/thumbnails/abc123.jpg" alt="Video title">
  <button aria-label="Play video">▶</button>
</div>
```

## Measurement

### Key metrics
| Metric | Target | Tool |
|--------|--------|------|
| LCP | < 2.5s | Lighthouse, CrUX |
| FCP | < 1.8s | Lighthouse |
| Speed Index | < 3.4s | Lighthouse |
| TBT | < 200ms | Lighthouse |
| TTI | < 3.8s | Lighthouse |

### Testing commands
```bash
# Lighthouse CLI
npx lighthouse https://example.com --output html --output-path report.html

# Web Vitals library
import {onLCP, onINP, onCLS} from 'web-vitals';
onLCP(console.log);
onINP(console.log);
onCLS(console.log);
```

## References

For Core Web Vitals specific optimizations, see [Core Web Vitals](../core-web-vitals/SKILL.md).

## Reference Files

For detailed checklists, see:
- **Performance Checklist**: `references/performance-checklist.md` — Bundle analysis, profiling workflow, anti-patterns
- **Testing Patterns**: `references/testing-patterns.md` — Test doubles, edge cases, naming conventions

## Where to Start Measuring

```
What is slow?
├── First page load
│   ├── Large bundle? → Measure bundle size, check code splitting
│   ├── Slow server response? → Measure TTFB in DevTools Network waterfall
│   └── Render-blocking resources? → Check network waterfall for CSS/JS blocking
├── Interaction feels sluggish
│   ├── UI freezes on click? → Profile main thread, look for long tasks (>50ms)
│   └── Animation jank? → Check layout thrashing, forced reflows
├── Backend / API
│   ├── Single endpoint slow? → Profile database queries, check indexes
│   ├── All endpoints slow? → Check connection pool, memory, CPU
│   └── Intermittent slowness? → Check for lock contention, GC pauses
```
| Rationalization | Reality |
|-----------------|---------|
| "It's fast enough on my machine" | Your machine isn't a mid-range phone on 3G. Measure on real devices with throttled networks. |
| "We'll optimize later" | Performance debt compounds. Every new feature makes optimization harder. Measure now, fix now. |
| "Pagination isn't needed for this dataset" | Datasets grow. Unbounded queries will crash when data scales. Add pagination now. |
| "Premature optimization is the root of all evil" | That quote says "premature" — measuring and adding pagination isn't premature, it's engineering. |
| "Lazy loading adds complexity" | Not lazy loading adds seconds to page load. One `loading="lazy"` attribute costs nothing. |
| "Sync file writes are fine for small data" | Small data grows. Sync writes block the event loop. Use async from the start. |

## Red Flags

- 🔴 No pagination on list/search endpoints (unbounded data fetching)
- 🔴 Synchronous file I/O in request handlers (`writeFileSync`, `readFileSync`)
- 🔴 N+1 query patterns (one DB query per item in a loop)
- 🔴 Missing `loading="lazy"` on below-fold images
- 🔴 All JavaScript loaded upfront (no code splitting)
- 🔴 No caching headers on static assets
- 🔴 Large bundle size without tree-shaking
- 🔴 Database queries without indexes on frequently filtered columns
- 🔴 Client-side aggregation of data that should be computed server-side
