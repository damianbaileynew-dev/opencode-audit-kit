# 🚀 Quick Start — 1 Dakikada Başla

## 1. Kurulum
```bash
cd opencode-audit-kit
chmod +x install-global.sh
./install-global.sh
```

## 2. Proje Hazırla
```bash
cd ../senin-projen/

# Proje dizin yapısını oluştur
/path/to/opencode-audit-kit/install-project.sh

# (Opsiyonel) CodeGraph index
codegraph init -i

# (Opsiyonel) Dev server başlat
npm run dev &
```

## 3. OpenCode Başlat
```bash
opencode
```

## 4. Audit Çalıştır
OpenCode TUI içinde:
```
/audit-all
```

## 5. Sonuçları İncele
```
.opencode/reports/
├── frontend/frontend-audit-*.md       # Frontend bulguları
├── frontend/frontend-test-scenarios-*.md  # Playwright test sonuçları
├── frontend/frontend-fix-*.md         # Uygulanan fix'ler
├── backend/backend-audit-*.md         # Backend bulguları
├── backend/backend-fix-*.md           # Uygulanan fix'ler
├── ux/ux-critic-*.md                 # UX değerlendirmesi
├── ux/ux-polish-*.md                 # UX iyileştirmeleri
├── innovation/innovation-ideas-*.md  # Yenilik önerileri
├── final/final-roadmap-*.md          # 📋 ÖNCELİKLENDİRİLMİŞ YOL HARİTASI
└── _state/handoff.md                 # İş devri kayıtları
```

## Environment Variables (Opsiyonel ama önerilir)
```bash
# LSP tool (deneysel ama güçlü)
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
```

## Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| `/audit-all` çalışmıyor | Global kurulum yapıldı mı? `ls ~/.config/opencode/agents/` |
| Subagent çağrılamıyor | Bug #29616. Skill tool ile fallback çalışır. |
| Playwright açılmıyor | `npx playwright install chromium` çalıştır |
| CodeGraph bulunamıyor | `npm install -g @colbymchenry/codegraph` |
| LSP çalışmıyor | `export OPENCODE_EXPERIMENTAL_LSP_TOOL=true` |
| Bash permission denied | opencode.json'da `"bash": "allow"` olmalı |
