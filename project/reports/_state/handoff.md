# 📋 İş Devri (Handoff) Dosyası

> Her ajan çalışmasını bitirdiğinde bu dosyaya bir blok ekler.
> Sonraki ajan bu dosyayı okuyarak önceki adımların sonucunu öğrenir.
> Orchestrator her adımın sonunda bu dosyayı kontrol eder.

---

## Format

```markdown
### Handoff: [Kimden] -> [Kime] | Tarih: YYYY-MM-DD HH:mm

**Yapan Ajan:** [agent adı]
**Kapsam:** [neler yapıldı]
**Tamamlanan İşler:**
- [madde 1]
- [madde 2]

**Ana Bulgular (öncelikli):**
| ID | Başlık | Şiddet | Durum | Dosya(lar) |
|---|---|---:|---|---|

**Dokunulan Dosyalar:**
- [path1]

**Sonraki Ajan için Öneri:**
- Hangi alana yoğunlaşsın?
- Nelere dikkat etsin?

**Onay Bekleyen Konular (Riskli):**
- [konu] -> neden riskli, çözüm önerisi, onay gerekli

**Ek Dosyalar:**
- Rapor: [rapor path]
```

---

## Handoff Girdileri

_(Henüz handoff yok. Audit başladığında ilk handoff buraya eklenir.)_

