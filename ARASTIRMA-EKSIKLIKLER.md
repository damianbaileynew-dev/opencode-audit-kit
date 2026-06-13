# 🔬 ARAŞTIRMA RAPORU — Eksiklikleri Tamamlayacak Repolar ve Çözümler

> **Tarih:** 2026-06-11
> **Amaç:** 10/10 puan için eksik kalan her şeyi tamamlamak

---

## 🏆 KRİTİK KEŞİF: OpenCode Non-Interactive Modda ÇALIŞIYOR!

**Komut:**
```bash
npx opencode-ai@latest run \
  --agent master-orchestrator \
  --model opencode/deepseek-v4-flash-free \
  --format json \
  "Bu projeyi analiz et..."
```

**Sonuç:**
- ✅ Agent yüklendi (master-orchestrator bulunamadı → default'a fallback)
- ✅ `task` tool ile `explore` subagent çağrıldı
- ✅ Subagent tüm projeyi taradı (glob, grep, read kullandı)
- ✅ 20 bug tespit edildi
- ✅ Rapor yazıldı: `reports/frontend/frontend-audit-20260611-summary.md`
- ✅ Bash, write tool'ları kullanıldı
- ✅ **Ücretsiz model** (deepseek-v4-flash-free) ile çalıştı

**Bulunan Sorun:** `--agent master-orchestrator` bulunamadı çünkü global agents dizininde değil, proje dizininde. `--agent` flag'i projenin `.opencode/agents/` dizinine bakıyor olmalı.

---

## 📦 Eksiklikleri Tamamlayacak Repolar

### 1. Subagent Çağırma → ÇÖZÜLDÜ (task tool çalışıyor!)

**Keşif:** OpenCode `task` tool'unun `subagent_type: "explore"` parametresi **gerçekten çalışıyor**. Yukarıdaki test bunu kanıtladı.

**Repo:** OpenCode' kendisi — https://github.com/anomalyco/opencode
- `task` tool built-in
- `explore` ve `general` subagent tipleri mevcut
- Custom agent dosyaları `--agent` flag'i ile kullanılabilir

**Çözüm:** Agent dosyalarını projenin `.opencode/agents/` dizinine kopyalamalıyız (global yerine proje bazlı).

---

### 2. Playwright MCP Skills ve Entegrasyon

| Repo | Açıklama | Bize Katkısı |
|------|----------|:-------------|
| [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) | Resmi Playwright MCP server (23 tool) | ✅ Zaten kullanıyoruz |
| [Svtter/opencode-playwright-test-agents](https://github.com/Svtter/opencode-playwright-test-agents) | OpenCode plugin: 2 Playwright agent (verify + generate) | 🔥 Otomatik Playwright test oluşturma |
| [jshsakura/awesome-opencode-skills](https://github.com/jshsakura/awesome-opencode-skills) | **136+ OpenCode skill** — accessibility-tester, browser-debugger, penetration-tester, security-auditor, test-automator, qa-expert | 🔥 Hazır skill'ler |
| [TheArchitectit/awesome-opencode-skills](https://github.com/TheArchitectit/awesome-opencode-skills) | Webapp Testing skill, Code Security Auditor, Staff Engineer Review | 🔥 Kapsamlı test skill'leri |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | **1,527+ skill** — QA, security, testing, DevOps | 🔥 En büyük koleksiyon |

---

### 3. Multi-Agent Workflow Şablonları

| Repo | Açıklama | Bize Katkısı |
|------|----------|:-------------|
| [wildwasser/opencode-agents](https://github.com/wildwasser/opencode-agents) | **Oscar→Scout→Ivan→Jester** multi-agent template | 🔥 Subagent koordinasyon şablonu |
| [gtheys/opencode](https://github.com/gtheys/opencode) | Skills + commands + agents template (TDD, security-review, playwright) | 🔥 Playwright skill, code-reviewer |
| [rmkohlman/opencode-agents](https://github.com/rmkohlman/opencode-agents) | Agent template referansı (frontmatter, permissions) | ✅ Kullanıyoruz |
| [jbeck018/agents-opencode](https://github.com/jbeck018/agents-opencode) | Production-ready agents (architect, reviewer, test-automator, security-auditor) | 🔥 Güvenlik denetimi şablonu |

---

### 4. Non-Interactive / CI Otomasyonu

| Repo / Kaynak | Açıklama |
|----------------|----------|
| [wesammustafa/OpenCode-Everything-You-Need-to-Know](https://github.com/wesammustafa/OpenCode-Everything-You-Need-to-Know) | `opencode run "..."` ile non-interactive, `opencode serve` ile headless server |
| [SpillwaveSolutions/opencode_cli](https://github.com/SpillwaveSolutions/opencode_cli) | Headless LLM automation skill — subprocess entegrasyonu |
| [Issue #13851](https://github.com/anomalyco/opencode/issues/13851) | Non-interactive pipeline sorunları ve çözümleri |

**Kritik:** `opencode run` komutu:
```bash
opencode run "prompt"                    # Tek seferlik çalıştırma
opencode run --agent myagent "prompt"    # Belirli agent ile
opencode run --model provider/model "prompt"  # Belirli model ile
opencode run --format json "prompt"      # JSON çıktı (CI için)
opencode serve --port 4096               # Headless HTTP server
```

---

### 5. Güvenlik ve Quality Assurance

| Repo | Açıklama |
|------|----------|
| [gmh5225/awesome-ai-security](https://github.com/gmh5225/awesome-ai-security) | AI güvenlik araçları (HOL Guard, AgentGuard, claudit-sec) |
| awesome-opencode-skills → `security-auditor`, `penetration-tester`, `compliance-auditor` | 136+ skill içinde güvenlik skill'leri |
| [gtheys/opencode → security-review skill](https://github.com/gtheys/opencode) | OpenCode security review skill |

---

## 📋 UYGULANACAK EYLEM PLANI

### Adım 1: Agent'ları Proje Bazlı Kopyala
`--agent` flag'i projenin `.opencode/agents/` dizinine bakıyor olmalı.
```bash
cp opencode-audit-kit/global/agents/*.md demo-project/.opencode/agents/
```

### Adım 2: awesome-opencode-skills'den İlgili Skill'leri Ekle
- `security-auditor` → Backend güvenlik denetimi
- `test-automator` → Test otomasyonu
- `browser-debugger` → Tarayıcı tabanlı debug
- `qa-expert` → QA stratejisi
- `code-reviewer` → Kod incelemesi

### Adım 3: `--agent master-orchestrator` ile Tekrar Test Et
Agent dosyaları proje dizinine kopyalandıktan sonra.

### Adım 4: Headless Server ile API Test
```bash
opencode serve --port 4096 --hostname 127.0.0.1
# Ardından HTTP API ile agent çağır
```
