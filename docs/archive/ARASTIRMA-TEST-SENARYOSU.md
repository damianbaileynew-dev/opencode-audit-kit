# 🔬 DERİN ARAŞTIRMA: "Ajan Gerçekte Ne Yapabilir?"

> **Tarih:** 2026-06-11  
> **Soru:** Sayfaların testi için senaryo yazılıyor mu? Yazılımın haritası mı çıkarılıyor?
> İlişkiler mi çıkarılıyor? Butona basınca nereye gidiyor? Form doldurunca kayıt ediliyor mu?

---

## 🎌 CEVAP: 3 KATMANLI SİSTEM GEREKLİ

Bizim paketin şu anki hali sadece **Katman 1**'i kapsıyor. Eksik olanlar:

```
Katman 1: KOD OKUMA (statik analiz)          ← Bizde var ✅
Katman 2: YAZILIM HARİTASI ÇIKARMA          ← Bizde YOK ❌
Katman 3: GERÇEK TEST (tarayıcıda çalıştırma) ← Playwright MCP ile kısmen var
Katman 4: DOĞRULAMA (sonuç karşılaştırma)     ← Bizde YOK ❌
```

---

## KATMAN 1: KOD OKUMA (Statik Analiz) ✅ Mevcut

OpenCode'un built-in tool'ları ile yapılabilenler:

### Ne yapar?
```
grep("<button") → Tüm butonları bul
grep("onClick") → Hangilerinin handler'ı var
grep("fetch(") → Hangi API'lere istek gidiyor
read("dosya.tsx") → Dosyanın içeriğini oku
glob("pages/**") → Tüm sayfaları bul
```

### Sınırları ne?
- Kodu OKUR ama ÇALIŞTIRMAZ
- "Bu buton onClick={handleSubmit} diyor" → bilir
- "handleSubmit gerçekten API'ye istek atıyor mu?" → okuyarak tahmin eder
- "API'ye istek gittiğinde response ne dönüyor?" → BİLEMEZ (çalıştırmadan)

---

## KATMAN 2: YAZILIM HARİTASI ÇIKARMA ❌ Eksik

### Sorun: "Tüm ilişkileri nereden bilecek?"

Ajan bir butona bastığında:
1. Hangi fonksiyon çağrılıyor?
2. O fonksiyon hangi API'ye istek atıyor?
3. O API hangi veritabanı tablosuna yazıyor?
4. Başarılı olunca hangi sayfaya yönlendiriyor?

Bu zinciri çıkarmak için **gerçek bir dependency/relationship haritası** gerekir.

### Çözüm Seçenekleri:

#### Seçenek A: LLM ile Kod Okuyarak Harita Çıkarma (Mevcut tool'larla)

Ajan `read` + `grep` + `lsp` kullanarak import zincirini takip eder:

```
1. read("src/pages/TodoPage.tsx")
   → import { addTodo } from '../api/todos'
   
2. read("src/api/todos.ts")
   → export function addTodo(text) {
   →   return fetch('/api/todos', { method: 'POST', body: JSON.stringify({ text }) })
   → }
   
3. read("src/App.tsx") → routes: /todos → TodoPage

SONUÇ HARİTA:
┌──────────┐    import    ┌───────────┐   fetch POST   ┌──────────────┐
│ TodoPage │ ──────────→ │ api/todos │ ─────────────→ │ POST /api/   │
│          │              │           │                │ todos        │
│ "Ekle"   │              │ addTodo() │                │ → DB insert  │
│ butonu   │              │           │                │ → response   │
└──────────┘              └───────────┘                └──────────────┘

Test Senaryosu:
"Ekle" butonuna bas → addTodo() çağrılır → POST /api/todos → response kontrol et
```

**Artı:** Ek kurulum gerektirmez, OpenCode'un built-in tool'larıyla çalışır
**Eksi:** Yavaş, her dosyayı tek tek okuması lazım, büyük projede token tüketir

#### Seçenek B: GitNexus / Depwire / Graphify (Profesyonel, MCP ile)

Bu araçlar kod tabanını **tamamen tarar** ve knowledge graph oluşturur:

| Araç | Ne Yapar | OpenCode Entegrasyonu |
|------|----------|----------------------|
| **GitNexus** (28K⭐) | Repo'yu knowledge graph'a çevirir, MCP server olarak sunar | MCP ile doğrudan entegre |
| **Depwire** | Dependency graph çıkarır, health score verir, MCP server | `depwire mcp ./proje` |
| **Graphify** (63K⭐) | Kod, doc, PDF → queryable knowledge graph, MCP | MCP server olarak çalışır |
| **Understand Anything** (15K⭐) | Interactive knowledge graph dashboard | OpenCode plugin |

**GitNexus ile örnek:**
```bash
# Bir kez çalıştır
npx gitnexus analyze

# Artık ajan şunu sorabilir:
# "addTodo fonksiyonuna bağımlı olan tüm fonksiyonlar hangileri?"
# "POST /api/todos endpoint'ini kullanan tüm sayfalar?"
# "TodoPage'den veritabanına giden tam yol ne?"
```

**Artı:** Çok hızlı, tam harita, tüm ilişkiler bir sorguda
**Eksi:** Kurulum gerekli, ilk analiz zaman alır

---

## KATMAN 3: GERÇEK TEST (Tarayıcıda Çalıştırma) ✅ Playwright MCP ile

### Playwright MCP'nin Tam Tool Listesi (23 Tool)

Bu tool'lar ajanın **gerçek bir tarayıcıda** sayfayı açıp test etmesini sağlar:

#### Keşif Tool'ları
| Tool | Ne Yapar | Test Senaryosundaki Kullanımı |
|------|----------|-------------------------------|
| `browser_navigate` | URL'ye git | `http://localhost:3000/login` aç |
| `browser_snapshot` | Sayfanın accessibility tree'sini al | Sayfadaki tüm butonları, input'ları listele |
| `browser_take_screenshot` | Ekran görüntüsü al | Kanıt olarak kaydet |

#### Etkileşim Tool'ları
| Tool | Ne Yapar | Test Senaryosundaki Kullanımı |
|------|----------|-------------------------------|
| `browser_click` | Elemente tıkla | "Save" butonuna tıkla |
| `browser_type` | Input'a yazı yaz | Email alanına "test@test.com" yaz |
| `browser_fill_form` | Birden fazla alan doldur | Tüm formu tek seferde doldur |
| `browser_select_option` | Dropdown seç | "Türkiye" seç |
| `browser_press_key` | Klavye tuşuna bas | Enter'a bas (form submit) |
| `browser_hover` | Üstüne gel | Tooltip açılsın |
| `browser_drag` | Sürükle-bırak | Sıralama değiştir |

#### Doğrulama Tool'ları
| Tool | Ne Yapar | Test Senaryosundaki Kullanımı |
|------|----------|-------------------------------|
| `browser_network_requests` | Tüm network isteklerini listele | POST /api/login isteği gitti mi? Response ne? |
| `browser_console_messages` | Console log'larını al | Hata var mı? "undefined is not a function"? |
| `browser_evaluate` | JavaScript çalıştır | `document.querySelector('.success-msg')` var mı? |
| `browser_wait_for` | Bir şeyi bekle | "Başarılı" mesajı çıkana kadar bekle |

#### Diğer
| Tool | Ne Yapar |
|------|----------|
| `browser_handle_dialog` | alert/confirm diyalogunu yönet |
| `browser_file_upload` | Dosya yükle |
| `browser_navigate_back` | Geri git |
| `browser_resize` | Ekran boyutu değiştir (responsive test) |
| `browser_tabs` | Sekme yönetimi |
| `browser_close` | Tarayıcıyı kapat |

### ÖRNEK: Tam Bir Test Senaryosu

**Senaryo:** "Login sayfasında email/şifre girip 'Giriş Yap' butonuna bastığında API'ye istek gidiyor mu? Başarılı response dönünce dashboard'a yönlendiriyor mu?"

```
# ADIM 1: Sayfayı aç
→ browser_navigate({ url: "http://localhost:3000/login" })

# ADIM 2: Sayfanın yapısını oku
→ browser_snapshot()
← SONUÇ: 
   - textbox "Email" [ref=e5]
   - textbox "Şifre" [ref=e6]  
   - button "Giriş Yap" [ref=e7]

# ADIM 3: Formu doldur
→ browser_type({ ref: "e5", text: "test@test.com" })
→ browser_type({ ref: "e6", text: "password123" })

# ADIM 4: Network izlemeyi başlat (sessizce)
→ (browser_network_requests otomatik kaydeder)

# ADIM 5: Butona tıkla
→ browser_click({ ref: "e7", element: "Giriş Yap button" })

# ADIM 6: Bekle
→ browser_wait_for({ time: 2000 })

# ADIM 7: Network isteklerini kontrol et
→ browser_network_requests()
← SONUÇ:
   POST http://localhost:3000/api/auth/login → 200 OK
   Body: { email: "test@test.com", password: "password123" }
   Response: { success: true, token: "jwt-xxx" }
   
   ✅ API'YE İSTEK GİTTİ
   ✅ 200 DÖNDÜ
   ✅ TOKEN ALINDI

# ADIM 8: URL değişti mi?
→ browser_snapshot()
← SONUÇ: URL = http://localhost:3000/dashboard
   ✅ DASHBOARD'A YÖNLENDİ

# ADIM 9: Ekran görüntüsü al (kanıt)
→ browser_take_screenshot({ filename: "login-success.png" })

# ADIM 10: Console hataları var mı?
→ browser_console_messages({ level: "error" })
← SONUÇ: Hata yok ✅

# SONUÇ: Login flow'u çalışıyor ✅
```

### ÖRNEK 2: "Filtre butonu gerçekten filtreliyor mu?"

```
# ADIM 1: Todo sayfasını aç
→ browser_navigate({ url: "http://localhost:3000/todos" })

# ADIM 2: Snapshot al
→ browser_snapshot()
← SONUÇ: 3 todo var (Alışveriş ✓, Toplantı, Temizlik)

# ADIM 3: "Aktif" filtresine tıkla
→ browser_click({ ref: "e12", element: "Aktif button" })

# ADIM 4: Snapshot al
→ browser_snapshot()
← SONUÇ: 2 todo var (Toplantı, Temizlik) — Alışveriş kayboldu mu?

# DOĞRULAMA:
Eğer hâlâ 3 todo görünüyorsa → ❌ BULGU: Filtre çalışmıyor!
Eğer 2 todo görünüyorsa → ✅ Filtre çalışıyor

# Kanıt
→ browser_take_screenshot({ filename: "filter-test.png" })
```

### ÖRNEK 3: "Form doldurup save'e basınca gerçekten kayıt ediliyor mu?"

```
# ADIM 1: Profil sayfasını aç
→ browser_navigate({ url: "http://localhost:3000/profile" })

# ADIM 2: Formu doldur
→ browser_fill_form({ fields: [
  { ref: "e3", value: "Ahmet" },
  { ref: "e4", value: "ahmet@test.com" },
  { ref: "e5", value: "05551234567" }
]})

# ADIM 3: Save butonuna tıkla
→ browser_click({ ref: "e6", element: "Kaydet button" })

# ADIM 4: Network isteğini kontrol et
→ browser_network_requests()
← SONUÇ:
   PUT http://localhost:3000/api/profile → 200 OK
   Body: { name: "Ahmet", email: "ahmet@test.com", phone: "05551234567" }
   Response: { success: true }
   
   ✅ API'YE PUT İSTEĞİ GİTTİ
   ✅ 200 DÖNDÜ

# ADIM 5: Sayfayı yenile, veri kalıcı mı?
→ browser_navigate({ url: "http://localhost:3000/profile" })
→ browser_snapshot()
← SONUÇ: Form alanlarında "Ahmet", "ahmet@test.com", "05551234567" görünüyor

   ✅ VERİ KAYIT EDİLMİŞ

# ADIM 6: Console ve network hataları
→ browser_console_messages({ level: "error" })
← SONUÇ: Hata yok ✅

# SONUÇ: Kayıt flow'u çalışıyor ✅
```

---

## KATMAN 4: DOĞRULAMA (Sonuç Karşılaştırma) ❌ Eksik

### "Butona bastığımda ne oldu?" sorusunun tam cevabı için:

```
1. Butona tıklamadan ÖNCE network'ü temizle
2. Butona tıkla
3. Network isteklerini kontrol et:
   - İstek gitti mi? (var mı POST/PUT/DELETE?)
   - Hangi URL'ye?
   - Body ne gönderdi?
   - Response ne döndü? (status code + body)
4. Sayfa değişti mi? (URL kontrolü)
5. DOM'da değişiklik var mı? (snapshot karşılaştırma)
6. Console hatası var mı?
7. Toast/notification çıktı mı?
```

Bu zinciri otomatik yapan bir **test şablonu** ajanlara eklenmeli.

---

## 📊 ÖZET: NE YAPILABİLİR, NE YAPILAMAZ

| Senaryo | Statik Analiz (grep/read) | Playwright MCP | Bash (curl) |
|---------|:-------------------------:|:---------------:|:-----------:|
| Tüm sayfaları bulmak | ✅ | — | — |
| Tüm butonları bulmak | ✅ | ✅ | — |
| Butonun onClick'i var mı? | ✅ | — | — |
| API endpoint'leri bulmak | ✅ | — | ✅ |
| **Butona tıklayıp sonucu görmek** | ❌ | ✅ | — |
| **Form doldurup submit etmek** | ❌ | ✅ | — |
| **API'ye istek gidiyor mu?** | ❌ | ✅ (network) | ✅ (curl) |
| **Response ne döndü?** | ❌ | ✅ (network) | ✅ (curl) |
| **Sayfa yönlendirmesi oldu mu?** | ❌ | ✅ (URL) | — |
| **Veri kayıt edildi mi?** | ❌ | ✅ (yenile+bak) | ✅ (GET) |
| **Console hatası var mı?** | ❌ | ✅ | — |
| **Filtre çalışıyor mu?** | ❌ | ✅ (tıkla+bak) | — |
| **Validation çalışıyor mu?** | ❌ | ✅ (boş gönder) | — |
| **Loading state var mı?** | ⚠️ (kodda var mı) | ✅ (gerçekten görünür mü) | — |
| **Empty state var mı?** | ⚠️ (kodda var mı) | ✅ (veri yokken bak) | — |

---

## 🔧 BİZİM PAKETE EKLENMESİ GEREKENLER

### 1. Test Senaryosu Şablonu (Her İnteraktif Element İçin)

Frontend audit ajanına her interaktif element türü için test senaryosu şablonu eklenmeli:

```
BUTON TEST ŞABLONU:
1. Sayfayı aç (browser_navigate)
2. Snapshot al (browser_snapshot) → butonu bul, ref kaydet
3. Network'ü temizle
4. Butona tıkla (browser_click)
5. Network isteklerini kontrol et → API'ye istek gitti mi?
6. Snapshot al → DOM değişti mi? Yönlendirme oldu mu?
7. Console hatalarını kontrol et
8. Screenshot al (kanıt)

FORM TEST ŞABLONU:
1. Sayfayı aç
2. Snapshot al → tüm input'ları bul
3. Formu doldur (browser_fill_form)
4. Network'ü temizle
5. Submit butonuna tıkla
6. Validation hatası mı gördün? (beklenen vs gerçekleşen)
7. Network isteklerini kontrol et → API'ye istek gitti mi? Body doğru mu?
8. Response'ı kontrol et → 200 mü? Hata mesajı var mı?
9. Sayfa değişti mi? Veri kaydedildi mi?
10. Screenshot al

FİLTRE TEST ŞABLONU:
1. Sayfayı aç
2. Snapshot al → toplam eleman sayısını kaydet
3. Filtre butonuna tıkla
4. Snapshot al → eleman sayısı değişti mi?
5. Beklenen filtreleme sonucuyla karşılaştır
6. Screenshot al
```

### 2. Backend API Test Şablonu (bash/curl ile)

```
API ENDPOINT TEST ŞABLONU:
1. curl -X POST http://localhost:3000/api/todos \
     -H "Content-Type: application/json" \
     -d '{"text": "Test todo"}'
2. Response code kontrol et → 200 mü? 400 mü? 500 mü?
3. Response body kontrol et → JSON formatında mı? Hata mesajı var mı?
4. GET isteği at → kayıt gerçekten oluşmuş mu?
5. DELETE isteği at → siliniyor mu?
6. Edge case'ler → boş body, geçersiz JSON, çok uzun string
```

### 3. Uygulama Haritası Çıkarma Talimatı

Frontend audit ajanına **zorunlu bir adım** olarak eklenmeli:

```
HER SAYFA İÇİN ZORUNLU HARİTA ÇIKARMA:

Sayfa: [sayfa adı]
Route: [URL yolu]

İnteraktif Element Haritası:
| Element | Tür | Handler | API Çağrısı | Beklenen Sonuç |
|---------|-----|---------|-------------|-----------------|
| "Kaydet" butonu | button | handleSubmit | POST /api/todos | 200 + yönlendirme |
| "Sil" butonu | button | handleDelete | DELETE /api/todos/:id | 200 + DOM'dan kaldır |
| Arama input'u | input | handleSearch | GET /api/todos?q= | Sonuç listesi |
| Filtre dropdown | select | handleFilter | — | Client-side filtre |

Veri Akışı:
Kullanıcı → UI Element → Handler → API İsteği → Backend → DB → Response → UI Güncelleme
```

---

## 🎯 SONUÇ

### Şu an bizde ne var:
- ✅ Ajan tanımları ve prompt'lar
- ✅ Rapor şablonları
- ✅ MCP konfigürasyonu (Playwright dahil)
- ✅ Güvenli Fix Sınırları
- ✅ Handoff sistemi

### Eksik olan (eklenmeli):
1. ❌ **Test senaryosu şablonları** — Her element türü için adım adım Playwright test talimatı
2. ❌ **Uygulama haritası çıkarma talimatı** — Her sayfa için element/API/flow haritası
3. ❌ **Doğrulama zinciri** — "İstek gitti mi → Response ne → UI güncellendi mi" kontrol adımları
4. ❌ **Backend API test talimatı** — curl ile endpoint testi şablonu
5. ❌ **Önceki/sonraki snapshot karşılaştırma** — Değişiklik tespiti

### Opsiyonel güçlendirme:
- GitNexus veya Depwire MCP eklenirse → Kod haritası otomatik çıkar, token tasarrufu
