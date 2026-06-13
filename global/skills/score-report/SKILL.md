---
name: score-report
description: "Projeyi 10 boyutta otomatik score'lar ve sonuçları güzel bir markdown rapor olarak gösterir. Her boyut için PASS/FAIL, check detayları ve toplam skor sunar."
---

# Skill: Score Report — 10 Boyut Otomatik Değerlendirme

**Amaç:** Proje dizininde `bash score.sh` çalıştırıp, çıktıyı yapılandırılmış markdown rapora dönüştürmek.
OpenCode içinde `npx opencode-ai run "score-report"` veya orchestrator tarafından otomatik çağrılır.

## ADIM 1: Framework Tespiti

```bash
# Önce hangi framework olduğunu belirle
if [ -f package.json ] && grep -q "@nestjs" package.json 2>/dev/null; then
  echo "FRAMEWORK: nestjs"
elif [ -f package.json ] && grep -q "express" package.json 2>/dev/null; then
  if [ -f tsconfig.json ]; then echo "FRAMEWORK: typescript-express"
  else echo "FRAMEWORK: js-express"; fi
elif [ -f requirements.txt ] && grep -q "fastapi" requirements.txt 2>/dev/null; then
  echo "FRAMEWORK: fastapi"
else
  echo "FRAMEWORK: unknown"
fi
```

## ADIM 2: Score Çalıştır

```bash
bash score.sh .
```

Bu komut 10 boyutun her birini check eder ve çıktı verir. Çıktıyı olduğu gibi kullanıcıya gösterme — ADIM 3'teki formata dönüştür.

## ADIM 3: Sonuçları Markdown Tablo Olarak Sun

Score çıktısını al ve aşağıdaki formatı KULLANARAK kullanıcıya göster:

```markdown
# 🔍 Audit Score Raporu

**Proje:** [proje adı]
**Framework:** [tespit edilen framework]
**Tarih:** [bugünün tarihi]

---

## 📊 Özet

| Boyut | Skor | Durum |
|:------|:----:|:-----:|
| 🔒 Security | 12/12 | ✅ |
| ⚡ Performance | 5/6 | ✅ |
| 🔍 Code Quality | 6/6 | ✅ |
| 🏗️ Architecture | 6/6 | ✅ |
| 🧪 Test | 4/6 | ❌ |
| ♿ Accessibility | 7/7 | ✅ |
| 🎨 UX | 7/7 | ✅ |
| 🚀 DevOps | 5/6 | ✅ |
| 🔎 SEO | 4/6 | ❌ |
| 📚 Documentation | 3/5 | ❌ |

**TOPLAM:** 59/67 = 88%
**GEÇEN:** 7/10 boyut ≥80%

---

## 🔒 Security (12/12 = 100% ✅)

| Check | Durum |
|:------|:-----:|
| S1: Helmet | ✅ |
| S2: Rate-limit | ✅ |
| ... | ... |

## ⚡ Performance (5/6 = 83% ✅)

| Check | Durum |
|:------|:-----:|
| P1: Pagination | ✅ |
| P2: N+1 comments | ✅ |
| P3: N+1 assignee | ✅ |
| P4: Async write | ❌ |
| P5: Search pagination | ✅ |
| P6: JS counting | ✅ |

> ⚠️ **P4: Async write** — `writeFileSync` hala kullanılıyor. `fs/promises` ile değiştir.

[... her boyut için aynı format ...]

---

## ❌ Kalan Sorunlar (3 boyut)

### 🧪 Test (4/6)
- **T5: Edge cases** — invalid, empty, short password testleri eksik
- **T6: Integration** — supertest/@nestjs/testing ile e2e test yok

### 🔎 SEO (4/6)
- **SEO4: JSON-LD** — structured data eksik
- **SEO6: robots.txt** — dosya yok

### 📚 Documentation (3/5)
- **DOC4: CONTRIBUTING.md** — dosya yok
- **DOC5: .env.example** — dosya yok

---

## 🎯 Öneriler

1. Test boyutu için: `tests/` dizinine edge case + integration test ekle
2. SEO için: `public/index.html`'e JSON-LD ekle, `public/robots.txt` oluştur
3. Documentation için: `CONTRIBUTING.md` ve `.env.example` oluştur
```

### Format Kuralları

1. **Her boyut için** ayrı başlık ve check tablosu oluştur
2. **PASS boyutlar** → ✅ ile yeşil göster (detaylı check listesi opsiyonel)
3. **FAIL boyutlar** → ❌ ile kırmızı göster + altında "Kalan Sorunlar" detayı ZORUNLU
4. **En altta** "Kalan Sorunlar" bölümü — sadece FAIL boyutların eksik check'lerini listele
5. **En altta** "Öneriler" bölümü — her FAIL check için somut düzeltme önerisi ver
6. Skor ≥80% olan boyutlar PASS, <80% olanlar FAIL

## ADIM 4: Eğer Tüm Boyutlar PASS ise

```markdown
🎉 **TÜM BOYUTLAR GEÇTİ!** — 10/10 boyut ≥80%

Proje 10 boyutun tamamında başarıyla geçti. Herhangi bir kritik eksiklik yok.
```

## ADIM 5: Eğer Bazı Boyutlar FAIL ise

Kullanıcıya şu mesajı ver:

```markdown
⚠️ **{X}/10 boyut geçti** — {10-X} boyutta düzeltme gerekiyor.

Hemen düzeltmek ister misin? Şu skill'leri kullanabilirsin:
- Test: `skill:fix-test`
- SEO: `skill:fix-seo`  
- Documentation: `skill:fix-docs`
- veya: `npx opencode-ai run "Kalan {boyutlar} boyutundaki eksiklikleri düzelt"`
```
