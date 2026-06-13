---
name: fix-architecture
description: >-
  Architecture fix skill. Architecture audit'ten gelen güvenli sorunları düzeltir.
  Business logic extraction, fat controller slimming, config externalization, error handling consistency.
  Trigger: "fix architecture", "architecture fix", "düzelt mimari", "onar mimari"
---

# Skill: Architecture Fix

**Amaç:** Architecture audit'ten gelen güvenli, düşük riskli mimari sorunlarını düzelt.

## Güvenli Fix Sınıfları

### ✅ Otomatik Yapılabilir
- **Business logic extraction** — Route handler'daki hesaplama kodunu service/helper fonksiyona taşıma
- **Fat controller slimming** — Email/file/analytics logic'ini ayrı modüllere taşıma
- **Hardcoded config → env variable** — Port, threshold, URL gibi değerleri `process.env`'e taşıma
- **Error handling standardizasyonu** — Tutarlı try/catch ve hata formatı
- **Global state isolation** — Module-scope state'i güvenli hale getirme
- **Config dosyası oluşturma** — Dağınık config değerlerini tek dosyada toplama
- **Helper/util fonksiyon çıkarma** — Tekrarlanan kodu shared fonksiyona dönüştürme

### ❌ Onay Gerekli
- Framework değiştirme
- Database değiştirme
- Yeni microservice ekleme
- Message queue / event system ekleme
- API contract değiştirme

---

## Adım 1: Raporları Oku

```
read("reports/architecture/architecture-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir (ZORUNLU ADIMLAR)

- **P0:** Error handling tutarsızlığı (crash riski)
- **P1:** Hardcoded config, business logic in controller
- **P2:** Fat controller, global state

### 🚨🚨🚨 EN ÖNEMLİ KURAL — BU ADIMLAR ATLANAMAZ:

**Sadece middleware oluşturmak YETERSİZDİR.** Aşağıdaki 2 dosya KESİNLİKLE oluşturulmalıdır:

1. **`src/config/index.js`** — Tüm config değerleri bu dosyada toplanmalı
   - `require("dotenv").config()` burada olmalı
   - `module.exports = { port, jwtSecret, bcryptRounds, ... }` ile export
   - `server.js`'ten `const config = require("./config")` ile import

2. **`src/services/taskService.js`** (veya proje entity'sine göre) — Business logic bu dosyaya taşınmalı
   - Validation logic (title, priority, etc.)
   - Side effects (file operations, logging, notifications)
   - Multi-step operations
   - `module.exports = { validateTask, createTask, ... }` ile export
   - `server.js`'ten `const taskService = require("./services/taskService")` ile import

**BU DOSYALAR OLMADAN ARCHITECTURE FIX TAMAMLANMIŞ SAYILMAZ!**

### ⚠️ ZORUNLU — Aşağıdakiler MUTLAKA ayrı dosya olarak oluşturulmalı:

1. **`src/config/index.js` (veya `src/config/app.js`) ZORUNLU:**
   - Tüm hardcoded değerler (PORT, SECRET, thresholds, rate limit config, salt rounds) bu dosyada toplanmalı
   - `process.env` okuması burada yapılmalı
   - `require("./config")` ile server.js'ten import edilmeli
   - **NOT: Inline config değişkenleri server.js'te bırakmak YETERSİZDİR — ayrı dosya şart!**

2. **`src/services/<entity>Service.js` ZORUNLU (en az bir tane):**
   - Route handler'daki business logic (validation, calculation, notification, file write) bu dosyaya taşınmalı
   - `require("../services/taskService")` şeklinde import edilmeli
   - Route handler sadece: input al → service çağır → response döndür
   - **NOT: Inline helper fonksiyonları server.js'te bırakmak YETERSİZDİR — ayrı dosya şart!**
   - 🚨 **SERVICE DOSYASI YOKSA ARCHITECTURE FIX TAMAMLANAMAZ!**
   - 🚨 **HER ZAMAN en az 1 service dosyası oluştur: `src/services/taskService.js` veya proje entity'sine göre adlandır**
   - 🚨 **Sadece config dosyası oluşturmak YETERLİ DEĞİLDİR — service layer DA ZORUNLU!**
   - Service dosyasına taşınacak tipik logic'ler:
     - Validation fonksiyonları (title, priority, etc.)
     - Side effect logic (file write, logging, notification)
     - Business rule hesaplamaları (discount, eligibility, etc.)
     - Multi-step operations (validate → create → log → notify)

## Adım 3: Fix Şablonları

### Business Logic → Service Layer (ZORUNLU: AYRI DOSYA)
```javascript
// YANLIŞ: Business logic route handler'da veya inline helper'da
app.post('/api/tasks', (req, res) => {
  // validation + creation + file write + logging hepsi burada
});

// DOĞRU: src/services/taskService.js adlı AYRI DOSYA oluştur
// src/services/taskService.js
const db = require("../config/database");
const fs = require("fs");
const path = require("path");

function validateTask(data) { /* validation logic */ }
function createTaskWithSideEffects(data, user) {
  const task = db.addTask(data);
  logTaskCreation(task, user); // file write + logging
  return task;
}
function logTaskCreation(task, user) {
  fs.promises.writeFile(/* ... */).catch(console.error);
}
module.exports = { validateTask, createTaskWithSideEffects };

// src/server.js'ten import:
const taskService = require("./services/taskService");
app.post('/api/tasks', auth, (req, res) => {
  try {
    const task = taskService.createTaskWithSideEffects(req.body, req.user);
    res.status(201).json({ task });
  } catch (err) {
    res.status(err.status || 500).json({ error: err.message });
  }
});
```

### Fat Controller → Modular
```javascript
// YANLIŞ: Email + file + log hepsi route handler'da
app.post('/api/orders', (req, res) => {
  // ... order creation ...
  const userEmail = db.getUserById(req.user.id).email;
  fs.writeFileSync(path.join(__dirname, 'data', `order_${order.id}.json`), JSON.stringify(order));
  console.log(`Order ${order.id} created for ${userEmail} — total: ${total}`);
});

// DOĞRU: Ayrı modüller
// src/services/notificationService.js
async function sendOrderConfirmation(userId, order) { /* ... */ }
// src/services/fileService.js
async function saveOrderFile(order) { await fs.promises.writeFile(/* ... */); }
// src/services/analyticsService.js
function logOrderCreated(order) { console.log(`Order ${order.id} — total: ${order.total}`); }

// Route handler:
await sendOrderConfirmation(req.user.id, order);
await saveOrderFile(order);
logOrderCreated(order);
```

### Hardcoded Config → Environment (ZORUNLU: AYRI DOSYA)
```javascript
// YANLIŞ: Config inline server.js'te
const PORT = 3000;
const SECRET = "secret";

// DOĞRU: src/config/index.js adlı AYRI DOSYA oluştur
// src/config/index.js
require("dotenv").config();
const config = {
  port: parseInt(process.env.PORT) || 3000,
  jwtSecret: process.env.JWT_SECRET,
  bcryptSaltRounds: 12,
  // ... tüm config değerleri burada
};
module.exports = config;

// src/server.js'ten import:
const config = require("./config");
app.listen(config.port);
```

### Error Handling Standardizasyonu
```javascript
// YANLIŞ: Bazı endpoint'ler catch bloğunda status kaybediyor
} catch (err) {
  res.status(500).json({ error: "Failed" });
}

// DOĞRU: Tutarlı hata formatı
} catch (err) {
  console.error("Operation error:", err);
  res.status(err.status || 500).json({ error: err.message || "Operation failed" });
}
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. Değişikliğin kapsamını anla
3. Yeni dosya gerekiyorsa `write()` ile oluştur
4. Mevcut dosyada `edit()` ile değişiklik yap
5. **Import/export tutarlılığını kontrol et**
6. Syntax: `bash("node -c dosya.js")`

### 🚨 ADIM 4.5: SERVICE DOSYASI DOĞRULAMA (ZORUNLU)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap:

```bash
# Service dosyası var mı?
ls src/services/*.js 2>/dev/null || echo "❌ KRİTİK: src/services/ altında hiç service dosyası yok!"

# Service dosyası server.js'ten import edilmiş mi?
grep -q "require.*services" src/server.js || echo "❌ KRİTİK: server.js'te service require yok!"

# Config dosyası var mı?
ls src/config/index.js 2>/dev/null || echo "❌ KRİTİK: src/config/index.js yok!"

# Config dosyası server.js'ten import edilmiş mi?
grep -q "require.*config" src/server.js || echo "❌ KRİTİK: server.js'te config require yok!"
```

**EĞER service dosyası YOKSA → HEMEN `write()` ile `src/services/<entity>Service.js` oluştur!**
**EĞER config dosyası YOKSA → HEMEN `write()` ile `src/config/index.js` oluştur!**

**Bu adım ATLANAMAZ — Architecture fix'in tamamlanmış sayılması için:**
1. ✅ `src/config/index.js` mevcut ve server.js'ten import edilmiş
2. ✅ `src/services/<entity>Service.js` mevcut ve server.js'ten import edilmiş
3. ✅ Business logic service dosyasına taşınmış, route handler sadece orchestration yapıyor

## Adım 5: Rapor Yaz

`reports/architecture/architecture-fix-YYYYMMDD.md`:

```markdown
# 🏗️ Architecture Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | Risk |
|---|-------|-------|-----|------|

## Oluşturulan Yeni Dosyalar
| # | Dosya | Amaç |
|---|-------|------|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## Architecture Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Oluşturulan Yeni Dosyalar:**
- **Kalan Sorunlar:**
- **Sonraki Ajan İçin Öneri:** Test audit'e geç
```

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Service layer is overkill for this project" | Any project with more than 5 route handlers benefits from service extraction. It's not overkill, it's separation of concerns. |
| "Config in server.js is fine for now" | "Now" becomes "forever". Extracting config is a 5-minute task that prevents bugs from hardcoded values. |
| "The helper function is already in server.js" | Inline helpers couple business logic to HTTP handling. Extract to a service file for testability and reuse. |
| "We'll refactor later" | Later never comes. Each new feature adds more coupling, making refactoring harder. Do it now. |
| "Separate files add complexity" | God files add more complexity. A 500-line server.js is harder to understand than 5 focused files. |
| "This is too simple for a config file" | Simple today, complex tomorrow. Config externalization is a habit, not a threshold. |

## Red Flags

- 🔴 No service layer (all business logic in route handlers)
- 🔴 No config file (hardcoded values in server.js)
- 🔴 God file (>300 lines in a single file doing everything)
- 🔴 Circular dependencies between modules
- 🔴 Business logic tightly coupled to HTTP framework
- 🔴 Global mutable state shared across handlers
- 🔴 No error handling standardization
