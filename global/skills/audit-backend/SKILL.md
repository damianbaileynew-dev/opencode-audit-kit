---
name: audit-backend
description: >-
  Backend audit skill. Kod tabanını güvenlik, tutarlılık ve işlevsellik açısından analiz eder.
  Trigger: "audit backend", "backend audit", "security audit", "güvenlik tarama", "backend tarama"
---

# Skill: Backend Audit

**Amaç:** Kod tabanını güvenlik, tutarlılık ve işlevsellik açısından analiz etmek.
**Kısıtlar:** Sadece oku ve raporla, dosya değiştirme.

---

## Adım 1: Proje Keşfi

```
glob("**/*.{js,ts,py,go,rs,java,rb}") → Backend dosyaları
glob("**/server.{js,ts}") → Entry points
glob("**/routes/**") → API routes
glob("**/.env*") → Config dosyaları
read("package.json") → Dependencies
```

## Adım 2: Güvenlik Taraması

### Injection
```
grep("SELECT.*\\$|query\\(|raw\\(", "src/**") → SQL Injection riski
grep("exec\\(|eval\\(|child_process", "src/**") → Command Injection riski
```

### Authentication & Secrets
```
grep("password|secret|api_key|token", "src/**") → Hardcoded secrets
grep("jwt|jsonwebtoken", "src/**") → JWT implementation
grep("cors|CORS", "src/**") → CORS config
```

### Validation
```
grep("validate|joi|zod|express-validator", "src/**") → Input validation
grep("rateLimit|rate-limit", "src/**") → Rate limiting
grep("helmet", "src/**") → Security headers
```

### Upload Path Traversal
```
grep("multer|upload|file", "src/**") → File upload noktaları
grep("path\\.join|path\\.resolve", "src/**") → Path manipulation
```
**Her upload noktasında:** `path.resolve(uploadDir, filename)` sonucu `uploadDir` ile başlıyor mu kontrol et.

## Adım 3: Sık Kaçırılan Kontroller (ÖNEMLİ!)

### 3a. Cryptography
```
grep("saltRounds|genSalt|bcrypt\\.hash", "src/**") → bcrypt salt rounds (minimum 10 olmalı)
grep("JWT_SECRET|jwt.*secret", "src/**") → JWT secret güçlü mü?
grep("totp|otpauth|authenticator|twoFactor", "src/**") → 2FA secret dinamik mi?
```

### 3b. Prototype Pollution
```
grep("merge\\(|Object\\.assign.*req\\.|\\.\\.\\.req\\.", "src/**") → Deep merge with user input
grep("lodash|deepExtend|deepMerge", "src/**") → Deep merge kütüphaneleri
```
**Kontrol:** Kullanıcı girdisi merge ediliyorsa `__proto__`, `constructor`, `prototype` filtreleniyor mu?

### 3c. Utility Logic Bugs
```
grep("getMonth\\(", "src/**") → 0-indexed! +1 eksik mi?
grep("parseInt\\(", "src/**") → Radix parametresi var mı?
```

### 3d. Variable Scope
```
grep("COOKIE_OPTIONS|cookieOptions|cookie.*options", "src/**") → Birden fazla yerde kullanılıyor mu?
grep("CORS.*options|corsOptions", "src/**") → Global scope'ta mı?
```
**Kontrol:** Birden fazla endpoint'te kullanılan ayarlar global scope'ta tanımlı mı?

### 3e. Import Cleanup
```
Her dosyada: import/require edilen ama kullanılmayan bağımlılıklar var mı?
Özellikle: exec, child_process, fs (kullanılmayanları raporla)
```

## Adım 4: Auth Lifecycle & Endpoint Tutarlılık Kontrolü

### 4a. Token Lifecycle (JWT / Session)
- [ ] **Logout endpoint var mı?** `grep("logout|signout|revoke", "src/**")` — JWT kullanan projelerde logout/revocation mekanizması olmalı
- [ ] **Token blacklist/revocation:** JWT invalidate edilebiliyor mu? Yoksa logout sadece cookie siliyorsa token hala geçerli mi?
- [ ] **Token rotation:** Refresh token mekanizması var mı?
- [ ] **Session cleanup:** Süresi dolmuş session'lar temizleniyor mu?

### 4b. CSP (Content-Security-Policy)
- [ ] `grep("contentSecurityPolicy|helmet.*csp|CSP", "src/**")` — CSP header tanımlı mı?
- [ ] Helmet kullanılsa bile default CSP koymaz — explicit yapılandırma gerekli
- [ ] Inline script/style izinleri doğru mu?

### 4c. CSRF Protection
- [ ] State-changing endpoint'ler (POST, PUT, DELETE) CSRF token içeriyor mu?
- [ ] `grep("csrf|csurf|csrfToken|_token", "src/**")` — CSRF middleware var mı?
- [ ] SameSite cookie kullanılıyor mu? (Strict/Lax — None değil)
- [ ] Custom header check (X-Requested-With, X-CSRF-Token) var mı?
- [ ] **Not:** SameSite=Strict cookie + CORS origin whitelist iyi koruma sağlar ama OWASP best practice: explicit CSRF token mekanizması

### 4d. API Tutarlılık
- REST conventions doğru mu?
- HTTP status codes doğru mu?
- Error response formatı tutarlı mı?
- **Her frontend'den çağrılan endpoint var mı?** (404 riski)

## Adım 5: Error Handling

- Global error handler var mı?
- Try/catch blokları var mı?
- Error mesajlarında sensitive bilgi sızdırıyor mu?
- **Async unhandledRejection:** `process.on("unhandledRejection")` handler var mı?

## Adım 6: Rapor Yaz

`reports/backend/backend-audit-YYYYMMDD-HHMM.md` dosyasını oluştur:

```markdown
# 🔒 Backend Audit Raporu
- **Tarih:**
- **Toplam Endpoint:**
- **Toplam Bulgu:**

## Kritik 🔴
| # | Bulgu | Dosya | Satır | Açıklama |

## Yüksek 🟠
...

## Sık Kaçırılanlar Kontrol Listesi
| # | Kontrol | Durum | Detay |
|---|---------|:-----:|-------|
| 1 | Helmet/Security headers | ✅/❌ | |
| 2 | Rate limiting | ✅/❌ | |
| 3 | bcrypt salt rounds ≥ 10 | ✅/❌ | |
| 4 | Upload path traversal koruması | ✅/❌ | |
| 5 | Prototype pollution guard | ✅/❌ | |
| 6 | Paylaşılan config scope | ✅/❌ | |
| 7 | Utility logic bugs (getMonth vb.) | ✅/❌ | |
| 8 | Kullanılmayan import'lar | ✅/❌ | |
| 9 | Logout/token revocation | ✅/❌ | |
| 10 | CSP header | ✅/❌ | |

## API Analizi
| Method | Path | Validation | Auth | Logout | Status |
```

## Adım 7: Handoff Güncelle

```markdown
## Backend Audit - TAMAMLANDI
- **Toplam Bulgu:**
- **Kritik Sayısı:**
- **Sık Kaçırılanlar Durumu:** (hangi kontroller geçti/kaldı)
- **Logout endpoint:** Var/Yok
- **CSP:** Var/Yok
- **Sonraki Ajan İçin Öneri:** Backend fix'e geç
```
