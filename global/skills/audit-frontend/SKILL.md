---
name: audit-frontend
description: >-
  Frontend audit skill. Tüm sayfa, component ve aksiyonların çalışırlığını tespit eder.
  XSS, SRI, CSRF, frontend-backend entegrasyon kontrolleri dahil.
  Trigger: "audit frontend", "test buttons", "check pages", "frontend audit", "sayfa test"
---

# Skill: Frontend Audit

**Amaç:** Tüm sayfa ve component'lerin gerçekten çalıştığını ve güvenli olduğunu tespit etmek.
**Kısıtlar:** Sadece oku ve raporla, dosya değiştirme.

---

## Adım 1: Proje Keşfi

```
glob("src/**/*.{jsx,tsx,vue,svelte,html,htm}") → Tüm frontend dosyaları
glob("src/**/*.{css,scss,less}") → Stil dosyaları
glob("public/**/*.{html,htm}") → Statik HTML
read("package.json") → Dependencies, scripts
```

## Adım 2: Route/Sayfa Yapısı

```
# React
grep("<Route|createBrowserRouter|useRoutes", "src/**")

# Next.js
glob("app/**/page.{tsx,jsx}") veya glob("pages/**/*.{tsx,jsx}")

# Vue
glob("src/router/**")
```

## Adım 3: Sayfa Bazlı Analiz

Her sayfa için şu checklist'i uygula:

### Form Analizi
- Submit handler var mı?
- Input validation var mı? (required, minLength, pattern)
- Error state gösterimi var mı?
- Loading state gösterimi var mı?

### Buton Analizi
- Her butonun handler'ı var mı?
- Disabled state doğru mu?

### Data Fetching
- Loading/Error/Empty state var mı?
- Race condition riski var mı?

## Adım 4: 🔴 FRONTEND GÜVENLİK TARAMASI

### XSS Kontrolü
```
grep("innerHTML|dangerouslySetInnerHTML|v-html|document\\.write", "src/**" veya "public/**")
```
**Her innerHTML kullanımı için:**
1. Veri nereden geliyor? (API response, user input, URL param)
2. `escapeHtml()` veya `textContent` kullanılmış mı?
3. **Her çağrıyı tek tek kontrol et** — fonksiyon var ama uygulanmamış olabilir!

### External Script / SRI
```
grep("<script src=", "public/**" veya "src/**")
```
**Her external script için:**
1. `integrity` attribute var mı?
2. `crossorigin="anonymous"` var mı?
3. Integrity hash gerçek mi? (FAKEHASH, placeholder kontrolü)

### CSRF Kontrolü
```
grep("csrf|_token|xsrf", "src/**" veya "public/**")
```
- State-changing request'ler (POST, PUT, DELETE) token içeriyor mu?
- SameSite cookie var mı?

### Frontend-API Entegrasyon
1. Frontend'deki tüm `fetch()` URL'lerini listele
2. Backend'de karşılığı olan endpoint'leri kontrol et
3. **Backend response formatı değiştiyse** frontend'in buna uyum sağladığını doğrula
4. Backend artık bir alan döndürmüyorsa, frontend'de o alanı kullanan kod var mı?

## Adım 5: Rapor Yaz

```markdown
# 🎨 Frontend Audit Raporu
- **Tarih:**
- **Toplam Sayfa:**
- **Toplam Bulgu:**

## Frontend Güvenlik Bulguları
| # | Tip | Dosya | Satır | Sorun | Severity |
|---|-----|-------|:-----:|-------|:--------:|

## XSS Analizi
| # | Dosya | innerHTML satırı | escapeHtml Uygulandı mı? | Risk |
|---|-------|:----------------:|:------------------------:|:----:|

## Frontend-API Uyumluluk
| # | Frontend Endpoint | Backend Durumu | Uyumlu mu? |
|---|------------------|:--------------:|:----------:|

## Form / UX Bulguları
| # | Element | Sorun | Severity |
```

## Adım 6: Handoff Güncelle
```markdown
## Frontend Audit - TAMAMLANDI
- **XSS riski:** X yerde innerHTML escape edilmemiş
- **SRI eksik:** X external script'te integrity yok
- **API uyumsuzluğu:** X endpoint'te mismatch var
- **Sonraki Ajan İçin Öneri:** Frontend fix'e geç
```
