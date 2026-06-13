# 🐛 ITERASYON TEST — BİLİNEN HATA HARİTASI
**Proje:** Next.js 16 + TypeScript Social App
**Tarih:** 2026-06-12
**Toplam Bilinen Hata:** 20
**Dosya:** README olarak KALMAYACAK — bu sadece benim (testi yazanın) referansıdır.

---

## BACKEND GÜVENLİK (10)

| # | Hata | Dosya | Satır | Kategori | Zorluk |
|---|------|-------|:------:|----------|:------:|
| 1 | Hardcoded JWT Secret (`"super-secret-key-12345"`) | `api-handlers.ts` | 10 | Auth | Kolay |
| 2 | bcrypt salt rounds = 8 (zayıf, ≥10 olmalı) | `api-handlers.ts` | 11 | Crypto | Orta |
| 3 | Mass Assignment — `role` alanı doğrudan alınıyor | `api-handlers.ts` | 35 | Auth | Kolay |
| 4 | Cookie httpOnly:false, Secure:false, SameSite:Lax | `api-handlers.ts` | 48 | Cookie | Kolay |
| 5 | JWT expiry 365d (çok uzun, max 7d olmalı) | `api-handlers.ts` | 46 | Auth | Kolay |
| 6 | JWT secret log'a yazılıyor (`console.log`) | `api-handlers.ts` | 51 | Info Leak | Kolay |
| 7 | Kullanılmayan import: `exec` from child_process | `api-handlers.ts` | 9 | Cleanup | Orta |
| 8 | Error mesajında stack trace sızdırma | `api-handlers.ts` | 57-58 | Info Leak | Kolay |
| 9 | Upload path traversal koruması yok | `api-handlers.ts` | 82-84 | File Upload | Orta |
| 10 | CORS wildcard `Access-Control-Allow-Origin: *` | `posts/route.ts` | 15 | CORS | Kolay |

## GİZLİ / SUBTLE BUG'LAR (5)

| # | Hata | Dosya | Satır | Kategori | Zorluk |
|---|------|-------|:------:|----------|:------:|
| 11 | Prototype Pollution — merge() filtre yok | `merge-utils.ts` | 4-13 | Security | **Zor** |
| 12 | getMonth() 0-indexed — +1 eksik | `merge-utils.ts` | 21 | Logic Bug | **Zor** |
| 13 | parseInt() radix parametresi eksik | `merge-utils.ts` | 27 | Logic Bug | Orta |
| 14 | .env dosyası .gitignore'da değil | `.gitignore` | — | Config | Kolay |
| 15 | Helmet / Rate Limiting yok — security headers hiç yok | genel | — | Headers | Orta |

## FRONTEND (5)

| # | Hata | Dosya | Satır | Kategori | Zorluk |
|---|------|-------|:------:|----------|:------:|
| 16 | useEffect cleanup yok — memory leak | `page.tsx` | 14-24 | React | Kolay |
| 17 | Search race condition — AbortController yok | `page.tsx` | 27-31 | React | Orta |
| 18 | XSS — dangerouslySetInnerHTML user content | `page.tsx` | 34 | Security | Kolay |
| 19 | Form validation yok (required, minLength) | `page.tsx` | 40-53 | UX | Kolay |
| 20 | htmlFor eksik — accessibility (label-select) | `page.tsx` | 56-62 | A11y | Kolay |

---

## SKOR HEDEFİ

| Kategori | Toplam | Hedeflenen Bulgu Oranı |
|----------|:------:|:----------------------:|
| Backend Güvenlik | 10 | 100% |
| Gizli Bug'lar | 5 | ≥80% |
| Frontend | 5 | 100% |
| **TOPLAM** | **20** | **≥90% (18/20)** |

## HATA BAŞARISIZLIK ANALİZİ İÇİN METRIKLER

- **Recall** = (Bulunan Hatalar) / 20
- **Precision** = (Doğru Bulunan) / (Toplam Bildirilen)
- **Fix Rate** = (Başarıyla Fixlenen) / (Bulunan)
- **False Fix** = (Yanlış Fixlenen) / (Toplam Fixlenen)

## ÖNCELİK SINIFLAMASI

- **P0 (Hemen):** #1, #3, #6, #8, #9, #11, #14, #18
- **P1 (Planla):** #2, #4, #5, #10, #13, #15
- **P2 (Sonra):** #7, #12, #16, #17, #19, #20
