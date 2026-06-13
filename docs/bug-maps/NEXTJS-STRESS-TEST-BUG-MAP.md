# 🗺️ Next.js STRESS TEST — BUG MAP
**Proje:** `/home/user/nextjs-stress-test/` (TaskFlow — Next.js App Router)
**Toplam Bug:** 62 (10 boyut)
**Amaç:** OpenCode'un ne kadarını bulup düzeltebildiğini ölçmek

---

## 🔒 SECURITY (12 bugs)

| # | Bug | Dosya | Açıklama | Severity |
|---|-----|-------|----------|----------|
| S1 | No security headers | next.config.js | Empty config | High |
| S2 | No rate limiting | — | No middleware | High |
| S3 | CORS wide open | — | No CORS check | High |
| S4 | Weak JWT secret | route.js:5 | `"secret"` hardcoded | Critical |
| S5 | bcrypt rounds = 5 | register/route.js | Too low, min 10 | High |
| S6 | Password hash in response | register/login | `user` object returned | Critical |
| S7 | No logout endpoint | — | Token revoke yok | Medium |
| S8 | Token in localStorage | page.js | httpOnly cookie değil | Medium |
| S9 | No auth on admin routes | admin/users | No role check | Critical |
| S10 | Admin returns password hashes | admin/users | `getAllUsers()` raw | Critical |
| S11 | Mass assignment on POST | tasks/route | `...body` spread | High |
| S12 | XSS via dangerouslySetInnerHTML | page.js | `t.title` unescaped | Critical |

## ⚡ PERFORMANCE (6 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| P1 | No pagination | GET /api/tasks | All tasks returned |
| P2 | N+1: comments per task | tasks GET | getCommentsByTaskId per task |
| P3 | No batch assignee | tasks GET | Per-task user lookup |
| P4 | Sync operations | — | No async writes |
| P5 | No search pagination | GET /api/search | All results returned |
| P6 | No caching | — | No caching headers |

## 🔍 CODE QUALITY (6 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| KQ1 | No password length check | register | password < 8 accepted |
| KQ2 | Missing status codes | routes | No 201/409/403 |
| KQ3 | No error handling class | — | Raw try/catch only |
| KQ4 | No title validation | tasks POST | Empty title accepted |
| KQ5 | No Bearer strip | routes | Full header used as token |
| KQ6 | No service layer | — | Logic in route handlers |

## 🏗️ ARCHITECTURE (6 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| AR1 | No service layer | — | src/lib/ missing |
| AR2 | No logic extraction | — | All logic in routes |
| AR3 | No env config | — | process.env not used |
| AR4 | No config file | — | src/lib/config.js missing |
| AR5 | No lib files | — | src/lib/ empty |
| AR6 | No consistent errors | — | No error class/middleware |

## 🧪 TEST (6 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| T1 | No tests | — | No test files |
| T2 | No CI | — | No GitHub Actions |
| T3 | No test framework | — | jest/vitest not installed |
| T4 | No CI checkout | — | No actions/checkout |
| T5 | No edge cases | — | No boundary tests |
| T6 | No integration tests | — | No supertest/fetch |

## ♿ ACCESSIBILITY (7 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| A1 | No lang attr | layout.js | `<html>` without lang |
| A2 | No charset | layout.js | No meta charset |
| A3 | No viewport | layout.js | No viewport meta |
| A4 | No labels | page.js | Inputs without label |
| A5 | No ARIA | page.js | No aria attributes |
| A6 | No ESC close | page.js | No keyboard handler |
| A7 | No focus mgmt | page.js | No focus management |

## 🎨 UX (7 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| U1 | No search | page.js | No search functionality |
| U2 | No filter | page.js | No status filter |
| U3 | No error feedback | page.js | No error display |
| U4 | No create feedback | page.js | No success/error feedback |
| U5 | No loading state | page.js | No loading indicator |
| U6 | No responsive | page.js | No @media queries |
| U7 | No empty state | page.js | No empty state display |

## 🚀 DEVOPS (6 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| D1 | No Dockerfile | — | No containerization |
| D2 | No .dockerignore | — | No ignore file |
| D3 | No health check | — | No /api/health |
| D4 | No CI | — | No GitHub Actions |
| D5 | No lockfile install | — | No npm ci |
| D6 | No graceful shutdown | — | No SIGTERM handler |

## 🔎 SEO (6 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| SEO1 | No meta description | layout.js | No description meta |
| SEO2 | No canonical | layout.js | No canonical URL |
| SEO3 | No OG tags | layout.js | No open graph |
| SEO4 | No JSON-LD | — | No structured data |
| SEO5 | No semantic HTML | page.js | All <div> tags |
| SEO6 | No robots.txt | — | No robots.txt |

## 📚 DOCUMENTATION (5 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| DOC1 | No README | — | README.md missing |
| DOC2 | No API docs | — | No endpoint documentation |
| DOC3 | No comments | — | 0 inline comments |
| DOC4 | No CONTRIBUTING | — | CONTRIBUTING.md missing |
| DOC5 | No .env.example | — | .env.example missing |
