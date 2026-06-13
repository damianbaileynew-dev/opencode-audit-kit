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

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "innerHTML is fine — we control the data" | You don't control the data. User input, API responses, and third-party data can contain XSS payloads. Use textContent. |
| "SRI isn't needed for CDN scripts" | CDN scripts can be compromised. SRI ensures the script hasn't been tampered with. It's one attribute. |
| "Backend already validates — frontend doesn't need to" | Frontend validation is for UX (instant feedback), not security. Both are needed for different reasons. |
| "The frontend is just a thin client" | Thin clients still have XSS risk, broken states, and missing error handling. Every user-facing surface needs care. |
| "We'll fix the frontend after the backend is stable" | Frontend bugs affect users right now. Backend stability doesn't excuse broken UI. |

## Red Flags

- 🔴 innerHTML with user-controlled data (XSS vector)
- 🔴 External scripts without SRI (integrity attribute)
- 🔴 No error handling in fetch calls
- 🔴 No loading states during async operations
- 🔴 Form submissions without client-side validation
- 🔴 Backend response format changes not reflected in frontend
- 🔴 Broken navigation links or non-functional buttons
