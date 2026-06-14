#!/bin/bash
# ============================================
#  🛡️ OpenCode Audit Kit - PROJE KURULUMU
# ============================================
#  Kullanım:
#    chmod +x install-project.sh
#    ./install-project.sh [/projenin/yolu]
#
#  Ne yapar?
#    - .opencode/ yapısını projeye kopyalar
#    - Agent'ları HER ZAMAN proje bazlı kopyalar (--agent flag için gerekli)
#    - Skill'leri kopyalar
#    - Komutları kopyalar
#    - Rapor dizinlerini oluşturur
#    - opencode.json'ı proje köküne kopyalar
#    - CodeGraph init (opsiyonel)
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Hedef dizin parametresi
TARGET_DIR="${1:-.}"
cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"

echo ""
echo "🛡️  OpenCode Audit Kit - Proje Kurulumu"
echo "========================================="
echo "📁 Hedef: $TARGET_DIR"
echo ""

# Proje kök dizininde miyiz kontrol et
if [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "requirements.txt" ] && [ ! -f "go.mod" ] && [ ! -f "Cargo.toml" ] && [ ! -f "pom.xml" ] && [ ! -f "Gemfile" ] && [ ! -f "composer.json" ]; then
    echo "⚠️  Uyarı: Proje kök dizininde değilsiniz gibi görünüyor."
    echo "   (package.json, pyproject.toml, go.mod vb. bulunamadı)"
    read -p "   Devam edilsin mi? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "İptal edildi."
        exit 0
    fi
fi

# Zaten .opencode var mı
if [ -d ".opencode" ]; then
    echo "⚠️  .opencode klasörü zaten mevcut!"
    read -p "   Üzerine yazılsın mı? (y/n): " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "İptal edildi."
        exit 0
    fi
    # Raporları koru, ama agents/skills/commands'ı temizle
    rm -rf .opencode/agents .opencode/commands .opencode/skills .opencode/checklists .opencode/templates
fi

# ============================================
# Dizinleri oluştur
# ============================================
echo "📁 Dizinler oluşturuluyor..."
mkdir -p .opencode/agents
mkdir -p .opencode/commands
mkdir -p .opencode/skills
mkdir -p .opencode/reports/_state
mkdir -p .opencode/reports/frontend
mkdir -p .opencode/reports/backend
mkdir -p .opencode/reports/ux
mkdir -p .opencode/reports/innovation
mkdir -p .opencode/reports/final
mkdir -p .opencode/reports/_memory
mkdir -p .opencode/screenshots
echo "   ✅ Rapor dizinleri oluşturuldu"

# ============================================
# State dosyalarını kopyala
# ============================================
echo "📦 State dosyaları kopyalanıyor..."
if [ -f "$SCRIPT_DIR/project/reports/_state/handoff.md" ]; then
    cp "$SCRIPT_DIR/project/reports/_state/handoff.md" .opencode/reports/_state/handoff.md
    echo "   ✅ handoff.md"
fi
if [ -f "$SCRIPT_DIR/project/reports/_state/decisions.md" ]; then
    cp "$SCRIPT_DIR/project/reports/_state/decisions.md" .opencode/reports/_state/decisions.md
    echo "   ✅ decisions.md"
fi
echo ""

# ============================================
# ÖNEMLİ: Agent'ları HER ZAMAN proje bazlı kopyala
# OpenCode --agent flag'i sadece proje bazlı .opencode/agents/ dizinini okur!
# ============================================
echo "📌 Agent'lar proje bazlı kopyalanıyor (zorunlu: --agent flag için)..."
AGENT_COUNT=0
for agent in "$SCRIPT_DIR/global/agents/"*.md; do
    if [ -f "$agent" ]; then
        cp "$agent" .opencode/agents/
        echo "   ✅ $(basename $agent)"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    fi
done
echo "   → $AGENT_COUNT agent kopyalandı"
echo ""

# ============================================
# Skill'leri kopyala
# ============================================
echo "📦 Skill'ler kopyalanıyor..."
SKILL_COUNT=0
for skill_dir in "$SCRIPT_DIR/global/skills/"*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p ".opencode/skills/$skill_name"
        if [ -f "$skill_dir/SKILL.md" ]; then
            cp "$skill_dir/SKILL.md" ".opencode/skills/$skill_name/SKILL.md"
            echo "   ✅ skills/$skill_name"
            SKILL_COUNT=$((SKILL_COUNT + 1))
        fi
    fi
done
echo "   → $SKILL_COUNT skill kopyalandı"
echo ""

# ============================================
# Komutları kopyala
# ============================================
echo "📦 Komutlar kopyalanıyor..."
CMD_COUNT=0
for cmd in "$SCRIPT_DIR/global/commands/"*.md; do
    if [ -f "$cmd" ]; then
        cp "$cmd" .opencode/commands/
        echo "   ✅ $(basename $cmd)"
        CMD_COUNT=$((CMD_COUNT + 1))
    fi
done
echo "   → $CMD_COUNT komut kopyalandı"
echo ""

# ============================================
# opencode.json kopyala (mevcut varsa birleştir)
# ============================================
echo "📦 Config dosyası kontrol ediliyor..."
if [ -f "$SCRIPT_DIR/global/opencode.json" ]; then
    if [ -f ".opencode.json" ] || [ -f "opencode.json" ]; then
        echo "   ⚠️  opencode.json zaten mevcut!"
        echo "   → Mevcut config korundu."
        echo "   → MCP tool'larını manuel ekleyin:"
        echo '       "mcp": {'
        echo '         "playwright": { "type": "local", "command": ["npx", "@playwright/mcp@latest", "--headless"], "enabled": true },'
        echo '         "context7": { "type": "local", "command": ["npx", "-y", "@upstash/context7-mcp"], "enabled": true },'
        echo '         "codegraph": { "type": "local", "command": ["codegraph", "serve", "--mcp"], "enabled": true }'
        echo '       }'
    else
        cp "$SCRIPT_DIR/global/opencode.json" .opencode.json
        echo "   ✅ opencode.json"
    fi
fi
echo ""

# ============================================
# CodeGraph init (opsiyonel)
# ============================================
echo "🔍 CodeGraph index oluşturma:"
if [ -d ".codegraph" ]; then
    echo "   ✅ .codegraph/ zaten mevcut"
else
    if command -v npx &> /dev/null; then
        read -p "   Bu proje için CodeGraph index'i oluşturulsun mu? (y/n): " init_cg
        if [ "$init_cg" = "y" ] || [ "$init_cg" = "Y" ]; then
            echo "   📦 CodeGraph index oluşturuluyor..."
            npx -y @colbymchenry/codegraph init -i 2>/dev/null && echo "   ✅ Index oluşturuldu!" || echo "   ⚠️  Index oluşturma başarısız"
        fi
    else
        echo "   ℹ️  npx kurulu değil. CodeGraph atlandı."
    fi
fi
echo ""

# ============================================
# Playwright MCP browser kontrolü
# ============================================
echo "🌐 Playwright MCP browser kontrolü:"
if npx @playwright/mcp@latest --help &>/dev/null 2>&1; then
    echo "   ✅ Playwright MCP mevcut"
    # Chrome kurulu mu?
    if command -v google-chrome &>/dev/null || command -v chromium-browser &>/dev/null; then
        echo "   ✅ Browser mevcut"
    else
        echo "   ⚠️  Chrome/Chromium bulunamadı"
        read -p "   Şimdi kurulsun mu? (y/n): " install_pw
        if [ "$install_pw" = "y" ] || [ "$install_pw" = "Y" ]; then
            echo "   📦 Browser kuruluyor..."
            npx playwright install chrome 2>/dev/null && echo "   ✅ Browser kuruldu!" || echo "   ⚠️  Kurulum başarısız, manuel deneyin: npx playwright install chrome"
        fi
    fi
else
    echo "   ℹ️  Playwright MCP ilk kullanımda otomatik kurulur."
fi
echo ""

# ============================================
# Özet
# ============================================
echo "✅ Proje kurulumu tamamlandı!"
echo ""
echo "📁 Oluşturulan yapı:"
echo "   .opencode/"
echo "   ├── agents/         ($AGENT_COUNT agent)"
echo "   ├── skills/         ($SKILL_COUNT skill)"
echo "   ├── commands/       ($CMD_COUNT komut)"
echo "   ├── reports/"
echo "   │   ├── _state/     (handoff + decisions)"
echo "   │   ├── frontend/"
echo "   │   ├── backend/"
echo "   │   ├── ux/"
echo "   │   ├── innovation/"
echo "   │   └── final/"
echo "   └── screenshots/"
echo ""
echo "🚀 Kullanım:"
echo "   # Non-interactive modda:"
echo "   opencode run --agent master-orchestrator \"Bu projeyi denetle\""
echo ""
echo "   # TUI içinde:"
echo "   opencode"
echo "   /audit-all"
echo ""
echo "   # Belirli bir agent ile:"
echo "   opencode run --agent frontend-audit \"Frontend taraması yap\""
echo "   opencode run --agent backend-audit \"Backend taraması yap\""
echo ""
