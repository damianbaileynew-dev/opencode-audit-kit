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

### S1: CORS Middleware Ekle (ZORUNLU)
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "http://localhost:3000").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```
🚨 `allow_origins=["*"]` ASLA kullanma! Environment variable'dan oku.

### S2: Rate Limiting Ekle (ZORUNLU)
```python
# requirements.txt'e ekle: slowapi
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Kullanım:
@app.post("/api/login")
@limiter.limit("5/minute")
def login(request: Request, payload: UserLogin):
    ...
```

### S3: CORS Restricted (S1 ile birlikte çözülür)

### S4: JWT Secret Environment Variable'a Taşı
```python
# config.py veya app/core/config.py oluştur
import os

class Settings:
    JWT_SECRET = os.getenv("JWT_SECRET", "dev-only-secret-change-in-prod")
    JWT_ALG = os.getenv("JWT_ALG", "HS256")
    BCRYPT_ROUNDS = int(os.getenv("BCRYPT_ROUNDS", "12"))
    # ... diğer ayarlar

settings = Settings()
```
🚨 `SECRET = "secret"` hardcoded ASLA olmamalı! `os.getenv("JWT_SECRET")` ZORUNLU!

### S5: bcrypt Salt Rounds ≥ 10 (ZORUNLU)
```python
# YANLIŞ: BCRYPT_ROUNDS = 5
# DOĞRU:
BCRYPT_ROUNDS = 12  # veya minimum 10
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt(settings.BCRYPT_ROUNDS)).decode()
```

### S6: Password Hash Response'dan Çıkar (ZORUNLU)
```python
# YANLIŞ: return {"user": user}  # password hash dahil!
# DOĞRU:
def sanitize_user(user: dict) -> dict:
    return {k: v for k, v in user.items() if k != "password"}

@app.post("/api/register")
def register(payload: UserRegister):
    ...
    return {"user": sanitize_user(user)}

@app.post("/api/login")
def login(payload: UserLogin):
    ...
    return {"user": sanitize_user(user), "token": token}
```

### S7: Logout Endpoint Ekle (ZORUNLU)
```python
@app.post("/api/logout")
def logout(response: Response):
    response.delete_cookie("token")
    return {"message": "Logged out successfully"}
```

### S8: httpOnly Cookie Kullan (ZORUNLU)
```python
from fastapi.responses import JSONResponse

@app.post("/api/login")
def login(payload: UserLogin):
    ...
    response = JSONResponse({"user": sanitize_user(user)})
    response.set_cookie(
        key="token",
        value=token,
        httponly=True,
        secure=os.getenv("ENV") == "production",
        samesite="strict",
        max_age=7 * 24 * 60 * 60  # 7 gün
    )
    return response

# Frontend: fetch('/api/tasks', { credentials: 'include' })
```
🚨 localStorage.setItem('token') YANLIŞ! httpOnly cookie ZORUNLU!

### S9: Admin Route'larda Auth Check (ZORUNLU)
```python
from fastapi import Depends

def require_admin(user: dict = Depends(get_current_user)):
    if user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return user

@app.get("/api/admin/users")
def admin_users(admin = Depends(require_admin)):
    ...
```
🚨 Admin route'larda `Depends(require_admin)` ZORUNLU! Sadece `get_current_user` yetersiz!

### S10: Admin Response'dan Password Çıkar (ZORUNLU)
```python
@app.get("/api/admin/users")
def admin_users(admin = Depends(require_admin)):
    return {"users": [sanitize_user(u) for u in _users]}
```
🚨 Password hash ASLA response'da olmamalı!

### S11: Mass Assignment Protection (ZORUNLU)
```python
from pydantic import BaseModel, Field, ConfigDict

# Pydantic v2: extra='forbid' ile izinsiz alanları reddet
class TaskUpdate(BaseModel):
    model_config = ConfigDict(extra='forbid')  # Sadece tanımlı alanlar kabul edilir
    
    title: str | None = None
    description: str | None = None
    status: str | None = None
    priority: str | None = None
    assignee_id: int | None = None
    # user_id, role, is_admin alanları KALDIRILDI

class UserRegister(BaseModel):
    model_config = ConfigDict(extra='forbid')
    
    email: str
    password: str = Field(min_length=8)
```
🚨 `role`, `is_admin`, `user_id` gibi alanlar update model'inde OLMAMALI!
🚨 `extra='forbid'` ile bilinmeyen alanlar reddedilir!

### S12: XSS Prevention (Frontend)
```javascript
// YANLIŞ: document.getElementById('task-list').innerHTML = html;
// DOĞRU: textContent kullan
tasks.forEach(function(t) {
    var div = document.createElement('div');
    div.className = 'task';
    var h3 = document.createElement('h3');
    h3.textContent = t.title;  // innerHTML DEĞİL!
    div.appendChild(h3);
    ...
});
```

---

## ADIM 3: Performans Fixleri (6 bug)

### P1: Pagination Ekle (ZORUNLU)
```python
from typing import Optional

@app.get("/api/tasks")
def get_tasks(
    request: Request,
    page: int = 1,
    limit: int = 20,
    user = Depends(get_current_user)
):
    offset = (page - 1) * limit
    total_tasks = len(_tasks)
    paginated_tasks = _tasks[offset:offset + limit]
    
    result = []
    for t in paginated_tasks:
        task = dict(t)
        task["comments"] = [c for c in _comments if c["task_id"] == t["id"]]
        if t["assignee_id"]:
            for u in _users:
                if u["id"] == t["assignee_id"]:
                    task["assignee"] = {"id": u["id"], "email": u["email"]}
                    break
        result.append(task)
    
    return {
        "tasks": result,
        "total": total_tasks,
        "page": page,
        "limit": limit,
        "pages": (total_tasks + limit - 1) // limit
    }
```
🚨 `page` ve `limit` query parametreleri ZORUNLU! Offset hesapla, slice uygula!

### P2: N+1 Comments Fix
```python
# Batch: Tüm task_id'ler için comment'ları bir seferde grupla
from collections import defaultdict

comments_by_task = defaultdict(list)
for c in _comments:
    comments_by_task[c["task_id"]].append(c)

for t in paginated_tasks:
    task["comments"] = comments_by_task.get(t["id"], [])
```

### P3: N+1 Assignee Fix
```python
# Batch: Tüm assignee_id'ler için user'ları bir seferde map'le
users_map = {u["id"]: {"id": u["id"], "email": u["email"]} for u in _users}

for t in paginated_tasks:
    if t["assignee_id"]:
        task["assignee"] = users_map.get(t["assignee_id"])
```

### P4: Sync File Write → Kaldır veya Async Yap
```python
# YANLIŞ: with open("task_log.json", "w") as f: json.dump(...)
# DOĞRU: Senkron dosya yazmayı kaldır, logging kullan
import logging
logger = logging.getLogger(__name__)
logger.info(f"Task created: {task['id']}")
```
🚨 `open("...", "w")` FastAPI'da event loop'u bloklar! Kaldır veya `aiofiles` kullan!

### P5: Search Pagination
```python
@app.get("/api/search")
def search_tasks(q: str = "", page: int = 1, limit: int = 20):
    all_results = [t for t in _tasks if q.lower() in t["title"].lower()]
    offset = (page - 1) * limit
    return {
        "tasks": all_results[offset:offset + limit],
        "total": len(all_results),
        "page": page,
        "limit": limit
    }
```

### P6: In-Memory Counting (Kabul Edilebilir)
In-memory DB'de `len()` kullanımı normaldir, DB kullanılsa `COUNT()` olurdu.

---

## ADIM 4: Kod Kalitesi Fixleri (6 bug)

### KQ1: Password Length Check (ZORUNLU)
```python
from pydantic import Field

class UserRegister(BaseModel):
    email: str
    password: str = Field(min_length=8, description="Password must be at least 8 characters")
```
🚨 `min_length=8` ZORUNLU! 1 karakter şifre ASLA kabul edilmemeli!

### KQ2: Correct Status Codes
```python
# YANLIŞ: raise HTTPException(status_code=200, detail="Invalid priority")
# DOĞRU:
raise HTTPException(status_code=400, detail="Invalid priority")

# Kaynak oluşturma: 201
return JSONResponse(status_code=201, content={"user": sanitize_user(user)})

# Silme: 200 veya 204
return {"deleted": True}
```

### KQ3: Specific Error Handling
```python
# YANLIŞ: except: raise HTTPException(...)
# DOĞRU:
from jwt import PyJWTError

def get_current_user(request: Request):
    token = request.headers.get("Authorization", "")
    if token.startswith("Bearer "):
        token = token[7:]
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALG])
        return payload
    except PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```
🚨 Bare `except:` YASAK! Her zaman spesifik exception yakala!

### KQ4: Title Validation
```python
class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200, description="Task title is required")
    description: str = ""
```

### KQ5: Bearer Token Strip (ZORUNLU)
```python
def get_current_user(request: Request):
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing Bearer token")
    token = auth_header[7:]  # "Bearer " prefix'ini kaldır
    ...
```
🚨 Token'dan "Bearer " prefix'ini çıkarmadan decode ETME! `token[7:]` veya `removeprefix("Bearer ")` ZORUNLU!

### KQ6: Python Best Practices
- Bare `except:` → `except PyJWTError:` veya `except Exception:`
- Type hints ekle
- f-string kullan

---

## ADIM 5: Mimari Fixleri (6 bug)

### AR1-AR2-AR5: Service Layer Oluştur (ZORUNLU)
```python
# app/services/task_service.py
class TaskService:
    def __init__(self, task_repo, comment_repo, user_repo):
        self.task_repo = task_repo
        self.comment_repo = comment_repo
        self.user_repo = user_repo

    def get_tasks(self, page: int, limit: int, user_id: str):
        offset = (page - 1) * limit
        tasks = self.task_repo.get_all(offset, limit)
        # Business logic burada, route'ta DEĞİL
        for task in tasks:
            if task.priority not in ["low", "medium", "high"]:
                raise ValueError("Invalid priority")
        return tasks

# app/services/auth_service.py
class AuthService:
    def __init__(self, user_repo, settings):
        self.user_repo = user_repo
        self.settings = settings

    def register(self, email: str, password: str):
        if self.user_repo.find_by_email(email):
            raise ValueError("Email already exists")
        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt(self.settings.BCRYPT_ROUNDS)).decode()
        user = self.user_repo.create(email, hashed)
        return user

    def login(self, email: str, password: str):
        user = self.user_repo.find_by_email(email)
        if not user or not bcrypt.checkpw(password.encode(), user["password"].encode()):
            raise ValueError("Invalid credentials")
        token = jwt.encode({"sub": str(user["id"]), "role": user["role"]}, self.settings.JWT_SECRET, algorithm=self.settings.JWT_ALG)
        return token, user
```
🚨 Service layer ZORUNLU! Tüm business logic route handler'dan ÇIKARILMALI!

### AR3-AR4: Config File Oluştur (ZORUNLU)
```python
# app/core/config.py
import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "TaskFlow API"
    JWT_SECRET: str = os.getenv("JWT_SECRET", "dev-only-secret")
    JWT_ALG: str = "HS256"
    BCRYPT_ROUNDS: int = int(os.getenv("BCRYPT_ROUNDS", "12"))
    CORS_ORIGINS: str = os.getenv("CORS_ORIGINS", "http://localhost:3000")
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./test.db")
    
    class Config:
        env_file = ".env"

settings = Settings()
```
🚨 Hardcoded değerler ASLA! `os.getenv()` veya `pydantic-settings` ZORUNLU!

### AR6: Consistent Error Handling
```python
# app/core/exceptions.py
class AppException(Exception):
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail

class NotFoundException(AppException):
    def __init__(self, detail="Resource not found"):
        super().__init__(404, detail)

class UnauthorizedException(AppException):
    def __init__(self, detail="Unauthorized"):
        super().__init__(401, detail)

# app/main.py
@app.exception_handler(AppException)
async def app_exception_handler(request, exc):
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
```

---

## ADIM 6: Test Fixleri (6 bug)

### T1-T6: Test Altyapısı Oluştur

```python
# requirements.txt'e ekle:
# pytest
# httpx
# pytest-asyncio

# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def auth_header():
    from app.core.security import create_access_token
    token = create_access_token("1", "user")
    return {"Authorization": f"Bearer {token}"}

@pytest.fixture
def admin_header():
    from app.core.security import create_access_token
    token = create_access_token("1", "admin")
    return {"Authorization": f"Bearer {token}"}
```

```python
# tests/test_auth.py
import pytest

def test_register_success(client):
    res = client.post("/api/register", json={"email": "new@test.com", "password": "longpassword123"})
    assert res.status_code in [200, 201]

def test_register_short_password(client):
    res = client.post("/api/register", json={"email": "new@test.com", "password": "123"})
    assert res.status_code == 422

def test_login_success(client):
    res = client.post("/api/login", json={"email": "user@example.com", "password": "user123"})
    assert res.status_code == 200

def test_login_invalid_credentials(client):
    res = client.post("/api/login", json={"email": "user@example.com", "password": "wrong"})
    assert res.status_code == 401

def test_login_missing_fields(client):
    res = client.post("/api/login", json={})
    assert res.status_code == 422
```

```python
# tests/test_tasks.py
import pytest

def test_get_tasks_authenticated(client, auth_header):
    res = client.get("/api/tasks", headers=auth_header)
    assert res.status_code == 200
    data = res.json()
    assert "tasks" in data or isinstance(data, list)

def test_get_tasks_unauthenticated(client):
    res = client.get("/api/tasks")
    assert res.status_code == 401

def test_create_task(client, auth_header):
    res = client.post("/api/tasks", json={"title": "Test task"}, headers=auth_header)
    assert res.status_code in [200, 201]

def test_create_task_empty_title(client, auth_header):
    res = client.post("/api/tasks", json={"title": ""}, headers=auth_header)
    assert res.status_code == 422

def test_pagination(client, auth_header):
    res = client.get("/api/tasks?page=1&limit=2", headers=auth_header)
    assert res.status_code == 200
```

```python
# tests/test_admin.py
import pytest

def test_admin_requires_auth(client):
    res = client.get("/api/admin/users")
    assert res.status_code in [401, 403]

def test_admin_requires_admin_role(client, auth_header):
    res = client.get("/api/admin/users", headers=auth_header)
    assert res.status_code == 403

def test_admin_access_with_admin(client, admin_header):
    res = client.get("/api/admin/users", headers=admin_header)
    assert res.status_code == 200
    # Password hash olmamalı
    for user in res.json().get("users", []):
        assert "password" not in user
```

CI workflow düzelt:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install --no-cache-dir -r requirements.txt
      - name: Run tests
        run: pytest -v
```

---

## ADIM 7: Erişilebilirlik Fixleri (7 bug) — Frontend HTML

HTML template'de şu değişiklikleri yap:

```html
<!DOCTYPE html>
<html lang="en">                    <!-- A1: lang attribute -->
<head>
    <meta charset="UTF-8">          <!-- A2: charset -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  <!-- A3: viewport -->
    <title>TaskFlow</title>
</head>
<body>
    <div id="app">
        <header>
            <nav aria-label="Main navigation">        <!-- A5: ARIA -->
                <h1>TaskFlow</h1>
            </nav>
        </header>
        <main>
            <form id="auth-form" aria-label="Login form">  <!-- A5: ARIA, A4: label -->
                <div>
                    <label for="email">Email</label>          <!-- A4: label binding -->
                    <input type="email" id="email" name="email" aria-required="true">
                </div>
                <div>
                    <label for="password">Password</label>     <!-- A4: label binding -->
                    <input type="password" id="password" name="password" aria-required="true">
                </div>
                <button type="button" onclick="login()">Login</button>
            </form>
            ...
        </main>
    </div>

    <!-- Modal with accessibility -->
    <div id="modal" role="dialog" aria-modal="true" aria-labelledby="modal-title" style="display:none">
        <div id="modal-content">
            <h2 id="modal-title">New Task</h2>
            <div>
                <label for="task-title">Title</label>    <!-- A4: label -->
                <input type="text" id="task-title" aria-required="true">
            </div>
            <button onclick="createTask()">Create</button>
            <button onclick="closeModal()">Cancel</button>
        </div>
    </div>

    <script>
    // A6: ESC key to close modal
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeModal();
    });

    // A7: Focus management
    function openModal() {
        document.getElementById('modal').style.display = 'block';
        document.getElementById('task-title').focus();  // Focus first input
    }
    function closeModal() {
        document.getElementById('modal').style.display = 'none';
        document.getElementById('task-title').focus();  // Return focus
    }
    </script>
</body>
</html>
```

---

## ADIM 8: UX Fixleri (7 bug) — Frontend JS

```javascript
// U1: Search actually works
document.getElementById('search').addEventListener('input', function(e) {
    var query = e.target.value.toLowerCase();
    var filtered = allTasks.filter(function(t) {
        return t.title.toLowerCase().includes(query);
    });
    renderTasks(filtered);
});

// U2: Filter actually works
document.getElementById('filter').addEventListener('change', function(e) {
    var status = e.target.value;
    var filtered = allTasks.filter(function(t) {
        return !status || t.status === status;
    });
    renderTasks(filtered);
});

// U3: Login error feedback
function login() {
    fetch('/api/login', { ... })
    .then(r => {
        if (!r.ok) return r.json().then(e => { throw new Error(e.detail); });
        return r.json();
    })
    .then(data => {
        if (data.token) { ... }
    })
    .catch(err => {
        document.getElementById('error-message').textContent = err.message;
        document.getElementById('error-message').style.display = 'block';
    });
}

// U4: Task create feedback
function createTask() {
    fetch('/api/tasks', { ... })
    .then(r => r.json())
    .then(data => {
        closeModal();      // Modal'ı kapat
        loadTasks();       // Listeyi yenile
        showToast('Task created!');  // Feedback
    });
}

// U5: Loading state
function loadTasks() {
    document.getElementById('task-list').innerHTML = '<div class="spinner">Loading...</div>';
    fetch('/api/tasks', { headers: {'Authorization': token} })
    .then(r => r.json())
    .then(tasks => { ... });
}

// U6: Responsive design
/* <style>
@media (max-width: 768px) {
    #main { flex-direction: column; }
    #sidebar { width: 100%; }
    #modal-content { width: 90%; margin: 50px auto; }
}
</style> */

// U7: Empty state
if (tasks.length === 0) {
    document.getElementById('task-list').innerHTML = '<div class="empty-state">No tasks found</div>';
}
```

---

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
