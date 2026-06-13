# Addy Osmani `agent-skills` Analizi — OpenCode Audit Kit'e Katkısı

> Tarih: 2026-06-14  
> Repo: https://github.com/addyosmani/agent-skills  
> Stars: 58.2k | Forks: 6.3k | Commits: 229 | Lisans: MIT

---

## 1. Repo Özeti

Addy Osmani'nin `agent-skills` reposu, AI kodlama ajanları için **24 adet production-grade engineering skill** içerir. 6 fazda organize edilmiştir:

| Faz | Skill'ler | Amacı |
|-----|-----------|-------|
| **Define** | interview-me, idea-refine, spec-driven-development | Ne yapılacağını netleştir |
| **Plan** | planning-and-task-breakdown | Küçük, doğrulanabilir task'lara böl |
| **Build** | incremental-implementation, source-driven-development, doubt-driven-development, context-engineering, frontend-ui-engineering, api-and-interface-design | Kodu yaz |
| **Verify** | test-driven-development, browser-testing-with-devtools, debugging-and-error-recovery | Çalıştığını kanıtla |
| **Review** | code-review-and-quality, code-simplification, security-and-hardening, performance-optimization | Quality gate'ler |
| **Ship** | git-workflow-and-versioning, ci-cd-and-automation, deprecation-and-migration, documentation-and-adrs, observability-and-instrumentation, shipping-and-launch | Güvenle deploy et |

**4 Agent Persona** içerir: code-reviewer, security-auditor, test-engineer, web-performance-auditor

**OpenCode desteği var**: `.opencode/skills` symlink ile çalışır. Ayrıca Claude Code, Gemini, Antigravity CLI desteği mevcut.

---

## 2. Bizim Audit Kit ile Karşılaştırma

### 2.1 Kesişen Alanlar

| Addy Osmani Skill | Bizim Skill | Kesişim | Kalite Farkı |
|--------------------|-------------|---------|--------------|
| `security-and-hardening` | `security-audit-full`, `fix-backend` | OWASP Top 10, input validation, auth, headers | Onlar **STRIDE threat model** + 3-tier boundary system + detaylı kod örnekleri. Biz **grep bazlı otomatik scoring** |
| `performance-optimization` | `performance-audit`, `fix-performance` | N+1, pagination, caching, bundle size | Onlar **Core Web Vitals hedefleri** + Measure→Identify→Fix→Verify→Guard workflow. Biz **score.sh pattern match** |
| `code-review-and-quality` | `code-review`, `impeccable-audit` | 5-eksen review (correctness, readability, architecture, security, performance) | Onlar **change sizing**, severity labels, split strategies. Biz **10 boyut scoring** |
| `test-driven-development` | `tdd`, `fix-test` | Red-Green-Refactor, test pyramid | Onlar **Prove-It pattern** (bug→test→fix), DAMP over DRY, test sizes. Biz **integration test zorunluluğu** |
| `documentation-and-adrs` | `fix-docs` | README, API docs, inline comments | Onlar **ADR template** + lifecycle + "document the why" felsefesi. Biz **5 zorunlu dosya** (README, CONTRIBUTING, CHANGELOG, ARCHITECTURE, API) |
| `frontend-ui-engineering` | `fix-a11y`, `fix-ux`, `fix-frontend` | WCAG 2.1 AA, responsive, component architecture | Onlar **design system** + state management. Biz **ARIA + responsive + search UX** |
| `ci-cd-and-automation` | `audit-devops`, `fix-devops` | Quality gates, automation | Onlar **Shift Left** felsefesi + feature flags. Biz **health endpoint + graceful shutdown** |

### 2.2 Bizde Olmayan ve Kopyalanabilir Özellikler

| Özellik | Kaynak Skill | Audit Kit'e Katkısı |
|---------|--------------|---------------------|
| **STRIDE Threat Modeling** | security-and-hardening | Audit sırasında ajanın threat model yapmasını sağlar — sadece "helmet var mı?" yerine "neye saldırılabilir?" sorusunu sorar |
| **Three-Tier Boundary System** | security-and-hardening | Always Do / Ask First / Never Do — fix skill'lerinin risk seviyesini net sınıflandırır |
| **Core Web Vitals Hedefleri** | performance-optimization | LCP ≤2.5s, INP ≤200ms, CLS ≤0.1 — somut metrik bazlı scoring |
| **Measure→Identify→Fix→Verify→Guard** | performance-optimization | Fix sonrası otomatik re-verify + regression guard — bizim auto-audit loop'umuzla tam örtüşür |
| **Prove-It Pattern** | test-driven-development | Bug fix'lerde önce test yazma zorunluluğu — fix-test skill'imiz geliştirilebilir |
| **ADR Template** | documentation-and-adrs | Mimari kararların neden kaydı — audit dimensional scoring'i daha anlamlı kılar |
| **Doubt-Driven Development** | doubt-driven-development | CLAIM→EXTRACT→DOUBT→RECONCILE→STOP — ajanın kendi fix'ini sorgulaması |
| **Context Engineering Anti-Patterns** | context-engineering | Skill prompt'larının LLM'ye daha iyi verilmesi — bizim SKILL.md dosyalarının kalitesini artırır |
| **Change Sizing** | code-review-and-quality | ~100 satır değişiklik hedefi — fix skill'lerinde parça parça düzeltme stratejisi |
| **Source-Driven Development** | source-driven-development | Framework resmi dokümanına göre düzeltme — NestJS/Next.js fix'lerde yanlış pattern kullanımını engeller |
| **Security Checklist Reference** | references/security-checklist.md | OWASP Top 10 + LLM Top 10 checklist — scorer'a yeni kontroller eklenebilir |
| **Accessibility Checklist** | references/accessibility-checklist.md | WCAG 2.1 AA detaylı checklist — a11y scoring'imizi geliştirir |
| **Performance Checklist** | references/performance-checklist.md | Bundle analysis, profiling workflow — performance scoring'i geliştirir |

### 2.3 Onlarda Olmayan ve Bizde Olan Özellikler

| Bizde Olan | Onlarda Durum |
|------------|---------------|
| **Otomatik Scoring (67 kontrol/framewwork)** | ❌ Yok — sadece nitel tavsiye |
| **10 Boyutlu Audit** | ❌ Yok — security + performance + code quality var ama puanlama yok |
| **5 Framework Desteği** | ❌ Yok — framework-agnostic |
| **Score.sh ile %80+ Hedef** | ❌ Yok — "iyi pratik" seviyesinde kalıyor |
| **Auto-Audit Retry Loop** | ❌ Yok — ancak Measure→Verify→Guard benzeri |
| **Buggy→Fixed Test Döngüsü** | ❌ Yok — test projeleri yok |
| **CLI + npm Package** | Kısmen — `/spec`, `/plan` gibi slash commands var ama bağımsız CLI yok |

---

## 3. Entegrasyon Stratejileri

### Strateji A: Yan Yana Kurulum (En Kolay, Düşük Risk)

```bash
# addyosmani skill'lerini ayrı bir OpenCode plugin olarak kur
npx opencode-ai plugin https://github.com/addyosmani/agent-skills --global

# Bizim audit kit zaten kurulu
# İkisi birlikte çalışır — ajan her iki skill set'i de görür
```

**Artıları:** Sıfır kod değişikliği, anında kullanılabilir  
**Eksileri:** Ajan aynı anda iki skill set'i arasında karar vermek zorunda kalabilir, duplicate davranışlar olabilir

### Strateji B: Cherry-Pick İnce Ayar (Orta Efor, Yüksek Değer)

En değerli 5 özelliği mevcut skill'lerimize entegre et:

1. **STRIDE + 3-Tier Boundary** → `security-audit-full` ve `fix-backend` SKILL.md'lere ekle
2. **Core Web Vitals Hedefleri** → `performance-audit` SKILL.md'ye ekle  
3. **Prove-It Pattern** → `fix-test` SKILL.md'ye ekle
4. **ADR Template** → `fix-docs` SKILL.md'ye ekle
5. **Common Rationalizations + Red Flags** → Tüm skill'lere ekle (addy'nin format standardı)

### Strateji C: Skill Format Standardizasyonu (Yüksek Efor, Uzun Vadeli)

Addy Osmani'nin **skill anatomy** formatını benimse:
- Frontmatter: `name` + `description` (max 1024 char)
- Standart bölümler: Overview → When to Use → Process → Common Rationalizations → Red Flags → Verification
- Reference dosyaları ayrı tut (SKILL.md < 500 satır)

Bu, skill'lerimizi daha profesyonel, daha keşfedilebilir ve daha güvenilir hale getirir.

### Strateji D: Referans Dosyalarını Kopyalama (Düşük Efor, Orta Değer)

```bash
# security-checklist.md → references/ klasörüne
# performance-checklist.md → references/ klasörüne
# accessibility-checklist.md → references/ klasörüne
```

Skill'lerimizden bu reference dosyalarına link vererek ajanın daha derinlemesine bilgiye erişmesini sağlarız.

---

## 4. Test Edilebilirlik

### 4.1 Doğrudan Test

```bash
# Repo'yu klonla
cd /home/user
git clone https://github.com/addyosmani/agent-skills.git

# OpenCode plugin olarak kur
npx opencode-ai plugin /home/user/agent-skills --global

# Test: Ajan addy'nin security skill'ini kullanabiliyor mu?
npx opencode-ai run "Bu Express.js projesini security-and-hardening skill'ine göre denetle" \
  --project /home/user/stress-test-project \
  --model opencode/deepseek-v4-flash-free
```

### 4.2 Entegrasyon Test

Mevcut test döngümüzle doğrulanabilir:

```bash
# 1. Buggy proje oluştur
# 2. Audit kit + addy skill'leri birlikte çalışsın
# 3. Score.sh ile puanla
# 4. 80%+ hedefi karşılaştı mı?
cd /home/user/opencode-audit-kit && bash auto-audit.sh
```

### 4.3 Potansiyel Sorunlar

| Sorun | Açıklama | Çözüm |
|-------|----------|-------|
| **Skill Çakışması** | Aynı intent'e iki skill yanıt verebilir | Master orchestrator'da öncelik tanımla |
| **Token Bütçesi** | 24 skill + 37 skill = 61 skill deskripsiyonu context'i şişirir | Sadece ilgili skill'leri aktif et |
| **Format Farkı** | Addy'nin frontmatter formatı bizimkinden biraz farklı | İkisi de SKILL.md standardına uyuyor, sorun yok |
| **Framework Uyumu** | Addy'nin skill'leri framework-agnostic | Bizim fix skill'leri framework-spesifik — çakışma yok, tamamlayıcı |

---

## 5. Somut Aksiyon Planı

### Faz 1: Hızlı Kazanç (1-2 saat)
- [ ] `agent-skills` repo'sunu klonla
- [ ] `references/security-checklist.md`, `references/performance-checklist.md`, `references/accessibility-checklist.md` dosyalarını audit kit'e kopyala
- [ ] Mevcut fix skill'lerinde bu referanslara link ver

### Faz 2: Skill Geliştirme (3-4 saat)
- [ ] `security-audit-full` SKILL.md'ye STRIDE threat modeling bölümü ekle
- [ ] `fix-backend` SKILL.md'ye Three-Tier Boundary (Always/Ask/Never) ekle
- [ ] `performance-audit` SKILL.md'ye Core Web Vitals hedefleri ekle
- [ ] `fix-test` SKILL.md'ye Prove-It Pattern ekle
- [ ] `fix-docs` SKILL.md'ye ADR Template ekle
- [ ] Tüm skill'lere **Common Rationalizations** ve **Red Flags** bölümleri ekle

### Faz 3: Format Standardizasyonu (2-3 saat)
- [ ] Skill anatomy formatını incele ve benimse
- [ ] Mevcut 37 skill'in frontmatter'larını description ≤1024 char kuralına uyarl
- [ ] SKILL.md dosyalarını 500 satır altına düşür (reference dosyaları ayır)
- [ ] validate.sh'ı yeni format kurallarına göre güncelle

### Faz 4: Entegrasyon Testi (2-3 saat)
- [ ] addyosmani/agent-skills'i ayrı plugin olarak kur
- [ ] Birlikte çalışabilirlik testi yap
- [ ] Scoring sonuçlarını karşılaştır (önce vs sonra)
- [ ] Master orchestrator'da öncelik mekanizması ekle

---

## 6. Sonuç

| Kriter | Değerlendirme |
|--------|---------------|
| **Bize katkısı olur mu?** | ✅ **EVET** — Özellikle security, performance ve documentation skill'lerinde önemli derinlik sağlar |
| **Test edebilir miyiz?** | ✅ **EVET** — OpenCode plugin olarak kurulabilir, mevcut auto-audit döngüsüyle test edilebilir |
| **Risk var mı?** | ⚠️ Düşük — Skill çakışması ve token bütçesi sorunları yönetilebilir |
| **Öncelik nedir?** | 🎯 **Faz 2** — Skill geliştirme en yüksek ROI sağlar (STRIDE, Core Web Vitals, Prove-It) |
| **Nasıl başlanır?** | Repo'yu klonla → referans dosyalarını kopyala → skill'lere ekleme yap → validate et |

**Anahtar Fark:** Addy'nin skill'leri "ajan nasıl çalışmalı"yı öğretir, bizim skill'ler "ajan neyi düzeltmeli"yi söyler. Birlikte kullanıldığında, ajan sadece neyi düzeltceğini bilmekle kalmaz, **nasıl düzelteceğini ve neden o şekilde düzeltmesi gerektiğini** de bilir.

**TL;DR:** Bu repo bizim audit kit'in "nasıl"ını geliştirir. Mevcut "neyi" altyapımız (scoring, auto-retry, 5 framework) korunurken, ajanın düşünme kalitesi artar. En değerli katkılar: STRIDE threat modeling, Core Web Vitals hedefleri, Prove-It pattern ve Common Rationalizations formatı.
