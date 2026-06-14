#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OpenCode Audit Kit — Auto-Audit with Retry (Multi-Framework)
# Kullanım: bash auto-audit.sh [project-dir] [max-runs]
# Örnek:   bash auto-audit.sh /home/user/fastapi-stress-test 3
# ═══════════════════════════════════════════════════════════════

PROJECT_DIR="${1:-.}"
MAX_RUNS="${2:-3}"
AUDIT_KIT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Detect Framework ---
FRAMEWORK="unknown"
if [ -f "$PROJECT_DIR/requirements.txt" ] && grep -q "fastapi" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
  FRAMEWORK="fastapi"
elif [ -f "$PROJECT_DIR/app/main.py" ] || [ -f "$PROJECT_DIR/main.py" ] && grep -rq "from fastapi import" "$PROJECT_DIR/main.py" "$PROJECT_DIR/app/main.py" 2>/dev/null; then
  FRAMEWORK="fastapi"
elif [ -f "$PROJECT_DIR/package.json" ]; then
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
fi

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  OpenCode Audit Kit — Auto-Audit with Retry             ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Proje:    $PROJECT_DIR"
echo "Framework: $FRAMEWORK"
echo "Max Run:  $MAX_RUNS"
echo ""

# --- Build audit message based on framework ---
build_audit_message() {
  if [ "$FRAMEWORK" = "fastapi" ]; then
    echo "Bu FastAPI/Python projesindeki TÜM bug'ları bul ve düzelt. skill:fix-fastapi kullan! 10 boyutta kapsamlı audit yap: Security, Performance, Code Quality, Architecture, Test Coverage, Accessibility, UX, DevOps, SEO, Documentation. Özellikle dikkat et: 1) CORSMiddleware ZORUNLU 2) slowapi rate limiting ZORUNLU 3) httpOnly cookie ZORUNLU 4) Service layer (app/services/) ZORUNLU 5) Pagination (page, limit) ZORUNLU 6) pytest + TestClient integration test ZORUNLU 7) robots.txt ZORUNLU 8) Inline comments ≥5 ZORUNLU 9) CONTRIBUTING.md ZORUNLU 10) Graceful shutdown ZORUNLU 11) README.md ZORUNLU 12) .env.example ZORUNLU 13) canonical URL ZORUNLU 14) JSON-LD structured data ZORUNLU 15) @media responsive ZORUNLU 16) require_admin Depends ZORUNLU 17) sanitize_user ZORUNLU 18) Bearer token strip ZORUNLU 19) Pydantic extra='forbid' ZORUNLU 20) Logout endpoint ZORUNLU"
  elif [ "$FRAMEWORK" = "nestjs" ]; then
    echo "Bu NestJS/TypeScript projesindeki TÜM bug'ları bul ve düzelt. skill:fix-nestjs kullan! 10 boyutta kapsamlı audit yap: Security, Performance, Code Quality, Architecture, Test Coverage, Accessibility, UX, DevOps, SEO, Documentation. Özellikle dikkat et: 1) Helmet ZORUNLU (npm helmet, app.use(helmet.default())) 2) @nestjs/throttler rate limiting ZORUNLU 3) app.enableCors({origin: config.CORS_ORIGIN}) ZORUNLU, * YASAK 4) JWT secret process.env'den ZORUNLU 5) BCRYPT_ROUNDS ≥12 ZORUNLU 6) sanitizeUser() ile password rest ZORUNLU 7) @Post('logout') endpoint ZORUNLU 8) response.cookie({httpOnly:true}) ZORUNLU 9) @Roles('admin') + RolesGuard ZORUNLU admin route'larda 10) ValidationPipe({whitelist:true, forbidNonWhitelisted:true}) ZORUNLU 11) *.service.ts files ZORUNLU (auth.service, tasks.service, admin.service) 12) Pagination (page, limit) ZORUNLU 13) Batch Map ile N+1 çözümü ZORUNLU 14) @MinLength(8) password DTO ZORUNLU 15) @IsNotEmpty() title DTO ZORUNLU 16) Bearer strip (slice(7)) ZORUNLU 17) AllExceptionsFilter @Catch() ZORUNLU 18) jest + supertest + @nestjs/testing ZORUNLU 19) HealthController /api/health ZORUNLU 20) enableShutdownHooks() ZORUNLU 21) Dockerfile USER appuser ZORUNLU 22) .dockerignore ZORUNLU 23) npm ci ZORUNLU Dockerfile ve CI'da 24) robots.txt ZORUNLU 25) CONTRIBUTING.md + .env.example + README.md ZORUNLU 26) Inline comments ≥5 ZORUNLU 27) HTML: lang, charset, viewport, label, aria, ESC close, focus ZORUNLU 28) HTML: search addEventListener, filter, error-message, loading, @media, empty-state ZORUNLU 29) HTML: meta description, canonical, og tags, JSON-LD, semantic tags ZORUNLU 30) process.env / dotenv config ZORUNLU"
  elif [ "$FRAMEWORK" = "nextjs" ]; then
    echo "Bu Next.js projesindeki TÜM bug'ları bul ve düzelt. skill:fix-nextjs kullan! 10 boyutta kapsamlı audit yap: Security, Performance, Code Quality, Architecture, Test Coverage, Accessibility, UX, DevOps, SEO, Documentation. Özellikle dikkat et: 1) Security headers in next.config.js ZORUNLU 2) Rate limiting in src/middleware.js ZORUNLU 3) CORS origin check ZORUNLU 4) JWT secret process.env.JWT_SECRET ZORUNLU 5) BCRYPT_ROUNDS ≥12 ZORUNLU 6) sanitizeUser() ile password rest ZORUNLU 7) httpOnly cookie login/register'da ZORUNLU 8) Logout endpoint cookie clear ZORUNLU 9) Admin route JWT+role check ZORUNLU 10) dangerouslySetInnerHTML KALDIR (React auto-escapes) 11) Mass assignment: sadece allowed fields ZORUNLU 12) Pagination (page, limit) ZORUNLU 13) N+1 batch Map comments ZORUNLU 14) password.length ≥8 ZORUNLU 15) title.trim() validation ZORUNLU 16) Bearer slice(7) ZORUNLU 17) src/lib/ service layer ZORUNLU 18) src/lib/config.js ZORUNLU 19) jest integration tests ZORUNLU 20) layout.js: lang=en, charset, viewport, meta desc, OG, canonical, JSON-LD, semantic HTML ZORUNLU 21) page.js: search, filter, error-message, loading, @media, empty-state, label, aria, ESC, focus ZORUNLU 22) Dockerfile USER appuser ZORUNLU 23) .dockerignore ZORUNLU 24) CI workflow ZORUNLU 25) /api/health ZORUNLU 26) robots.txt ZORUNLU 27) README.md + CONTRIBUTING.md + .env.example ZORUNLU 28) Inline comments ≥5 ZORUNLU"
  else
    echo "Bu projedeki TÜM bug'ları bul ve düzelt. 10 boyutta kapsamlı audit yap: Security, Performance, Code Quality, Architecture, Test Coverage, Accessibility, UX, DevOps, SEO, Documentation. Her skill'in ADIM 4.5 doğrulama adımını MUTLAKA uygula! Özellikle dikkat et: 1) express-rate-limit ZORUNLU 2) httpOnly cookie ZORUNLU 3) Service layer ZORUNLU 4) Pagination ZORUNLU 5) supertest integration test ZORUNLU 6) robots.txt ZORUNLU 7) Inline comments ≥5 ZORUNLU 8) CONTRIBUTING.md ZORUNLU 9) Graceful shutdown ZORUNLU 10) README.md ZORUNLU 11) .env.example ZORUNLU 12) canonical URL ZORUNLU 13) JSON-LD structured data ZORUNLU 14) @media responsive ZORUNLU"
  fi
}

build_targeted_message() {
  local score_file="$1"
  local msg="KRİTİK EKSİKLİKLERİ DÜZELT — Aşağıdaki bug'lar hala mevcut:"
  local count=0

  if [ "$FRAMEWORK" = "fastapi" ]; then
    # FastAPI-specific targeted checks
    if grep -q "S1.*FAIL\|S2.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) CORS middleware + Rate limiting (slowapi) EKSİK — HEMEN ekle!"
    fi
    if grep -q "S4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) JWT secret hardcoded — os.getenv() ile environment variable'a taşı, config.py oluştur!"
    fi
    if grep -q "S5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) bcrypt rounds < 10 — BCRYPT_ROUNDS = 12 yap!"
    fi
    if grep -q "S6.*FAIL\|S10.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Password hash response'da — sanitize_user() fonksiyonu ekle!"
    fi
    if grep -q "S7.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Logout endpoint YOK — POST /api/logout ekle!"
    fi
    if grep -q "S8.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) httpOnly cookie YOK — response.set_cookie() kullan, localStorage'I KALDIR!"
    fi
    if grep -q "S9.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Admin auth YOK — require_admin dependency ekle, Depends(require_admin) kullan!"
    fi
    if grep -q "S11.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Mass assignment — Pydantic model'e model_config = ConfigDict(extra='forbid') ekle!"
    fi
    if grep -q "KQ1.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Password min_length YOK — password: str = Field(min_length=8) ekle!"
    fi
    if grep -q "KQ5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Bearer token strip YOK — token[7:] veya removeprefix('Bearer ') ekle!"
    fi
    if grep -q "AR1.*FAIL\|AR2.*FAIL\|AR5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Service layer YOK — app/services/ dizini ve service dosyaları oluştur!"
    fi
    if grep -q "AR3.*FAIL\|AR4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Config file YOK — app/core/config.py oluştur, os.getenv() kullan!"
    fi
    if grep -q "T1.*FAIL\|T3.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Test YOK — tests/ dizini oluştur, pytest + TestClient ekle, requirements.txt'e pytest httpx ekle!"
    fi
    if grep -q "D1.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Dockerfile root user — RUN useradd -m appuser + USER appuser ekle!"
    fi
    if grep -q "D3.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Health endpoint YOK — GET /api/health ekle!"
    fi
    if grep -q "D6.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Graceful shutdown YOK — signal.signal() veya FastAPI lifespan ekle!"
    fi
    if grep -q "SEO1.*FAIL\|SEO2.*FAIL\|SEO4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) SEO: meta description + canonical URL + JSON-LD ekle HTML'e!"
    fi
    if grep -q "SEO6.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) robots.txt YOK — oluştur!"
    fi
    if grep -q "DOC1.*FAIL\|DOC4.*FAIL\|DOC5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) README.md + CONTRIBUTING.md + .env.example YOK — write() ile oluştur!"
    fi
  elif [ "$FRAMEWORK" = "nestjs" ]; then
    # NestJS-specific targeted checks
    if grep -q "S1.*FAIL\|S2.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Helmet + @nestjs/throttler EKSİK — app.use(helmet.default()) ve ThrottlerModule ekle!"
    fi
    if grep -q "S3.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) CORS wildcard — app.enableCors({origin: config.CORS_ORIGIN}) yap, * YASAK!"
    fi
    if grep -q "S4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) JWT secret hardcoded — process.env.JWT_SECRET ile environment variable'a taşı!"
    fi
    if grep -q "S5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) bcrypt rounds < 10 — BCRYPT_ROUNDS = 12 yap!"
    fi
    if grep -q "S6.*FAIL\|S10.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Password hash response'da — sanitizeUser() fonksiyonu ekle!"
    fi
    if grep -q "S7.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Logout endpoint YOK — @Post('logout') ekle!"
    fi
    if grep -q "S8.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) httpOnly cookie YOK — response.cookie({httpOnly:true}) kullan!"
    fi
    if grep -q "S9.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Admin auth YOK — @Roles('admin') + RolesGuard ekle!"
    fi
    if grep -q "S11.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Mass assignment — ValidationPipe({whitelist:true, forbidNonWhitelisted:true}) ekle!"
    fi
    if grep -q "KQ1.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Password minLength YOK — @MinLength(8) password DTO'ya ekle!"
    fi
    if grep -q "KQ4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Title validation YOK — @IsNotEmpty() title DTO'ya ekle!"
    fi
    if grep -q "KQ5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Bearer strip YOK — authHeader.slice(7) ekle!"
    fi
    if grep -q "AR1.*FAIL\|AR2.*FAIL\|AR5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Service layer YOK — *.service.ts dosyaları oluştur!"
    fi
    if grep -q "T1.*FAIL\|T3.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Test YOK — jest + @nestjs/testing + supertest ekle!"
    fi
    if grep -q "D1.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Dockerfile root user — USER appuser ekle!"
    fi
    if grep -q "D3.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Health endpoint YOK — HealthController ekle!"
    fi
    if grep -q "D6.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Graceful shutdown YOK — app.enableShutdownHooks() ekle!"
    fi
    if grep -q "SEO1.*FAIL\|SEO2.*FAIL\|SEO4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) SEO: meta description + canonical URL + JSON-LD ekle HTML'e!"
    fi
    if grep -q "DOC1.*FAIL\|DOC4.*FAIL\|DOC5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) README.md + CONTRIBUTING.md + .env.example YOK — oluştur!"
    fi
  elif [ "$FRAMEWORK" = "nextjs" ]; then
    # Next.js-specific targeted checks
    if grep -q "S1.*FAIL\|S2.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Security headers + rate limiting EKSİK — next.config.js headers + src/middleware.js ekle!"
    fi
    if grep -q "S4.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) JWT secret hardcoded — process.env.JWT_SECRET kullan, src/lib/config.js oluştur!"
    fi
    if grep -q "S5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) bcrypt rounds < 10 — BCRYPT_ROUNDS = 12 yap!"
    fi
    if grep -q "S6.*FAIL\|S10.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Password response'da — sanitizeUser() fonksiyonu ekle!"
    fi
    if grep -q "S8.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) httpOnly cookie YOK — response.cookies.set({httpOnly:true}) kullan!"
    fi
    if grep -q "S9.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Admin route auth YOK — middleware'de JWT + role check ekle!"
    fi
    if grep -q "S12.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) dangerouslySetInnerHTML VAR — KALDIR, normal JSX kullan!"
    fi
    if grep -q "KQ1.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Password minLength YOK — password.length >= 8 ekle!"
    fi
    if grep -q "AR1.*FAIL\|AR2.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Service layer YOK — src/lib/ dizini oluştur!"
    fi
    if grep -q "DOC1.*FAIL\|DOC4.*FAIL\|DOC5.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) README.md + CONTRIBUTING.md + .env.example YOK — oluştur!"
    fi
  else
    # Express.js-specific targeted checks
    if grep -q "S9.*FAIL" "$score_file" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) Admin route'larda auth middleware eksik — adminAuth ZORUNLU"
    fi
    if ! grep -rq "httpOnly\|res\.cookie" "$PROJECT_DIR/src/" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) httpOnly cookie EKSİK — login/register'da res.cookie ZORUNLU"
    fi
    if ! compgen -G "$PROJECT_DIR/src/services/*.ts" > /dev/null 2>&1 && ! compgen -G "$PROJECT_DIR/src/services/*.js" > /dev/null 2>&1; then
      count=$((count+1)); msg="$msg $count) Service layer YOK — src/services/ oluştur"
    fi
    if ! grep -rq "supertest\|request(app)" "$PROJECT_DIR/src/__tests__/" "$PROJECT_DIR/tests/" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) supertest integration test YOK"
    fi
    if ! [ -f "$PROJECT_DIR/public/robots.txt" ]; then
      count=$((count+1)); msg="$msg $count) public/robots.txt YOK"
    fi
    if ! [ -f "$PROJECT_DIR/README.md" ]; then
      count=$((count+1)); msg="$msg $count) README.md YOK — API endpoint'leri dokümante et"
    fi
    if ! [ -f "$PROJECT_DIR/.env.example" ]; then
      count=$((count+1)); msg="$msg $count) .env.example YOK"
    fi
    if ! [ -f "$PROJECT_DIR/CONTRIBUTING.md" ]; then
      count=$((count+1)); msg="$msg $count) CONTRIBUTING.md YOK"
    fi
    if ! grep -q 'canonical' "$PROJECT_DIR/public/index.html" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) canonical URL YOK"
    fi
    if ! grep -q 'application/ld+json' "$PROJECT_DIR/public/index.html" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) JSON-LD structured data YOK"
    fi
    if ! grep -q '@media' "$PROJECT_DIR/public/index.html" 2>/dev/null; then
      count=$((count+1)); msg="$msg $count) @media responsive YOK"
    fi
  fi

  echo "$msg"
}

# --- Run 1: Full Audit ---
RUN=1
echo "══════════════════════════════════════════════════════════"
echo "  RUN $RUN: Full 10-Boyut Audit ($FRAMEWORK)"
echo "══════════════════════════════════════════════════════════"

cd "$PROJECT_DIR"

AUDIT_MSG=$(build_audit_message)
npx opencode-ai run "$AUDIT_MSG" --model "opencode/deepseek-v4-flash-free" 2>&1 | tail -30

echo ""
echo "Run $RUN tamamlandı. Skorlanıyor..."
echo ""

# Score after run
bash "$AUDIT_KIT_DIR/score.sh" "$PROJECT_DIR" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' > /tmp/audit-score-run$RUN.txt
cat /tmp/audit-score-run$RUN.txt | grep -E "^(  [A-Z]|  TOPLAM|  GEÇEN)"

# Check if all dimensions pass
PASSING=$(grep "GEÇEN" /tmp/audit-score-run$RUN.txt | grep -oP '\d+' | head -1)
TOTAL_DIMS=$(grep "GEÇEN" /tmp/audit-score-run$RUN.txt | grep -oP '\d+/' | tr -d '/' | tail -1)

echo ""
echo "Sonuç: ${PASSING:-0}/${TOTAL_DIMS:-10} boyut geçti"

if [ "${PASSING:-0}" -eq "${TOTAL_DIMS:-10}" ]; then
  echo "🎉 TÜM BOYUTLAR GEÇTİ! Auto-audit başarılı."
  exit 0
fi

# --- Follow-up Runs: Targeted Fixes ---
while [ "$RUN" -lt "$MAX_RUNS" ]; do
  RUN=$((RUN + 1))
  
  # Extract failing dimensions
  FAILING=$(grep "FAIL" /tmp/audit-score-run$((RUN-1)).txt | grep -oP '[A-Z][a-z]+(\s[A-Z][a-z]+)*' | head -5 | tr '\n' ', ')
  
  echo ""
  echo "══════════════════════════════════════════════════════════"
  echo "  RUN $RUN: Targeted Fix — $FAILING"
  echo "══════════════════════════════════════════════════════════"
  
  MSG=$(build_targeted_message "/tmp/audit-score-run$((RUN-1)).txt")
  
  npx opencode-ai run "$MSG" --model "opencode/deepseek-v4-flash-free" 2>&1 | tail -20
  
  echo ""
  echo "Run $RUN tamamlandı. Skorlanıyor..."
  
  bash "$AUDIT_KIT_DIR/score.sh" "$PROJECT_DIR" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' > /tmp/audit-score-run$RUN.txt
  cat /tmp/audit-score-run$RUN.txt | grep -E "^(  [A-Z]|  TOPLAM|  GEÇEN)"
  
  PASSING=$(grep "GEÇEN" /tmp/audit-score-run$RUN.txt | grep -oP '\d+' | head -1)
  
  if [ "${PASSING:-0}" -eq "${TOTAL_DIMS:-10}" ]; then
    echo ""
    echo "🎉 TÜM BOYUTLAR GEÇTİ! Auto-audit Run $RUN'da başarılı."
    exit 0
  fi
done

echo ""
echo "⚠️ $MAX_RUNS run tamamlandı ama bazı boyutlar hala geçemedi."
echo "Manuel müdahale gerekebilir."
exit 1
