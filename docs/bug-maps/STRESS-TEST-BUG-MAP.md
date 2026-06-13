# 🗺️ STRESS TEST — GOLDEN TRUTH BUG MAP
**Proje:** `/home/user/stress-test-project/` (TaskFlow — Task Management App)
**Toplam Bug:** 60 (10 boyut × 6 bug)
**Amaç:** OpenCode'un ne kadarını bulup düzeltebildiğini ölçmek

---

## 🔒 SECURITY (7 bugs)

| # | Bug | Dosya | Açıklama | Severity |
|---|-----|-------|----------|----------|
| S1 | No helmet | server.js:14 | Security headers yok | High |
| S2 | No rate limiting | server.js:15 | Brute force açık | High |
| S3 | CORS wide open | server.js:16 | `cors()` — her origin izinli | High |
| S4 | Weak JWT secret | server.js:19 | `"secret"` hardcoded | Critical |
| S5 | bcrypt salt rounds = 5 | server.js:32 | Çok düşük, min 10 olmalı | High |
| S6 | Password hash in response | server.js:36 | `user: user` tüm user objesini döndürür | Critical |
| S7 | No logout endpoint | — | Token revoke yok | Medium |
| S8 | Token in localStorage | index.html JS | HttpOnly cookie değil | Medium |
| S9 | No auth on admin routes | server.js:125,135 | `/api/admin/*` role check yok | Critical |
| S10 | Admin returns password hashes | server.js:127 | `getAllUsers()` hash'lerle birlikte | Critical |
| S11 | Mass assignment on PUT | server.js:110 | `for (key in req.body)` — id, userId overwrite | High |
| S12 | XSS via innerHTML | index.html loadTasks | `t.title`, `t.desc` escape edilmiyor | Critical |

## ⚡ PERFORMANCE (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| P1 | No pagination on tasks | server.js GET /api/tasks | Tüm task'ları döndürür |
| P2 | N+1: comments per task | server.js GET /api/tasks | Her task için ayrı getCommentsByTask |
| P3 | N+1: assignee per task | server.js GET /api/tasks | Her task için ayrı getUserById |
| P4 | Sync file write | server.js POST /api/tasks | `fs.writeFileSync` event loop bloke |
| P5 | No pagination on search | server.js GET /api/search | Tüm sonuçlar döner |
| P6 | JS counting in stats | server.js GET /api/admin/stats | tasks.length + for loop count |

## 🔍 CODE QUALITY (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| KQ1 | No password length check | server.js register | 1 karakter şifre kabul |
| KQ2 | Wrong status codes | server.js multiple | Error'larda 200 dönüyor |
| KQ3 | Generic error handler | server.js bottom | `res.json({error:"Error"})` 200 ile |
| KQ4 | No title validation | server.js POST /api/tasks | Boş title kabul |
| KQ5 | Token not Bearer stripped | server.js auth() | "Bearer xxx" doğrulanamaz |
| KQ6 | `var` instead of `const`/`let` | database.js | Modern JS değil |

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
| T3 | No test framework | package.json | Jest yok |
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
| D5 | npm install (not ci) | ci.yml | `npm install` production'da yavaş |
| D6 | No graceful shutdown | server.js | SIGTERM handler yok |

## 🔎 SEO (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| S1 | No meta description | index.html | `<meta name="description">` yok |
| S2 | No canonical URL | index.html | canonical link yok |
| S3 | No Open Graph | index.html | OG tags yok |
| S4 | No structured data | index.html | JSON-LD yok |
| S5 | No semantic HTML | index.html | `<div>` soup |
| S6 | No robots.txt | — | yok |

## 📚 DOCUMENTATION (5 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| DOC1 | No README.md | — | yok |
| DOC2 | No API docs | — | yok |
| DOC3 | No inline comments | server.js | Karmaşık logic yorumlanmamış |
| DOC4 | No CONTRIBUTING.md | — | yok |
| DOC5 | No .env.example | — | yok |

---

## SCORE TRACKER (Boş — test sonrası doldurulacak)

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
