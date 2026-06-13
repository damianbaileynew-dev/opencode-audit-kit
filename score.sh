#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OpenCode Audit Kit — Auto-Scorer (Multi-Framework)
# Kullanım: bash score.sh [project-dir]
# Destek: js-express, typescript-express, fastapi, nextjs, nestjs
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

# --- Args ---
PROJECT_DIR="${1:-.}"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- Score tracking ---
TOTAL_BUGS=0
TOTAL_FIXED=0
DIMENSION_RESULTS=()

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "PASS" ]; then
    echo -e "  ${GREEN}✅${NC} $desc"
    return 0
  else
    echo -e "  ${RED}❌${NC} $desc"
    return 1
  fi
}

score_dimension() {
  local name="$1"
  local total="$2"
  local fixed="$3"
  local pct=0
  if [ "$total" -gt 0 ]; then
    pct=$(( (fixed * 100) / total ))
  fi
  
  TOTAL_BUGS=$((TOTAL_BUGS + total))
  TOTAL_FIXED=$((TOTAL_FIXED + fixed))
  
  local status=""
  if [ "$pct" -ge 80 ]; then
    status="${GREEN}✅ PASS${NC}"
  else
    status="${RED}❌ FAIL${NC}"
  fi
  
  DIMENSION_RESULTS+=("$name|$total|$fixed|$pct|$status")
  echo -e "  ${BOLD}$name${NC}: ${fixed}/${total} = ${BOLD}${pct}%${NC} $status"
}

# --- Project Detection ---
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenCode Audit Kit — Auto-Scorer (Multi-Framework)     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Proje: ${BOLD}$PROJECT_DIR${NC}"

FRAMEWORK="unknown"
if [ -f "$PROJECT_DIR/package.json" ]; then
  if grep -q "@nestjs" "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="nestjs"
  elif grep -q "express" "$PROJECT_DIR/package.json" 2>/dev/null; then
    if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
      FRAMEWORK="typescript-express"
    else
      FRAMEWORK="js-express"
    fi
  elif grep -q "next" "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="nextjs"
  fi
elif [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/app/main.py" ] || [ -f "$PROJECT_DIR/main.py" ]; then
  FRAMEWORK="fastapi"
fi
echo -e "Framework: ${BOLD}$FRAMEWORK${NC}"
echo ""

cd "$PROJECT_DIR" 2>/dev/null || { echo "❌ Dizin bulunamadı: $PROJECT_DIR"; exit 1; }

# ═══════════════════════════════════════════════════════════
# FASTAPI SCORING
# ═══════════════════════════════════════════════════════════
if [ "$FRAMEWORK" = "fastapi" ]; then

# Helper: find Python source files
PY_FILES=$(find app/ src/ . -maxdepth 3 -name "*.py" ! -path "./.venv/*" ! -path "./venv/*" ! -path "./__pycache__/*" 2>/dev/null)
HTML_FILE=""
for f in "app/templates/index.html" "templates/index.html" "static/index.html"; do
  if [ -f "$f" ]; then HTML_FILE="$f"; break; fi
done
# Also check if HTML is embedded in Python
PY_HAS_HTML=""
if grep -rq "response_class=HTMLResponse\|HTMLResponse" app/ main.py src/ 2>/dev/null; then
  PY_HAS_HTML="yes"
fi

# ──── SECURITY ────
echo -e "${BOLD}🔒 SECURITY${NC}"
s=0

# S1: CORS middleware
if grep -rq "CORSMiddleware\|add_middleware.*CORS" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S1: CORS middleware" "PASS"
else
  check "S1: CORS middleware" "FAIL"
fi

# S2: Rate limiting
if grep -rq "slowapi\|rate_limit\|RateLimiter\|Limiter\|limiter" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S2: Rate limiting" "PASS"
else
  check "S2: Rate limiting" "FAIL"
fi

# S3: CORS not wildcard
if grep -rq "allow_origins" app/ main.py src/ 2>/dev/null && ! grep -rq 'allow_origins.*"\*"' app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S3: CORS restricted" "PASS"
else
  check "S3: CORS restricted" "FAIL"
fi

# S4: JWT from env/config
if grep -rq "os\.environ\|os\.getenv\|Settings.*SECRET\|JWT_SECRET.*env\|config.*secret" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S4: JWT env-based" "PASS"
else
  check "S4: JWT env-based" "FAIL"
fi

# S5: bcrypt rounds >= 10
if grep -rq "rounds.*1[0-9]\|BCRYPT_ROUNDS.*1[0-9]\|gensalt(1[0-9])\|salt.*1[0-9]\|cost.*1[0-9]" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S5: bcrypt≥10" "PASS"
else
  check "S5: bcrypt≥10" "FAIL"
fi

# S6: No password in response
if grep -rq "password.*rest\|Omit.*password\|sanitize.*user\|strip.*password\|exclude.*password\|model_dump.*exclude" app/ main.py src/ 2>/dev/null || \
   grep -rq '"email".*"id"' app/ main.py src/ 2>/dev/null | grep -v "password"; then
  # More specific check: if the register/login response explicitly excludes password
  if grep -rq "exclude.*password\|password.*rest\|Omit\|sanitize\|strip.*pass\|safe_user\|public_user\|user_response" app/ main.py src/ 2>/dev/null; then
    ((s++)); check "S6: No pwd in response" "PASS"
  else
    check "S6: No pwd in response" "FAIL"
  fi
else
  check "S6: No pwd in response" "FAIL"
fi

# S7: Logout endpoint
if grep -rq "logout\|revoke\|blacklist\|invalidate" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S7: Logout endpoint" "PASS"
else
  check "S7: Logout endpoint" "FAIL"
fi

# S8: httpOnly cookie
if grep -rq "httpOnly\|set_cookie\|response\.set_cookie\|Cookie\|httponly" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S8: httpOnly cookie" "PASS"
else
  check "S8: httpOnly cookie" "FAIL"
fi

# S9: Admin auth (actual auth dependency/guard on admin routes, not just data)
if grep -rq "Depends.*admin\|require_admin\|admin_required\|verify_admin\|check_admin_role\|admin.*Depends\|current_user.*role.*==\|role.*==.*admin\|@router.*admin.*Depends" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S9: Admin auth" "PASS"
else
  check "S9: Admin auth" "FAIL"
fi

# S10: Admin strips passwords
if grep -rq "safe_users\|sanitize_user\|exclude.*password\|password.*rest\|strip.*password\|public_user\|Omit.*password" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S10: Admin strips pwd" "PASS"
else
  check "S10: Admin strips pwd" "FAIL"
fi

# S11: Mass assignment protection
if grep -rq "ALLOWED_FIELDS\|allowed_fields\|whitelist\|safe_fields\|Field.*exclude\|model_config.*extra.*forbid\|extra.*forbid" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S11: Mass assign protect" "PASS"
else
  check "S11: Mass assign protect" "FAIL"
fi

# S12: XSS prevention
if [ -n "$HTML_FILE" ] && grep -rq "textContent\|innerText\|escapeHtml\|createTextNode\|DOMPurify" "$HTML_FILE" 2>/dev/null; then
  ((s++)); check "S12: XSS fix" "PASS"
elif [ -n "$PY_HAS_HTML" ] && grep -rq "textContent\|innerText\|escapeHtml\|DOMPurify" app/ main.py src/ 2>/dev/null; then
  ((s++)); check "S12: XSS fix" "PASS"
else
  check "S12: XSS fix" "FAIL"
fi

score_dimension "Security" 12 $s
echo ""

# ──── PERFORMANCE ────
echo -e "${BOLD}⚡ PERFORMANCE${NC}"
p=0

# P1: Pagination on tasks
if grep -rq "page\|limit\|offset\|skip\|paginate\|pagination" app/ main.py src/ 2>/dev/null; then
  ((p++)); check "P1: Pagination" "PASS"
else
  check "P1: Pagination" "FAIL"
fi

# P2: N+1 comments fix (batch fetch or eager load)
if grep -rq "batch\|prefetch\|eager\|comments_by_task\|Map.*comment\|grouped\|join" app/ main.py src/ 2>/dev/null; then
  ((p++)); check "P2: N+1 comments" "PASS"
else
  check "P2: N+1 comments" "FAIL"
fi

# P3: N+1 assignee fix
if grep -rq "batch\|users_map\|prefetch\|Map.*user\|get_users_by_ids\|grouped" app/ main.py src/ 2>/dev/null; then
  ((p++)); check "P3: N+1 assignee" "PASS"
else
  check "P3: N+1 assignee" "FAIL"
fi

# P4: No sync file write (check for actual sync open with "w" mode)
P4_SYNC_WRITE=$(grep -rn 'open(' app/ main.py src/ 2>/dev/null | grep -v "test_\|_test\|__pycache__\|\.venv" | grep '"w"' | grep -v "async\|aiofiles" | head -1)
if [ -z "$P4_SYNC_WRITE" ]; then
  ((p++)); check "P4: No sync write" "PASS"
else
  # Check if it's async (aiofiles, asyncio)
  if grep -rq "aiofiles\|async.*open\|asyncio.*write\|aio.*write" app/ main.py src/ 2>/dev/null; then
    ((p++)); check "P4: Async write" "PASS"
  else
    check "P4: Sync write found" "FAIL"
  fi
fi

# P5: Search pagination
if grep -rq "search" app/ main.py src/ 2>/dev/null && grep -rq "page\|limit\|offset\|skip" app/ main.py src/ 2>/dev/null; then
  ((p++)); check "P5: Search pagination" "PASS"
else
  check "P5: Search pagination" "FAIL"
fi

# P6: Python counting (acceptable for in-memory)
((p++)); check "P6: In-memory counting (OK)" "PASS"

score_dimension "Performance" 6 $p
echo ""

# ──── CODE QUALITY ────
echo -e "${BOLD}🔍 CODE QUALITY${NC}"
kq=0

# KQ1: Password length check (Pydantic Field min_length, not just "password" near "min")
if grep -rq "min_length\|Field.*min.*[6-9]\|MinLength\|constr.*min\|password.*len.*>=\|len(.*password.*)*>=" app/ main.py src/ 2>/dev/null; then
  ((kq++)); check "KQ1: Pwd length check" "PASS"
else
  check "KQ1: Pwd length check" "FAIL"
fi

# KQ2: Proper status codes
if grep -rq "status_code=400\|status_code=401\|status_code=403\|status_code=404\|status_code=409\|status_code=422\|status_code=500\|HTTP_400\|HTTP_401\|HTTP_403" app/ main.py src/ 2>/dev/null; then
  ((kq++)); check "KQ2: Status codes" "PASS"
else
  check "KQ2: Status codes" "FAIL"
fi

# KQ3: Specific error handling
if grep -rq "AppError\|CustomError\|HTTPException.*detail\|except.*Error\|class.*Error\|ErrorHandler\|exception_handler" app/ main.py src/ 2>/dev/null; then
  ((kq++)); check "KQ3: Error handling" "PASS"
else
  check "KQ3: Error handling" "FAIL"
fi

# KQ4: Title validation
if grep -rq "min_length\|title.*required\|!title\|title.*trim\|title.*empty\|Field.*min\|title.*len\|title.*validate" app/ main.py src/ 2>/dev/null; then
  ((kq++)); check "KQ4: Title validation" "PASS"
else
  check "KQ4: Title validation" "FAIL"
fi

# KQ5: Bearer token strip
if grep -rq "Bearer \|replace.*Bearer\|split.*Bearer\|startsWith.*Bearer\|removeprefix.*Bearer" app/ main.py src/ 2>/dev/null; then
  ((kq++)); check "KQ5: Bearer strip" "PASS"
else
  check "KQ5: Bearer strip" "FAIL"
fi

# KQ6: Python best practices (no bare except)
BARE_EXCEPTS=$(grep -rn "except:" app/ main.py src/ 2>/dev/null | grep -v "test_\|_test\|__pycache__\|\.venv\|except:.*#" | wc -l)
if [ "$BARE_EXCEPTS" -eq 0 ]; then
  ((kq++)); check "KQ6: No bare except" "PASS"
else
  check "KQ6: Bare except found ($BARE_EXCEPTS)" "FAIL"
fi

score_dimension "Code Quality" 6 $kq
echo ""

# ──── ARCHITECTURE ────
echo -e "${BOLD}🏗️ ARCHITECTURE${NC}"
ar=0

# AR1: Service layer exists
if [ -d app/services ] || [ -d src/services ] || [ -d services ]; then
  ((ar++)); check "AR1: Service dir" "PASS"
else
  # Check if service files exist anywhere
  if find app/ src/ . -maxdepth 3 -name "*service*.py" ! -path "./.venv/*" ! -path "./venv/*" 2>/dev/null | grep -q .; then
    ((ar++)); check "AR1: Service files" "PASS"
  else
    check "AR1: No service layer" "FAIL"
  fi
fi

# AR2: Logic extracted from routes
if [ -d app/services ] || [ -d src/services ] || [ -d services ]; then
  ((ar++)); check "AR2: Logic extracted" "PASS"
else
  if find app/ src/ . -maxdepth 3 -name "*service*.py" ! -path "./.venv/*" ! -path "./venv/*" 2>/dev/null | grep -q .; then
    ((ar++)); check "AR2: Logic extracted" "PASS"
  else
    check "AR2: Logic not extracted" "FAIL"
  fi
fi

# AR3: Env-based config
if grep -rq "os\.environ\|os\.getenv\|pydantic.*BaseSettings\|Settings.*model\|dotenv\|env_file" app/ main.py src/ 2>/dev/null; then
  ((ar++)); check "AR3: Env config" "PASS"
else
  check "AR3: Env config" "FAIL"
fi

# AR4: Config file
if [ -f app/config.py ] || [ -f app/core/config.py ] || [ -f src/config.py ] || [ -f config.py ]; then
  ((ar++)); check "AR4: Config file" "PASS"
else
  check "AR4: Config file" "FAIL"
fi

# AR5: Service layer files
if compgen -G "app/services/*.py" > /dev/null 2>&1 || compgen -G "src/services/*.py" > /dev/null 2>&1 || compgen -G "services/*.py" > /dev/null 2>&1; then
  ((ar++)); check "AR5: Service files" "PASS"
else
  if find app/ src/ . -maxdepth 3 -name "*service*.py" ! -path "./.venv/*" ! -path "./venv/*" 2>/dev/null | grep -q .; then
    ((ar++)); check "AR5: Service files found" "PASS"
  else
    check "AR5: No service files" "FAIL"
  fi
fi

# AR6: Consistent error handling
if grep -rq "exception_handler\|@app.exception_handler\|HTTPException\|AppError\|try:.*except" app/ main.py src/ 2>/dev/null; then
  ((ar++)); check "AR6: Consistent errors" "PASS"
else
  check "AR6: Consistent errors" "FAIL"
fi

score_dimension "Architecture" 6 $ar
echo ""

# ──── TEST ────
echo -e "${BOLD}🧪 TEST${NC}"
t=0

# T1: Test files exist
if find tests/ . -maxdepth 4 -name "test_*.py" -o -name "*_test.py" -o -name "*.spec.py" 2>/dev/null | grep -q .; then
  ((t++)); check "T1: Tests exist" "PASS"
else
  check "T1: No tests" "FAIL"
fi

# T2: CI works (pytest must be in requirements AND CI must reference it)
if grep -rq "pytest" requirements.txt pyproject.toml 2>/dev/null && grep -rq "pytest" .github/workflows/*.yml 2>/dev/null; then
  ((t++)); check "T2: CI pytest" "PASS"
else
  check "T2: CI broken" "FAIL"
fi

# T3: Test framework
if grep -rq "pytest\|unittest\|httpx.*test" requirements.txt pyproject.toml 2>/dev/null; then
  ((t++)); check "T3: Test framework" "PASS"
else
  check "T3: No test framework" "FAIL"
fi

# T4: CI checkout
if grep -q "actions/checkout" .github/workflows/*.yml 2>/dev/null; then
  ((t++)); check "T4: CI checkout" "PASS"
else
  check "T4: No CI checkout" "FAIL"
fi

# T5: Edge case tests
if find tests/ . -maxdepth 4 -name "test_*.py" -o -name "*_test.py" 2>/dev/null | xargs grep -l "invalid\|empty\|short.*password\|duplicate\|reject\|boundary\|edge\|missing\|wrong" 2>/dev/null | grep -q .; then
  ((t++)); check "T5: Edge cases" "PASS"
else
  check "T5: No edge cases" "FAIL"
fi

# T6: Integration tests (TestClient or httpx)
if grep -rl "TestClient\|httpx\|test_client\|@pytest.fixture" tests/ 2>/dev/null | grep -q .; then
  ((t++)); check "T6: Integration tests" "PASS"
else
  check "T6: No integration tests" "FAIL"
fi

score_dimension "Test" 6 $t
echo ""

# ──── ACCESSIBILITY ────
echo -e "${BOLD}♿ ACCESSIBILITY${NC}"
a=0

# Check HTML file (embedded or standalone)
HTML_CHECK_FILE="$HTML_FILE"
if [ -z "$HTML_CHECK_FILE" ]; then
  # Create temp file from embedded HTML in Python
  EMBEDDED_HTML=$(grep -A 500 "response_class=HTMLResponse\|HTMLResponse" app/main.py main.py 2>/dev/null | grep -B 500 '"""$' | head -100)
fi

check_html() {
  local pattern="$1"
  local desc="$2"
  if [ -n "$HTML_CHECK_FILE" ] && grep -q "$pattern" "$HTML_CHECK_FILE" 2>/dev/null; then
    ((a++)); check "$desc" "PASS"
  elif grep -rq "$pattern" app/ main.py src/ static/ 2>/dev/null; then
    ((a++)); check "$desc" "PASS"
  else
    check "$desc" "FAIL"
  fi
}

check_html 'lang=' "A1: html lang"
check_html 'charset' "A2: charset"
check_html 'viewport' "A3: viewport"
check_html '<label\|aria-label' "A4: Labels"
check_html 'aria-\|role=' "A5: ARIA"
check_html 'Escape\|keydown\|onkeydown' "A6: ESC close"
check_html '\.focus()\|focus(' "A7: Focus mgmt"

score_dimension "Accessibility" 7 $a
echo ""

# ──── UX ────
echo -e "${BOLD}🎨 UX${NC}"
u=0

check_ux() {
  local pattern="$1"
  local desc="$2"
  if [ -n "$HTML_CHECK_FILE" ] && grep -q "$pattern" "$HTML_CHECK_FILE" 2>/dev/null; then
    ((u++)); check "$desc" "PASS"
  elif grep -rq "$pattern" app/ main.py src/ static/ 2>/dev/null; then
    ((u++)); check "$desc" "PASS"
  else
    check "$desc" "FAIL"
  fi
}

check_ux 'search.*addEventListener\|addEventListener.*input.*search\|search\.addEventListener\|keyup.*search\|input.*event.*search\|searchTasks\|performSearch' "U1: Search works"
check_ux 'filter.*addEventListener\|addEventListener.*change.*filter\|filterByStatus\|renderFiltered\|applyFilter\|status.*filter.*render' "U2: Filter works"
check_ux 'error-message\|errorMessage\|showError\|loginError\|error.*feedback\|invalid.*credential\|alert(\|error.*textContent' "U3: Error feedback"
check_ux 'createTask.*closeModal\|then.*closeModal\|then.*loadTasks\|modal.*close.*create\|showToast\|success.*message' "U4: Create feedback"
check_ux 'spinner\|loading\|isLoading\|skeleton\|showLoading' "U5: Loading state"
check_ux '@media' "U6: Responsive"
check_ux 'empty-state\|No tasks\|no-result\|no-tasks\|emptyState' "U7: Empty state"

score_dimension "UX" 7 $u
echo ""

# ──── DEVOPS ────
echo -e "${BOLD}🚀 DEVOPS${NC}"
d=0

if grep -q '^USER\|^USER ' Dockerfile 2>/dev/null || grep -q 'appuser\|non-root' Dockerfile 2>/dev/null; then ((d++)); check "D1: Non-root" "PASS"; else check "D1: Non-root" "FAIL"; fi
if [ -f .dockerignore ]; then ((d++)); check "D2: .dockerignore" "PASS"; else check "D2: .dockerignore" "FAIL"; fi
if grep -rq '/health\|/api/health\|health_check' app/ main.py src/ 2>/dev/null || grep -q 'HEALTHCHECK' Dockerfile 2>/dev/null; then ((d++)); check "D3: Health check" "PASS"; else check "D3: Health check" "FAIL"; fi
if grep -q 'actions/checkout' .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D4: CI checkout" "PASS"; else check "D4: CI checkout" "FAIL"; fi
if grep -q 'pip install --no-cache-dir\|pip cache\|cache:*pip' Dockerfile .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D5: Pip cache" "PASS"; else check "D5: Pip cache" "FAIL"; fi
if grep -rq 'SIGTERM\|SIGINT\|signal\.signal\|graceful\|shutdown\|lifespan' app/ main.py src/ 2>/dev/null; then ((d++)); check "D6: Graceful shutdown" "PASS"; else check "D6: Graceful shutdown" "FAIL"; fi

score_dimension "DevOps" 6 $d
echo ""

# ──── SEO ────
echo -e "${BOLD}🔎 SEO${NC}"
se=0

check_seo() {
  local pattern="$1"
  local desc="$2"
  if [ -n "$HTML_CHECK_FILE" ] && grep -q "$pattern" "$HTML_CHECK_FILE" 2>/dev/null; then
    ((se++)); check "$desc" "PASS"
  elif grep -rq "$pattern" app/ main.py src/ static/ 2>/dev/null; then
    ((se++)); check "$desc" "PASS"
  else
    check "$desc" "FAIL"
  fi
}

check_seo 'name="description"' "SEO1: Meta desc"
check_seo 'rel="canonical"' "SEO2: Canonical"
check_seo 'og:title\|og:description\|og:image' "SEO3: OG tags"
check_seo 'application/ld+json' "SEO4: JSON-LD"
check_seo '<header\|<main\|<section\|<article\|<nav\|<footer' "SEO5: Semantic"
if [ -f static/robots.txt ] || [ -f public/robots.txt ] || [ -f robots.txt ]; then ((se++)); check "SEO6: robots.txt" "PASS"; else check "SEO6: robots.txt" "FAIL"; fi

score_dimension "SEO" 6 $se
echo ""

# ──── DOCUMENTATION ────
echo -e "${BOLD}📚 DOCUMENTATION${NC}"
doc=0

if [ -f README.md ]; then ((doc++)); check "DOC1: README" "PASS"; else check "DOC1: README" "FAIL"; fi

if [ -f README.md ] && grep -q 'API\|endpoint\|/api/' README.md 2>/dev/null; then ((doc++)); check "DOC2: API docs" "PASS"; else check "DOC2: API docs" "FAIL"; fi

# Inline comments count in Python files (exclude CSS selectors like #header, #modal)
comment_count=$(grep -rn '^\s*#\|[^"'"'"']\s#[^{]' app/ main.py src/ 2>/dev/null | grep -v "test_\|_test\|__pycache__\|\.venv\|#header\|#sidebar\|#content\|#modal\|#main\|#app\|#task\|#ccc\|#auth" | wc -l)
if [ "$comment_count" -ge 5 ]; then ((doc++)); check "DOC3: Comments ($comment_count)" "PASS"; else check "DOC3: Comments ($comment_count <5)" "FAIL"; fi

if [ -f CONTRIBUTING.md ]; then ((doc++)); check "DOC4: CONTRIBUTING" "PASS"; else check "DOC4: CONTRIBUTING" "FAIL"; fi

if [ -f .env.example ]; then ((doc++)); check "DOC5: .env.example" "PASS"; else check "DOC5: .env.example" "FAIL"; fi

score_dimension "Documentation" 5 $doc
echo ""

# ═══════════════════════════════════════════════════════════
# EXPRESS.JS / TYPESCRIPT-EXPRESS SCORING
# ═══════════════════════════════════════════════════════════
elif [ "$FRAMEWORK" = "nestjs" ]; then

# ──── NESTJS SECURITY ────
echo -e "${BOLD}🔒 SECURITY${NC}"
s=0

# S1: Helmet or security headers
if grep -rq "helmet\|Helmet\|app.use.*helmet" src/ 2>/dev/null; then
  ((s++)); check "S1: Helmet" "PASS"
else
  check "S1: Helmet" "FAIL"
fi

# S2: Rate limiting (express-rate-limit or @nestjs/throttler)
if grep -rq "rateLimit\|rate-limit\|ThrottlerModule\|throttler\|@nestjs/throttler" src/ 2>/dev/null; then
  ((s++)); check "S2: Rate-limit" "PASS"
else
  check "S2: Rate-limit" "FAIL"
fi

# S3: CORS not wildcard (check for app.enableCors or CORS setup, not just config)
if grep -rq "enableCors\|app.enableCors\|CorsModule\|cors.*origin" src/ 2>/dev/null && ! grep -rq 'origin.*"\*"' src/ 2>/dev/null; then
  ((s++)); check "S3: CORS restricted" "PASS"
else
  check "S3: CORS restricted" "FAIL"
fi

# S4: JWT secret from env
if grep -rq "process\.env\|dotenv\|ConfigModule\|config\.env\|JWT_SECRET.*env\|env\.JWT" src/ 2>/dev/null; then
  ((s++)); check "S4: JWT env" "PASS"
else
  check "S4: JWT env" "FAIL"
fi

# S5: bcrypt rounds >= 10
if grep -rq "BCRYPT_ROUNDS.*1[0-9]\|saltRounds.*1[0-9]\|gensalt.*1[0-9]\|genSaltSync.*1[0-9]" src/ 2>/dev/null; then
  ((s++)); check "S5: bcrypt≥10" "PASS"
else
  check "S5: bcrypt≥10" "FAIL"
fi

# S6: No password in response
if grep -rq "sanitizeUser\|sanitize.*user\|Omit.*password\|stripPassword\|password.*rest\|exclude.*password\|safeUser" src/ 2>/dev/null; then
  ((s++)); check "S6: No pwd response" "PASS"
else
  check "S6: No pwd response" "FAIL"
fi

# S7: Logout endpoint
if grep -rl "logout\|Logout" src/ 2>/dev/null | grep -v "test_\|spec_\|\.spec\|\.test" 2>/dev/null | grep -q .; then
  ((s++)); check "S7: Logout" "PASS"
else
  check "S7: Logout" "FAIL"
fi

# S8: httpOnly cookie
if grep -rl "httpOnly\|httponly\|res\.cookie\|response\.cookie\|Cookie" src/ 2>/dev/null | grep -v "test_\|spec_" 2>/dev/null | grep -q .; then
  ((s++)); check "S8: httpOnly cookie" "PASS"
else
  check "S8: httpOnly cookie" "FAIL"
fi

# S9: Admin auth (Guard or decorator, not just data role)
if grep -rq "@Roles\|RolesGuard\|@UseGuards.*Admin\|@UseGuards.*Auth.*Admin\|requireAdmin\|adminGuard" src/ 2>/dev/null; then
  ((s++)); check "S9: Admin auth" "PASS"
else
  check "S9: Admin auth" "FAIL"
fi

# S10: Admin strips passwords
if grep -rq "safeUsers\|sanitizeUser\|Omit.*password\|password.*rest\|stripPassword\|exclude.*password" src/ 2>/dev/null; then
  ((s++)); check "S10: Admin strips pwd" "PASS"
else
  check "S10: Admin strips pwd" "FAIL"
fi

# S11: Mass assignment (NestJS: Whitelist, forbidNonWhitelisted)
if grep -rq "Whitelist\|forbidNonWhitelisted\|ALLOWED\|whitelist\|allowedFields\|safeFields\|@Body.*whitelist" src/ 2>/dev/null; then
  ((s++)); check "S11: Mass assign" "PASS"
else
  check "S11: Mass assign" "FAIL"
fi

# S12: XSS prevention
if grep -rq "textContent\|innerText\|escapeHtml\|createTextNode\|DOMPurify" public/ src/ 2>/dev/null; then
  ((s++)); check "S12: XSS fix" "PASS"
else
  check "S12: XSS fix" "FAIL"
fi

score_dimension "Security" 12 $s
echo ""

# ──── NESTJS PERFORMANCE ────
echo -e "${BOLD}⚡ PERFORMANCE${NC}"
p=0

if grep -rq "page\|limit\|offset\|pagination" src/ 2>/dev/null; then ((p++)); check "P1: Pagination" "PASS"; else check "P1: Pagination" "FAIL"; fi
if grep -rq "batch\|prefetch\|Map.*comment\|grouped\|join" src/ 2>/dev/null; then ((p++)); check "P2: N+1 comments" "PASS"; else check "P2: N+1 comments" "FAIL"; fi
if grep -rq "batch\|users_map\|Map.*user\|getUsersByIds\|grouped" src/ 2>/dev/null; then ((p++)); check "P3: N+1 assignee" "PASS"; else check "P3: N+1 assignee" "FAIL"; fi
if ! grep -rq "writeSync\|writeFileSync" src/ 2>/dev/null; then ((p++)); check "P4: Async write" "PASS"; else check "P4: Async write" "FAIL"; fi
if grep -rq "search" src/ 2>/dev/null && grep -rq "page\|limit\|offset" src/ 2>/dev/null; then ((p++)); check "P5: Search pagination" "PASS"; else check "P5: Search pagination" "FAIL"; fi
((p++)); check "P6: JS counting (acceptable)" "PASS"

score_dimension "Performance" 6 $p
echo ""

# ──── NESTJS CODE QUALITY ────
echo -e "${BOLD}🔍 CODE QUALITY${NC}"
kq=0

KQ1_FILES=
if grep -rq "password.*minLength\|minLength.*password\|password.*MinLength\|MinLength.*password\|password.*Field.*min\|password.*min_length\|password.*min.*[6-9]\|password.*length.*>=*[6-9]" src/ 2>/dev/null; then ((kq++)); check "KQ1: Pwd length" "PASS"
elif [ -n "" ] && grep -rq "password"  2>/dev/null; then ((kq++)); check "KQ1: Pwd length" "PASS"
else check "KQ1: Pwd length" "FAIL"; fi
if grep -rq "BadRequestException\|NotFoundException\|ForbiddenException\|UnauthorizedException\|HttpStatus\.4" src/ 2>/dev/null; then ((kq++)); check "KQ2: Status codes" "PASS"; else check "KQ2: Status codes" "FAIL"; fi
if grep -rq "ExceptionFilter\|HttpException\|AllExceptionsFilter\|try.*catch" src/ 2>/dev/null; then ((kq++)); check "KQ3: Error handling" "PASS"; else check "KQ3: Error handling" "FAIL"; fi
KQ4_FILES=$(grep -rl "IsNotEmpty" src/ 2>/dev/null || true)
if grep -rq "title.*required\|IsNotEmpty.*title\|!title\|title.*empty\|title.*min\|title.*trim" src/ 2>/dev/null; then ((kq++)); check "KQ4: Title validation" "PASS"
elif [ -n "$KQ4_FILES" ] && grep -rq "title" $KQ4_FILES 2>/dev/null; then ((kq++)); check "KQ4: Title validation" "PASS"
else check "KQ4: Title validation" "FAIL"; fi
if grep -rq "Bearer \|replace.*Bearer\|startsWith.*Bearer\|slice(7)\|\.split.*Bearer" src/ 2>/dev/null; then ((kq++)); check "KQ5: Bearer strip" "PASS"; else check "KQ5: Bearer strip" "FAIL"; fi
if ! grep -rq "\bvar\b" src/main.ts src/**/*.ts 2>/dev/null; then ((kq++)); check "KQ6: No var" "PASS"; else check "KQ6: No var" "FAIL"; fi

score_dimension "Code Quality" 6 $kq
echo ""

# ──── NESTJS ARCHITECTURE ────
echo -e "${BOLD}🏗️ ARCHITECTURE${NC}"
ar=0

# NestJS: service files in src/*/*.service.ts
if find src/ -maxdepth 2 -name "*.service.ts" 2>/dev/null | grep -q .; then ((ar++)); check "AR1: Service layer" "PASS"; else check "AR1: Service layer" "FAIL"; fi
if find src/ -maxdepth 2 -name "*.service.ts" 2>/dev/null | grep -q .; then ((ar++)); check "AR2: Logic extracted" "PASS"; else check "AR2: Logic extracted" "FAIL"; fi
if grep -rq "process\.env\|dotenv\|ConfigModule\|config\.env\|env\.JWT\|env\.PORT" src/ 2>/dev/null; then ((ar++)); check "AR3: Env config" "PASS"; else check "AR3: Env config" "FAIL"; fi
if [ -f src/config/env.ts ] || [ -f src/config/env.js ] || [ -f src/config/config.ts ]; then ((ar++)); check "AR4: Config file" "PASS"; else check "AR4: Config file" "FAIL"; fi
if find src/ -maxdepth 2 -name "*.service.ts" 2>/dev/null | grep -q .; then ((ar++)); check "AR5: Services exist" "PASS"; else check "AR5: Services exist" "FAIL"; fi
if grep -rq "ExceptionFilter\|HttpException\|AllExceptionsFilter\|try.*catch\|@Catch" src/ 2>/dev/null; then ((ar++)); check "AR6: Consistent errors" "PASS"; else check "AR6: Consistent errors" "FAIL"; fi

score_dimension "Architecture" 6 $ar
echo ""

# ──── NESTJS TEST ────
echo -e "${BOLD}🧪 TEST${NC}"
t=0

# T1: Test files exist (capture to variable to avoid pipefail issues)
NESTJS_SPEC_FILES=$(find test/ tests/ src/ \( -name "*.spec.ts" -o -name "*.e2e-spec.ts" -o -name "*.test.ts" \) 2>/dev/null || true)
if [ -n "$NESTJS_SPEC_FILES" ]; then ((t++)); check "T1: Tests exist" "PASS"; else check "T1: Tests exist" "FAIL"; fi
if grep -q "jest\|vitest\|mocha" package.json 2>/dev/null && grep -q "npm test\|jest\|vitest" .github/workflows/*.yml 2>/dev/null; then ((t++)); check "T2: CI works" "PASS"; else check "T2: CI works" "FAIL"; fi
if grep -q "jest\|vitest\|mocha\|@nestjs/testing" package.json 2>/dev/null; then ((t++)); check "T3: Test framework" "PASS"; else check "T3: Test framework" "FAIL"; fi
if grep -q "actions/checkout" .github/workflows/*.yml 2>/dev/null; then ((t++)); check "T4: CI checkout" "PASS"; else check "T4: CI checkout" "FAIL"; fi
# T5: Edge case tests
NESTJS_EDGE_FILES=$(echo "$NESTJS_SPEC_FILES" | xargs grep -l "invalid\|empty\|short.*password\|duplicate\|boundary\|edge\|missing\|wrong" 2>/dev/null || true)
if [ -n "$NESTJS_EDGE_FILES" ]; then ((t++)); check "T5: Edge cases" "PASS"; else check "T5: Edge cases" "FAIL"; fi
# T6: Integration tests
NESTJS_INT_FILES=$(echo "$NESTJS_SPEC_FILES" | xargs grep -l "supertest\|request(app\|Test\|@nestjs/testing" 2>/dev/null || true)
if [ -n "$NESTJS_INT_FILES" ]; then ((t++)); check "T6: Integration" "PASS"; else check "T6: Integration" "FAIL"; fi

score_dimension "Test" 6 $t
echo ""

# ──── NESTJS ACCESSIBILITY ────
echo -e "${BOLD}♿ ACCESSIBILITY${NC}"
a=0

if grep -q 'lang=' public/index.html 2>/dev/null; then ((a++)); check "A1: html lang" "PASS"; else check "A1: html lang" "FAIL"; fi
if grep -q 'charset' public/index.html 2>/dev/null; then ((a++)); check "A2: charset" "PASS"; else check "A2: charset" "FAIL"; fi
if grep -q 'viewport' public/index.html 2>/dev/null; then ((a++)); check "A3: viewport" "PASS"; else check "A3: viewport" "FAIL"; fi
if grep -q '<label\|aria-label' public/index.html 2>/dev/null; then ((a++)); check "A4: Labels" "PASS"; else check "A4: Labels" "FAIL"; fi
if grep -q 'aria-\|role=' public/index.html 2>/dev/null; then ((a++)); check "A5: ARIA" "PASS"; else check "A5: ARIA" "FAIL"; fi
if grep -q 'Escape\|keydown' public/index.html 2>/dev/null; then ((a++)); check "A6: ESC close" "PASS"; else check "A6: ESC close" "FAIL"; fi
if grep -q '\.focus()\|focus(' public/index.html 2>/dev/null; then ((a++)); check "A7: Focus mgmt" "PASS"; else check "A7: Focus mgmt" "FAIL"; fi

score_dimension "Accessibility" 7 $a
echo ""

# ──── NESTJS UX ────
echo -e "${BOLD}🎨 UX${NC}"
u=0

if grep -q 'search.*addEventListener\|addEventListener.*search\|searchTasks\|performSearch' public/index.html 2>/dev/null; then ((u++)); check "U1: Search works" "PASS"; else check "U1: Search works" "FAIL"; fi
if grep -q 'filter.*addEventListener\|filterByStatus\|renderFiltered\|applyFilter' public/index.html 2>/dev/null; then ((u++)); check "U2: Filter works" "PASS"; else check "U2: Filter works" "FAIL"; fi
if grep -q 'error-message\|showError\|loginError\|error.*feedback\|error.*textContent' public/index.html 2>/dev/null; then ((u++)); check "U3: Error feedback" "PASS"; else check "U3: Error feedback" "FAIL"; fi
if grep -q 'closeModal.*loadTasks\|then.*closeModal\|then.*loadTasks\|showToast\|success.*message' public/index.html 2>/dev/null; then ((u++)); check "U4: Create feedback" "PASS"; else check "U4: Create feedback" "FAIL"; fi
if grep -q 'spinner\|loading\|isLoading\|showLoading' public/index.html 2>/dev/null; then ((u++)); check "U5: Loading state" "PASS"; else check "U5: Loading state" "FAIL"; fi
if grep -q '@media' public/index.html 2>/dev/null; then ((u++)); check "U6: Responsive" "PASS"; else check "U6: Responsive" "FAIL"; fi
if grep -q 'empty-state\|No tasks\|no-result\|no-tasks\|emptyState' public/index.html 2>/dev/null; then ((u++)); check "U7: Empty state" "PASS"; else check "U7: Empty state" "FAIL"; fi

score_dimension "UX" 7 $u
echo ""

# ──── NESTJS DEVOPS ────
echo -e "${BOLD}🚀 DEVOPS${NC}"
d=0

if grep -q '^USER\|^USER ' Dockerfile 2>/dev/null || grep -q 'appuser\|non-root' Dockerfile 2>/dev/null; then ((d++)); check "D1: Non-root" "PASS"; else check "D1: Non-root" "FAIL"; fi
if [ -f .dockerignore ]; then ((d++)); check "D2: .dockerignore" "PASS"; else check "D2: .dockerignore" "FAIL"; fi
if grep -rq '/health\|/api/health\|HealthModule\|HealthController' src/ 2>/dev/null || grep -q 'HEALTHCHECK' Dockerfile 2>/dev/null; then ((d++)); check "D3: Health check" "PASS"; else check "D3: Health check" "FAIL"; fi
if grep -q 'actions/checkout' .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D4: CI checkout" "PASS"; else check "D4: CI checkout" "FAIL"; fi
if grep -q 'npm ci' Dockerfile .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D5: npm ci" "PASS"; else check "D5: npm ci" "FAIL"; fi
if grep -rq 'SIGTERM\|SIGINT\|process\.on\|graceful\|enableShutdownHooks\|shutdown' src/ 2>/dev/null; then ((d++)); check "D6: Graceful shutdown" "PASS"; else check "D6: Graceful shutdown" "FAIL"; fi

score_dimension "DevOps" 6 $d
echo ""

# ──── NESTJS SEO ────
echo -e "${BOLD}🔎 SEO${NC}"
se=0

if grep -q 'name="description"' public/index.html 2>/dev/null; then ((se++)); check "SEO1: Meta desc" "PASS"; else check "SEO1: Meta desc" "FAIL"; fi
if grep -q 'rel="canonical"' public/index.html 2>/dev/null; then ((se++)); check "SEO2: Canonical" "PASS"; else check "SEO2: Canonical" "FAIL"; fi
if grep -q 'og:title\|og:description' public/index.html 2>/dev/null; then ((se++)); check "SEO3: OG tags" "PASS"; else check "SEO3: OG tags" "FAIL"; fi
if grep -q 'application/ld+json' public/index.html 2>/dev/null; then ((se++)); check "SEO4: JSON-LD" "PASS"; else check "SEO4: JSON-LD" "FAIL"; fi
if grep -q '<header\|<main\|<section\|<article\|<nav' public/index.html 2>/dev/null; then ((se++)); check "SEO5: Semantic" "PASS"; else check "SEO5: Semantic" "FAIL"; fi
if [ -f public/robots.txt ] || [ -f robots.txt ]; then ((se++)); check "SEO6: robots.txt" "PASS"; else check "SEO6: robots.txt" "FAIL"; fi

score_dimension "SEO" 6 $se
echo ""

# ──── NESTJS DOCUMENTATION ────
echo -e "${BOLD}📚 DOCUMENTATION${NC}"
doc=0

if [ -f README.md ]; then ((doc++)); check "DOC1: README" "PASS"; else check "DOC1: README" "FAIL"; fi
if [ -f README.md ] && grep -q 'API\|endpoint\|/api/' README.md 2>/dev/null; then ((doc++)); check "DOC2: API docs" "PASS"; else check "DOC2: API docs" "FAIL"; fi
comment_count=$(grep -rc '//' src/**/*.controller.ts src/**/*.service.ts src/**/*.ts 2>/dev/null | awk -F: '{sum+=$2} END{print sum+0}')
if [ "$comment_count" -ge 5 ]; then ((doc++)); check "DOC3: Comments ($comment_count)" "PASS"; else check "DOC3: Comments ($comment_count <5)" "FAIL"; fi
if [ -f CONTRIBUTING.md ]; then ((doc++)); check "DOC4: CONTRIBUTING" "PASS"; else check "DOC4: CONTRIBUTING" "FAIL"; fi
if [ -f .env.example ]; then ((doc++)); check "DOC5: .env.example" "PASS"; else check "DOC5: .env.example" "FAIL"; fi

score_dimension "Documentation" 5 $doc
echo ""

# ═══════════════════════════════════════════════════════════
# EXPRESS.JS / TYPESCRIPT-EXPRESS SCORING
# ═══════════════════════════════════════════════════════════
elif [ "$FRAMEWORK" = "js-express" ] || [ "$FRAMEWORK" = "typescript-express" ]; then

# ──── SECURITY ────
echo -e "${BOLD}🔒 SECURITY${NC}"
s=0

# S1: Helmet / Security headers (express-helmet or NestJS equivalent)
if grep -rq "helmet\|Helmet" src/ 2>/dev/null; then ((s++)); check "S1: Helmet" "PASS"; else check "S1: Helmet" "FAIL"; fi
# S2: Rate limiting (express-rate-limit or @nestjs/throttler or slowapi)
if grep -rq "rateLimit\|rate-limit\|ThrottlerModule\|throttler\|@nestjs/throttler" src/ 2>/dev/null; then ((s++)); check "S2: Rate-limit" "PASS"; else check "S2: Rate-limit" "FAIL"; fi
if grep -rq "CORS_ORIGIN\|origin:" src/ 2>/dev/null && ! grep -rq "cors()" src/ 2>/dev/null; then ((s++)); check "S3: CORS restricted" "PASS"; else check "S3: CORS restricted" "FAIL"; fi
if grep -rq "process.env\|dotenv\|requireEnv\|JWT_SECRET" src/config/ 2>/dev/null; then ((s++)); check "S4: JWT env" "PASS"; else check "S4: JWT env" "FAIL"; fi
if grep -rq "BCRYPT_ROUNDS.*1[0-9]\|saltRounds.*1[0-9]\|rounds.*1[0-9]" src/ 2>/dev/null; then ((s++)); check "S5: bcrypt≥10" "PASS"; else check "S5: bcrypt≥10" "FAIL"; fi
if grep -rq "sanitizeUser\|password.*rest\|Omit.*password\|stripPassword\|safe_user\|id:.*username:" src/ 2>/dev/null; then ((s++)); check "S6: No pwd response" "PASS"; else check "S6: No pwd response" "FAIL"; fi
if grep -rq "logout" src/ 2>/dev/null; then ((s++)); check "S7: Logout" "PASS"; else check "S7: Logout" "FAIL"; fi
if grep -rq "httpOnly\|res\.cookie" src/ 2>/dev/null; then ((s++)); check "S8: httpOnly cookie" "PASS"; else check "S8: httpOnly cookie" "FAIL"; fi
# S9: Admin auth (middleware, guard, or decorator)
if grep -rq "adminAuth\|requireAdmin\|requireRole\|role.*admin\|auth.*admin\|router\.get.*auth\|@Roles\|RolesGuard\|UseGuards.*Auth\|Roles.*admin" src/ 2>/dev/null; then ((s++)); check "S9: Admin auth" "PASS"; else check "S9: Admin auth" "FAIL"; fi
if grep -rq "safeUsers\|Omit.*password\|password.*rest\|stripPassword\|sanitize.*user\|map.*u.*=>" src/ 2>/dev/null; then ((s++)); check "S10: Admin strips pwd" "PASS"; else check "S10: Admin strips pwd" "FAIL"; fi
if grep -rq "ALLOWED\|whitelist\|allowedFields\|safeFields\|Whitelist\|@Body.*whitelist\|forbidNonWhitelisted" src/ 2>/dev/null; then ((s++)); check "S11: Mass assign" "PASS"; else check "S11: Mass assign" "FAIL"; fi
if grep -rq "escapeHtml\|textContent\|createTextNode" public/ 2>/dev/null; then ((s++)); check "S12: XSS fix" "PASS"; else check "S12: XSS fix" "FAIL"; fi

score_dimension "Security" 12 $s
echo ""

# ──── PERFORMANCE ────
echo -e "${BOLD}⚡ PERFORMANCE${NC}"
p=0

if grep -rq "req\.query\.page\|parseInt(req.query\|page.*limit" src/ 2>/dev/null; then ((p++)); check "P1: Pagination" "PASS"; else check "P1: Pagination" "FAIL"; fi
if grep -rq "batchComment\|getCommentsByTask\|commentsByTask\|Map.*comment" src/ 2>/dev/null; then ((p++)); check "P2: N+1 comments" "PASS"; else check "P2: N+1 comments" "FAIL"; fi
if grep -rq "getUsersByIds\|usersMap\|Map.*User\|batchUser" src/ 2>/dev/null || grep -rq "req\.query\.page" src/ 2>/dev/null; then ((p++)); check "P3: N+1 assignee" "PASS"; else check "P3: N+1 assignee" "FAIL"; fi
if ! grep -rq "writeSync\|writeFileSync" src/ 2>/dev/null; then ((p++)); check "P4: Async write" "PASS"; else check "P4: Async write" "FAIL"; fi
if grep -rq "search" src/ 2>/dev/null && (grep -A10 "search" src/routes/searchRoutes.ts src/routes/searchRoutes.js src/server.ts src/server.js 2>/dev/null | grep -q "page\|limit\|offset" || grep -rq "page\|limit" src/routes/ src/services/ src/server.ts src/server.js 2>/dev/null); then ((p++)); check "P5: Search pagination" "PASS"; else check "P5: Search pagination" "FAIL"; fi
((p++)); check "P6: JS counting (acceptable)" "PASS"

score_dimension "Performance" 6 $p
echo ""

# ──── CODE QUALITY ────
echo -e "${BOLD}🔍 CODE QUALITY${NC}"
kq=0

if grep -rq "password.*length\|length.*[6-8]\|min.*[6-8]\|password.*min" src/ 2>/dev/null; then ((kq++)); check "KQ1: Pwd length" "PASS"; else check "KQ1: Pwd length" "FAIL"; fi
if grep -rq "status(201\|status(400\|status(401\|status(403\|status(404\|status(409\|status(500)" src/ 2>/dev/null; then ((kq++)); check "KQ2: Status codes" "PASS"; else check "KQ2: Status codes" "FAIL"; fi
if grep -rq "AppError\|statusCode\|AuthError\|ValidationError\|status(500)" src/ 2>/dev/null; then ((kq++)); check "KQ3: Error handling" "PASS"; else check "KQ3: Error handling" "FAIL"; fi
if grep -rq "title.*trim\|title.*required\|!title\|title.*empty" src/ 2>/dev/null; then ((kq++)); check "KQ4: Title validation" "PASS"; else check "KQ4: Title validation" "FAIL"; fi
if grep -rq "slice(7)\|replace.*Bearer\|startsWith.*Bearer\|Bearer " src/ 2>/dev/null; then ((kq++)); check "KQ5: Bearer strip" "PASS"; else check "KQ5: Bearer strip" "FAIL"; fi
if ! grep -rq "\bvar\b" src/server.ts src/server.js src/store/database.ts src/config/env.ts 2>/dev/null; then ((kq++)); check "KQ6: No var" "PASS"; else check "KQ6: No var" "FAIL"; fi

score_dimension "Code Quality" 6 $kq
echo ""

# ──── ARCHITECTURE ────
echo -e "${BOLD}🏗️ ARCHITECTURE${NC}"
ar=0

if [ -d src/services ]; then ((ar++)); check "AR1: Service layer" "PASS"; else
  if find src/ -maxdepth 2 -name "*.service.ts" -o -name "*.service.js" 2>/dev/null | grep -q .; then ((ar++)); check "AR1: Service layer (NestJS)" "PASS"; else check "AR1: Service layer" "FAIL"; fi
fi
if [ -d src/services ]; then ((ar++)); check "AR2: Logic extracted" "PASS"; else
  if find src/ -maxdepth 2 -name "*.service.ts" -o -name "*.service.js" 2>/dev/null | grep -q .; then ((ar++)); check "AR2: Logic extracted (NestJS)" "PASS"; else check "AR2: Logic extracted" "FAIL"; fi
fi
if grep -rq "dotenv\|process.env\|requireEnv" src/config/ 2>/dev/null; then ((ar++)); check "AR3: Env config" "PASS"; else check "AR3: Env config" "FAIL"; fi
if [ -f src/config/env.ts ] || [ -f src/config/env.js ] || [ -f src/config/index.js ] || [ -f src/config/index.ts ]; then ((ar++)); check "AR4: Config file" "PASS"; else check "AR4: Config file" "FAIL"; fi
if compgen -G "src/services/*.ts" > /dev/null 2>&1 || compgen -G "src/services/*.js" > /dev/null 2>&1; then ((ar++)); check "AR5: Services exist" "PASS"; else
  if find src/ -maxdepth 2 -name "*.service.ts" -o -name "*.service.js" 2>/dev/null | grep -q .; then ((ar++)); check "AR5: Services exist (NestJS)" "PASS"; else check "AR5: Services exist" "FAIL"; fi
fi
if grep -rq "AppError\|asyncHandler\|errorHandler\|try.*catch\|err.*req.*res.*next\|use.*err.*req.*res" src/ 2>/dev/null; then ((ar++)); check "AR6: Consistent errors" "PASS"; else check "AR6: Consistent errors" "FAIL"; fi

score_dimension "Architecture" 6 $ar
echo ""

# ──── TEST ────
echo -e "${BOLD}🧪 TEST${NC}"
t=0

TS_TEST_FILES=$(find src/ tests/ -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" 2>/dev/null || true)
if [ -n "$TS_TEST_FILES" ]; then ((t++)); check "T1: Tests exist" "PASS"; else check "T1: Tests exist" "FAIL"; fi
if grep -q "npm test\|vitest\|jest" package.json .github/workflows/*.yml 2>/dev/null; then ((t++)); check "T2: CI works" "PASS"; else check "T2: CI works" "FAIL"; fi
if grep -q "vitest\|jest\|mocha" package.json 2>/dev/null; then ((t++)); check "T3: Test framework" "PASS"; else check "T3: Test framework" "FAIL"; fi
if grep -q "actions/checkout" .github/workflows/*.yml 2>/dev/null; then ((t++)); check "T4: CI checkout" "PASS"; else check "T4: CI checkout" "FAIL"; fi
if grep -rq "invalid\|empty.*title\|short.*password\|duplicate\|reject\|boundary\|edge" src/__tests__/ tests/ 2>/dev/null; then ((t++)); check "T5: Edge cases" "PASS"; else check "T5: Edge cases" "FAIL"; fi
if grep -rq "supertest\|request(app)" src/__tests__/ tests/ 2>/dev/null; then ((t++)); check "T6: Integration" "PASS"; else check "T6: Integration" "FAIL"; fi

score_dimension "Test" 6 $t
echo ""

# ──── ACCESSIBILITY ────
echo -e "${BOLD}♿ ACCESSIBILITY${NC}"
a=0

if grep -q 'lang=' public/index.html 2>/dev/null; then ((a++)); check "A1: html lang" "PASS"; else check "A1: html lang" "FAIL"; fi
if grep -q 'charset' public/index.html 2>/dev/null; then ((a++)); check "A2: charset" "PASS"; else check "A2: charset" "FAIL"; fi
if grep -q 'viewport' public/index.html 2>/dev/null; then ((a++)); check "A3: viewport" "PASS"; else check "A3: viewport" "FAIL"; fi
if grep -q '<label\|aria-label' public/index.html 2>/dev/null; then ((a++)); check "A4: Labels" "PASS"; else check "A4: Labels" "FAIL"; fi
if grep -q 'aria-\|role=' public/index.html 2>/dev/null; then ((a++)); check "A5: ARIA" "PASS"; else check "A5: ARIA" "FAIL"; fi
if grep -q 'Escape\|keydown' public/index.html 2>/dev/null; then ((a++)); check "A6: ESC close" "PASS"; else check "A6: ESC close" "FAIL"; fi
if grep -q '\.focus()\|focus(' public/index.html 2>/dev/null; then ((a++)); check "A7: Focus mgmt" "PASS"; else check "A7: Focus mgmt" "FAIL"; fi

score_dimension "Accessibility" 7 $a
echo ""

# ──── UX ────
echo -e "${BOLD}🎨 UX${NC}"
u=0

if grep -q 'search\|filterTasks\|renderFiltered' public/index.html 2>/dev/null; then ((u++)); check "U1: Search works" "PASS"; else check "U1: Search works" "FAIL"; fi
if grep -q 'filterSelect\|renderFiltered\|status.*filter' public/index.html 2>/dev/null; then ((u++)); check "U2: Filter works" "PASS"; else check "U2: Filter works" "FAIL"; fi
if grep -q 'error-msg\|showError\|loginError\|error-message\|error.*feedback' public/index.html 2>/dev/null; then ((u++)); check "U3: Error feedback" "PASS"; else check "U3: Error feedback" "FAIL"; fi
if grep -q 'modal.*close\|closeModal\|refreshTasks\|showTasks' public/index.html 2>/dev/null; then ((u++)); check "U4: Create feedback" "PASS"; else check "U4: Create feedback" "FAIL"; fi
if grep -q 'spinner\|loading\|Loading' public/index.html 2>/dev/null; then ((u++)); check "U5: Loading state" "PASS"; else check "U5: Loading state" "FAIL"; fi
if grep -q '@media' public/index.html 2>/dev/null; then ((u++)); check "U6: Responsive" "PASS"; else check "U6: Responsive" "FAIL"; fi
if grep -q 'empty\|No tasks\|no-result' public/index.html 2>/dev/null; then ((u++)); check "U7: Empty state" "PASS"; else check "U7: Empty state" "FAIL"; fi

score_dimension "UX" 7 $u
echo ""

# ──── DEVOPS ────
echo -e "${BOLD}🚀 DEVOPS${NC}"
d=0

if grep -q 'USER\|appuser\|node' Dockerfile 2>/dev/null; then ((d++)); check "D1: Non-root" "PASS"; else check "D1: Non-root" "FAIL"; fi
if [ -f .dockerignore ]; then ((d++)); check "D2: .dockerignore" "PASS"; else check "D2: .dockerignore" "FAIL"; fi
if grep -rq '/api/health\|/health' src/ 2>/dev/null || grep -q 'HEALTHCHECK' Dockerfile 2>/dev/null; then ((d++)); check "D3: Health check" "PASS"; else check "D3: Health check" "FAIL"; fi
if grep -q 'actions/checkout' .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D4: CI checkout" "PASS"; else check "D4: CI checkout" "FAIL"; fi
if grep -q 'npm ci' Dockerfile .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D5: npm ci" "PASS"; else
  if grep -q 'npm install --production\|npm ci\|ci:' Dockerfile .github/workflows/*.yml 2>/dev/null; then ((d++)); check "D5: npm ci/lockfile" "PASS"; else check "D5: npm ci" "FAIL"; fi
fi
if grep -rq 'SIGTERM\|SIGINT\|process\.on\|graceful' src/ 2>/dev/null; then ((d++)); check "D6: Graceful shutdown" "PASS"; else check "D6: Graceful shutdown" "FAIL"; fi

score_dimension "DevOps" 6 $d
echo ""

# ──── SEO ────
echo -e "${BOLD}🔎 SEO${NC}"
se=0

if grep -q 'name="description"' public/index.html 2>/dev/null; then ((se++)); check "SEO1: Meta desc" "PASS"; else check "SEO1: Meta desc" "FAIL"; fi
if grep -q 'rel="canonical"' public/index.html 2>/dev/null; then ((se++)); check "SEO2: Canonical" "PASS"; else check "SEO2: Canonical" "FAIL"; fi
if grep -q 'og:title\|og:description' public/index.html 2>/dev/null; then ((se++)); check "SEO3: OG tags" "PASS"; else check "SEO3: OG tags" "FAIL"; fi
if grep -q 'application/ld+json' public/index.html 2>/dev/null; then ((se++)); check "SEO4: JSON-LD" "PASS"; else check "SEO4: JSON-LD" "FAIL"; fi
if grep -q '<header\|<main\|<section\|<article\|<nav' public/index.html 2>/dev/null; then ((se++)); check "SEO5: Semantic" "PASS"; else check "SEO5: Semantic" "FAIL"; fi
if [ -f public/robots.txt ] || [ -f robots.txt ]; then ((se++)); check "SEO6: robots.txt" "PASS"; else check "SEO6: robots.txt" "FAIL"; fi

score_dimension "SEO" 6 $se
echo ""

# ──── DOCUMENTATION ────
echo -e "${BOLD}📚 DOCUMENTATION${NC}"
doc=0

if [ -f README.md ]; then ((doc++)); check "DOC1: README" "PASS"; else check "DOC1: README" "FAIL"; fi
if [ -f README.md ] && grep -q 'API\|endpoint\|/api/' README.md 2>/dev/null; then ((doc++)); check "DOC2: API docs" "PASS"; else check "DOC2: API docs" "FAIL"; fi
comment_count=$(grep -rc '//' src/server.ts src/routes/*.ts src/services/*.ts src/server.js src/routes/*.js src/services/*.js 2>/dev/null | awk -F: '{sum+=$2} END{print sum+0}')
if [ "$comment_count" -ge 5 ]; then ((doc++)); check "DOC3: Comments ($comment_count)" "PASS"; else check "DOC3: Comments ($comment_count <5)" "FAIL"; fi
if [ -f CONTRIBUTING.md ]; then ((doc++)); check "DOC4: CONTRIBUTING" "PASS"; else check "DOC4: CONTRIBUTING" "FAIL"; fi
if [ -f .env.example ]; then ((doc++)); check "DOC5: .env.example" "PASS"; else check "DOC5: .env.example" "FAIL"; fi

score_dimension "Documentation" 5 $doc
echo ""

else
  echo -e "${RED}⚠️ Bilinmeyen framework: $FRAMEWORK — scoring skipped${NC}"
  echo ""
fi

# ═══════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  SONUÇ ÖZETİ                                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

overall_pct=0
if [ "$TOTAL_BUGS" -gt 0 ]; then
  overall_pct=$(( (TOTAL_FIXED * 100) / TOTAL_BUGS ))
fi

passing=0
for dim in "${DIMENSION_RESULTS[@]}"; do
  IFS='|' read -r name total fixed pct status <<< "$dim"
  printf "  %-15s %2d/%2d  %3d%%  %b\n" "$name" "$fixed" "$total" "$pct" "$status"
  if [ "$pct" -ge 80 ]; then
    passing=$((passing + 1))
  fi
done

echo ""
echo -e "  ${BOLD}TOPLAM:${NC}  ${TOTAL_FIXED}/${TOTAL_BUGS} = ${BOLD}${overall_pct}%${NC}"
echo -e "  ${BOLD}GEÇEN:${NC}  ${passing}/${#DIMENSION_RESULTS[@]} boyut ≥80%"
echo ""

if [ "$passing" -eq "${#DIMENSION_RESULTS[@]}" ] && [ "${#DIMENSION_RESULTS[@]}" -gt 0 ]; then
  echo -e "  ${GREEN}${BOLD}🎉 TÜM BOYUTLAR GEÇTİ!${NC}"
  exit 0
else
  echo -e "  ${RED}${BOLD}❌ ${passing}/${#DIMENSION_RESULTS[@]} boyut geçti — ${RED}$(( ${#DIMENSION_RESULTS[@]} - passing )) boyut KALDI${NC}"
  exit 1
fi
