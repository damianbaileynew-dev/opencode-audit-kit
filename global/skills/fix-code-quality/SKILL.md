---
name: fix-code-quality
description: >-
  Code quality fix skill. Code review'den gelen güvenli sorunları düzeltir.
  Unused variables, missing validation, magic numbers, error handling, fragile patterns.
  Trigger: "fix code quality", "code quality fix", "düzelt kod kalitesi", "onar kod"
---

# Skill: Code Quality Fix

**Amaç:** Code review'den gelen güvenli, düşük riskli kod kalitesi sorunlarını düzelt.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Kullanılmayan değişken kaldırma** — `const filteredOrders = orders;` gibi
- **Eksik input validation ekleme** — Rating 1-5 aralığı, string boşluk kontrolü
- **Magic number → named constant** — `0.1` → `PREMIUM_DISCOUNT_RATE`
- **Error handler status code kaybı düzeltme** — Generic 500 yerine orijinal status'u koruma
- **Fragile pattern düzeltme** — Counter race condition, global state leak
- **Tutarsız isimlendirme düzeltme** — camelCase ↔ snake_case
- **Eksik error message düzeltme** — Generic hata → spesifik hata mesajı
- ** console.error ile loglama** — Silent failure'ları görünür kılma

### ❌ Onay Gerekli
- Fonksiyon imzası değiştirme (breaking change)
- Yeni bağımlılık ekleme
- Design pattern değiştirme (Singleton → Factory vb.)
- Modül bölme/refactor

---

## Adım 1: Raporları Oku

```
read("reports/code-quality/code-review-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Missing validation (güvenlik riski), silent error swallowing
- **P1:** Magic numbers, unused variables, error handler status kaybı
- **P2:** Fragile patterns, naming inconsistencies

## Adım 3: Fix Şablonları

### Unused Variable Kaldırma
```javascript
// YANLIŞ:
const filteredOrders = orders;
const processedOrders = orders.map(o => ({ ...o }));

// DOĞRU:
const processedOrders = orders.map(o => ({ ...o }));
```

### Input Validation Ekleme
```javascript
// YANLIŞ: Rating validation yok
const { rating, comment } = req.body;
if (!rating || !comment) return res.status(400).json({ error: "Required" });

// DOĞRU: Range validation ekle
const { rating, comment } = req.body;
if (!rating || !comment) return res.status(400).json({ error: "Rating and comment required" });
const numRating = Number(rating);
if (!Number.isInteger(numRating) || numRating < 1 || numRating > 5) {
  return res.status(400).json({ error: "Rating must be an integer between 1 and 5" });
}
```

### 🚨 Password Validation (ZORUNLU — HER register/signup endpoint'te)
```javascript
// YANLIŞ: Password validation yok veya minimum 6
const { username, email, password } = req.body;
if (!username || !email || !password) return res.status(400).json({ error: "Required" });

// DOĞRU: Password minimum 8 karakter ZORUNLU
const { username, email, password } = req.body;
if (!username || !email || !password) return res.status(400).json({ error: "All fields required" });
if (password.length < 8) {
  return res.status(400).json({ error: "Password must be at least 8 characters" });
}

// 🚨 PASSWORD MİNİMUM 8 KARAKTER — 6 DEĞİL, 7 DEĞİL, 8!
// OWASP ve NIST standartlarına göre minimum parola uzunluğu 8'dir.
// 6 karakter YETERSİZ — brute force saldırısına karşı koruma sağlamaz.
```

🚨 **PASSWORD LENGTH CHECK ZORUNLU:** Her register/signup endpoint'te `password.length < 8`
kullanılmalıdır. 6 veya 7 karakter KABUL EDİLEMEZ. Minimum 8 olmalıdır.

### Magic Number → Named Constant
```javascript
// YANLIŞ:
if (total > 1000) { order.discount = total * 0.1; }
if (req.user.role === "premium") { order.discount = (order.discount || 0) + total * 0.05; }

// DOĞRU:
const BULK_ORDER_THRESHOLD = 1000;
const BULK_DISCOUNT_RATE = 0.10;
const PREMIUM_DISCOUNT_RATE = 0.05;

if (total > BULK_ORDER_THRESHOLD) { order.discount = total * BULK_DISCOUNT_RATE; }
if (req.user.role === "premium") { order.discount = (order.discount || 0) + total * PREMIUM_DISCOUNT_RATE; }
```

### Error Handler Status Code Koruma
```javascript
// YANLIŞ: Her zaman 500
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
});

// DOĞRU: Orijinal status'u koru
app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ error: status === 500 ? "Internal server error" : err.message });
});
```

### Fragile Counter Pattern
```javascript
// YANLIŞ: Global counter, concurrency riskli
let userIdCounter = 1;
function createUser(data) {
  const user = { id: userIdCounter++, ...data };
  users.push(user);
  return user;
}

// DOĞRU: Safe ID generation
let userIdCounter = 1;
function getNextId() { return userIdCounter++; }
function createUser(data) {
  const user = { id: getNextId(), ...data };
  users.push(user);
  return user;
}
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. **Komşu kodları etkilemediğini kontrol et**
4. Her fix sonrası dosyayı tekrar oku — önceki fix'i bozma!
5. Syntax kontrol: `bash("node -c dosya.js")`

### 🚨 ADIM 4.5: Password Validation Doğrulama (ZORUNLU)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap:

```bash
# Register endpoint'te password length check var mı?
grep -n "password.*length\|password.*min\|password.*8" src/server.js || echo "❌ KRİTİK: Password length validation YOK veya 8'den küçük!"

# Password min 6 mı 8 mi? (6 YANLIŞ, 8 DOĞRU)
grep "password.*<.*[67]\|password.*length.*[67]" src/server.js && echo "❌ KRİTİK: Password minimum 6 veya 7 — 8 OLMALI!"
```

**EĞER password length check YOKSA → HEMEN ekle!**
**EĞER password minimum 6 veya 7 ise → 8'e ÇEVİR!**

## Adım 5: Rapor Yaz

`reports/code-quality/code-quality-fix-YYYYMMDD.md`:

```markdown
# 🔍 Code Quality Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | Severity |
|---|-------|-------|-----|:--------:|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## Code Quality Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Kalan Sorunlar:**
- **Sonraki Ajan İçin Öneri:** Architecture audit'e geç
```
