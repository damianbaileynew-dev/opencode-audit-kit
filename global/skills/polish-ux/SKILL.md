---
name: polish-ux
description: >-
  UX polish skill. UX critic'ten gelen düşük riskli iyileştirmeleri uygular.
  Trigger: "polish ux", "ux polish", "ux iyileştir", "ux düzelt"
---

# Skill: UX Polish

**Amaç:** Düşük riskli, yüksek etkili UX iyileştirmelerini hayata geçirmek.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- Spacing/boşluk düzeltmeleri
- Font boyutu/kalınlık ayarları
- Renk kontrast düzeltmeleri
- Eksik aria-label ekleme
- Placeholder text düzeltmeleri
- Loading state ekleme (spinner)
- Empty state mesajı ekleme
- Error state mesajı ekleme

### ❌ Onay Gerekli
- Sayfa düzeni değiştirme
- Navigation yapısını değiştirme
- Yeni component ekleme

---

## Adım 1: UX Critique Raporunu Oku

```
read("reports/ux/ux-critique-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: İyileştirmeleri Önceliklendir

- **Hemen:** Spacing, font, color, aria-label
- **Planla:** Loading/empty/error state
- **Sonra:** Büyük değişiklikler

## Adım 3: Uygula

Her iyileştirme için:
1. `read()` ile dosyayı oku
2. `edit()` ile düzelt
3. Başka dosyaları etkilemediğini kontrol et

## Adım 4: Rapor Yaz

`reports/ux/ux-polish-YYYYMMDD.md`:

```markdown
# ✨ UX Polish Raporu
- **Toplam İyileştirme:**
- **Uygulanan:**

## Uygulanan İyileştirmeler
| # | Dosya | Değişiklik | Önceki | Sonraki |

## Onay Bekleyenler
| # | Değişiklik | Risk | Neden |
```

## Adım 5: Handoff Güncelle

```markdown
## UX Polish - TAMAMLANDI
- **Uygulanan İyileştirmeler:**
- **Sonraki Ajan İçin Öneri:** Innovation agent'e geç
```
