# 🗺️ Audit Kit Framework Genişletme Planı

## Mevcut Durum
- Audit kit sadece **Express.js (vanilla JS)** projelerini test ediyor
- 4 iteration test + 1 stress test = hepsi Express/JS
- Gerçek dünyada projeler TypeScript, NestJS, FastAPI, Next.js kullanıyor

## Hedef
Audit kit'i **framework-agnostic** yapmak: Express, TypeScript/Express, NestJS, FastAPI

## Değer Önermesi

| Katkı | Açıklama |
|-------|----------|
| **TypeScript desteği** | Şu an sadece JS projeleri denetlenebiliyor, TS eklenince kapsama 2x artar |
| **Python/FastAPI desteği** | Backend dünyasının %30'u Python, bu açığı kapatır |
| **Cross-framework pattern bilgisi** | "İyi kod" şablonu olarak reference architecture |
| **NestJS decorator güvenlik denetimi** | Guard, Module, Interceptor pattern'leri için özel audit |
| **WebSocket güvenlik denetimi** | Hiçbir test projemizde WS yok, bu eklenti ile gelir |

## Uygulama Planı

### Aşama 1: Bug'lı Test Projeleri Oluştur (Öncelik: YÜKSEK)

nodeJS.md'den → `iteration-test-5/` (TypeScript/Express, 25 bilinen bug)
test python.md'den → `iteration-test-6/` (FastAPI/Python, 20 bilinen bug)

Her birine bilinen bug'lar inject et:

**TypeScript/Express Bug Haritası (25 bug):**
- S1: No helmet
- S2: No rate limiting
- S3: CORS wide open
- S4: JWT secret hardcoded in env.ts
- S5: Plain text passwords (no bcrypt)
- S6: Password in login response
- S7: No logout endpoint
- S8: Token not httpOnly cookie
- S9: No auth on admin routes
- S10: Admin returns passwords
- S11: No input validation on register
- S12: No file type validation on upload
- P1: No pagination
- P2: Sync file operations
- P3: No caching headers
- KQ1: No password length check
- KQ2: Wrong status codes (200 for errors)
- KQ3: No TypeScript strict mode
- AR1: No config file (env values inline)
- AR2: No service layer (logic in routes)
- AR3: No error handling middleware
- T1: Zero tests
- T2: No test framework
- D1: No Dockerfile
- D2: No .env.example

**FastAPI Bug Haritası (20 bug):**
- S1: No CORS middleware
- S2: No rate limiting
- S3: JWT secret hardcoded
- S4: Plain text passwords
- S5: No password validation
- S6: No logout
- S7: Token in response body not cookie
- S8: No auth on some routes
- S9: No input sanitization
- S10: No file size check (server-side)
- P1: No pagination
- P2: No async DB operations
- KQ1: No type validation on some endpoints
- KQ2: Generic error responses
- AR1: Business logic in route handlers
- AR2: No dependency injection for services
- T1: Zero tests
- T2: No test configuration
- D1: No Dockerfile
- D2: No .env.example

### Aşama 2: Framework-Specific Audit Skills Ekle (Öncelik: ORTA)

Yeni skill dosyaları:

1. `global/skills/audit-typescript/SKILL.md`
   - TypeScript-specific: strict mode, type safety, any usage
   - Decorator patterns, interface compliance
   - ESM vs CommonJS issues

2. `global/skills/audit-fastapi/SKILL.md`
   - Python-specific: type hints, async patterns, Pydantic validation
   - FastAPI patterns: dependency injection, middleware, WebSocket
   - Security: CORS, rate limiting, JWT with passlib

3. `global/skills/audit-nestjs/SKILL.md`
   - NestJS-specific: Guard effectiveness, Module boundaries
   - Decorator security: @UseGuards, @Roles
   - Interceptor/Filter patterns

4. `global/skills/fix-typescript/SKILL.md`
   - TypeScript fix patterns: strict mode enable, type assertions
   - ESM import fixes, .js extension requirements

5. `global/skills/fix-fastapi/SKILL.md`
   - Python fix patterns: bcrypt, JWT, rate limiting
   - Pydantic models, dependency injection setup

### Aşama 3: Master Orchestrator Framework Algılama (Öncelik: ORTA)

```markdown
## Adım 0.5: Framework Algılama

Proje tipini tespit et:
- `package.json` + `tsconfig.json` → TypeScript/Node
- `package.json` + `@nestjs/core` → NestJS
- `package.json` + `next` → Next.js
- `requirements.txt` + `fastapi` → FastAPI/Python
- `package.json` sadece → Express/JS

Framework'e göre skill seç:
- Express/JS → mevcut akış
- TypeScript/Node → +audit-typescript, +fix-typescript
- NestJS → +audit-nestjs
- FastAPI → +audit-fastapi, +fix-fastapi
- Next.js → +audit-frontend (Next.js özel)
```

### Aşama 4: Reference Architecture Şablonları (Öncelik: DÜŞÜK)

nodeJS.md ve test python.md'nin temiz kodunu "reference architecture" olarak skill'lere ekle:

```markdown
## Reference: TypeScript/Express İyi Örnek

### Config Pattern (src/config/env.ts)
[buraya nodeJS.md'deki env.ts kodu]

### Service Layer Pattern (src/services/authService.ts)
[buraya nodeJS.md'deki authService.ts kodu]

### Middleware Pattern (src/middleware/auth.ts)
[buraya nodeJS.md'deki auth middleware kodu]
```

Bu sayede fix skill'leri "nasıl düzeltmeli" şablonuna sahip olur.

## Öncelik Sırası

1. 🔴 **Aşama 1** — Bug'lı test projeleri oluştur (bunun olmadan test edemeyiz)
2. 🟡 **Aşama 2** — Framework-specific skill'ler (TypeScript ve FastAPI audit)
3. 🟡 **Aşama 3** — Framework algılama (orchestrator güncelleme)
4. 🟢 **Aşama 4** — Reference architecture (nice-to-have)

## Tahmini Efor

| Aşama | Süre | Risk |
|-------|------|------|
| Aşama 1 | 2-3 saat | Düşük (şablon hazır, bug inject et) |
| Aşama 2 | 3-4 saat | Orta (yeni skill yazımı) |
| Aşama 3 | 1 saat | Düşük (orchestrator güncelleme) |
| Aşama 4 | 1 saat | Düşük (kopyala-yapıştır) |
| **Toplam** | **7-9 saat** | |

## Kriter: Katkısı olur mu?

### EVET, çünkü:
1. **Kapsama alanı 3x artar** — JS → JS + TS + Python
2. **Gerçek dünya projeksiyonu** — Production projelerinin %70'i TypeScript veya Python
3. **Framework-specific güvenlik** — NestJS guard, FastAPI dependency injection gibi pattern'ler JS'de yok
4. **WebSocket güvenlik denetimi** — İlk kez WS audit yapabiliriz
5. **Çapraz-framework karşılaştırma** — "Express vs NestJS vs FastAPI güvenlik açıkları" raporu üretebiliriz

### RİSKLER:
1. **Skill şişkinliği** — 36 skill + 5 yeni = 41 skill, karmaşıklık artar
2. **Bakım yükü** — Her framework sürüm güncellemesinde skill'leri de güncellemek lazım
3. **LLM non-determinism** — Farklı framework'lerde farklı hatalar çıkabilir
4. **Python ortamı** — pip/venv gerektirir, Node.js kadar basit değil
