---
name: fix-devops
description: >-
  DevOps fix skill. DevOps audit'ten gelen güvenli sorunları düzeltir.
  Dockerfile security, .dockerignore, health check endpoint, CI pipeline fix, config separation.
  Trigger: "fix devops", "devops fix", "düzelt devops", "onar devops", "docker fix", "ci fix"
---

# Skill: DevOps Fix

**Amaç:** DevOps audit'ten gelen güvenli altyapı sorunlarını düzelt.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Dockerfile: non-root user** — `USER node` ekleme
- **Dockerfile: .dockerignore** — `.env`, `node_modules`, `.git` hariç tutma
- **Dockerfile: COPY . . → specific paths** — Hassas dosyaları hariç tutma
- **Health check endpoint** — `GET /health` ekleme
- **CI pipeline fix** — Test script, cache, proper steps
- **Config separation** — `config/development.js`, `config/production.js`
- **Environment variable validation** — Startup'ta gerekli env'leri kontrol etme
- **Graceful shutdown** — SIGTERM handler ekleme

### ❌ Onay Gerekli
- Kubernetes/Docker Compose konfigürasyonu
- Cloud provider özel ayarları
- Database migration script'leri
- SSL/TLS certificate konfigürasyonu
- Monitoring/logging infrastructure ekleme

---

## Adım 1: Raporları Oku

```
read("reports/devops/devops-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Dockerfile root user, .env dosyası image'da
- **P1:** Health check eksik, CI broken
- **P1.5 (ZORUNLU):** Graceful shutdown — SIGTERM/SIGINT handler ZORUNLU olarak eklenmeli
- **P2:** Config separation

### ⚠️ MUTLAKA YAPILACAKLAR (atlanmamalı):
1. Dockerfile: `USER node` veya `USER appuser` EKLE
2. `.dockerignore` OLUŞTUR (node_modules, .env, .git)
3. `/health` endpoint EKLE
4. CI pipeline: `actions/checkout@v4` + `actions/setup-node@v4` + `npm ci` + `npm test`
5. **Graceful shutdown: `process.on('SIGTERM')` + `process.on('SIGINT')` + `server.close()` EKLE — bunu atlama!**

## Adım 3: Fix Şablonları

### Dockerfile: Non-Root User
```dockerfile
# YANLIŞ: root olarak çalışıyor
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "src/server.js"]

# DOĞRU: node user olarak çalıştır
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "src/server.js"]
```

### .dockerignore
```dockerignore
node_modules
.env
.env.*
.git
.github
.gitignore
README.md
CONTRIBUTING.md
docs
docker
Dockerfile
.dockerignore
npm-debug.log
.nyc_output
coverage
tests
```

### Health Check Endpoint (ZORUNLU — KESİNLİKLE EKLE!)
```javascript
// server.js'e ekle (diğer route'lardan ÖNCE):
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});
```

🚨 **HEALTH ENDPOINT ZORUNLU!** Bunu atlamak DevOps fix'i tamamlanmamış sayar.
- Endpoint path: `/api/health` veya `/health`
- Response: `{ status: 'ok' }` en minimum
- Dockerfile HEALTHCHECK ile uyumlu olmalı

### CI Pipeline Fix
```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - name: Upload coverage
        if: matrix.node-version == 20
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  docker:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t shopapp:${{ github.sha }} .
```

### Config Separation
```javascript
// config/default.js
module.exports = {
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET,
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  bulkThreshold: parseInt(process.env.BULK_ORDER_THRESHOLD) || 1000,
  bulkDiscountRate: parseFloat(process.env.BULK_DISCOUNT_RATE) || 0.1,
  premiumDiscountRate: parseFloat(process.env.PREMIUM_DISCOUNT_RATE) || 0.05,
};

// config/production.js
const defaults = require('./default');
module.exports = {
  ...defaults,
  // Production overrides
};
```

### Graceful Shutdown
```javascript
// server.js sonuna ekle
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

function gracefulShutdown(signal) {
  console.log(`${signal} received, closing server...`);
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` veya `write()` ile düzelt/oluştur
3. Dockerfile syntax: `bash("docker build --check . 2>&1 || true")`
4. CI yaml syntax kontrol et

### 🚨 ADIM 4.5: DevOps Doğrulama (ZORUNLU — ATLAMA!)

```bash
# Health endpoint var mı?
grep -q '/api/health\|/health' src/server.ts src/server.js || echo "❌ KRİTİK: Health endpoint YOK — HEMEN ekle!"

# Graceful shutdown var mı?
grep -q 'SIGTERM\|SIGINT\|process.on' src/server.ts src/server.js || echo "❌ KRİTİK: Graceful shutdown YOK — HEMEN ekle!"

# Dockerfile non-root user var mı?
grep -q 'USER' Dockerfile || echo "❌ KRİTİK: Dockerfile USER directive YOK!"

# .dockerignore var mı?
test -f .dockerignore || echo "❌ KRİTİK: .dockerignore YOK!"

# CI checkout var mı?
grep -q 'checkout' .github/workflows/ci.yml || echo "❌ KRİTİK: CI checkout YOK!"
```

🚨🚨🚨 **EĞER health endpoint YOKSA → HEMEN ekle! ATLAMA!**
🚨🚨🚨 **EĞER graceful shutdown YOKSA → HEMEN ekle! ATLAMA!**

**Health endpoint — HEMEN uygula:**
```javascript
// server.ts/server.js'e diğer route'lardan ÖNCE ekle:
app.get("/api/health", (_req, res) => {
  res.json({
    status: "ok",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development"
  });
});
```

**Graceful shutdown — HEMEN uygula:**
```javascript
// server.ts/server.js'in sonuna ekle — app.listen'den sonra:
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

function gracefulShutdown(signal: string) {
  console.log(`${signal} received, closing server gracefully...`);
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
  // Force shutdown after 10 seconds
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
```

**DİKKAT:** `app.listen()` sonucunu `const server = ...` değişkenine ata, sonra `server.close()` kullan!

## Adım 5: Rapor Yaz

`reports/devops/devops-fix-YYYYMMDD.md`:

```markdown
# 🚀 DevOps Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix |
|---|-------|-------|-----|

## Oluşturulan Yeni Dosyalar
| # | Dosya | Amaç |
|---|-------|------|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## DevOps Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Oluşturulan Yeni Dosyalar:**
- **Sonraki Ajan İçin Öneri:** SEO audit'e geç
```
