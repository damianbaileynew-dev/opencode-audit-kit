#!/bin/bash
# ============================================
#  🛡️ OpenCode Audit Kit - KALDIR
# ============================================
#  Kullanım:
#    chmod +x uninstall.sh
#    ./uninstall.sh
#
#  Ne yapar?
#    - Global ajanları kaldırır
#    - Global skill'leri kaldırır
#    - Global komutu kaldırır
# ============================================

set -e

GLOBAL_DIR="$HOME/.config/opencode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "🛡️  OpenCode Audit Kit - Kaldırma"
echo "=================================="
echo ""

# Kaldırılacak dosyalar
AGENTS=(
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
)

COMMANDS=(
    "audit-all.md"
)

SKILLS=(
    "audit-frontend"
    "test-frontend"
    "fix-frontend"
    "audit-backend"
    "fix-backend"
    "critique-ux"
    "polish-ux"
    "manage-memory"
    "web-quality-audit"
    "accessibility-audit"
    "performance-audit"
    "vulnerability-scan"
    "code-review"
    "security-audit-full"
    "suggest-innovation"
)

echo "Kaldırılacak dosyalar:"
echo ""
echo "Ajanlar:"
FOUND_COUNT=0
for agent in "${AGENTS[@]}"; do
    if [ -f "$GLOBAL_DIR/agents/$agent" ]; then
        echo "  ✗ agents/$agent"
        FOUND_COUNT=$((FOUND_COUNT + 1))
    fi
done

echo ""
echo "Skill'ler:"
for skill in "${SKILLS[@]}"; do
    if [ -d "$GLOBAL_DIR/skills/$skill" ]; then
        echo "  ✗ skills/$skill/"
        FOUND_COUNT=$((FOUND_COUNT + 1))
    fi
done

echo ""
echo "Komutlar:"
for cmd in "${COMMANDS[@]}"; do
    if [ -f "$GLOBAL_DIR/commands/$cmd" ]; then
        echo "  ✗ commands/$cmd"
        FOUND_COUNT=$((FOUND_COUNT + 1))
    fi
done

if [ "$FOUND_COUNT" -eq 0 ]; then
    echo ""
    echo "ℹ️  Kaldırılacak dosya bulunamadı."
    exit 0
fi

echo ""
read -p "Devam edilsin mi? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "İptal edildi."
    exit 0
fi

echo ""
for agent in "${AGENTS[@]}"; do
    if [ -f "$GLOBAL_DIR/agents/$agent" ]; then
        rm "$GLOBAL_DIR/agents/$agent"
        echo "   🗑️  Kaldırıldı: agents/$agent"
    fi
done

for skill in "${SKILLS[@]}"; do
    if [ -d "$GLOBAL_DIR/skills/$skill" ]; then
        rm -rf "$GLOBAL_DIR/skills/$skill"
        echo "   🗑️  Kaldırıldı: skills/$skill/"
    fi
done

for cmd in "${COMMANDS[@]}"; do
    if [ -f "$GLOBAL_DIR/commands/$cmd" ]; then
        rm "$GLOBAL_DIR/commands/$cmd"
        echo "   🗑️  Kaldırıldı: commands/$cmd"
    fi
done

echo ""
echo "✅ Global ajanlar, skill'ler ve komutlar kaldırıldı."
echo "   (Proje bazlı .opencode/ klasörleri etkilenmedi)"
echo "   (opencode.json config dosyası etkilenmedi)"
echo ""
