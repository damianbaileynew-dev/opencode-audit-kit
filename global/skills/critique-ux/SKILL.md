---
name: critique-ux
description: >-
  UX eleştiri skill. Kullanıcı yolculuklarını haritalar, sürtünme noktalarını tespit eder.
  Trigger: "ux audit", "ux critic", "user experience", "kullanıcı deneyimi", "sürtünme", "ux tarama"
---

# Skill: UX Critic

**Amaç:** Ürünün kullanım ahengini, sadeliğini ve kolaylığını eleştir.
**Kısıtlar:** Sadece oku ve raporla, dosya değiştirme.

---

## Adım 1: Kullanıcı Yolculuk Haritası

Her ana kullanıcı yolculuğunu map'le:
```
Giriş → Ana Sayfa → [Aksiyon] → Sonuç → [Sonraki Aksiyon]
```

Her yolculuk için:
- Hedef açık mı?
- Adım sayısı minimum mu?
- Her adımda kullanıcı ne yapacağını biliyor mu?
- Geri bildirim yeterli mi?

## Adım 2: Sürtünme Noktaları

### Cognitive Load
- Ekranda çok fazla bilgi var mı?
- Terminoloji tutarlı mı?
- İkonlar anlaşılır mı?

### Interaction Friction
- Çok fazla tıklama gerektiren işler var mı?
- Form alanları mantıklı sırada mı?
- Default değerler kullanılmış mı?

### Visual Hierarchy
- CTA net mi?
- Renk kontrastı yeterli mi?
- Boşluk doğru kullanılmış mı?

### Error Handling UX
- Hata mesajları anlaşılır mı?
- Inline validation var mı?
- Form submit sonrası net feedback var mı?

## Adım 3: Nielsen's Heuristics (10 Madde)

1. System status visibility
2. System-world match
3. User control & freedom
4. Consistency & standards
5. Error prevention
6. Recognition over recall
7. Flexibility & efficiency
8. Aesthetic & minimalist design
9. Error recovery
10. Help & documentation

Her madde için 1-5 puan ver.

## Adım 4: Rapor Yaz

`reports/ux/ux-critique-YYYYMMDD.md`:

```markdown
# 🎭 UX Critique Raporu
- **Tarih:**

## Kullanıcı Yolculukları
### Yolculuk 1: [Adı]
| Adım | Sürtünme | Açıklama |

## Sürtünme Noktaları
| # | Sayfa | Element | Sorun | Severity | Öneri |

## Nielsen Heuristics
| # | Heuristic | Puan (1-5) | Açıklama |

## Öncelikli İyileştirmeler
```

## Adım 5: Handoff Güncelle

```markdown
## UX Critic - TAMAMLANDI
- **Toplam Sürtünme Noktası:**
- **Yüksek Öncelikliler:**
- **Sonraki Ajan İçin Öneri:** UX polish'e geç
```
