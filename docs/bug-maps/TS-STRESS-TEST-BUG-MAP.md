# 🗺️ TYPESCRIPT STRESS TEST — GOLDEN TRUTH BUG MAP
**Proje:** `/home/user/ts-stress-test/` (TaskFlow TS — TypeScript + Express)
**Toplam Bug:** 62 (10 boyut)
**Amaç:** OpenCode Audit Kit'in TypeScript projesindeki bulma/düzeltme oranını ölçmek

---

## 🔒 SECURITY (12 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| S1 | No helmet | server.js:14 | Security headers yok |
| S2 | No rate limiting | server.js:15 | Brute force açık |
| S3 | CORS wide open | server.js:16 | `cors()` her origin |
| S4 | Weak JWT secret | env.ts:4 | `"secret"` hardcoded |
| S5 | bcrypt salt=5 | env.ts:5 | Min 10 olmalı |
| S6 | Password hash in response | server.js register | `user: user` tüm objeyi döner |
| S7 | No logout endpoint | — | Token revoke yok |
| S8 | Token in localStorage | index.html JS | httpOnly cookie değil |
| S9 | No auth on admin routes | server.js:125,135 | Role check yok |
| S10 | Admin returns password hashes | server.js:127 | `getAllUsers()` hash'lerle |
| S11 | Mass assignment on PUT | server.js:110 | `for (key in req.body)` |
| S12 | XSS via innerHTML | index.html loadTasks | `t.title` escape edilmiyor |

## ⚡ PERFORMANCE (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| P1 | No pagination on tasks | GET /api/tasks | Tüm task'ları döndürür |
| P2 | N+1: comments per task | GET /api/tasks | Her task için ayrı getCommentsByTask |
| P3 | N+1: assignee per task | GET /api/tasks | Her task için ayrı getUserById |
| P4 | Sync file write | POST /api/tasks | `fs.writeFileSync` event loop bloke |
| P5 | No pagination on search | GET /api/search | Tüm sonuçlar döner |
| P6 | JS counting in stats | GET /api/admin/stats | `.length` + `.filter` |

## 🔍 CODE QUALITY (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| KQ1 | No password length check | server.js register | 1 karakter şifre kabul |
| KQ2 | Wrong status codes | server.js multiple | Error'larda 200 dönüyor |
| KQ3 | Generic error handler | server.js bottom | `res.json({error:"Error"})` 200 ile |
| KQ4 | No title validation | POST /api/tasks | Boş title kabul |
| KQ5 | Token not Bearer stripped | server.js auth() | "Bearer xxx" doğrulanamaz |
| KQ6 | `var` instead of `const`/`let` | database.ts | Modern JS değil |

## 🏗️ ARCHITECTURE (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| AR1 | Business logic in route | server.js POST /api/tasks | Priority validation route'ta |
| AR2 | Fat controller | server.js POST /api/tasks | File write + logging route'ta |
| AR3 | Hardcoded config | server.js | PORT=3000, SECRET="secret" |
| AR4 | No config file | — | Tüm config server.js içinde |
| AR5 | No service layer | — | Tüm logic route handler'larda |
| AR6 | Inconsistent error handling | server.js | Bazı try/catch var, bazıları yok |

## 🧪 TEST (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| T1 | Zero tests | — | Hiç test yok |
| T2 | CI broken | ci.yml | `npm test` = exit 1 |
| T3 | No test framework | package.json | Jest/Vitest yok |
| T4 | No checkout step | ci.yml | checkout action yok |
| T5 | No edge case tests | — | — |
| T6 | No integration tests | — | — |

## ♿ ACCESSIBILITY (7 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| A1 | No `<html lang>` | index.html | `lang` attribute yok |
| A2 | No `<meta charset>` | index.html | charset tanımsız |
| A3 | No `<meta viewport>` | index.html | Mobil zoom yok |
| A4 | No label-input binding | index.html | Hiç `<label>` yok |
| A5 | No ARIA attributes | index.html | Screen reader desteği yok |
| A6 | No keyboard modal close | index.html | ESC ile modal kapanmaz |
| A7 | No focus management | index.html | Modal açılınca focus taşınmaz |

## 🎨 UX (7 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| U1 | Search doesn't work | index.html | Empty event handler |
| U2 | Filter doesn't work | index.html | Empty event handler |
| U3 | No login error feedback | index.html | Başarısız girişte mesaj yok |
| U4 | Task create no feedback | index.html | Modal kapanmaz, liste yenilenmez |
| U5 | No loading state | index.html | Spinner/loading yok |
| U6 | No responsive design | index.html | Media query yok |
| U7 | No empty state | index.html | "No tasks" mesajı yok |

## 🚀 DEVOPS (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| D1 | Dockerfile runs as root | Dockerfile | USER directive yok |
| D2 | No .dockerignore | — | .env image'da |
| D3 | No health check | — | /health endpoint yok |
| D4 | CI missing checkout | ci.yml | checkout action yok |
| D5 | npm install (not ci) | ci.yml | Production'da yavaş |
| D6 | No graceful shutdown | server.js | SIGTERM handler yok |

## 🔎 SEO (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| SEO1 | No meta description | index.html | `<meta name="description">` yok |
| SEO2 | No canonical URL | index.html | canonical link yok |
| SEO3 | No Open Graph | index.html | OG tags yok |
| SEO4 | No structured data | index.html | JSON-LD yok |
| SEO5 | No semantic HTML | index.html | `<div>` soup |
| SEO6 | No robots.txt | — | yok |

## 📚 DOCUMENTATION (5 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| DOC1 | No README.md | — | yok |
| DOC2 | No API docs | — | yok |
| DOC3 | No inline comments | server.js | Karmaşık logic yorumlanmamış |
| DOC4 | No CONTRIBUTING.md | — | yok |
| DOC5 | No .env.example | — | yok |

---

## SCORE TRACKER

| Boyut | Toplam | Buldu | Düzeltti | Skor |
|-------|:------:|:-----:|:--------:|:----:|
| Security | 12 | ? | ? | ?% |
| Performance | 6 | ? | ? | ?% |
| Code Quality | 6 | ? | ? | ?% |
| Architecture | 6 | ? | ? | ?% |
| Test | 6 | ? | ? | ?% |
| Accessibility | 7 | ? | ? | ?% |
| UX | 7 | ? | ? | ?% |
| DevOps | 6 | ? | ? | ?% |
| SEO | 6 | ? | ? | ?% |
| Documentation | 5 | ? | ? | ?% |
| **TOTAL** | **67** | ? | ? | ?% |
