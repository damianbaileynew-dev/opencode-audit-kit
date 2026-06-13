---
name: fix-frontend
description: >-
  Frontend fix skill. Frontend audit'ten gelen güvenli sorunları düzeltir.
  XSS fix, SRI fix, frontend-backend regresyon kontrolleri dahil.
  Trigger: "fix frontend", "frontend fix", "düzelt frontend", "onar frontend"
---

# Skill: Frontend Fix

**Amaç:** Frontend audit'ten gelen güvenli sorunları düzelt.
**Artı:** Backend fix sonrası frontend regresyon kontrolleri yap.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- Kopuk handler bağını düzeltme
- Eksik error/loading/empty state ekleme
- Form validasyonu düzeltme
- Navigation linklerini düzeltme
- Tutarsız isimlendirme düzeltme
- Eksik aria-label / htmlFor ekleme
- **XSS fix:** innerHTML → escapeHtml() veya textContent
- **SRI fix:** External script integrity ekleme
- **API uyum:** Backend değişikliklerine frontend'i uyarlama

### ❌ Onay Gerekli
- Büyük refactor
- Yeni bağımlılık ekleme
- State management değiştirme

---

## Adım 1: Raporları Oku

```
read("reports/frontend/frontend-audit-*-summary.md")
read("reports/backend/backend-fix-*.md")  ← Backend'in neyi değiştirdiğini anla
read("reports/_state/handoff.md")
```

## Adım 2: Backend-Frontend Regresyon Kontrolü

Backend fix sonrası frontend kırılabilir! Şunları kontrol et:

| Senaryo | Ne Yapmalı |
|---------|-----------|
| Backend response format değişti | Frontend'deki `data.field` parse kodunu güncelle |
| Backend endpoint kaldırıldı | Frontend'deki fetch URL'ini güncelle |
| Backend artık alan gizliyor | Frontend'de null/undefined check ekle |
| Backend cookie değiştirdi | Frontend auth mekanizmasını güncelle |
| Backend token artık response'da yok | Frontend flow'u güncelle (örn: forgot password) |

## Adım 3: Önceliklendir

- **P0:** XSS, kırık auth flow, kopuk handler
- **P1:** SRI eksik, error/loading state, form validation
- **P2:** UX iyileştirmeleri, accessibility

## Adım 4: XSS Fix Şablonları

```javascript
// Her innerHTML kullanımında escapeHtml UYGULA:
element.innerHTML = '<p>' + escapeHtml(data.name) + '</p>';
// veya EN İYİSİ:
element.textContent = data.name;
```

## Adım 5: Rapor Yaz

```markdown
# 🔧 Frontend Fix Raporu
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | Severity |
|---|-------|-------|-----|:--------:|

## Backend-Frontend Regresyon
| # | Backend Değişikliği | Frontend Etkisi | Düzeltildi mi? |
|---|---------------------|----------------|:--------------:|
```

## Adım 6: Handoff Güncelle
```markdown
## Frontend Fix - TAMAMLANDI
- **XSS fixlenen:** X yer
- **SRI fixlenen:** X script
- **Regresyon fixlenen:** X uyumsuzluk
- **Sonraki Ajan İçin Öneri:** Backend audit'e geç
```
