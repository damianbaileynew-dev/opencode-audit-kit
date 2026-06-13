---
name: suggest-innovation
description: >-
  Innovation skill. Rakiplerden farklılaştıracak yenilik önerileri üretir.
  Trigger: "innovation", "yenilik", "rakip analizi", "öneri", "fark yarat"
---

# Skill: Innovation Agent

**Amaç:** Projeye özel, uygulanabilir yenilikler önermek.

---

## Adım 1: Tüm Raporları Oku

```
read("reports/_state/handoff.md")
read("reports/frontend/frontend-audit-*.md")
read("reports/backend/backend-audit-*.md")
read("reports/ux/ux-critique-*.md")
```

## Adım 2: Proje Özelliklerini Çıkar

- Hedef kitle kim?
- Çözdüğü problem ne?
- Mevcut özellikler neler?
- Hangi teknoloji/platform?

## Adım 3: Rakip Analizi

```
websearch("benzer ürünler: [proje konusu]")
websearch("[sektör] best practices 2025")
websearch("[proje konusu] yeni özellikler trend")
```

Her rakip için:
- Ortak özellikler
- Fark yaratan özellikler
- Eksik kaldığı alanlar

## Adım 4: Önerileri Üret

Her öneri için:
- **Problem:** Hangi kullanıcı sorununu çözüyor?
- **Çözüm:** Nasıl uygulanacak?
- **Fark:** Rakiplerden ne farkı var?
- **Karmaşıklık:** Düşük/Orta/Yüksek
- **MVP:** Minimum uygulanabilir versiyon

### Kategoriler:
- 🚀 **Quick Wins** (1-3 gün)
- 💡 **Medium Impact** (1-2 hafta)
- 🔮 **Moonshots** (1+ ay)

## Adım 5: Rapor Yaz

`reports/innovation/innovation-YYYYMMDD.md`:

```markdown
# 💡 Innovation Önerileri
- **Tarih:**

## 🚀 Quick Wins (1-3 gün)
| # | Özellik | Problem | Çözüm | Fark | Karmaşıklık |

## 💡 Medium Impact (1-2 hafta)
...

## 🔮 Moonshots (1+ ay)
...

## Rakip Analizi
| Rakip | Özellikler | Güçlü Yan | Zayıf Yan |
```

## Adım 6: Handoff Güncelle

```markdown
## Innovation - TAMAMLANDI
- **Toplam Öneri:**
- **Quick Win Sayısı:**
- **Sonraki Ajan İçin Öneri:** Final rapor için master orchestrator'a dön
```
