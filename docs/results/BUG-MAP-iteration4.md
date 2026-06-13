# 🗺️ BUG-MAP: Iteration 4 — 45 Non-Security Bugs (9 Dimensions)

**Proje:** `/home/user/iteration-test-4/` (Express 5 ShopApp)
**Toplam Bug:** 45
**Hedef:** ≥36/45 (%80) fix rate

---

## ⚡ Performance (6 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| P1 | No pagination | `src/server.js` | GET /api/products | Tüm ürünler döndürülüyor, page/limit yok |
| P2 | N+1 reviews query | `src/server.js` | GET /api/products/:id | Her review için ayrı getReviewById + getUserById |
| P3 | Inefficient sort | `src/server.js` | sort=="price" bloğu | 3 satırlık karşılaştırma yerine `a.price - b.price` |
| P4 | Sync DB loop | `src/server.js` | POST /api/orders | for loop içinde getProductById (sync) |
| P5 | JS counting | `src/server.js` | GET /api/admin/stats | getAllProducts/Orders/Users → .length / .reduce |
| P6 | Sync file write | `src/server.js` | POST /api/orders | `fs.writeFileSync` → async olmalı |

## 🔍 Code Quality (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| KQ1 | Unused `filteredOrders` | `src/server.js` | GET /api/orders | `const filteredOrders = orders;` kullanılmıyor |
| KQ2 | No rating validation | `src/server.js` | POST /api/products/:id/reviews | Rating 1-5 aralığı kontrol edilmiyor |
| KQ3 | Magic numbers | `src/server.js` | POST /api/orders | `0.1`, `0.05`, `1000` hardcoded |
| KQ4 | Error handler loses status | `src/server.js` | Global error handler | Her zaman 500, orijinal status kaybolur |
| KQ5 | Fragile counter pattern | `src/config/database.js` | Global counters | userIdCounter++, race condition riskli |

## 🏗️ Architecture (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| AR1 | Business logic in route | `src/server.js` | POST /api/orders | Discount hesaplama route handler'da |
| AR2 | Fat controller | `src/server.js` | POST /api/orders | Email + file write + log hepsi route'ta |
| AR3 | Global state db | `src/config/database.js` | Module scope | Tüm veriler module-scope array'lerde |
| AR4 | Hardcoded config | `src/server.js` | 1000, 0.1, 0.05 | Config değerleri env'den okunmuyor |
| AR5 | Inconsistent error handling | `src/server.js` | Various | Bazı endpoint'ler try/catch, bazıları yok |

## 🧪 Test (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| T1 | Zero tests | `package.json` | scripts.test | Test yok, `"test": "echo \"Error: no test specified\" && exit 1"` |
| T2 | CI broken | `.github/workflows/ci.yml` | npm test | CI `npm test` çalıştırıyor ama test yok → fail |
| T3 | No test framework | `package.json` | devDependencies | Jest/Vitest kurulu değil |
| T4 | No edge case tests | — | — | Boş input, null, boundary testleri yok |
| T5 | No integration tests | — | — | API endpoint testleri yok |

## ♿ Accessibility (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| A1 | No label-input binding | `public/index.html` | Login form | `<input id="login-email">` için `<label>` yok |
| A2 | Modal not keyboard dismissable | `public/index.html` | Modals | ESC ile kapanmıyor |
| A3 | Placeholder img alt="" | `public/index.html` | JS template | Placeholder görseli için anlamlı alt yok |
| A4 | Select dropdowns no labels | `public/index.html` | category/sort filter | `<select>` için `<label>` yok |
| A5 | No ARIA live regions | `public/index.html` | products div | Dinamik içerik değişimi duyurulmuyor |

## 🎨 UX (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| U1 | No review submit feedback | `public/index.html` | submitReview() | Submit sonrası success/error mesajı yok |
| U2 | Cart button non-functional | `public/index.html` | cart-btn | Sepet butonu hiçbir şey yapmıyor |
| U3 | Login modal doesn't update UI | `public/index.html` | Login sonrası | Login olunca UI güncellenmiyor |
| U4 | No responsive design | `public/index.html` | CSS | Media query yok, mobil uyumsuz |
| U5 | Logout button visibility | `public/index.html` | logout-btn | Auth state'e göre göster/gizle yapılmıyor (hardcoded display:none) |

## 🚀 DevOps (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| D1 | Dockerfile runs as root | `Dockerfile` | — | `USER` directive yok |
| D2 | COPY . . includes .env | `Dockerfile` | — | `.dockerignore` yok, .env image'da |
| D3 | No health check endpoint | `src/server.js` | — | `/health` endpoint yok |
| D4 | CI broken (no test script) | `.github/workflows/ci.yml` | — | npm test = exit 1 |
| D5 | No staging/prod config | — | — | NODE_ENV bazlı config ayrımı yok |

## 🔎 SEO (5 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| S1 | No meta description | `public/index.html` | <head> | `<meta name="description">` yok |
| S2 | No canonical URL | `public/index.html` | <head> | `<link rel="canonical">` yok |
| S3 | No Open Graph tags | `public/index.html` | <head> | `og:title`, `og:description`, `og:image` yok |
| S4 | No structured data | `public/index.html` | — | JSON-LD schema yok |
| S5 | No semantic HTML | `public/index.html` | Body | `<div>` soup, `<nav>`, `<main>`, `<header>`, `<footer>` kullanılmamış |

## 📚 Documentation (4 bugs)

| # | Bug | Dosya | Satır | Açıklama |
|---|-----|-------|:-----:|----------|
| DOC1 | No README.md | — | — | Proje kökünde README yok |
| DOC2 | No API docs | — | — | Endpoint dokümantasyonu yok |
| DOC3 | Insufficient inline comments | `src/server.js` | — | Karmaşık logic'lere yorum yok |
| DOC4 | No CONTRIBUTING.md | — | — | Katkı rehberi yok |

---

## Scoring Matrix

| Dimension | Bugs | Target (≥80%) | Min Fix |
|-----------|:----:|:------------:|:-------:|
| Performance | 6 | 80% | 5/6 |
| Code Quality | 5 | 80% | 4/5 |
| Architecture | 5 | 80% | 4/5 |
| Test | 5 | 80% | 4/5 |
| Accessibility | 5 | 80% | 4/5 |
| UX | 5 | 80% | 4/5 |
| DevOps | 5 | 80% | 4/5 |
| SEO | 5 | 80% | 4/5 |
| Documentation | 4 | 80% | 4/4 (100%) |
| **TOTAL** | **45** | **≥36/45** | **36** |
