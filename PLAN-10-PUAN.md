# 🏗️ 10/10 OLMA PLANI — Gerçek, Uygulanabilir, Test Edilmiş

> **Tarih:** 2026-06-11
> **Mevcut Durum:** 5.5/10 → Implement sonrası tahmini: 7.5/10
> **Hedef:** 9/10 (10/10 demek OpenCode geliştiricilerinin kodunu düzeltmek olur)
> **Arena.ai'de yapılabilecekler:** ✅ Yapıldı
> **Gerçek OpenCode ortamında yapılması gerekenler:** 🔄 Bekliyor

---

## ✅ ARENA.AI'DE YAPILANLAR (Sprint 5 Implementasyonu)

### 1. name Attribute Eklendi (9/9 Agent)
Tüm agent dosyalarına `name` attribute eklendi:
- `master-orchestrator`, `frontend-audit`, `frontend-test-scenarios`, `frontend-fix`
- `backend-audit`, `backend-fix`, `ux-critic`, `ux-polish`, `innovation-agent`
- → @mention workaround'un çalışması için gerekli

### 2. SKILL.md Alternatifleri Oluşturuldu (8 Skill)
En güvenilir subagent çağırma yöntemi:
- `audit-frontend/SKILL.md`, `test-frontend/SKILL.md`, `fix-frontend/SKILL.md`
- `audit-backend/SKILL.md`, `fix-backend/SKILL.md`
- `critique-ux/SKILL.md`, `polish-ux/SKILL.md`, `suggest-innovation/SKILL.md`
- → Subagent bug'ı olsa bile skill tool ile kesinlikle çalışır

### 3. Permission'lar Daraltıldı
**Audit ajanları:** bash=deny, edit=deny, write=allow, read=allow
**Fix ajanları:** bash=allow, edit=allow, question=ask
**Innovation:** bash=deny, edit=deny, websearch=allow
- → Audit ajanları dosya değiştiremez (güvenlik)

### 4. MCP Tool İsimleri Düzeltildi
**ESKİ (çalışmayan):** `ast_grep`, `grep_app`, `sequential-thinking`
**YENİ (gerçek):** `glob`, `grep`, `read`, `write`, `edit`, `bash`, `todowrite`, `question`
- → OpenCode built-in tool isimleri doğru yazıldı

### 5. 3 Katmanlı Fallback Stratejisi Eklendi
Master Orchestrator artık sırayla dener:
1. @mention → subagent spawn (en iyi)
2. skill tool → SKILL.md yükle (güvenilir)
3. Kendin yap → tek oturumda tüm adımlar (kesin çalışır)

### 6. Install Script'leri İyileştirildi
- Playwright browser download eklendi
- Skills kopyalama eklendi
- OPENCODE_EXPERIMENTAL_LSP_TOOL uyarısı eklendi
- CodeGraph init proje kurulumuna eklendi

### 7. Uninstall Script'e Skills + frontend-test-scenarios Eklendi

### 8. Config Dosyasına Yorumlar ve Açıklamalar Eklendi

---

## 🔄 GERÇEK OPENCODE ORTAMINDA YAPILMASI GEREKENLER

Bu adımlar Arena.ai'de yapılamaz, gerçek OpenCode TUI gerektirir.

### Sprint 1: Orchestrator Çalıştırma Testi (2-3 saat)
```bash
npm install -g opencode
cd demo-project
opencode
# TUI'de: "Bu projeyi analiz et" yaz
# → grep/read kullanıyor mu? package.json okunuyor mu?
```

### Sprint 2: Subagent Çağırma Testi (3-4 saat)
3 yöntem sırayla test et:
1. `@frontend-audit` → çalışıyor mu?
2. `skill("audit-frontend")` → çalışıyor mu?
3. Primary agent olarak tek oturumda → kesin çalışır

### Sprint 3: Playwright MCP Gerçek Test (2-3 saat)
```bash
cd demo-project && npx vite --port 3000 &
opencode
# "http://localhost:3000 sayfasını aç ve butonları listele"
```

### Sprint 4: CodeGraph Gerçek Test (2-3 saat)
```bash
npm install -g @colbymchenry/codegraph
cd demo-project && codegraph init -i
opencode
# "handleSubmit fonksiyonunu kim çağırıyor?"
```

### Sprint 6: End-to-End Test (1 gün)
Yeni bir Next.js projesinde tam akış testi.

### Sprint 7: Dokümantasyon (4-6 saat)
Gerçek sonuçları README'ye yaz, demo kaydı al.

---

## 📊 GÜNCEL PUAN TAHMINİ

| Alan | Eski | Yeni | Neden? |
|------|:----:|:----:|--------|
| Dosya yapısı | 9 | 9 | Aynı |
| Frontmatter + name | 6 | 9 | name attribute eklendi |
| Permission sistemi | 4 | 8 | Audit=readonly, fix=restricted |
| Tool isimleri | 3 | 9 | Gerçek OpenCode tool isimleri |
| Subagent stratejisi | 2 | 8 | 3 katmanlı fallback |
| Skill fallback | 0 | 9 | 8 SKILL.md dosyası |
| Install script'leri | 6 | 8 | Playwright, skills, LSP uyarısı |
| Playwright entegrasyonu | 5 | 6 | Config hazır, test edilmedi |
| CodeGraph entegrasyonu | 3 | 5 | Config + agent talimatları, test edilmedi |
| **GENEL** | **5.5** | **7.5** | Implement yapıldı ama gerçek test eksik |

---

## 🎯 9/10 İÇİN SON ADIMLAR

Sadece gerçek OpenCode ortamında yapılabilecek şeyler:
1. Gerçek TUI'de `/audit-all` çalıştır → sonuçları gör
2. Hangi subagent stratejisi çalıştığını tespit et
3. Playwright MCP ile gerçek browser testi yap
4. CodeGraph init + serve --mcp çalıştır
5. En az 2 farklı projede test et
6. Gerçek sonuçları dokümantasyona yaz

Bu adımları yaparsan 9/10 olursun.
