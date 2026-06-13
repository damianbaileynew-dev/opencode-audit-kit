#!/bin/bash
# ============================================
#  🛡️ OpenCode Audit Kit - GLOBAL KURULUM
# ============================================
#  Kullanım:
#    chmod +x install-global.sh
#    ./install-global.sh
#
#  Ne yapar?
#    - Ajanları ~/.config/opencode/agents/ altına kopyalar
#    - Skill'leri ~/.config/opencode/skills/ altına kopyalar
#    - Komutu ~/.config/opencode/commands/ altına kopyalar
#    - Config dosyasını kopyalar (mevcut config korumalı)
#    - CodeGraph kurulumu (opsiyonel)
#    - Playwright browser download kontrolü
#    - Artık HER projede /audit-all komutu çalışır!
# ============================================

set -e

GLOBAL_DIR="$HOME/.config/opencode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "🛡️  OpenCode Audit Kit - Global Kurulum"
echo "========================================="
echo ""

# ---- OpenCode kurulu mu kontrol ----
echo "🔍 OpenCode kontrol ediliyor..."
if command -v opencode &> /dev/null; then
    echo "   ✅ OpenCode mevcut: $(opencode --version 2>/dev/null || echo 'kurulu')"
else
    echo "   ⚠️  OpenCode bulunamadı!"
    echo "   → npm install -g opencode-ai ile kurabilirsiniz"
    echo "   → NOT: npm paket adı 'opencode-ai' (opencode değil!)"
    echo "   → Kurulum olmadan ajanlar kopyalanır ama çalışmaz"
fi
echo ""

# ---- CodeGraph kontrol ----
echo "🔍 CodeGraph kontrol ediliyor..."
if command -v codegraph &> /dev/null; then
    echo "   ✅ CodeGraph zaten kurulu: $(codegraph --version 2>/dev/null || echo 'mevcut')"
else
    echo "   ⚠️  CodeGraph kurulu değil."
    echo "   → Yüksek performanslı kod haritası için önerilir."
    read -p "   Şimdi kurulsun mu? (y/n): " install_cg
    if [ "$install_cg" = "y" ] || [ "$install_cg" = "Y" ]; then
        echo "   📦 CodeGraph kuruluyor..."
        if npm install -g @colbymchenry/codegraph 2>/dev/null; then
            echo "   ✅ CodeGraph kuruldu!"
        else
            echo "   ❌ CodeGraph kurulumu başarısız."
            echo "   → Manuel kurulum: npm install -g @colbymchenry/codegraph"
        fi
    else
        echo "   ℹ️  CodeGraph atlandı. grep/read ile çalışmaya devam edecek."
    fi
fi
echo ""

# ---- Playwright MCP browser kontrol ----
echo "🔍 Playwright MCP kontrol ediliyor..."
if npx @playwright/mcp@latest --help &> /dev/null 2>&1; then
    echo "   ✅ Playwright MCP mevcut"
else
    echo "   ℹ️  Playwright MCP ilk çalıştırmada otomatik kurulur."
    echo "   → İsterseniz şimdi browser download yapabilirsiniz:"
    read -p "   Playwright browser download şimdi yapılsın mı? (y/n): " install_pw
    if [ "$install_pw" = "y" ] || [ "$install_pw" = "Y" ]; then
        echo "   📦 Playwright browser indiriliyor..."
        npx @playwright/mcp@latest install-browser chrome-for-testing 2>/dev/null && echo "   ✅ Browser indirildi!" || echo "   ⚠️  Browser download başarısız, ilk kullanımda tekrar denenecek"
    fi
fi
echo ""

# ---- Dizinleri oluştur ----
echo "📁 Dizinler oluşturuluyor..."
mkdir -p "$GLOBAL_DIR/agents"
mkdir -p "$GLOBAL_DIR/commands"
mkdir -p "$GLOBAL_DIR/skills"
echo "   ✅ $GLOBAL_DIR/agents/"
echo "   ✅ $GLOBAL_DIR/commands/"
echo "   ✅ $GLOBAL_DIR/skills/"
echo ""

# ---- Ajanları kopyala ----
echo "📦 Ajanlar kopyalanıyor..."
AGENT_COUNT=0
for agent in "$SCRIPT_DIR/global/agents/"*.md; do
    if [ -f "$agent" ]; then
        filename=$(basename "$agent")
        if [ -f "$GLOBAL_DIR/agents/$filename" ]; then
            echo "   ⚠️  Üzerine yazılıyor: $filename"
        else
            echo "   ✅ $filename"
        fi
        cp "$agent" "$GLOBAL_DIR/agents/$filename"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    fi
done
echo ""

# ---- Skill'leri kopyala ----
echo "📦 Skill'ler kopyalanıyor..."
SKILL_COUNT=0
for skill_dir in "$SCRIPT_DIR/global/skills/"*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "$GLOBAL_DIR/skills/$skill_name"
        if [ -f "$skill_dir/SKILL.md" ]; then
            cp "$skill_dir/SKILL.md" "$GLOBAL_DIR/skills/$skill_name/SKILL.md"
            if [ -f "$GLOBAL_DIR/skills/$skill_name/SKILL.md" ]; then
                echo "   ⚠️  Üzerine yazılıyor: skills/$skill_name/SKILL.md"
            else
                echo "   ✅ skills/$skill_name/SKILL.md"
            fi
            SKILL_COUNT=$((SKILL_COUNT + 1))
        fi
    fi
done
echo ""

# ---- Komutu kopyala ----
echo "📦 Komutlar kopyalanıyor..."
for cmd in "$SCRIPT_DIR/global/commands/"*.md; do
    if [ -f "$cmd" ]; then
        filename=$(basename "$cmd")
        if [ -f "$GLOBAL_DIR/commands/$filename" ]; then
            echo "   ⚠️  Üzerine yazılıyor: $filename"
        else
            echo "   ✅ $filename"
        fi
        cp "$cmd" "$GLOBAL_DIR/commands/$filename"
    fi
done
echo ""

# ---- Config dosyasını kopyala ----
echo "📦 Config dosyası kontrol ediliyor..."
if [ -f "$SCRIPT_DIR/global/opencode.json" ]; then
    if [ -f "$GLOBAL_DIR/opencode.json" ]; then
        echo "   ⚠️  opencode.json zaten mevcut!"
        echo "   → Mevcut config korundu."
        echo "   → Yeni config referansı: $SCRIPT_DIR/global/opencode.json"
        echo "   → MCP tool'larını (playwright, codegraph, context7) eklemek için manuel birleştirin."
        echo ""
        echo "   📋 opencode.json'a eklenmesi gereken MCP'ler:"
        echo '   {'
        echo '     "mcp": {'
        echo '       "playwright": { "type": "local", "command": ["npx", "@playwright/mcp@latest"], "enabled": true },'
        echo '       "context7": { "type": "local", "command": ["npx", "-y", "@upstash/context7-mcp"], "enabled": true },'
        echo '       "codegraph": { "type": "local", "command": ["codegraph", "serve", "--mcp"], "enabled": true }'
        echo '     }'
        echo '   }'
    else
        cp "$SCRIPT_DIR/global/opencode.json" "$GLOBAL_DIR/opencode.json"
        echo "   ✅ opencode.json (MCP + tool ayarları)"
    fi
fi
echo ""

# ---- Environment variable uyarısı ----
echo "⚙️  Environment Variable Kontrolü:"
if [ -n "$OPENCODE_EXPERIMENTAL_LSP_TOOL" ]; then
    echo "   ✅ OPENCODE_EXPERIMENTAL_LSP_TOOL=$OPENCODE_EXPERIMENTAL_LSP_TOOL"
else
    echo "   ⚠️  OPENCODE_EXPERIMENTAL_LSP_TOOL ayarlı değil"
    echo "   → LSP tool (goToDefinition, findReferences) için:"
    echo '   → export OPENCODE_EXPERIMENTAL_LSP_TOOL=true'
    echo "   → Bunu ~/.bashrc veya ~/.zshrc dosyana ekleyin"
fi
echo ""

# ---- Özet ----
echo "✅ Global kurulum tamamlandı!"
echo ""
echo "📊 Yüklenen:"
echo "   - $AGENT_COUNT ajan   → $GLOBAL_DIR/agents/"
echo "   - $SKILL_COUNT skill  → $GLOBAL_DIR/skills/"
echo "   - 1 komut     → $GLOBAL_DIR/commands/audit-all.md"
echo ""
echo "🚀 Artık HER projede şu şekilde kullanabilirsin:"
echo ""
echo "   # OpenCode TUI içinde:"
echo "   /audit-all"
echo ""
echo "   # Proje için CodeGraph index'i oluşturmak istersen:"
echo "   cd proje-klasoru && codegraph init -i"
echo ""
echo "📝 Bilinen Sınırlar:"
echo "   - Custom subagent @mention çağırma bug'ı olabilir (Issue #29616)"
echo "     → Fallback: skill tool ile skill'ler yüklenir"
echo "     → Fallback: primary agent tüm adımları kendin yapar"
echo "   - Playwright MCP ilk çalıştırmada browser download gerektirebilir"
echo "   - LSP tool deneysel, OPENCODE_EXPERIMENTAL_LSP_TOOL=true gerekli"
echo ""
