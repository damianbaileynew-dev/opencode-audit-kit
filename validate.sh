#!/bin/bash
# ============================================
#  🛡️ OpenCode Audit Kit - DOĞRULAMA TESTİ
# ============================================
#  Kullanım:
#    chmod +x validate.sh
#    ./validate.sh [proje-dizini]
#
#  Ne yapar?
#    - Agent dosyalarının frontmatter'ını doğrular
#    - SKILL.md dosyalarını doğrular
#    - Install script'lerin çalıştığını doğrular
#    - MCP server'ların yanıt verdiğini doğrular
#    - OpenCode CLI'nin agent'ları tanıdığını doğrular
# ============================================

set +e  # Don't exit on error, collect results

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    local name="$1"
    local result="$2"
    if [ "$result" = "pass" ]; then
        echo -e "  ${GREEN}✅${NC} $name"
        PASS=$((PASS + 1))
    elif [ "$result" = "warn" ]; then
        echo -e "  ${YELLOW}⚠️${NC}  $name"
        WARN=$((WARN + 1))
    else
        echo -e "  ${RED}❌${NC} $name"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "🛡️  OpenCode Audit Kit - Doğrulama Testi"
echo "=========================================="
echo "📁 Dizin: $SCRIPT_DIR"
echo ""

# ============================================
# 1. DOSYA YAPISI DOĞRULAMA
# ============================================
echo "📦 1. DOSYA YAPISI DOĞRULAMA"
echo "----------------------------"

# Required agents
REQUIRED_AGENTS=(
    "master-orchestrator.md"
    "frontend-audit.md"
    "frontend-test-scenarios.md"
    "frontend-fix.md"
    "backend-audit.md"
    "backend-fix.md"
    "ux-critic.md"
    "ux-polish.md"
    "innovation-agent.md"
    "project-memory.md"
    "performance-fix.md"
    "code-quality-fix.md"
    "architecture-fix.md"
    "test-fix.md"
    "a11y-fix.md"
    "devops-fix.md"
    "seo-fix.md"
    "docs-fix.md"
)

for agent in "${REQUIRED_AGENTS[@]}"; do
    if [ -f "$SCRIPT_DIR/global/agents/$agent" ]; then
        check "$agent mevcut" "pass"
    else
        check "$agent mevcut" "fail"
    fi
done

# Required skills
REQUIRED_SKILLS=(
    "audit-frontend"
    "test-frontend"
    "fix-frontend"
    "audit-backend"
    "fix-backend"
    "critique-ux"
    "polish-ux"
    "suggest-innovation"
    "manage-memory"
    "web-quality-audit"
    "accessibility-audit"
    "performance-audit"
    "vulnerability-scan"
    "code-review"
    "security-audit-full"
    "tdd"
    "code-review-graph"
    "impeccable-audit"
    "brainstorming"
    "temporal-memory"
    "grill-me"
    "enquire-rag"
    "diagnose"
    "hivemind-kb"
    "lsp-analysis"
    "fix-performance"
    "fix-code-quality"
    "fix-architecture"
    "fix-test"
    "fix-a11y"
    "fix-ux"
    "fix-devops"
    "fix-seo"
    "fix-docs"
    "audit-devops"
    "audit-docs"
)

for skill in "${REQUIRED_SKILLS[@]}"; do
    if [ -f "$SCRIPT_DIR/global/skills/$skill/SKILL.md" ]; then
        check "skills/$skill/SKILL.md mevcut" "pass"
    else
        check "skills/$skill/SKILL.md mevcut" "fail"
    fi
done

# Required commands
if [ -f "$SCRIPT_DIR/global/commands/audit-all.md" ]; then
    check "commands/audit-all.md mevcut" "pass"
else
    check "commands/audit-all.md mevcut" "fail"
fi

# Config
if [ -f "$SCRIPT_DIR/global/opencode.json" ]; then
    check "opencode.json mevcut" "pass"
else
    check "opencode.json mevcut" "fail"
fi

# Scripts
for script in install-global.sh install-project.sh uninstall.sh; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        check "$script mevcut" "pass"
    else
        check "$script mevcut" "fail"
    fi
done

echo ""

# ============================================
# 2. FRONTMATTER DOĞRULAMA
# ============================================
echo "📋 2. FRONTMATTER DOĞRULAMA"
echo "----------------------------"

for agent in "$SCRIPT_DIR/global/agents/"*.md; do
    if [ ! -f "$agent" ]; then continue; fi
    agent_name=$(basename "$agent")
    
    # Check name attribute
    if grep -q "^name:" "$agent"; then
        name_val=$(grep "^name:" "$agent" | head -1 | sed 's/name: *//' | tr -d '"')
        check "$agent_name → name: $name_val" "pass"
    else
        check "$agent_name → name: EKSİK!" "fail"
    fi
    
    # Check mode
    if grep -q "^mode:" "$agent"; then
        mode_val=$(grep "^mode:" "$agent" | head -1 | sed 's/mode: *//')
        check "$agent_name → mode: $mode_val" "pass"
    else
        check "$agent_name → mode: EKSİK!" "fail"
    fi
    
    # Check model
    if grep -q "^model:" "$agent"; then
        model_val=$(grep "^model:" "$agent" | head -1 | sed 's/model: *//')
        check "$agent_name → model: $model_val" "pass"
    else
        check "$agent_name → model: YOK (default kullanılacak)" "warn"
    fi
    
    # Check permission
    if grep -q "permission:" "$agent"; then
        check "$agent_name → permission: tanımlı" "pass"
    else
        check "$agent_name → permission: EKSİK!" "fail"
    fi
done

echo ""

# ============================================
# 3. PERMISSION KURALLARI DOĞRULAMA
# ============================================
echo "🔒 3. PERMISSION KURALLARI"
echo "---------------------------"

# Audit agents should have bash=deny, edit=deny
AUDIT_AGENTS=("frontend-audit.md" "backend-audit.md" "ux-critic.md" "innovation-agent.md")
for agent in "${AUDIT_AGENTS[@]}"; do
    file="$SCRIPT_DIR/global/agents/$agent"
    if [ ! -f "$file" ]; then continue; fi
    
    if grep -q "bash: deny\|bash: false" "$file"; then
        check "$agent → audit: bash=deny ✅" "pass"
    else
        check "$agent → audit: bash=deny BEKLENİYOR!" "fail"
    fi
    
    if grep -q "edit: deny\|edit: false" "$file"; then
        check "$agent → audit: edit=deny ✅" "pass"
    else
        check "$agent → audit: edit=deny BEKLENİYOR!" "fail"
    fi
done

# Fix agents should have bash=allow, edit=allow (except frontend-test-scenarios which is read-only)
FIX_AGENTS=("frontend-fix.md" "backend-fix.md" "ux-polish.md" "performance-fix.md" "code-quality-fix.md" "architecture-fix.md" "test-fix.md" "a11y-fix.md" "devops-fix.md" "seo-fix.md" "docs-fix.md")
for agent in "${FIX_AGENTS[@]}"; do
    file="$SCRIPT_DIR/global/agents/$agent"
    if [ ! -f "$file" ]; then continue; fi
    
    if grep -q "bash: allow\|bash: true" "$file"; then
        check "$agent → fix: bash=allow ✅" "pass"
    else
        check "$agent → fix: bash=allow BEKLENİYOR!" "fail"
    fi
    
    if grep -q "edit: allow\|edit: true" "$file"; then
        check "$agent → fix: edit=allow ✅" "pass"
    else
        check "$agent → fix: edit=allow BEKLENİYOR!" "fail"
    fi
done

# Test agent: bash=allow (for dev server), edit=deny (read-only tests)
TEST_AGENT="frontend-test-scenarios.md"
file="$SCRIPT_DIR/global/agents/$TEST_AGENT"
if [ -f "$file" ]; then
    if grep -q "bash: allow\|bash: true" "$file"; then
        check "$TEST_AGENT → test: bash=allow ✅" "pass"
    else
        check "$TEST_AGENT → test: bash=allow BEKLENİYOR!" "fail"
    fi
    
    if grep -q "edit: deny\|edit: false" "$file"; then
        check "$TEST_AGENT → test: edit=deny (read-only) ✅" "pass"
    else
        check "$TEST_AGENT → test: edit=deny BEKLENİYOR (test agent değiştirmemeli)!" "fail"
    fi
fi

# Memory agent: bash=allow, edit=allow, write=allow
MEM_AGENT="project-memory.md"
file="$SCRIPT_DIR/global/agents/$MEM_AGENT"
if [ -f "$file" ]; then
    if grep -q "bash: allow\|bash: true" "$file"; then
        check "$MEM_AGENT → memory: bash=allow ✅" "pass"
    else
        check "$MEM_AGENT → memory: bash=allow BEKLENİYOR!" "fail"
    fi
    
    if grep -q "edit: allow\|edit: true" "$file"; then
        check "$MEM_AGENT → memory: edit=allow ✅" "pass"
    else
        check "$MEM_AGENT → memory: edit=allow BEKLENİYOR!" "fail"
    fi
fi

echo ""

# ============================================
# 4. OPENCODE CLI DOĞRULAMA
# ============================================
echo "🔧 4. OPENCODE CLI DOĞRULAMA"
echo "-----------------------------"

if command -v opencode &> /dev/null; then
    OC_VERSION=$(opencode --version 2>/dev/null || echo "bilinmiyor")
    check "OpenCode CLI kurulu: $OC_VERSION" "pass"
    
    # Check if agents are recognized (project level)
    if [ -d "$TARGET_DIR/.opencode/agents" ]; then
        AGENT_COUNT=$(ls "$TARGET_DIR/.opencode/agents/"*.md 2>/dev/null | wc -l)
        if [ "$AGENT_COUNT" -ge 9 ]; then
            check "Proje bazlı agents: $AGENT_COUNT dosya" "pass"
        else
            check "Proje bazlı agents: $AGENT_COUNT dosya (9 bekleniyor)" "warn"
        fi
    else
        check "Proje bazlı .opencode/agents/ bulunamadı" "warn"
    fi
else
    check "OpenCode CLI kurulu değil" "warn"
fi

echo ""

# ============================================
# 5. MCP SERVER DOĞRULAMA
# ============================================
echo "🌐 5. MCP SERVER DOĞRULAMA"
echo "---------------------------"

# Check Playwright MCP
echo "   Playwright MCP test ediliyor..."
PW_RESULT=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"protocolVersion":"2024-11-05","clientInfo":{"name":"validate","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | timeout 10 npx @playwright/mcp@latest --headless 2>/dev/null | grep -o '"name":"browser_[^"]*"' | wc -l)

if [ "$PW_RESULT" -gt 0 ]; then
    check "Playwright MCP: $PW_RESULT tool çalışıyor" "pass"
else
    check "Playwright MCP: yanıt alınamadı" "warn"
fi

# Check CodeGraph
if command -v npx &> /dev/null; then
    CG_RESULT=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"protocolVersion":"2024-11-05","clientInfo":{"name":"validate","version":"1.0.0"}}}' | timeout 5 npx -y @colbymchenry/codegraph serve --mcp 2>/dev/null | grep -c "codegraph")
    if [ "$CG_RESULT" -gt 0 ]; then
        check "CodeGraph MCP: çalışıyor" "pass"
    else
        check "CodeGraph MCP: test edilemedi" "warn"
    fi
fi

# Check Memory MCP (Knowledge Graph)
echo "   Memory MCP test ediliyor..."
MEM_TOOLS=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"protocolVersion":"2024-11-05","clientInfo":{"name":"validate","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | timeout 10 npx -y @modelcontextprotocol/server-memory 2>/dev/null | grep -o '"name":"[^"]*"' | grep -v memory-server | wc -l)
if [ "$MEM_TOOLS" -gt 0 ]; then
    check "Memory MCP (Knowledge Graph): $MEM_TOOLS tool çalışıyor" "pass"
else
    check "Memory MCP: test edilemedi" "warn"
fi

# Check cavemem MCP (Session Tracker)
echo "   cavemem MCP test ediliyor..."
CAVE_TOOLS=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"protocolVersion":"2024-11-05","clientInfo":{"name":"validate","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | timeout 10 npx -y cavemem mcp 2>/dev/null | grep -o '"name":"[^"]*"' | grep -v cavemem | wc -l)
if [ "$CAVE_TOOLS" -gt 0 ]; then
    check "cavemem MCP (Session Tracker): $CAVE_TOOLS tool çalışıyor" "pass"
else
    check "cavemem MCP: test edilemedi" "warn"
fi

# Check Local Memory MCP (13 tools, SQLite + FTS5)
echo "   Local Memory MCP test ediliyor..."
LMEM_TOOLS=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"protocolVersion":"2024-11-05","clientInfo":{"name":"validate","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | timeout 10 npx -y @studiomeyer/local-memory-mcp 2>/dev/null | grep -o '"name":"[^"]*"' | wc -l)
if [ "$LMEM_TOOLS" -gt 0 ]; then
    check "Local Memory MCP (SQLite+KG): $LMEM_TOOLS tool çalışıyor" "pass"
else
    check "Local Memory MCP: test edilemedi" "warn"
fi

# Check Context7 MCP
echo "   Context7 MCP test ediliyor..."
C7_TOOLS=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"protocolVersion":"2024-11-05","clientInfo":{"name":"validate","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | timeout 10 npx -y @upstash/context7-mcp 2>/dev/null | grep -o '"name":"[^"]*"' | wc -l)
if [ "$C7_TOOLS" -gt 0 ]; then
    check "Context7 MCP (Docs): $C7_TOOLS tool çalışıyor" "pass"
else
    check "Context7 MCP: test edilemedi" "warn"
fi

# Check Hivemind MCP (opsiyonel - init gerekli)
echo "   Hivemind MCP kontrol ediliyor..."
if command -v npx &> /dev/null; then
    HIVEMIND_CHECK=$(timeout 5 npx -y hivemind-mcp --help 2>/dev/null | head -1)
    if [ -n "$HIVEMIND_CHECK" ]; then
        check "Hivemind MCP (Knowledge Base): paket mevcut" "pass"
    else
        check "Hivemind MCP: init gerekli (npx hivemind-mcp init)" "warn"
    fi
fi

# Check Code Review Graph (opsiyonel - pip/uvx gerekli)
if command -v uvx &> /dev/null || command -v pip &> /dev/null; then
    if command -v code-review-graph &> /dev/null || pip show code-review-graph &>/dev/null 2>&1; then
        check "Code Review Graph (22 tool): kurulu" "pass"
    else
        check "Code Review Graph: kurulu değil (pip install code-review-graph)" "warn"
    fi
else
    check "Code Review Graph: pip/uvx bulunamadı" "warn"
fi

echo ""

# ============================================
# 6. SKILL İÇERİK DOĞRULAMA
# ============================================
echo "📖 6. SKILL İÇERİK DOĞRULAMA"
echo "------------------------------"

for skill_dir in "$SCRIPT_DIR/global/skills/"*/; do
    if [ ! -d "$skill_dir" ]; then continue; fi
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    
    if [ ! -f "$skill_file" ]; then
        check "$skill_name → SKILL.md bulunamadı" "fail"
        continue
    fi
    
    # Check frontmatter
    if head -1 "$skill_file" | grep -q "^---"; then
        check "$skill_name → frontmatter var" "pass"
    else
        check "$skill_name → frontmatter EKSİK!" "fail"
    fi
    
    # Check content length (should be substantial)
    LINES=$(wc -l < "$skill_file")
    if [ "$LINES" -gt 20 ]; then
        check "$skill_name → $LINES satır içerik" "pass"
    else
        check "$skill_name → $LINES satır (20+ bekleniyor)" "warn"
    fi
    
    # Check for name in frontmatter
    if grep -q "^name:" "$skill_file"; then
        check "$skill_name → name tanımlı" "pass"
    else
        check "$skill_name → name EKSİK!" "fail"
    fi
done

echo ""

# ============================================
# 7. SCRIPT TEST (Dry Run)
# ============================================
echo "🧪 7. SCRIPT DOĞRULAMA"
echo "------------------------"

# Check script executability
for script in install-global.sh install-project.sh uninstall.sh validate.sh; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        if [ -x "$SCRIPT_DIR/$script" ]; then
            check "$script → çalıştırılabilir" "pass"
        else
            check "$script → chmod +x gerekli" "warn"
        fi
        # Check bash syntax
        bash -n "$SCRIPT_DIR/$script" 2>/dev/null
        if [ $? -eq 0 ]; then
            check "$script → bash syntax OK" "pass"
        else
            check "$script → bash syntax HATASI!" "fail"
        fi
    fi
done

echo ""

# ============================================
# SONUÇ
# ============================================
echo "════════════════════════════════════════"
echo -e "  ${GREEN}✅ PASS:${NC} $PASS"
echo -e "  ${YELLOW}⚠️  WARN:${NC} $WARN"
echo -e "  ${RED}❌ FAIL:${NC} $FAIL"
echo "  📊 TOTAL: $TOTAL"
echo "════════════════════════════════════════"

if [ "$FAIL" -eq 0 ]; then
    echo ""
    echo -e "  ${GREEN}🎉 TÜM TESTLERİ GEÇTİ!${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "  ${RED}❌ $FAIL test başarısız!${NC}"
    echo ""
    exit 1
fi
