---
name: fix-docs
description: >-
  Documentation fix skill. Documentation audit'ten gelen güvenli sorunları düzeltir.
  README.md, API docs, inline comments, CONTRIBUTING.md oluşturma.
  Trigger: "fix docs", "docs fix", "düzelt dokümantasyon", "onar docs", "documentation fix"
---

# Skill: Documentation Fix

**Amaç:** Documentation audit'ten gelen eksiklikleri tamamla, dokümantasyon oluştur.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **README.md oluşturma** — Proje açıklaması, kurulum, kullanım, API
- **API documentation** — Endpoint'lerin dokümantasyonu
- **Inline comment ekleme** — Karmaşık logic'lere açıklayıcı yorum
- **CONTRIBUTING.md oluşturma** — Katkı rehberi
- **.env.example oluşturma** — Gerekli environment variable'ların listesi
- **CHANGELOG.md oluşturma** — Versiyon geçmişi
- **JSDoc/doc comment ekleme** — Fonksiyon imzalarına açıklama

### ❌ Onay Gerekli
- Architecture Decision Records (ADR)
- API versioning dokümantasyonu
- Runbook / Incident response
- On-call rehberleri
- Third-party integration docs

---

## Adım 1: Raporları Oku

```
read("reports/documentation/docs-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** README.md yok
- **P1:** 🚨 **API docs (API.md) ZORUNLU**, .env.example yok
- **P2:** 🚨 **Inline comments ZORUNLU** (server.js'teki her endpoint ve karmaşık logic), CONTRIBUTING.md, JSDoc

### ⚠️ MUTLAKA YAPILACAKLAR (atlanmamalı):
1. `README.md` — ZORUNLU
2. 🚨 **`API.md` — ZORUNLU, KESİNLİKLE ATLAMA!** Her endpoint'in dokümantasyonu yazılmalı
3. 🚨 **Inline comments — ZORUNLU!** `src/server.js`'teki her endpoint'e açıklayıcı yorum ekle
4. `CONTRIBUTING.md` — ZORUNLU
5. `.env.example` — ZORUNLU

## Adım 3: Fix Şablonları

### README.md
```markdown
# ShopApp

E-ticaret platformu — Express.js + vanilla HTML/CSS/JS.

## Kurulum

\```bash
git clone <repo-url>
cd shopapp
npm install
cp .env.example .env
# .env dosyasını düzenleyin
npm start
\```

## Ortam Değişkenleri

| Değişken | Açıklama | Varsayılan | Zorunlu |
|----------|----------|:----------:|:-------:|
| `PORT` | Sunucu portu | 3000 | ❌ |
| `JWT_SECRET` | JWT imzalama anahtarı (min 32 karakter) | — | ✅ |
| `CORS_ORIGIN` | İzin verilen origin | http://localhost:3000 | ❌ |
| `NODE_ENV` | Ortam | development | ❌ |

## API Endpoint'leri

Ayrıntılı API dokümantasyonu için: [API.md](docs/API.md)

## Test

\```bash
npm test
\```

## Proje Yapısı

\```
├── src/
│   ├── server.js          # Express uygulaması
│   └── config/
│       └── database.js    # In-memory database modülü
├── public/
│   └── index.html         # Frontend SPA
├── tests/                 # Test dosyaları
├── Dockerfile             # Docker konfigürasyonu
└── package.json
\```

## Lisans

ISC
```

### API Documentation (docs/API.md)
```markdown
# ShopApp API Dokümantasyonu

## Base URL
`http://localhost:3000/api`

## Authentication

Protected endpoint'ler JWT token gerektirir. Token cookie olarak gönderilir.

---

## Auth

### POST /api/auth/register
Yeni kullanıcı kaydı.

**Body:**
| Alan | Tip | Zorunlu | Açıklama |
|------|-----|:-------:|----------|
| username | string | ✅ | Kullanıcı adı |
| email | string | ✅ | E-posta adresi |
| password | string | ✅ | Şifre (min 8 karakter) |

**Response:** `201` — `{ user: { id, username, email, role } }`

### POST /api/auth/login
Kullanıcı girişi.

**Body:** `{ email, password }`
**Response:** `200` — `{ user: { id, username, email, role } }`

### POST /api/auth/logout
Çıkış yapar, cookie'yi temizler.
**Response:** `200` — `{ message: "Logged out" }`

---

## Products

### GET /api/products
Ürün listesini getirir.

**Query Params:**
| Param | Tip | Açıklama |
|-------|-----|----------|
| search | string | İsme göre arama |
| category | string | Kategori filtresi |
| sort | string | `price` veya `name` |
| page | number | Sayfa numarası |
| limit | number | Sayfa başına ürün (varsayılan: 20) |

**Response:** `200` — `{ products: [], total, page, totalPages }`

### GET /api/products/:id
Tek ürün detayı + yorumlar.
**Response:** `200` — `{ product, reviews: [] }`

### POST /api/products
Yeni ürün oluşturur (auth gerekli).
**Body:** `{ name, description, price, category, imageUrl }`

### POST /api/products/:id/reviews
Ürüne yorum ekler (auth gerekli).
**Body:** `{ rating: 1-5, comment: string }`

---

## Orders

### POST /api/orders
Yeni sipariş oluşturur (auth gerekli).
**Body:** `{ items: [{ productId, quantity }] }`

### GET /api/orders
Kullanıcının siparişlerini listeler (auth gerekli).

---

## Profile

### GET /api/profile
Kullanıcı profili (auth gerekli).

### PUT /api/profile
Profil güncelleme (auth gerekli).
**Body:** `{ username?, bio?, avatar? }`

---

## Admin

### GET /api/admin/stats
Admin istatistikleri (admin rolü gerekli).
```

### CONTRIBUTING.md
```markdown
# Katkı Rehberi

ShopApp projesine katkıda bulunmak için aşağıdaki adımları izleyin.

## Geliştirme Ortamı

1. Repo'yu fork'layın
2. `npm install`
3. `cp .env.example .env`
4. `npm start`

## Kod Standartları

- JavaScript (ES6+)
- Tutarlı isimlendirme: camelCase
- Error handling: try/catch kullanın
- Input validation: Her endpoint'te zorunlu alan kontrolü

## Pull Request Süreci

1. Feature branch oluşturun: `git checkout -b feature/yeni-ozellik`
2. Değişikliklerinizi commit edin
3. Testlerin geçtiğinden emin olun: `npm test`
4. PR açın ve açıklama ekleyin

## Commit Mesajları

- `feat:` Yeni özellik
- `fix:` Bug düzeltme
- `docs:` Dokümantasyon
- `refactor:` Kod iyileştirme
- `test:` Test ekleme
```

### .env.example
```env
# Server
PORT=3000
NODE_ENV=development

# Auth
JWT_SECRET=change-me-to-a-random-string-at-least-32-characters-long!!!

# CORS
CORS_ORIGIN=http://localhost:3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/shopapp
```

### Inline Comments
```javascript
// Karmaşık logic'lere yorum ekle:
// Discount calculation: Bulk orders over 1000 TL get 10% off,
// premium users get additional 5% discount
function calculateDiscount(total, userRole) { /* ... */ }

// JSDoc formatı:
/**
 * Calculate order discount based on total amount and user role
 * @param {number} total - Order total before discount
 * @param {string} userRole - User role ('user', 'premium', 'admin')
 * @returns {{ discount: number, finalTotal: number }}
 */
function calculateDiscount(total, userRole) { /* ... */ }
```

## Adım 4: Fix Uygula — DOSYA OLUŞTURMA (ZORUNLU)

🚨🚨🚨 AŞAĞIDAKİ 5 DOSYAYI MUTLAKA OLUŞTUR — ATLA MA!

1. `write("README.md", ...)` — Proje açıklaması, kurulum, kullanım, API linki, test
2. `write("API.md", ...)` — Tüm endpoint'ler: method, path, body, response, status codes
3. `write("CONTRIBUTING.md", ...)` — Fork → branch → commit → PR süreci
4. `write(".env.example", ...)` — Tüm env variable'lar ve açıklamaları
5. `edit("src/server.js" veya "src/server.ts", ...)` — Her endpoint'e inline comment ekle

🚨 HER DOSYAYI `write()` İLE OLUŞTURDUKTAN SONRA DOĞRULA:
```bash
test -f README.md || echo "❌ README.md YOK"
test -f API.md || echo "❌ API.md YOK"
test -f CONTRIBUTING.md || echo "❌ CONTRIBUTING.md YOK"
test -f .env.example || echo "❌ .env.example YOK"
```

🚨 INLINE COMMENTS: Server dosyasındaki her route handler'a yorum ekle:
- `// AUTH: Register new user` — auth endpoint'leri
- `// TASKS: List tasks with pagination` — task endpoint'leri
- `// ADMIN: Get all users` — admin endpoint'leri
- `// MIDDLEWARE: JWT authentication` — middleware
- `// ERROR: Global error handler` — error handler

**EN AZ 5 INLINE COMMENT OLMALI — DAHA AZ İSE EKLE!**

### 🚨 ADIM 4.5: Documentation Doğrulama (ZORUNLU — ATLAMA!)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap. .js VE .ts uzantılarını kontrol et!

```bash
# README.md var mı?
test -f README.md || echo "❌ KRİTİK: README.md YOK — HEMEN write() ile oluştur!"

# API.md var mı?
test -f API.md || echo "❌ KRİTİK: API.md YOK — HEMEN write() ile oluştur!"

# Inline comments var mı? (server dosyasında en az 5 yorum olmalı — .js ve .ts)
count=$(grep -c '//' src/server.js src/server.ts 2>/dev/null | awk -F: '{sum+=$2} END{print sum}')
if [ "$count" -lt 5 ]; then echo "❌ KRİTİK: Inline comments YETERSİZ ($count adet, en az 5 olmalı) — HEMEN edit() ile ekle!"; fi

# CONTRIBUTING.md var mı?
test -f CONTRIBUTING.md || echo "❌ KRİTİK: CONTRIBUTING.md YOK — HEMEN write() ile oluştur!"

# .env.example var mı?
test -f .env.example || echo "❌ KRİTİK: .env.example YOK — HEMEN write() ile oluştur!"
```

🚨🚨🚨 **EĞER herhangi bir dosya YOKSA → HEMEN `write()` ile oluştur! ATLAMA!**
🚨🚨🚨 **EĞER inline comments YETERSİZSE → HEMEN `edit()` ile yorum ekle!**

**Inline comments ekleme — HEMEN uygula:**
Her endpoint'e şu formatta yorum ekle:
```javascript
// AUTH: Register a new user with validated input
app.post("/api/register", ...)

// AUTH: Login with credentials, return JWT token
app.post("/api/login", ...)

// AUTH: Logout and clear authentication
app.post("/api/logout", ...)

// TASKS: List all tasks with pagination
app.get("/api/tasks", ...)

// TASKS: Create a new task with validation
app.post("/api/tasks", ...)

// TASKS: Update task with mass assignment protection
app.put("/api/tasks/:id", ...)

// ADMIN: Get all users (admin only)
app.get("/api/admin/users", ...)

// MIDDLEWARE: Verify JWT Bearer token
function auth(req, res, next) { ... }

// ERROR: Global error handler with status codes
app.use((err, req, res, next) => { ... })
```

**SADECE mevcut yorumları saymak YETMEZ — eğer 5'ten azsa HEMEN edit() ile ekle!**
**Her route handler'ın üstüne ve her middleware'in üstüne yorum ekle.**

**Documentation fix'in tamamlanmış sayılması için:**
1. ✅ `README.md` mevcut ve kurulum/kullanım açıklanmış
2. ✅ `API.md` mevcut ve tüm endpoint'ler dokümante edilmiş
3. ✅ `src/server.js`'te en az 5 inline comment mevcut
4. ✅ `CONTRIBUTING.md` mevcut
5. ✅ `.env.example` mevcut

## Adım 5: Rapor Yaz

`reports/documentation/docs-fix-YYYYMMDD.md`:

```markdown
# 📚 Documentation Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Oluşturulan Dosyalar
| # | Dosya | İçerik |
|---|-------|--------|

## Güncellenen Dosyalar
| # | Dosya | Değişiklik |
|---|-------|------------|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## Documentation Fix - TAMAMLANDI
- **Oluşturulan Dosyalar:** README.md, API.md, CONTRIBUTING.md, .env.example
- **Güncellenen Dosyalar:** X dosyaya inline comment eklendi
- **Sonraki Ajan İçin Öneri:** Final rapor hazırla
```
