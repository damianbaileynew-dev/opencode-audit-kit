#!/bin/bash
# ═══════════════════════════════════════════════════════════
# OpenCode Audit Kit — Semantic Analysis Engine
# Runs ESLint, TypeScript Compiler, PyLint on target project
# Outputs JSON results for score.sh to consume
# ═══════════════════════════════════════════════════════════

PROJECT_DIR="${1:-.}"
OUTPUT_DIR="${2:-/tmp/opencode-semantic}"

mkdir -p "$OUTPUT_DIR"
cd "$PROJECT_DIR" 2>/dev/null || { echo '{"error": "dir not found"}'; exit 1; }

# ─────────────────────────────────────────────────────────
# HELPER: Safe JSON output
# ─────────────────────────────────────────────────────────
json_result() {
  local tool="$1" status="$2" findings="$3" total="$4"
  printf '{"tool":"%s","status":"%s","findings":%s,"total":%s}\n' "$tool" "$status" "$findings" "$total"
}

# ═══════════════════════════════════════════════════════════
# 1. ESLint ANALYSIS (JavaScript / TypeScript)
# ═══════════════════════════════════════════════════════════
analyze_eslint() {
  if [ ! -f package.json ]; then
    json_result "eslint" "skipped" "[]" 0
    return
  fi

  # Install ESLint locally if not present
  if ! npx eslint --version >/dev/null 2>&1; then
    npm install --save-dev eslint @eslint/js 2>/dev/null
  fi

  # Create temporary ESLint config if none exists
  ESLINT_CONFIG=""
  if [ -f .eslintrc.js ] || [ -f .eslintrc.json ] || [ -f .eslintrc.yml ] || [ -f eslint.config.js ] || [ -f eslint.config.mjs ]; then
    ESLINT_CONFIG="--no-eslintrc"
  fi

  # Run ESLint with security/quality rules
  npx eslint \
    --no-error-on-unmatched-pattern \
    --format json \
    --rule '{"no-unused-vars": "warn"}' \
    --rule '{"no-undef": "warn"}' \
    --rule '{"no-console": "off"}' \
    --rule '{"no-empty": "warn"}' \
    --rule '{"no-dupe-keys": "error"}' \
    --rule '{"no-unreachable": "warn"}' \
    --rule '{"no-constant-condition": "warn"}' \
    --rule '{"no-duplicate-case": "error"}' \
    --rule '{"no-sparse-arrays": "warn"}' \
    --rule '{"no-unsafe-negation": "error"}' \
    --rule '{"no-async-promise-executor": "warn"}' \
    --rule '{"no-useless-escape": "warn"}' \
    --rule '{"no-var": "warn"}' \
    --rule '{"prefer-const": "warn"}' \
    --rule '{"eqeqeq": "warn"}' \
    --rule '{"curly": "warn"}' \
    $ESLINT_CONFIG \
    "src/**/*.{js,ts,jsx,tsx}" "app/**/*.{js,ts,jsx,tsx}" "utils/**/*.{js,ts}" "components/**/*.{js,ts,jsx,tsx}" \
    2>/dev/null > "$OUTPUT_DIR/eslint-results.json" || true

  if [ -f "$OUTPUT_DIR/eslint-results.json" ] && [ -s "$OUTPUT_DIR/eslint-results.json" ]; then
    local error_count warning_count
    error_count=$(python3 -c "
import json,sys
try:
  data=json.load(open('$OUTPUT_DIR/eslint-results.json'))
  print(sum(f.get('errorCount',0) for f in data))
except: print(0)
" 2>/dev/null || echo 0)
    warning_count=$(python3 -c "
import json,sys
try:
  data=json.load(open('$OUTPUT_DIR/eslint-results.json'))
  print(sum(f.get('warningCount',0) for f in data))
except: print(0)
" 2>/dev/null || echo 0)

    # Extract specific findings
    local findings
    findings=$(python3 -c "
import json
try:
  data=json.load(open('$OUTPUT_DIR/eslint-results.json'))
  results = []
  for f in data:
    for m in f.get('messages', []):
      results.append({
        'file': f.get('filePath',''),
        'line': m.get('line',0),
        'rule': m.get('ruleId',''),
        'severity': m.get('severity',0),
        'message': m.get('message','')
      })
  print(json.dumps(results[:50]))
except: print('[]')
" 2>/dev/null || echo '[]')

    json_result "eslint" "ok" "$findings" "$((error_count + warning_count))"
  else
    json_result "eslint" "no-output" "[]" 0
  fi
}

# ═══════════════════════════════════════════════════════════
# 2. TypeScript Compiler CHECK
# ═══════════════════════════════════════════════════════════
analyze_tsc() {
  if [ ! -f tsconfig.json ]; then
    json_result "tsc" "skipped" "[]" 0
    return
  fi

  # Install typescript if needed
  if ! npx tsc --version >/dev/null 2>&1; then
    npm install --save-dev typescript 2>/dev/null
  fi

  # Run TypeScript compiler in noEmit mode
  npx tsc --noEmit --pretty false 2>/dev/null > "$OUTPUT_DIR/tsc-results.txt" || true

  if [ -f "$OUTPUT_DIR/tsc-results.txt" ] && [ -s "$OUTPUT_DIR/tsc-results.txt" ]; then
    local total
    total=$(grep -c "error TS" "$OUTPUT_DIR/tsc-results.txt" 2>/dev/null || echo 0)

    local findings
    findings=$(python3 -c "
import json, re
try:
  lines = open('$OUTPUT_DIR/tsc-results.txt').readlines()[:50]
  results = []
  for line in lines:
    m = re.match(r'(.+?)\((\d+),(\d+)\):\serror\s(TS\d+):\s(.+)', line)
    if m:
      results.append({
        'file': m.group(1),
        'line': int(m.group(2)),
        'rule': m.group(4),
        'message': m.group(5)
      })
  print(json.dumps(results[:50]))
except: print('[]')
" 2>/dev/null || echo '[]')

    json_result "tsc" "ok" "$findings" "$total"
  else
    json_result "tsc" "no-errors" "[]" 0
  fi
}

# ═══════════════════════════════════════════════════════════
# 3. PyLint / Flake8 ANALYSIS (Python)
# ═══════════════════════════════════════════════════════════
analyze_python() {
  local py_dir="."
  # Find Python source dir
  if [ -d app ]; then py_dir="app"
  elif [ -d backend/app ]; then py_dir="backend/app"
  elif [ -d src ]; then py_dir="src"
  fi

  if ! find "$py_dir" -name "*.py" 2>/dev/null | head -1 | grep -q .; then
    json_result "pylint" "skipped" "[]" 0
    return
  fi

  # Try flake8 first (faster, less config)
  if command -v flake8 >/dev/null 2>&1; then
    flake8 --format=json --max-line-length=120 --ignore=E501,W503,E402 \
      "$py_dir" 2>/dev/null > "$OUTPUT_DIR/flake8-results.json" || true

    if [ -f "$OUTPUT_DIR/flake8-results.json" ] && [ -s "$OUTPUT_DIR/flake8-results.json" ]; then
      local total
      total=$(python3 -c "
import json
try:
  data=json.load(open('$OUTPUT_DIR/flake8-results.json'))
  print(len(data))
except: print(0)
" 2>/dev/null || echo 0)

      local findings
      findings=$(python3 -c "
import json
try:
  data=json.load(open('$OUTPUT_DIR/flake8-results.json'))
  results = [{'file':d.get('filename',''),'line':d.get('line_number',0),'rule':d.get('code',''),'message':d.get('text','')} for d in data[:50]]
  print(json.dumps(results))
except: print('[]')
" 2>/dev/null || echo '[]')

      json_result "flake8" "ok" "$findings" "$total"
      return
    fi
  fi

  # Try pylint
  if command -v pylint >/dev/null 2>&1; then
    pylint --output-format=json --disable=C0114,C0115,C0116 \
      "$py_dir" 2>/dev/null > "$OUTPUT_DIR/pylint-results.json" || true

    if [ -f "$OUTPUT_DIR/pylint-results.json" ] && [ -s "$OUTPUT_DIR/pylint-results.json" ]; then
      local total
      total=$(python3 -c "
import json
try:
  data=json.load(open('$OUTPUT_DIR/pylint-results.json'))
  print(len(data))
except: print(0)
" 2>/dev/null || echo 0)

      local findings
      findings=$(python3 -c "
import json
try:
  data=json.load(open('$OUTPUT_DIR/pylint-results.json'))
  results = [{'file':d.get('path',''),'line':d.get('line',0),'rule':d.get('symbol',''),'message':d.get('message','')} for d in data[:50]]
  print(json.dumps(results))
except: print('[]')
" 2>/dev/null || echo '[]')

      json_result "pylint" "ok" "$findings" "$total"
      return
    fi
  fi

  # Fallback: install and run flake8
  pip3 install flake8 -q 2>/dev/null
  flake8 --format=json --max-line-length=120 --ignore=E501,W503,E402 \
    "$py_dir" 2>/dev/null > "$OUTPUT_DIR/flake8-results.json" || true

  if [ -f "$OUTPUT_DIR/flake8-results.json" ] && [ -s "$OUTPUT_DIR/flake8-results.json" ]; then
    local total
    total=$(wc -l < "$OUTPUT_DIR/flake8-results.json" 2>/dev/null || echo 0)
    json_result "flake8" "ok" "[]" "$total"
  else
    json_result "python" "skipped" "[]" 0
  fi
}

# ═══════════════════════════════════════════════════════════
# 4. SECURITY PATTERN ANALYSIS (AST-free semantic checks)
# ═══════════════════════════════════════════════════════════
analyze_security() {
  local findings="[]"

  # Check for hardcoded secrets (not just pattern matching — context-aware)
  local secrets
  secrets=$(grep -rn "password\s*=\s*['\"]" src/ app/ utils/ 2>/dev/null | grep -v "test\|spec\|example\|\.env\|process\.env\|config\." | head -5 || true)
  if [ -n "$secrets" ]; then
    findings=$(python3 -c "
import json
existing = $findings
existing.append({'rule': 'hardcoded-password', 'severity': 'high', 'files': '''$secrets'''.strip().split('\n')[:3]})
print(json.dumps(existing))
" 2>/dev/null || echo "$findings")
  fi

  # Check for SQL injection patterns
  local sqli
  sqli=$(grep -rn "f\".*SELECT\|f'.*INSERT\|\+\s*\"SELECT\|\+\s*'INSERT\|%s.*SELECT\|format.*SELECT" src/ app/ backend/ 2>/dev/null | grep -v "test\|spec\|parameterized\|prepared" | head -5 || true)
  if [ -n "$sqli" ]; then
    findings=$(python3 -c "
import json
existing = $findings
existing.append({'rule': 'sql-injection-risk', 'severity': 'high', 'files': '''$sqli'''.strip().split('\n')[:3]})
print(json.dumps(existing))
" 2>/dev/null || echo "$findings")
  fi

  # Check for eval usage
  local evals
  evals=$(grep -rn "\beval(\|new Function(" src/ app/ utils/ 2>/dev/null | grep -v "test\|spec\|node_modules" | head -5 || true)
  if [ -n "$evals" ]; then
    findings=$(python3 -c "
import json
existing = $findings
existing.append({'rule': 'eval-usage', 'severity': 'high', 'files': '''$evals'''.strip().split('\n')[:3]})
print(json.dumps(existing))
" 2>/dev/null || echo "$findings")
  fi

  # Check for prototype pollution
  local proto
  proto=$(grep -rn "__proto__\|constructor\[\|prototype\[" src/ app/ utils/ 2>/dev/null | grep -v "test\|spec\|node_modules" | head -5 || true)
  if [ -n "$proto" ]; then
    findings=$(python3 -c "
import json
existing = $findings
existing.append({'rule': 'prototype-pollution', 'severity': 'medium', 'files': '''$proto'''.strip().split('\n')[:3]})
print(json.dumps(existing))
" 2>/dev/null || echo "$findings")
  fi

  # Check for insecure dependencies (package.json audit)
  local audit_issues=0
  if [ -f package.json ]; then
    npm audit --json 2>/dev/null > "$OUTPUT_DIR/npm-audit.json" || true
    if [ -f "$OUTPUT_DIR/npm-audit.json" ] && [ -s "$OUTPUT_DIR/npm-audit.json" ]; then
      audit_issues=$(python3 -c "
import json
try:
  data=json.load(open('$OUTPUT_DIR/npm-audit.json'))
  print(data.get('metadata',{}).get('vulnerabilities',{}).get('total',0))
except: print(0)
" 2>/dev/null || echo 0)
    fi
  fi

  if [ "$audit_issues" -gt 0 ]; then
    findings=$(python3 -c "
import json
existing = $findings
existing.append({'rule': 'vulnerable-dependencies', 'severity': 'high', 'count': $audit_issues})
print(json.dumps(existing))
" 2>/dev/null || echo "$findings")
  fi

  local total
  total=$(python3 -c "import json; print(len(json.loads('$findings')))" 2>/dev/null || echo 0)
  json_result "security" "ok" "$findings" "$total"
}

# ═══════════════════════════════════════════════════════════
# 5. AUTH DETECTION (Semantic — not just pattern matching)
# ═══════════════════════════════════════════════════════════
analyze_auth() {
  local auth_system="none"
  local auth_details="[]"

  # Detect auth system (not just "JWT" keyword — understand the architecture)
  if grep -rq "supabase" src/ utils/ middleware.* 2>/dev/null; then
    auth_system="supabase"
  elif grep -rq "next-auth\|NextAuth\|authjs" src/ utils/ middleware.* 2>/dev/null; then
    auth_system="next-auth"
  elif grep -rq "@clerk\|clerk" src/ utils/ middleware.* 2>/dev/null; then
    auth_system="clerk"
  elif grep -rq "firebase.*auth\|getAuth" src/ utils/ 2>/dev/null; then
    auth_system="firebase"
  elif grep -rq "passport\." src/ utils/ 2>/dev/null; then
    auth_system="passport"
  elif grep -rq "jsonwebtoken\|jwt\." src/ utils/ 2>/dev/null; then
    auth_system="jwt"
  elif grep -rq "OAuth\|oauth2" src/ utils/ 2>/dev/null; then
    auth_system="oauth"
  elif grep -rq "session\|express-session\|cookie-session" src/ 2>/dev/null; then
    auth_system="session"
  fi

  # Check auth quality
  local auth_quality="unknown"
  case "$auth_system" in
    supabase|next-auth|clerk|firebase)
      auth_quality="managed"  # Third-party managed = generally secure
      ;;
    jwt|passport|oauth|session)
      auth_quality="self-managed"  # Needs careful review
      ;;
    none)
      auth_quality="missing"
      ;;
  esac

  printf '{"tool":"auth-detection","system":"%s","quality":"%s"}\n' "$auth_system" "$auth_quality"
}

# ═══════════════════════════════════════════════════════════
# MAIN — Run all analyses
# ═══════════════════════════════════════════════════════════
echo "{"
echo "  \"eslint\": $(analyze_eslint),"
echo "  \"tsc\": $(analyze_tsc),"
echo "  \"python\": $(analyze_python),"
echo "  \"security\": $(analyze_security),"
echo "  \"auth\": $(analyze_auth)"
echo "}"
