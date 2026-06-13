# FastAPI Stress Test Bug Map

**Proje:** `/home/user/fastapi-stress-test/` (TaskFlow API — FastAPI + Python)
**Toplam Bug:** 62 (10 boyut)
**Amaç:** OpenCode Audit Kit'in FastAPI/Python projesindeki bulma/düzeltme oranını ölçmek

---

## 🔒 SECURITY (12 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| S1 | No CORS middleware | main.py | CORSMiddleware hiç eklenmemiş |
| S2 | No rate limiting | main.py | slowapi veya custom rate limit yok |
| S3 | CORS wide open | main.py:7 | `CORS_ORIGINS = "*"` ama middleware bile yok |
| S4 | Weak JWT secret | main.py:6 | `SECRET = "secret"` hardcoded |
| S5 | bcrypt rounds=5 | main.py:7 | `BCRYPT_ROUNDS = 5` (min 10 olmalı) |
| S6 | Password hash in response | main.py:88 | `{"user": user}` tüm objeyi döner |
| S7 | No logout endpoint | — | Token revoke yok |
| S8 | Token in localStorage | index.html JS | httpOnly cookie değil |
| S9 | No auth on admin routes | main.py:157,163 | Role check yok |
| S10 | Admin returns password hashes | main.py:157 | `_users` hash'lerle döner |
| S11 | Mass assignment | main.py:56-60 | TaskUpdate'de `role`, `is_admin`, `user_id` var |
| S12 | XSS via innerHTML | index.html loadTasks | `t.title` escape edilmiyor |

## ⚡ PERFORMANCE (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| P1 | No pagination on tasks | GET /api/tasks | Tüm task'ları döndürür |
| P2 | N+1: comments per task | GET /api/tasks | Her task için _comments filter |
| P3 | N+1: assignee per task | GET /api/tasks | Her task için _users search |
| P4 | Sync file write | POST /api/tasks | `open("task_log.json", "w")` event loop bloke |
| P5 | No search pagination | GET /api/search | Tüm sonuçlar döner |
| P6 | Python counting in stats | GET /api/admin/stats | `len()` + list comprehension |

## 🔍 CODE QUALITY (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| KQ1 | No password length check | UserRegister model | 1 karakter şifre kabul |
| KQ2 | Wrong status codes | main.py:107 | `status_code=200` for invalid priority |
| KQ3 | Generic error handler | main.py:45 | Bare `except:` with generic message |
| KQ4 | No title validation | TaskCreate model | Boş title kabul |
| KQ5 | Token not Bearer stripped | get_current_user | "Bearer xxx" doğrulanamaz |
| KQ6 | Bare except | main.py:45 | `except:` instead of `except PyJWTError:` |

## 🏗️ ARCHITECTURE (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| AR1 | Business logic in route | POST /api/tasks | Priority validation route'ta |
| AR2 | Fat controller | POST /api/tasks | File write + logging route'ta |
| AR3 | Hardcoded config | main.py:5-7 | PORT=8000, SECRET="secret" |
| AR4 | No config file | — | Tüm config main.py içinde |
| AR5 | No service layer | — | Tüm logic route handler'larda |
| AR6 | Inconsistent error handling | main.py | Bazı try/catch var, bazıları yok |

## 🧪 TEST (6 bugs)

| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| T1 | Zero tests | — | Hiç test yok |
| T2 | CI broken | ci.yml | pytest çalışmaz (requirements.txt'de yok) |
| T3 | No test framework | requirements.txt | pytest yok |
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
| U1 | Search doesn't work | index.html | Event listener yok |
| U2 | Filter doesn't work | index.html | Empty function body |
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
| D5 | pip install no cache | ci.yml | --no-cache-dir yok |
| D6 | No graceful shutdown | main.py | SIGTERM handler yok |

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
| DOC3 | No inline comments | main.py | Yorum yok |
| DOC4 | No CONTRIBUTING.md | — | yok |
| DOC5 | No .env.example | — | yok |

---

## BASELINE SCORE (Scorer Output)

| Boyut | Toplam | Düzeltilmemiş | Skor |
|-------|:------:|:------------:|:----:|
| Security | 12 | 0 | 0% |
| Performance | 6 | 1 | 16% |
| Code Quality | 6 | 2 | 33% |
| Architecture | 6 | 1 | 16% |
| Test | 6 | 0 | 0% |
| Accessibility | 7 | 0 | 0% |
| UX | 7 | 0 | 0% |
| DevOps | 6 | 0 | 0% |
| SEO | 6 | 0 | 0% |
| Documentation | 5 | 0 | 0% |
| **TOTAL** | **67** | **4** | **5%** |
