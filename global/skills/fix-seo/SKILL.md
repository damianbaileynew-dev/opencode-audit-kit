---
name: fix-seo
description: >-
  SEO fix skill. SEO audit'ten gelen güvenli sorunları düzeltir.
  Meta description, canonical URL, Open Graph tags, JSON-LD structured data, semantic HTML.
  Trigger: "fix seo", "seo fix", "düzelt seo", "onar seo", "seo iyileştir"
---

# Skill: SEO Fix

**Amaç:** SEO audit'ten gelen güvenli, düşük riskli arama motoru optimizasyonu sorunlarını düzelt.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Meta description ekleme** — `<meta name="description" content="...">`
- **Canonical URL ekleme** — `<link rel="canonical" href="...">`
- **Open Graph tags ekleme** — `og:title`, `og:description`, `og:image`, `og:url`
- **JSON-LD structured data** — Ürün/site schema markup'ı
- **Semantic HTML** — `<div>` → `<nav>`, `<main>`, `<section>`, `<article>`, `<header>`, `<footer>`
- **Heading hierarchy** — Tekil `<h1>`, mantıklı h1→h2→h3 sırası
- **Title tag optimization** — Sayfa başlığını descriptive yapma
- **robots.txt oluşturma** — Arama motoru erişim kuralları

### ❌ Onay Gerekli
- Sitemap.xml oluşturma
- URL structure değiştirme
- İçerik stratejisi
- hreflang tags (çok dilli site)
- AMP sayfaları

---

## Adım 1: Raporları Oku

```
read("reports/seo/seo-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Semantic HTML (div soup), title tag
- **P1:** Meta description, Open Graph, **canonical URL (ZORUNLU)**
- **P2:** JSON-LD, heading hierarchy, robots.txt

### ⚠️ MUTLAKA YAPILACAKLAR (atlanmamalı):
1. `<meta name="description" content="...">` — ZORUNLU
2. `<link rel="canonical" href="https://example.com/">` — **ZORUNLU, atlama!**
3. Open Graph tags: `og:title`, `og:description`, `og:type`, `og:url`, `og:image` — ZORUNLU
4. 🚨 **JSON-LD structured data — ZORUNLU, KESİNLİKLE ATLAMA!** `<script type="application/ld+json">` etiketi `</body>` öncesine eklenmeli
5. Semantic HTML: `<header>`, `<nav>`, `<main>`, `<footer>` — ZORUNLU
6. 🚨 **`public/robots.txt` dosyası oluşturma — ZORUNLU, KESİNLİKLE ATLAMA!** `write()` ile dosya yazılmalı

## Adım 3: Fix Şablonları

### Meta Description
```html
<!-- YANLIŞ: Meta description yok -->
<head>
  <meta charset="UTF-8">
  <title>ShopApp — En İyi Ürünler</title>
</head>

<!-- DOĞRU: Meta description ekle -->
<head>
  <meta charset="UTF-8">
  <title>ShopApp — En İyi Ürünler</title>
  <meta name="description" content="ShopApp ile en kaliteli ürünleri uygun fiyatlarla keşfedin. Elektronik, giyim, kitap ve daha fazlası.">
</head>
```

### Canonical URL + Open Graph
```html
<head>
  <meta charset="UTF-8">
  <title>ShopApp — En İyi Ürünler</title>
  <meta name="description" content="ShopApp ile en kaliteli ürünleri uygun fiyatlarla keşfedin.">
  <link rel="canonical" href="https://shopapp.example.com/">
  
  <!-- Open Graph -->
  <meta property="og:title" content="ShopApp — En İyi Ürünler">
  <meta property="og:description" content="ShopApp ile en kaliteli ürünleri uygun fiyatlarla keşfedin.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://shopapp.example.com/">
  <meta property="og:image" content="https://shopapp.example.com/img/og-image.png">
  <meta property="og:locale" content="tr_TR">
  <meta property="og:site_name" content="ShopApp">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="ShopApp — En İyi Ürünler">
  <meta name="twitter:description" content="ShopApp ile en kaliteli ürünleri uygun fiyatlarla keşfedin.">
</head>
```

### JSON-LD Structured Data
```html
<!-- Body'nin sonuna, </body> öncesine ekle -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "ShopApp",
  "url": "https://shopapp.example.com",
  "description": "En kaliteli ürünleri uygun fiyatlarla keşfedin",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "https://shopapp.example.com/search?q={search_term_string}",
    "query-input": "required name=search_term_string"
  }
}
</script>
```

### Semantic HTML (Div Soup → Semantic)
```html
<!-- YANLIŞ: Div soup -->
<div class="header">...</div>
<div class="filters">...</div>
<div id="products" class="product-grid"></div>
<div class="footer">...</div>

<!-- DOĞRU: Semantic HTML -->
<header class="header">...</header>
<nav class="filters" aria-label="Ürün filtreleri">...</nav>
<main>
  <section id="products" class="product-grid" aria-label="Ürün listesi"></section>
</main>
<footer class="footer">...</footer>
```

### robots.txt
```
User-agent: *
Allow: /
Disallow: /api/
Disallow: /admin/

Sitemap: https://shopapp.example.com/sitemap.xml
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. **Mevcut CSS/JS'in bozulmadığını kontrol et** (class isimleri değişmemeli)
4. Her fix sonrası dosyayı tekrar oku

### 🚨 ADIM 4.5: SEO Doğrulama (ZORUNLU — ATLAMA!)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap:

```bash
# JSON-LD structured data var mı?
grep -q 'application/ld+json' public/index.html || echo "❌ KRİTİK: JSON-LD structured data YOK — HEMEN ekle!"

# 🚨 robots.txt dosyası var mı? ZORUNLU!
test -f public/robots.txt || echo "❌ KRİTİK: public/robots.txt YOK — HEMEN write() ile oluştur!"

# Meta description var mı?
grep -q 'name="description"' public/index.html || echo "❌ KRİTİK: Meta description YOK!"

# Canonical URL var mı?
grep -q 'rel="canonical"' public/index.html || echo "❌ KRİTİK: Canonical URL YOK!"

# Open Graph tags var mı?
grep -q 'og:title' public/index.html || echo "❌ KRİTİK: OG tags YOK!"

# Semantic HTML var mı?
grep -q '<header\|<main\|<section\|<article\|<nav\|<footer' public/index.html || echo "❌ KRİTİK: Semantic HTML YOK!"
```

🚨🚨🚨 **EĞER robots.txt YOKSA → HEMEN `write("public/robots.txt", ...)` ile oluştur! ATLAMA!**

**robots.txt — HEMEN uygula:**
```
User-agent: *
Allow: /
Disallow: /api/
Disallow: /admin/

Sitemap: https://taskflow.app/sitemap.xml
```

**EĞER JSON-LD YOKSA → HEMEN `edit()` ile `</body>` öncesine `<script type="application/ld+json">` ekle!**

**SEO fix'in tamamlanmış sayılması için:**
1. ✅ `<meta name="description">` mevcut
2. ✅ `<link rel="canonical">` mevcut
3. ✅ OG tags (`og:title`, `og:description`, `og:type`) mevcut
4. ✅ `<script type="application/ld+json">` mevcut
5. ✅ Semantic HTML elementleri kullanılmış (`<header>`, `<nav>`, `<main>`, `<footer>`)
6. ✅ `public/robots.txt` dosyası mevcut

## Adım 5: Rapor Yaz

`reports/seo/seo-fix-YYYYMMDD.md`:

```markdown
# 🔍 SEO Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | Etki |
|---|-------|-------|-----|------|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## SEO Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Meta Tags Eklendi:** X adet
- **Structured Data:** WebSite schema
- **Semantic HTML:** X element düzeltildi
- **Sonraki Ajan İçin Öneri:** Documentation audit'e geç
```

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "SEO isn't important for internal tools" | Internal tools still get searched. Intranet search, knowledge bases, and documentation all benefit from proper SEO. |
| "Meta descriptions don't affect ranking" | They affect click-through rate, which affects traffic. A good meta description can double your CTR. |
| "JSON-LD is too complex" | JSON-LD is just a script tag with structured data. It's 10 lines of JSON that makes your site eligible for rich results. |
| "We don't need a robots.txt" | Without robots.txt, crawlers index everything including API endpoints and admin pages. It's 3 lines of configuration. |
| "Semantic HTML doesn't matter" | Search engines use semantic HTML to understand page structure. `<article>` means more than `<div class="article">`. |
| "Canonical URLs aren't needed for single-page sites" | Canonical URLs prevent duplicate content issues from www/non-www, HTTP/HTTPS, and trailing slash variations. |

## Red Flags

- 🔴 No meta description tag
- 🔴 No canonical URL
- 🔴 No Open Graph tags (broken social sharing)
- 🔴 No JSON-LD structured data
- 🔴 Div soup instead of semantic HTML (header, nav, main, footer)
- 🔴 No robots.txt
- 🔴 Multiple `<h1>` tags on a single page
- 🔴 Missing or duplicate title tags
