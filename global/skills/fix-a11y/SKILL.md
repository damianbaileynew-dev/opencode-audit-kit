---
name: fix-a11y
description: >-
  Accessibility fix skill. Accessibility audit'ten gelen güvenli sorunları düzeltir.
  Label-input binding, keyboard navigation, alt text, ARIA roles, focus management.
  Trigger: "fix accessibility", "a11y fix", "düzelt erişilebilirlik", "onar a11y"
---

# Skill: Accessibility Fix

**Amaç:** WCAG 2.2 accessibility audit'ten gelen güvenli sorunları düzelt.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Label-input binding** — `<label for="id">` + `<input id="id">` eşleştirme
- **Placeholder image alt text** — `alt=""` → anlamlı açıklama
- **Select dropdown labels** — Her `<select>` için `<label>` ekleme
- **ARIA live regions** — Dinamik içerik değişimlerini duyurma
- **Keyboard dismissable modals** — ESC ile modal kapama
- **Focus management** — Modal açılınca focus'u ilk elemente taşıma
- **Skip link ekleme** — "Skip to main content" linki
- **Semantic HTML** — `<div>` → `<nav>`, `<main>`, `<section>`, `<article>`
- **Lang attribute** — `<html>` elementine `lang` ekleme
- **Color contrast** — Yetersiz kontrastı düzeltme
- **Focus visible** — `:focus-visible` outline ekleme

### ❌ Onay Gerekli
- Tamamen yeni component oluşturma
- Screen reader test ortamı kurma
- Complex ARIA widget (tabs, tree, grid) ekleme
- Tasarım değişikliği gerektiren kontrast düzeltmeleri

---

## Adım 1: Raporları Oku

```
read("reports/accessibility/a11y-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Label-input bağlantısı eksik, modal klavye erişilebilir değil
- **P1:** Alt text eksik, ARIA live region eksik, select labels
- **P2:** Semantic HTML, skip link, focus visible

## Adım 3: Fix Şablonları

### Label-Input Binding
```html
<!-- YANLIŞ: Label ve input bağlantısız -->
<div>
  Email: <input type="email" id="login-email" />
  Şifre: <input type="password" id="login-password" />
</div>

<!-- DOĞRU: Label htmlFor ile input id eşleşmeli -->
<div>
  <label for="login-email">Email:</label>
  <input type="email" id="login-email" />
  <label for="login-password">Şifre:</label>
  <input type="password" id="login-password" />
</div>
```

### Keyboard Dismissable Modal
```html
<!-- YANLIŞ: Modal sadece X butonu ile kapanır -->
<div id="login-modal" class="modal">...</div>

<!-- DOĞRU: ESC tuşu ile de kapansın -->
<script>
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    document.querySelectorAll('.modal').forEach(m => m.style.display = 'none');
  }
});
</script>
```

### Alt Text Düzeltme
```html
<!-- YANLIŞ: Placeholder görseli için boş alt -->
<img src="/img/placeholder.png" alt="" />

<!-- DOĞRU: Anlamlı alt text -->
<img src="/img/placeholder.png" alt="Ürün görseli" />
<!-- VEYA gerçekten dekoratifse: -->
<img src="/img/placeholder.png" alt="" role="presentation" />
```

### Select Dropdown Labels
```html
<!-- YANLIŞ: Label yok -->
<select id="category-filter">
  <option value="">Tüm Kategoriler</option>
</select>

<!-- DOĞRU: Label ekle -->
<label for="category-filter" class="sr-only">Kategori Filtrele</label>
<select id="category-filter">
  <option value="">Tüm Kategoriler</option>
</select>
```

### ARIA Live Region
```html
<!-- YANLIŞ: Dinamik içerik değişimi duyurulmuyor -->
<div id="products" class="product-grid"></div>

<!-- DOĞRU: Değişiklikleri duyur -->
<div id="products-status" class="sr-only" aria-live="polite" aria-atomic="true"></div>
<div id="products" class="product-grid"></div>

<!-- JS'te güncelle: -->
document.getElementById('products-status').textContent = `${data.products.length} ürün yüklendi`;
```

### Focus Management (Modal)
```javascript
// Modal açılınca focus'u ilk input'a taşı
function openModal(modalId) {
  const modal = document.getElementById(modalId);
  modal.style.display = 'block';
  const firstInput = modal.querySelector('input, button, textarea, select');
  if (firstInput) firstInput.focus();
}

// Modal kapanınca focus'u geri taşı
function closeModal(modalId, triggerElementId) {
  document.getElementById(modalId).style.display = 'none';
  document.getElementById(triggerElementId)?.focus();
}
```

### Skip Link
```html
<!-- Body'nin en başına ekle -->
<a href="#main-content" class="skip-link">Ana içeriğe geç</a>
<!-- ... -->
<main id="main-content">...</main>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px 16px;
  z-index: 100;
  transition: top 0.2s;
}
.skip-link:focus { top: 0; }
</style>
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. **Komşu HTML/JS bozulmadığını kontrol et**
4. Her fix sonrası dosyayı tekrar oku

## Adım 5: Rapor Yaz

`reports/accessibility/a11y-fix-YYYYMMDD.md`:

```markdown
# ♿ Accessibility Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | WCAG Kriteri |
|---|-------|-------|-----|:------------:|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## A11y Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **WCAG Compliance:** X/A düzeltildi
- **Sonraki Ajan İçin Öneri:** UX audit'e geç
```

## Reference Files

For detailed checklists, see:
- **Accessibility Checklist**: `references/accessibility-checklist.md` — WCAG 2.1 AA criteria, screen reader testing, ARIA patterns

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "We don't have blind users" | You don't know who your users are. Accessibility also helps: motor-impaired users, situational impairments (bright sun, noisy room), SEO, and legal compliance. |
| "ARIA is too complex" | Most accessibility is just good HTML: labels, headings, alt text. ARIA is for custom widgets, not basic forms. |
| "Screen readers will figure it out" | They won't. Without proper labels, roles, and structure, screen readers announce gibberish. |
| "Alt text isn't important for decorative images" | Decorative images should have `alt=""` or `role="presentation"`. Missing alt makes screen readers announce the filename. |
| "Keyboard navigation is a nice-to-have" | Keyboard navigation is required by WCAG 2.1 AA. It also helps power users and is a legal requirement in many jurisdictions. |
| "We'll fix accessibility after launch" | Accessibility retrofitting costs 10x more than building it in from the start. Fix it now. |

## Red Flags

- 🔴 Form inputs without associated labels
- 🔴 Images without alt text
- 🔴 Modals that can't be closed with ESC key
- 🔴 No skip-to-content link
- 🔴 Missing `lang` attribute on `<html>`
- 🔴 Low color contrast ratios
- 🔴 Interactive elements not reachable via keyboard
- 🔴 Dynamic content changes not announced to screen readers
