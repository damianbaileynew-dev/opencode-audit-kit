---
name: impeccable-audit
description: "Premium UI Design Audit: 5 boyutlu (accessibility, performance, theming, responsive, anti-patterns) tasarım denetimi. P0-P3 severity scoring, AI slop tespiti, yeniden denetim desteği."
model: opencode/deepseek-v4-flash-free
tools:
  read: true
  glob: true
  grep: true
  bash: true
  write: true
  edit: true
  todowrite: true
  todoread: true
  websearch: true
  webfetch: true
  question: true
permission:
  bash: allow
  edit: allow
  write: allow
  read: allow
---

# 🎨 Skill: Impeccable Design Audit

**Kaynak:** pbakaus/impeccable — Premium UI Design Expertise
**Komutlar:** /impeccable audit, /impeccable polish, /impeccable critique, /impeccable distill
**Boyutlar:** Accessibility, Performance, Theming, Responsive, Anti-Patterns
**CLI:** `npx impeccable detect src/`

---

## 🎯 5 Boyutlu Audit

### Boyut 1: Accessibility (Erişilebilirlik)
- [ ] Heading hiyerarşisi doğru mu? (h1→h2→h3, atlamadan)
- [ ] Touch target boyutu minimum 44x44px mi?
- [ ] Renk kontrastı WCAG AA standardında mı? (4.5:1 normal, 3:1 büyük)
- [ ] Form label'ları mevcut ve doğru mu?
- [ ] Alt text mevcut mi?
- [ ] Focus visible durumları tanımlı mı?
- [ ] ARIA attribute'ları doğru kullanılmış mı?
- [ ] Klavye navigasyonu mümkün mü?
- [ ] Screen reader uyumlu mu?

### Boyut 2: Performance (Performans)
- [ ] Büyük resimler optimize edildi mi? (WebP/AVIF, lazy loading)
- [ ] CSS kritik yol kritize edildi mi?
- [ ] JavaScript bundle boyutu makul mü? (<200KB first load)
- [ ] Font loading stratejisi var mı? (swap, optional)
- [ ] Layout shift'ler minimize edildi mi? (CLS < 0.1)
- [ ] Animation'larda GPU-accelerated properties kullanılmış mı?
- [ ] Dead code elimine edildi mi?

### Boyut 3: Theming (Tema Sistemi)
- [ ] Tasarım token'ları tanımlı mı? (renk, spacing, typography)
- [ ] Dark mode desteği var mı?
- [ ] CSS custom property'ler kullanılmış mı?
- [ ] Tema tutarlı mı? (aynı renk aynı amaç için)
- [ ] Sıfırdan tema oluşturulabilir mi?

### Boyut 4: Responsive (Duyarlılık)
- [ ] Mobile-first yaklaşım kullanılmış mı?
- [ ] Breakpoint'ler mantıklı mı? (320, 768, 1024, 1440)
- [ ] Container query'ler kullanılmış mı?
- [ ] Touch ve mouse input'ları ayrılmış mı?
- [ ] Landscape/orientation değişimi handle ediliyor mu?
- [ ] Viewport meta tag doğru mu?

### Boyut 5: Anti-Patterns (Tasarım Hataları)
- [ ] **AI Slop tespiti:**
  - Side-tab borders (yanlardan kesilmiş kenarlıklar)
  - Purple gradient泛滥 (mor gradyan aşırı kullanımı)
  - Bounce/elastic easing (eski tarihli animasyonlar)
  - Dark glows (karanlık parlamalar)
  - Over-nested cards (iç içe kart yığını)
- [ ] **Genel hatalar:**
  - Satır uzunluğu >80 karakter (okuma zorluğu)
  - Sıkıştırılmış padding (nefes almayan tasarım)
  - Küçük touch target'lar (<44px)
  - Atlanan heading seviyeleri
  - Gri metin renkli arka plan üzerinde
  - Saf siyah/beyaz kullanımı (renk tonlaması olmadan)
  - Arial/Inter/system font varsayılanı (karaktersiz)
  - Overused gradient paternleri

---

## 📊 Severity Scoring

| Seviye | Etiket | Açıklama |
|:------:|--------|----------|
| P0 | 🔴 Blocker | Erişilebilirlik engeli, tamamen kırık UX |
| P1 | 🟠 Kritik | Ciddi kullanılabilirlik sorunu, dönüş düşürür |
| P2 | 🟡 Uyarı | Tutarsızlık veya küçük UX sorunu |
| P3 | 🟢 Öneri | İyileştirme önerisi, çözümde tercih |

---

## 🚫 Yapılmaması Gerekenler (Design Laws)

1. **Don't use overused fonts** — Arial, Inter, system defaults yerine karakterli fontlar seç
2. **Don't use gray text on colored backgrounds** — Kontrastı renk tonlaması ile sağla
3. **Don't use pure black/gray** — Her zaman bir renk tonu ekle (#1a1a2e gibi)
4. **Don't wrap everything in cards** — Her şeyi kart içine sarmak visual noise yaratır
5. **Don't use dated bounce/elastic easing** — ease-out veya spring kullan
6. **Don't center long text** — 6+ kelimeli metinleri sola hizala
7. **Don't use tiny touch targets** — Minimum 44x44px
8. **Don't skip heading levels** — h1→h3 atlama yok
9. **Don't use placeholder as label** — Her form alanında görünür label olsun
10. **Don't over-animate** — Her etkileşim animasyon gerekmez

---

## Skor Sistemi

Her boyut 0-100 puan arasında değerlendirilir:

```
Score = (passed_checks / total_checks) * 100

A+ : 95-100  → Üstün
A  : 85-94   → Mükemmel  
B+ : 75-84   → İyi
B  : 65-74   → Kabul edilebilir
C  : 50-64   → Geliştirilebilir
D  : 25-49   → Zayıf
F  : 0-24    → Başarısız
```

---

## Çalışma Akışı

### Adım 1: Hedef Belirle
```
# Belirli bir dosya/dizin
/impeccable-audit src/components/LoginForm.jsx

# Tüm proje
/impeccable-audit

# CLI ile tarama
npx impeccable detect src/
```

### Adım 2: Kaynak Kod Analizi
1. Hedef dosyaları oku
2. CSS/HTML/JSX yapısını çıkar
3. Component hiyerarşisini haritala
4. Responsive breakpoint'leri tespit et

### Adım 3: Her Boyutu Puanla
Her boyut için kontrol listesini doldur:
- ✅ Geçti → puan ekle
- ❌ Başarısız → sorun kaydı oluştur
- ⚠️ Kısmen → yarım puan

### Adım 4: Playwright ile Görsel Doğrulama (opsiyonel)
```
browser_navigate(url)
browser_take_screenshot()
browser_resize(width: 375, height: 812)  # Mobile
browser_take_screenshot()
browser_resize(width: 1440, height: 900)  # Desktop
browser_take_screenshot()
```

### Adım 5: Rapor Oluştur

```markdown
# 🎨 Impeccable Design Audit Raporu

## Genel Puan
| Boyut | Puan | Seviye |
|-------|:----:|:------:|
| Accessibility | /100 | |
| Performance | /100 | |
| Theming | /100 | |
| Responsive | /100 | |
| Anti-Patterns | /100 | |
| **ORTALAMA** | **/100** | |

## 🔴 P0 Blocker'lar
1. ...

## 🟠 P1 Kritikler
1. ...

## 🟡 P2 Uyarılar
1. ...

## 🟢 P3 Öneriler
1. ...

## Dosya Bazlı Puanlar
| Dosya | Access. | Perf. | Theme | Resp. | Anti-P | Ort. |
|-------|:-------:|:-----:|:-----:|:-----:|:------:|:----:|

## Önerilen İyileştirmeler (Öncelik Sırasıyla)
1. ...
```

### Adım 6: Re-Audit (Opsiyonel)
Fix'ler uygulandıktan sonra tekrar denetle ve skor değişimini raporla:
```markdown
## Skor Değişimi
| Boyut | Önceki | Yeni | Değişim |
|-------|:------:|:----:|:-------:|
| Accessibility | 45 | 82 | +37 🎉 |
```

---

## Başla
1. Hedef dosyaları/dizinleri belirle
2. Kaynak kod analizini yap
3. Her 5 boyutu puanla
4. Raporu `reports/ux/impeccable-audit-*.md` dosyasına yaz
