---
name: fix-fastapi
description: >-
  FastAPI/Python projesindeki tüm 10 boyuttaki sorunları düzeltir.
  Trigger: "fix fastapi", "fastapi fix", "python fix", "audit fastapi"
  Framework: FastAPI + Python + Uvicorn
---

# Skill: FastAPI Full Audit & Fix

**Amaç:** FastAPI/Python projesindeki tüm güvenlik, performans, kod kalitesi, mimari, test, erişilebilirlik, UX, DevOps, SEO ve dokümantasyon sorunlarını düzeltmek.

## Framework Tespiti

Eğer projede `requirements.txt` içinde `fastapi` veya `main.py`/`app/main.py` içinde `from fastapi import FastAPI` varsa, BU skill kullanılmalıdır.

---

## ADIM 1: Mevcut Durumu Oku

```python
read("main.py")
read("app/main.py")
read("requirements.txt")
read("Dockerfile")
read(".github/workflows/ci.yml")
```

Ayrıca frontend HTML varsa (HTMLResponse veya templates/index.html):
```python
read("app/templates/index.html")
read("templates/index.html")
read("static/index.html")
```

---

## ADIM 2: Güvenlik Fixleri (12 bug)

| Bug | Fix | Priority |
|-----|-----|:--------:|
| S1: CORS Middleware yok | `CORSMiddleware` ekle | ZORUNLU |
| S2: Rate Limiting yok | `slowapi` ile rate limit | ZORUNLU |
| S3: CORS `*` yerine restricted | `allow_origins=["..."]` | ZORUNLU |
| S4: JWT Secret hardcoded | `os.environ["JWT_SECRET"]` | ZORUNLU |
| S5: bcrypt salt < 10 | `bcrypt.gensalt(rounds=12)` | ZORUNLU |
| S6: Password hash response'da | `sanitize_user()` ekle | ZORUNLU |
| S7: Logout endpoint yok | `POST /api/auth/logout` ekle | ZORUNLU |
| S8: Cookie httpOnly yok | `response.set_cookie(httponly=True, ...)` | ZORUNLU |
| S9: Admin route auth yok | `Depends(get_current_admin)` ekle | ZORUNLU |
| S10: Admin response password | `sanitize_user()` admin'de de | ZORUNLU |
| S11: Mass assignment | Pydantic model ile whitelist | ZORUNLU |
| S12: XSS frontend | `textContent` veya `escapeHtml()` | ZORUNLU |

→ **Full fix templates with code**: `references/fastapi-fix-templates.md` (ADIM 2 section)

## ADIM 3: Performans Fixleri (6 bug)

| Bug | Fix | Priority |
|-----|-----|:--------:|
| P1: Pagination yok | `skip/limit` params ekle | ZORUNLU |
| P2: N+1 comments | `include` ile batch query | P1 |
| P3: N+1 assignee | Eager loading | P1 |
| P4: Sync file write | `aiofiles` ile async | P1 |
| P5: Search pagination yok | Search'e de `skip/limit` | ZORUNLU |
| P6: In-memory counting | DB aggregation | P2 |

→ **Full fix templates**: `references/fastapi-fix-templates.md` (ADIM 3 section)

## ADIM 4: Kod Kalitesi Fixleri (6 bug)

| Bug | Fix | Priority |
|-----|-----|:--------:|
| KQ1: Password length check yok | `Field(min_length=8)` | ZORUNLU |
| KQ2: HTTP status codes yanlış | `201`, `404`, `422` düzelt | P1 |
| KQ3: Generic error handling | Specific exception classes | P1 |
| KQ4: Title validation yok | `Field(min_length=1)` | ZORUNLU |
| KQ5: Bearer token strip | `.replace("Bearer ", "")` | ZORUNLU |
| KQ6: Python best practices | Type hints, `if __name__` | P2 |

→ **Full fix templates**: `references/fastapi-fix-templates.md` (ADIM 4 section)

## ADIM 5: Mimari Fixleri (6 bug)

| Bug | Fix | Priority |
|-----|-----|:--------:|
| AR1-AR2-AR5: Service layer yok | `app/services/` oluştur | ZORUNLU |
| AR3-AR4: Config file yok | `app/config.py` oluştur | ZORUNLU |
| AR6: Error handling tutarsız | Centralized `HTTPException` | P1 |

→ **Full fix templates**: `references/fastapi-fix-templates.md` (ADIM 5 section)

## ADIM 6: Test Fixleri (6 bug)

| Bug | Fix | Priority |
|-----|-----|:--------:|
| T1: Test framework yok | `pytest` + `httpx` kur | ZORUNLU |
| T2: Integration test yok | `TestClient` ile API test | ZORUNLU |
| T3: Auth edge cases yok | Invalid login, empty input test | P1 |
| T4: Admin route test yok | 403 for non-admin test | P1 |
| T5: Test config yok | `conftest.py` oluştur | P2 |
| T6: CI pipeline yok | `.github/workflows/ci.yml` | P2 |

→ **Full fix templates**: `references/fastapi-fix-templates.md` (ADIM 6 section)

## ADIM 7: Erişilebilirlik Fixleri (7 bug)

Label-input binding, alt text, ARIA live regions, keyboard navigation, semantic HTML, skip link, focus visible.

→ **Full fix templates**: `references/fastapi-fix-templates.md` (ADIM 7 section)

## ADIM 8: UX Fixleri (7 bug)

Loading states, search feedback, responsive design, empty states, logout visibility, form validation feedback, error messages.

→ **Full fix templates**: `references/fastapi-fix-templates.md` (ADIM 8 section)

## ADIM 9: DevOps Fixleri (6 bug)

### D1: Dockerfile Non-Root User
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd -m appuser
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')"

CMD ["python", "main.py"]
```

### D2: .dockerignore Oluştur
```
.git
.env
__pycache__
*.pyc
.venv
venv
.pytest_cache
task_log.json
```

### D3: Health Endpoint
```python
@app.get("/api/health")
def health():
    return {"ok": True, "status": "healthy"}
```

### D6: Graceful Shutdown
```python
import signal
import sys

def graceful_shutdown(signum, frame):
    logger.info("Shutting down gracefully...")
    sys.exit(0)

signal.signal(signal.SIGTERM, graceful_shutdown)
signal.signal(signal.SIGINT, graceful_shutdown)
```

Veya FastAPI lifespan:
```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up...")
    yield
    logger.info("Shutting down gracefully...")

app = FastAPI(lifespan=lifespan)
```

---

## ADIM 10: SEO Fixleri (6 bug) — Frontend HTML

```html
<head>
    <meta name="description" content="TaskFlow - Task management application">  <!-- SEO1 -->
    <link rel="canonical" href="https://taskflow.example.com/">               <!-- SEO2 -->
    <meta property="og:title" content="TaskFlow">                             <!-- SEO3 -->
    <meta property="og:description" content="Task management application">     <!-- SEO3 -->
    <script type="application/ld+json">                                       <!-- SEO4 -->
    {
        "@context": "https://schema.org",
        "@type": "WebApplication",
        "name": "TaskFlow",
        "description": "Task management application"
    }
    </script>
</head>
<body>
    <header>...</header>     <!-- SEO5: Semantic HTML -->
    <main>...</main>
    <nav>...</nav>
    <footer>...</footer>
</body>
```

robots.txt dosyası oluştur:
```
User-agent: *
Allow: /
Sitemap: https://taskflow.example.com/sitemap.xml
```

---

## ADIM 11: Dokümantasyon Fixleri (5 bug)

### DOC1: README.md Oluştur (ZORUNLU)
```markdown
# TaskFlow API

Task management REST API built with FastAPI.

## Quick Start
\`\`\`bash
pip install -r requirements.txt
python main.py
\`\`\`

## API Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | /api/register | Register new user |
| POST | /api/login | Login |
| POST | /api/logout | Logout |
| GET | /api/tasks | List tasks (paginated) |
| POST | /api/tasks | Create task |
| PUT | /api/tasks/{id} | Update task |
| DELETE | /api/tasks/{id} | Delete task |
| GET | /api/search?q=&page=&limit= | Search tasks |
| GET | /api/admin/users | Admin: list users |
| GET | /api/admin/stats | Admin: statistics |
| GET | /api/health | Health check |

## Environment Variables
| Variable | Default | Description |
|----------|---------|-------------|
| JWT_SECRET | dev-only-secret | JWT signing key |
| BCRYPT_ROUNDS | 12 | bcrypt salt rounds |
| CORS_ORIGINS | http://localhost:3000 | Allowed origins |
```

### DOC3: Inline Comments (≥5 yorum ZORUNLU)
```python
# Authentication middleware: validates JWT token from Authorization header
def get_current_user(request: Request):
    ...

# Sanitize user object by removing password hash before sending to client
def sanitize_user(user: dict) -> dict:
    ...

# Paginated task listing with N+1 optimized comment/assignee fetching
@app.get("/api/tasks")
def get_tasks(page: int = 1, limit: int = 20):
    ...
```

### DOC4: CONTRIBUTING.md Oluştur
```markdown
# Contributing to TaskFlow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `pytest`
5. Submit a pull request
```

### DOC5: .env.example Oluştur
```
JWT_SECRET=your-secret-key-here
BCRYPT_ROUNDS=12
CORS_ORIGINS=http://localhost:3000
ENV=development
DATABASE_URL=sqlite:///./test.db
```

---

## ADIM 12: Doğrulama (ZORUNLU — ATLAMA!)

Tüm fixler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap:

```bash
# S1: CORS middleware aktif mi?
grep -rq "CORSMiddleware" app/ main.py src/ || echo "❌ CORS YOK!"

# S2: Rate limiting aktif mi?
grep -rq "slowapi\|rate_limit\|Limiter" app/ main.py src/ || echo "❌ RATE LIMIT YOK!"

# S4: JWT secret env-based mi?
grep -rq "os.getenv\|os.environ\|pydantic.*Settings" app/ main.py src/ || echo "❌ JWT SECRET HARDCODED!"

# S5: bcrypt rounds >= 10 mu?
grep -rq "BCRYPT_ROUNDS.*1[0-9]\|gensalt(1[0-9])" app/ main.py src/ || echo "❌ BCRYPT < 10!"

# S6: Password hash response'da yok mu?
grep -rq "sanitize_user\|exclude.*password" app/ main.py src/ || echo "❌ PASSWORD HASH RESPONSE'DA!"

# S7: Logout endpoint var mı?
grep -rq "logout" app/ main.py src/ || echo "❌ LOGOUT YOK!"

# S8: httpOnly cookie kullanılıyor mu?
grep -rq "set_cookie\|httpOnly\|httponly" app/ main.py src/ || echo "❌ HTTPONLY COOKIE YOK!"

# S9: Admin auth dependency var mı?
grep -rq "Depends.*admin\|require_admin\|admin.*Depends" app/ main.py src/ || echo "❌ ADMIN AUTH YOK!"

# S11: Mass assignment protection var mı?
grep -rq "extra.*forbid\|forbid\|ALLOWED_FIELDS" app/ main.py src/ || echo "❌ MASS ASSIGNMENT KORUMASI YOK!"

# KQ1: Password min_length var mı?
grep -rq "min_length\|Field.*min" app/ main.py src/ || echo "❌ PASSWORD LENGTH KONTROLÜ YOK!"

# KQ5: Bearer token strip var mı?
grep -rq "Bearer \|removeprefix.*Bearer\|token\[7:\]" app/ main.py src/ || echo "❌ BEARER STRIP YOK!"

# KQ6: Bare except yok mu?
grep -rn "except:" app/ main.py src/ | grep -v "test_\|__pycache__" && echo "❌ BARE EXCEPT BULUNDU!"

# AR1-AR5: Service layer var mı?
find app/ src/ . -name "*service*.py" -maxdepth 3 | grep -q . || echo "❌ SERVICE LAYER YOK!"

# AR4: Config file var mı?
ls app/config.py app/core/config.py config.py 2>/dev/null | grep -q . || echo "❌ CONFIG FILE YOK!"

# T1: Test dosyaları var mı?
find tests/ . -name "test_*.py" -maxdepth 4 | grep -q . || echo "❌ TEST YOK!"

# D3: Health endpoint var mı?
grep -rq "/health\|/api/health" app/ main.py src/ || echo "❌ HEALTH ENDPOINT YOK!"

# D6: Graceful shutdown var mı?
grep -rq "SIGTERM\|lifespan\|signal\.signal\|shutdown" app/ main.py src/ || echo "❌ GRACEFUL SHUTDOWN YOK!"
```

🚨🚨🚨 EĞER herhangi bir kontrol başarısız olursa → HEMEN düzelt! ATLAMA!

---

## ADIM 13: Rapor Yaz

`reports/fastapi-fix-YYYYMMDD.md` oluştur:

```markdown
# 🔧 FastAPI Fix Raporu
- **Toplam Bulgu:** 62
- **Fixlenen:**

## Uygulanan Fixler
| # | Boyut | Bulgu | Fix | Dosya |
|---|-------|-------|-----|-------|

## Doğrulama Sonucu
| # | Kontrol | Durum |
|---|---------|:-----:|
```

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Pydantic validation is enough" | Pydantic validates input, but you still need: CORS configuration, rate limiting, error sanitization, and auth checks. Validation is one layer, not the whole stack. |
| "FastAPI handles security automatically" | FastAPI provides tools, not defaults. You must explicitly add CORS middleware, rate limiting, input sanitization, and auth dependencies. |
| "SQL injection isn't possible with SQLAlchemy" | It IS possible with raw queries, text(), or f-strings. Always use parameterized queries or ORM methods. |
| "We don't need dependency injection for auth" | Without DI-based auth checks, any developer can forget to add auth to a new endpoint. Use `Depends(get_current_user)` consistently. |

## Red Flags

- 🔴 No Pydantic models for request validation
- 🔴 Raw SQL queries with f-strings (SQL injection)
- 🔴 No CORS middleware configured
- 🔴 Endpoints without auth dependencies
- 🔴 Exception handlers that expose internal details
- 🔴 No rate limiting on auth endpoints
