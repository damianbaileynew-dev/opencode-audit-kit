# NestJS Stress Test Bug Map

**Proje:** `/home/user/nestjs-stress-test/` (TaskFlow API — NestJS + TypeScript)
**Toplam Bug:** 62 (10 boyut)
**Baseline Score:** 8% (6/67)

---

## 🔒 SECURITY (12 bugs)
| # | Bug | Dosya | Açıklama |
|---|-----|-------|----------|
| S1 | No helmet | main.ts | Security headers yok |
| S2 | No rate limiting | main.ts | @nestjs/throttler yok |
| S3 | CORS wildcard | config/env.ts | `CORS_ORIGIN: "*"` |
| S4 | Weak JWT secret | config/env.ts | `SECRET: "secret"` hardcoded |
| S5 | bcrypt rounds=5 | config/env.ts | `BCRYPT_ROUNDS: 5` (min 10) |
| S6 | Password hash in response | auth.controller.ts | `{ user }` tüm objeyi döner |
| S7 | No logout endpoint | — | Logout yok |
| S8 | Token in localStorage | public/index.html | httpOnly cookie değil |
| S9 | No admin guard | admin.controller.ts | @Roles yok |
| S10 | Admin returns passwords | admin.controller.ts | `_users` hash'lerle |
| S11 | Mass assignment | tasks.controller.ts | `...body` doğrudan |
| S12 | XSS via innerHTML | public/index.html | `t.title` escape değil |

## ⚡ PERFORMANCE (6 bugs)
| P1 | No pagination | GET /api/tasks | Tüm task'lar |
| P2 | N+1 comments | GET /api/tasks | filter per task |
| P3 | N+1 assignee | GET /api/tasks | search per task |
| P4 | Sync file write | POST /api/tasks | `writeFileSync` |
| P5 | No search pagination | GET /api/search | Tüm sonuçlar |
| P6 | JS counting | GET /api/admin/stats | `.length` + `.filter` |

## 🔍 CODE QUALITY (6 bugs)
| KQ1 | No password length check | UserRegister DTO | 1 karakter şifre |
| KQ2 | Wrong status codes | tasks.controller.ts | status 200 for errors |
| KQ3 | Bare catch | auth.controller.ts | Generic catch |
| KQ4 | No title validation | CreateTask DTO | Boş title |
| KQ5 | No Bearer strip | getUser() | "Bearer xxx" decode |
| KQ6 | var kullanımı | — | const/let yok (NestJS'de genelde yok) |

## 🏗️ ARCHITECTURE (6 bugs)
| AR1 | No service layer | — | Logic in controllers |
| AR2 | Fat controllers | — | File write in controller |
| AR3 | Hardcoded config | config/env.ts | SECRET, PORT hardcoded |
| AR4 | No proper config | config/env.ts | process.env yok |
| AR5 | No *.service.ts files | — | No NestJS services |
| AR6 | No exception filter | — | No global @Catch() filter |

## 🧪 TEST (6 bugs)
| T1 | Zero tests | — | Hiç test yok |
| T2 | CI broken | ci.yml | npm test fail |
| T3 | No test framework | package.json | jest/supertest yok |
| T4 | No checkout | ci.yml | actions/checkout yok |
| T5 | No edge case tests | — | — |
| T6 | No integration tests | — | — |

## ♿ ACCESSIBILITY (7), 🎨 UX (7), 🚀 DEVOPS (6), 🔎 SEO (6), 📚 DOCUMENTATION (5)
Express/TS ile aynı bug'lar — HTML frontend ve Dockerfile/CI aynı sorunları içeriyor.

---

## BASELINE: 8% (6/67) — 0/10 boyut geçti
