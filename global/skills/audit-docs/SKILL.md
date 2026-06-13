---
name: audit-docs
description: >-
  Documentation audit skill. README, API docs, inline comments, contributing guide taraması.
  Eksik ve yetersiz dokümantasyon tespiti.
  Trigger: "docs audit", "audit docs", "dokümantasyon audit", "documentation review"
---

# Skill: Documentation Audit

**Amaç:** Projenin dokümantasyonunu denetle — README, API docs, inline comments, contributing guide.

## Kısıtlar
**Sadece oku ve raporla.** Dosya değiştirme. Raporu `reports/documentation/` dizinine yaz.

---

## Adım 1: README.md Kontrolü

### Kontroller
1. **README.md var mı?** — Proje kök dizininde README.md bulunuyor mu?
2. **Proje açıklaması** — Ne yaptığı, kimin için olduğu açık mı?
3. **Kurulum talimatı** — `npm install`, env setup, migration adımları var mı?
4. **Kullanım talimatı** — Nasıl çalıştırılır? CLI komutları, API kullanımı var mı?
5. **Ortam değişkenleri** — `.env.example` var mı? Hangi değişkenler gerekli?
6. **Proje yapısı** — Dizin yapısı dokümante edilmiş mi?
7. **Test talimatı** — Test nasıl çalıştırılır?
8. **Lisans** — Lisans bilgisi var mı?

```bash
glob("README.md")
glob("README*")
read("README.md")  # Varsa
```

## Adım 2: API Dokümantasyonu Kontrolü

### Kontroller
1. **API docs var mı?** — `docs/API.md`, Swagger/OpenAPI, Postman collection?
2. **Endpoint listesi** — Tüm endpoint'ler dokümante edilmiş mi?
3. **Request format** — Body, query params, headers açıklanmış mı?
4. **Response format** — Success ve error response'lar dokümante mi?
5. **Authentication** — Auth mekanizması açıklanmış mı?
6. **Örnekler** — Request/response örnekleri var mı?
7. **Error codes** — HTTP status kodları ve anlamları var mı?

```bash
glob("docs/API*")
glob("docs/api*")
glob("swagger*")
glob("openapi*")
# Endpoint'leri tespit et:
grep("app\\.get|app\\.post|app\\.put|app\\.delete|router\\.", "src/**/*.js")
```

## Adım 3: Inline Comment Kontrolü

### Kontroller
1. **Karmaşık logic yorumlanmış mı?** — Hesaplama, algoritma, business rules
2. **Fonksiyon imzaları** — JSDoc veya açıklayıcı yorum var mı?
3. **Magic number'lar açıklanmış mı?** — `0.1` → "Premium discount rate"
4. **TODO/FIXME/HACK** — İşaretlenmiş teknik borçlar var mı?
5. **Modül seviye açıklama** — Her dosyanın ne yaptığı belli mi?

```bash
# Comment yoğunluğunu kontrol et
grep("//|/\\*|\\*/", "src/**/*.js")
# Magic number tespit
grep("[0-9]+\\.[0-9]+", "src/**/*.js")
# TODO/FIXME tespit
grep("TODO|FIXME|HACK|XXX", "src/**/*.js")
```

## Adım 4: Katkı Rehberi Kontrolü

### Kontroller
1. **CONTRIBUTING.md var mı?** — Geliştiriciler nasıl katkıda bulunur?
2. **Kod standartları** — Linting, formatting kuralları
3. **PR süreci** — Branch naming, commit mesaj formatı
4. **Test gereksinimleri** — Yeni kod için test zorunluluğu
5. **Code review süreci** — Reviewer beklentileri

```bash
glob("CONTRIBUTING*")
glob(".github/PULL_REQUEST_TEMPLATE*")
glob(".editorconfig")
glob(".eslintrc*")
glob(".prettierrc*")
```

## Adım 5: Changelog & Version Kontrolü

### Kontroller
1. **CHANGELOG.md var mı?** — Versiyon geçmişi tutuluyor mu?
2. **package.json version** — Anlamlı versiyon numarası mı?
3. **Git tags** — Release'ler tag'lenmiş mi?
4. **Release notes** — GitHub/GitLab release'ler var mı?

## Adım 6: Rapor Yaz

`reports/documentation/docs-audit-YYYYMMDD.md`:

```markdown
# 📚 Documentation Audit Raporu

## README.md
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|
| 1 | README mevcut | ✅/❌ | |
| 2 | Proje açıklaması | ✅/❌ | |
| 3 | Kurulum talimatı | ✅/❌ | |
| 4 | Kullanım talimatı | ✅/❌ | |
| 5 | Ortam değişkenleri | ✅/❌ | |
| 6 | Proje yapısı | ✅/❌ | |
| 7 | Test talimatı | ✅/❌ | |
| 8 | Lisans | ✅/❌ | |

## API Dokümantasyonu
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|

## Inline Comments
| # | Dosya | Yorum Durumu | Öneri |
|---|-------|:------------:|-------|

## Katkı Rehberi
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|

## Dokümantasyon Skoru
- README: X/8
- API Docs: X/7
- Inline Comments: X/5
- Contributing: X/5
- **Toplam: X/25**

## Önceliklendirme
### P0 — Hemen Oluşturulmalı
### P1 — Planla ve Oluştur
### P2 — İyileştirme
```
