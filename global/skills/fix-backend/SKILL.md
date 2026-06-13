---
name: fix-backend
description: >-
  Backend fix skill. Backend audit'ten gelen güvenli sorunları düzeltir.
  Trigger: "fix backend", "backend fix", "düzelt backend", "onar backend"
---

# Skill: Backend Fix

**Amaç:** Güvenli ve düşük riskli backend sorunlarını çözmek.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- Input validation ekleme
- Error handling ekleme (try/catch)
- SQL injection → parametric query'e çevirme
- Hardcoded secret → env variable'a taşıma
- CORS configuration düzeltme
- Missing HTTP status code düzeltme
- **Rate limiting ekleme** (`express-rate-limit`)
- **Security headers ekleme** (`helmet`)
- **Güvenlik bağımlılıkları**: `helmet`, `express-rate-limit`, `cors`, `bcrypt`, `cookie-parser`
- **bcrypt salt rounds artırma** (8→10 veya 12)
- **Upload path traversal koruması** ekleme
- **Prototype pollution guard** ekleme
- **Paylaşılan config scope düzeltme** (global scope'a taşıma)
- **Utility fonksiyon bug fix** (getMonth +1, parseInt radix vb.)
- **Kullanılmayan import cleanup**
- **Logout endpoint ekleme** — JWT kullanan projelerde cookie clear + token invalidation
- **CSP header ekleme** — helmet.contentSecurityPolicy() yapılandırması
- **CSRF protection ekleme** — `csurf` veya custom CSRF token middleware + SameSite cookie kombinasyonu

### ❌ Onay Gerekli
- Database schema değişikliği
- Auth sisteminin yeniden yazılması
- Yeni API endpoint ekleme
- Breaking API change
- **Büyük/bilinmeyen bağımlılıklar** (helmet, rate-limit, cors dışındakiler)

---

## Adım 1: Raporları Oku

```
read("reports/backend/backend-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** SQL injection, hardcoded secret, prototype pollution
- **P1:** Error handling, CORS, rate limiting, security headers, bcrypt salt
- **P1.5 — Sık Kaçırılanlar (MUTLAKA KONTROL ET):**
  - Helmet + Rate limiting yüklü ve aktif mi?
  - Upload path traversal koruması var mı?
  - bcrypt salt rounds ≥ 10 mu?
  - Paylaşılan config (COOKIE_OPTIONS vb.) global scope'ta mı?
  - Utility bug'ları (getMonth +1) düzeltilmiş mi?
  - Kullanılmayan import'lar kaldırılmış mı?
- **P2:** API tutarlılık
- **Dışarıda:** Breaking changes

## Adım 3: Sık Kaçırılan Fix Şablonları

### Helmet + Rate Limiting (ZORUNLU — HER İKİSİ DE OLMALI)
```javascript
// npm install helmet express-rate-limit
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
app.use(helmet());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
```

🚨 **HELMET VE RATE LIMITING BİRLİKTE KULLANILMALI!**
- Sadece `helmet()` eklemek YETERSİZ — `rateLimit()` DA ZORUNLU
- `express-rate-limit` package.json'da olsa bile, server.js'te `app.use(rateLimit(...))` ile uygulanmamışsa düzeltilmeli
- **Her ikisi de server.js'te import edilmiş ve app.use() ile uygulanmış olmalı**

### Upload Path Traversal
```javascript
const uploadedPath = path.resolve(uploadDir, filename);
if (!uploadedPath.startsWith(path.resolve(uploadDir) + path.sep)) {
  return res.status(400).json({ error: 'Invalid file path' });
}
```

### Prototype Pollution Guard
```javascript
const DANGEROUS_KEYS = ['__proto__', 'constructor', 'prototype'];
function safeMerge(target, source) {
  for (const key of Object.keys(source)) {
    if (DANGEROUS_KEYS.includes(key)) continue;
    target[key] = source[key];
  }
  return target;
}
```

### bcrypt Salt Rounds
```javascript
const saltRounds = 10; // minimum 10, 8 değil!
```

### Variable Scope (COOKIE_OPTIONS vb.)
```javascript
// DOĞRU: Global scope'ta tanımla, tüm endpoint'ler kullanır
const COOKIE_OPTIONS = { httpOnly: true, secure: true, sameSite: 'strict' };

app.post('/register', (req, res) => { res.cookie('token', token, COOKIE_OPTIONS); });
app.post('/login', (req, res) => { res.cookie('token', token, COOKIE_OPTIONS); });
```

### getMonth +1
```javascript
// YANLIŞ: const month = d.getMonth();
// DOĞRU:
const month = d.getMonth() + 1;
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. **Komşu kodları etkilemediğini kontrol et**
4. Her fix sonrası dosyayı tekrar oku — önceki fix'i bozma!
5. Syntax kontrol: `bash("node -c dosya.js")`

### 🚨 ADIM 4.5: Backend Security Doğrulama (ZORUNLU — ATLAMA!)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap. .js VE .ts uzantılarını kontrol et!

```bash
# Helmet aktif mi?
grep -q "helmet" src/server.js src/server.ts || echo "❌ KRİTİK: helmet() uygulanmamış!"

# Rate limiting aktif mi?
grep -q "rateLimit\|rate-limit" src/server.js src/server.ts || echo "❌ KRİTİK: rateLimit() uygulanmamış!"

# bcrypt salt rounds >= 10 mu?
grep -q "saltRounds\|BCRYPT_ROUNDS\|bcrypt.hash.*1[0-9]" src/server.js src/server.ts src/services/*.ts src/services/*.js src/config/*.ts src/config/*.js || echo "❌ KRİTİK: bcrypt salt rounds < 10!"

# 🚨 Logout endpoint var mı? ZORUNLU!
grep -q "logout" src/server.js src/server.ts src/routes/*.js src/routes/*.ts src/services/*.js src/services/*.ts || echo "❌ KRİTİK: Logout endpoint YOK — HEMEN ekle!"

# 🚨 HttpOnly cookie kullanılıyor mu? ZORUNLU!
grep -q "res\.cookie\|httpOnly" src/server.js src/server.ts src/routes/*.js src/routes/*.ts src/services/*.js src/services/*.ts || echo "❌ KRİTİK: httpOnly cookie YOK — HEMEN ekle! Token SADECE localStorage/sessionStorage'da OLAMAZ!"

# 🚨 Mass assignment protection var mı? ZORUNLU!
grep -q "safeFields\|ALLOWED\|whitelist\|allowedFields" src/server.js src/server.ts src/routes/*.js src/routes/*.ts src/services/*.js src/services/*.ts src/store/*.js src/store/*.ts || echo "❌ KRİTİK: Mass assignment protection YOK — HEMEN whitelist ekle!"
```

🚨🚨🚨 **EĞER logout YOKSA → HEMEN ekle! ATLAMA!**
🚨🚨🚨 **EĞER httpOnly cookie YOKSA → HEMEN ekle! ATLAMA!**

**Logout endpoint — HEMEN uygula:**
```javascript
// TypeScript
app.post("/api/logout", auth, (req: Request, res: Response) => {
  res.clearCookie('token', { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'strict' });
  res.json({ message: 'Logged out' });
});
```

**httpOnly cookie — HEMEN uygula:**
🚨🚨🚨 **Token SADECE localStorage veya sessionStorage'da saklanıyorsa BU YANLIŞ!**
🚨 **httpOnly cookie ZORUNLU — token response body'den ÇIKARILMALI ve SADECE cookie ile gönderilmeli!**

```javascript
// Login: Token'ı httpOnly cookie olarak gönder, response body'de token dÖNDÜRME
app.post("/api/login", asyncHandler(async (req: Request, res: Response) => {
  const { username, password } = req.body;
  const result = await userService.login(username, password);
  // Token'ı httpOnly cookie olarak ayarla
  res.cookie('token', result.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 gün
  });
  // Response body'de token döndürME — sadece user bilgisi
  res.json({ user: result.user });
}));

// Register: Aynı şekilde
app.post("/api/register", asyncHandler(async (req: Request, res: Response) => {
  const { username, password } = req.body;
  const result = await userService.register(username, password);
  res.cookie('token', result.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000
  });
  res.status(201).json({ user: result.user });
}));

// Frontend: cookie-based auth — Authorization header YERİNE cookie kullan
// fetch('/api/tasks', { credentials: 'include' }) — cookie otomatik gönderilir
```

**Mass assignment whitelist — HEMEN uygula:**
```javascript
const ALLOWED_TASK_UPDATES = new Set(['title', 'description', 'priority', 'assigneeId', 'status']);
function updateTask(id, updates) {
  const task = tasks.find(t => t.id === id);
  if (!task) return undefined;
  const cleanUpdates = {};
  for (const key of Object.keys(updates)) {
    if (ALLOWED_TASK_UPDATES.has(key)) cleanUpdates[key] = updates[key];
  }
  Object.assign(task, cleanUpdates);
  return task;
}
```

## Adım 5: Rapor Yaz

`reports/backend/backend-fix-YYYYMMDD.md`:

```markdown
# 🔧 Backend Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | Severity |
|---|-------|-------|-----|:--------:|

## Sık Kaçırılanlar Kontrol Sonucu
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|
| 1 | Helmet | ✅/❌ | |
| 2 | Rate limiting | ✅/❌ | |
| 3 | bcrypt salt ≥ 10 | ✅/❌ | |
| 4 | Upload path traversal | ✅/❌ | |
| 5 | Prototype pollution | ✅/❌ | |
| 6 | Config scope | ✅/❌ | |
| 7 | Utility bugs | ✅/❌ | |
| 8 | Import cleanup | ✅/❌ | |

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix |
|---|-------|-------|-------------|
```

## Adım 6: Handoff Güncelle

```markdown
## Backend Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Sık Kaçırılanlar Durumu:** (8 kontrolün geçti/kaldı durumu)
- **Kalan Sorunlar:**
- **Sonraki Ajan İçin Öneri:** UX critic'e geç
```
