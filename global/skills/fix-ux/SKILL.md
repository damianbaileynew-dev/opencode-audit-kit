---
name: fix-ux
description: >-
  UX fix skill. UX audit'ten gelen güvenli sorunları düzeltir.
  Submit feedback, button functionality, UI state updates, responsive design, visibility issues.
  Trigger: "fix ux", "ux fix", "düzelt ux", "onar ux", "ux iyileştir"
---

# Skill: UX Fix

**Amaç:** UX audit'ten gelen güvenli, düşük riskli kullanıcı deneyimi sorunlarını düzelt.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Submit feedback ekleme** — Loading spinner, success/error mesajı
- **Non-functional button fix** — Kopuk event handler bağlantısı, eksik onClick
- **Login state UI update** — Login sonrası UI'ı güncelleme (logout butonu göster, login linki gizle)
- **Responsive design ekleme** — CSS media queries ile mobil uyumluluk
- **Logout button visibility** — Auth state'ine göre göster/gizle
- **Empty/loading/error state ekleme** — Kullanıcıya durum bildirimi
- **Form feedback** — Submit sonrası "Gönderildi" / "Hata" mesajı
- **Tutarsız UX düzeltme** — Button placement, text tutarlılığı

### ❌ Onay Gerekli
- Tamamen yeni sayfa/akış oluşturma
- State management değiştirme
- Navigation yapısını değiştirme
- Yeni bağımlılık ekleme

---

## Adım 1: Raporları Oku

```
read("reports/ux/ux-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Non-functional button (sepet, login), login state update
- **P1:** Submit feedback, responsive design
- **P2:** Logout visibility, spacing, text tutarlılık

## Adım 3: Fix Şablonları

### Review Submit Feedback
```javascript
// YANLIŞ: Submit sonrası hiçbir feedback yok
async function submitReview() {
  await fetch('/api/products/' + currentProduct + '/reviews', { /* ... */ });
  document.getElementById('review-modal').style.display = 'none';
}

// DOĞRU: Success/error feedback ekle
async function submitReview() {
  const btn = document.getElementById('review-submit');
  btn.disabled = true;
  btn.textContent = 'Gönderiliyor...';
  try {
    const res = await fetch('/api/products/' + currentProduct + '/reviews', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ rating, comment })
    });
    if (!res.ok) throw new Error('Review failed');
    // Success feedback
    showFeedback('Yorumunuz başarıyla gönderildi!', 'success');
    document.getElementById('review-modal').style.display = 'none';
    loadProducts(); // Listeyi yenile
  } catch (err) {
    showFeedback('Yorum gönderilemedi. Tekrar deneyin.', 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Gönder';
  }
}

function showFeedback(message, type) {
  const el = document.createElement('div');
  el.className = 'feedback feedback-' + type;
  el.textContent = message;
  document.body.appendChild(el);
  setTimeout(() => el.remove(), 3000);
}
```

### Cart Button Functional
```javascript
// YANLIŞ: Sepet butonu hiçbir şey yapmıyor
document.getElementById('cart-btn').addEventListener('click', () => {});

// DOĞRU: Sepet işlevselliği ekle
let cart = [];
document.getElementById('cart-btn').addEventListener('click', () => {
  // Sepet panelini aç veya sepet sayfasına yönlendir
  alert('Sepetinizde ' + cart.length + ' ürün var');
});

// Ürün ekleme butonu ekle
function addToCart(productId) {
  cart.push(productId);
  document.getElementById('cart-btn').textContent = 'Sepet (' + cart.length + ')';
}
```

### Login Modal → UI Update
```javascript
// YANLIŞ: Login sonrası UI güncellenmiyor
const res = await fetch('/api/auth/login', { /* ... */ });
document.getElementById('login-modal').style.display = 'none';

// DOĞRU: Login state'ini UI'a yansıt
const res = await fetch('/api/auth/login', { /* ... */ });
const data = await res.json();
document.getElementById('login-modal').style.display = 'none';
// UI'ı güncelle
document.getElementById('logout-btn').style.display = 'inline-block';
document.getElementById('cart-btn').style.display = 'inline-block';
// Kullanıcı adını göster
const userSpan = document.createElement('span');
userSpan.textContent = 'Merhaba, ' + data.user.username;
document.querySelector('.header').appendChild(userSpan);
```

### Responsive Design
```css
/* YANLIŞ: Sadece desktop */
.product-grid { display: grid; grid-template-columns: repeat(3, 1fr); }

/* DOĞRU: Responsive */
.product-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
@media (max-width: 768px) {
  .product-grid { grid-template-columns: repeat(2, 1fr); }
  .header { flex-direction: column; gap: 12px; }
}
@media (max-width: 480px) {
  .product-grid { grid-template-columns: 1fr; }
}
```

### Logout Button Visibility
```javascript
// Sayfa yüklendiğinde auth durumunu kontrol et
async function checkAuth() {
  try {
    const res = await fetch('/api/profile');
    if (res.ok) {
      const data = await res.json();
      document.getElementById('logout-btn').style.display = 'inline-block';
    } else {
      document.getElementById('logout-btn').style.display = 'none';
    }
  } catch {
    document.getElementById('logout-btn').style.display = 'none';
  }
}
checkAuth();

// Logout handler
document.getElementById('logout-btn').addEventListener('click', async () => {
  await fetch('/api/auth/logout', { method: 'POST' });
  document.getElementById('logout-btn').style.display = 'none';
  showFeedback('Çıkış yapıldı', 'success');
});
```

## Adım 4: Fix Uygula

Her fix için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. **Mevcut JS fonksiyonlarını bozmadığını kontrol et**
4. Her fix sonrası dosyayı tekrar oku

### 🚨 ADIM 4.5: UX Doğrulama (ZORUNLU)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap:

```bash
# Loading state var mı?
grep -q "loading\|spinner\|busy" public/index.html || echo "❌ KRİTİK: Loading state YOK — HEMEN ekle!"

# Responsive design var mı?
grep -q "@media" public/index.html || echo "❌ KRİTİK: Responsive design YOK — HEMEN @media query ekle!"

# Empty state var mı?
grep -q "empty\|No tasks\|no-result" public/index.html || echo "❌ KRİTİK: Empty state YOK — HEMEN ekle!"

# Search functionality çalışıyor mu?
grep -q "search\|q=" public/index.html || echo "❌ KRİTİK: Search functionality YOK!"

# Error feedback var mı?
grep -q "error\|feedback\|toast" public/index.html || echo "❌ KRİTİK: Error feedback YOK!"
```

**EĞER loading state YOKSA → HEMEN ekle:**
```html
<div id="loading" class="loading-state" style="display:none;text-align:center;padding:20px;">
  <div class="spinner"></div>
  <p>Loading...</p>
</div>
```
CSS: `.spinner { border: 3px solid #eee; border-top: 3px solid #333; border-radius: 50%; width: 30px; height: 30px; animation: spin 1s linear infinite; margin: 0 auto; } @keyframes spin { to { transform: rotate(360deg); } }`

**EĞER @media query YOKSA → HEMEN ekle:**
```css
@media (max-width: 600px) {
  body { padding: 12px; }
  .task-grid { grid-template-columns: 1fr; }
  .header { flex-direction: column; gap: 12px; }
  .filters { flex-direction: column; }
}
```

## Adım 5: Rapor Yaz

`reports/ux/ux-fix-YYYYMMDD.md`:

```markdown
# 🎨 UX Fix Raporu
- **Toplam Bulgu:**
- **Fixlenen:**

## Uygulanan Fixler
| # | Dosya | Bulgu | Fix | Etki |
|---|-------|-------|-----|------|

## Onay Bekleyenler
| # | Dosya | Sorun | Önerilen Fix | Risk |
|---|-------|-------|-------------|------|
```

## Adım 6: Handoff Güncelle
```markdown
## UX Fix - TAMAMLANDI
- **Fixlenen Sorunlar:**
- **Kalan Sorunlar:**
- **Sonraki Ajan İçin Öneri:** DevOps audit'e geç
```
