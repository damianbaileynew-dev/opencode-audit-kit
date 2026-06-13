---
name: fix-performance
description: >-
  Performance fix skill. Performance audit'ten gelen güvenli sorunları düzeltir.
  Pagination, N+1 queries, inefficient sort, sync loops, JS aggregation, sync file writes.
  Trigger: "fix performance", "performance fix", "düzelt performance", "onar performance"
---

# Skill: Performance Fix

**Amaç:** Performance audit'ten gelen güvenli sorunları düzelt.
**Artı:** Her fix sonrası mevcut fonksiyonaliteyi koruduğunu doğrula.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Pagination ekleme** — `page`/`limit` query param'ları ile sonuç küçültme
- **N+1 query düzeltme** — Döngü içindeki tekil sorguları toplu sorguya çevirme
- **Inefficient sort düzeltme** — `localeCompare` veya basitleştirilmiş karşılaştırma
- **Sync DB loop → async** — `for...of` ile sıralı async veya `Promise.all` ile paralel
- **JS counting → DB aggregation** — `.length` / `.reduce` yerine DB tarafında count/sum
- **Synchronous fs.writeFile → async** — `writeFileSync` → `writeFile` veya `fs.promises.writeFile`
- **Missing pagination metadata** — `totalPages`, `hasNext`, `hasPrev` ekleme
- **Lazy loading ekleme** — IMG'lere `loading="lazy"` attribute'u
- **Bundle optimization** — Kullanılmayan import/require kaldırma

### ❌ Onay Gerekli
- Database index ekleme
- Caching layer ekleme (Redis vb.)
- Yeni bağımlılık ekleme
- Worker thread / child process ekleme
- ORM değiştirme

---

## Adım 1: Raporları Oku

```
read("reports/performance/performance-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Sync write dosya kaybı riski, N+1 query
- **P1:** Pagination eksikliği (TÜM endpoint'lerde — özellikle search endpoint'i), JS aggregation, inefficient sort
- **P2:** Lazy loading, bundle cleanup

## Adım 3: Fix Şablonları

### Pagination Ekleme (ZORUNLU — TÜM list/search endpoint'lerde)
```javascript
// YANLIŞ: Tüm ürünleri döndür
app.get('/api/products', (req, res) => {
  const products = db.getAllProducts();
  res.json({ products });
});

// YANLIŞ: Search endpoint'te pagination yok
app.get('/api/search', (req, res) => {
  const results = db.search(req.query.q);
  res.json({ results });
});

// DOĞRU: Pagination ekle (TÜM list ve search endpoint'lerde)
app.get('/api/products', (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const offset = (page - 1) * limit;
  const products = db.getAllProducts();
  const paginated = products.slice(offset, offset + limit);
  res.json({
    products: paginated,
    total: products.length,
    page,
    totalPages: Math.ceil(products.length / limit),
    hasNext: offset + limit < products.length,
    hasPrev: page > 1
  });
});

// DOĞRU: Search endpoint'te de pagination ZORUNLU
app.get('/api/search', (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const offset = (page - 1) * limit;
  const results = db.search(req.query.q);
  const paginated = results.slice(offset, offset + limit);
  res.json({
    results: paginated,
    total: results.length,
    page,
    totalPages: Math.ceil(results.length / limit),
    hasNext: offset + limit < results.length,
    hasPrev: page > 1
  });
});
```

🚨 **SEARCH ENDPOINT'TE PAGINATION ZORUNLU!** Sadece ana list endpoint'leri değil,
search endpoint'i de dahil TÜM endpoint'ler pagination'a sahip olmalı.
Arama sonuçları bile yüzlerce kayıt döndürebilir — mutlaka sınırla!

### N+1 Query Düzeltme
```javascript
// YANLIŞ: Her review için ayrı sorgu
for (const reviewId of product.reviewIds) {
  const review = db.getReviewById(reviewId);
  // ...
}

// DOĞRU: Toplu sorgu veya batch
const reviews = product.reviewIds.map(id => db.getReviewById(id)).filter(Boolean);
// VEYA: DB'de batch query fonksiyonu oluştur
```

### Inefficient Sort → Basitleştir
```javascript
// YANLIŞ: Verbose comparison
products.sort((a, b) => {
  if (a.price > b.price) return 1;
  if (a.price < b.price) return -1;
  return 0;
});

// DOĞRU: Kısa ve net
products.sort((a, b) => a.price - b.price);
// String sort:
products.sort((a, b) => a.name.localeCompare(b.name));
```

### Synchronous fs.writeFile → Async
```javascript
// YANLIŞ: Sync write — event loop'u bloklar
fs.writeFileSync(filepath, data);

// DOĞRU: Async write — event loop serbest
await fs.promises.writeFile(filepath, data);
// VEYA:
fs.writeFile(filepath, data, (err) => { if (err) console.error(err); });
```

### JS Counting → DB Aggregation
```javascript
// YANLIŞ: Tüm kayıtları çekip JS'te say
const products = db.getAllProducts();
const totalProducts = products.length;

// DOĞRU: DB tarafında say (eğer fonksiyon varsa)
const totalProducts = db.getProductCount();
// VEYA: En azından sadece count al
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. **Komşu kodları etkilemediğini kontrol et**
4. Her fix sonrası dosyayı tekrar oku — önceki fix'i bozma!
5. Syntax kontrol: `bash("node -c dosya.js")`

### 🚨 ADIM 4.5: Pagination Doğrulama (ZORUNLU — ATLAMA!)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap. .js VE .ts uzantılarını kontrol et!

```bash
# Ana list endpoint'te req.query.page veya req.query.limit kullanılıyor mu?
grep -q "req\.query\.page\|req\.query\.limit\|parseInt(req.query" src/server.js src/server.ts src/routes/*.js src/routes/*.ts src/services/*.js src/services/*.ts 2>/dev/null || echo "❌ KRİTİK: List endpoint'lerde pagination YOK! req.query.page/limit OKUNMUYOR!"

# Search endpoint'te pagination var mı?
grep -q "req\.query\.page\|req\.query\.limit" src/server.js src/server.ts src/routes/*.js src/routes/*.ts 2>/dev/null || echo "❌ KRİTİK: Search endpoint'te pagination YOK! req.query.page/limit OKUNMUYOR!"

# Response'ta pagination metadata var mı? (total, page, totalPages, hasNext)
grep -q "totalPages\|hasNext\|total.*page" src/server.js src/server.ts src/services/*.js src/services/*.ts 2>/dev/null || echo "❌ KRİTİK: Pagination metadata YOK (totalPages, hasNext vb.)!"
```

🚨🚨🚨 **EĞER pagination YOKSA → HEMEN server.ts/server.js'e ekle!**
🚨 **SADECE "page" veya "limit" kelimesi geçmesi YETMEZ — `req.query.page` OKUNMALI ve `.slice(offset, offset+limit)` UYGULANMALI!**

**Pagination eksikse, şu şablonu HEMEN uygula:**

```javascript
// GET /api/tasks (veya herhangi bir list endpoint)
app.get("/api/tasks", auth, asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const offset = (page - 1) * limit;
  const allTasks = taskService.getAllTasksWithDetails();
  const paginated = allTasks.slice(offset, offset + limit);
  res.json({
    tasks: paginated,
    total: allTasks.length,
    page,
    totalPages: Math.ceil(allTasks.length / limit),
    hasNext: offset + limit < allTasks.length,
    hasPrev: page > 1
  });
}));

// GET /api/search (search endpoint de dahil!)
app.get("/api/search", auth, asyncHandler(async (req, res) => {
  const q = (req.query.q as string) || "";
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const offset = (page - 1) * limit;
  const allResults = taskService.searchTasks(q);
  const paginated = allResults.slice(offset, offset + limit);
  res.json({
    results: paginated,
    total: allResults.length,
    page,
    totalPages: Math.ceil(allResults.length / limit),
    hasNext: offset + limit < allResults.length,
    hasPrev: page > 1
  });
}));
```

## Adım 5: Rapor Yaz

`reports/performance/performance-fix-YYYYMMDD.md`:

```markdown
# ⚡ Performance Fix Raporu
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
## Performance Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Kalan Sorunlar:**
- **Sonraki Ajan İçin Öneri:** Code quality audit'e geç
```
