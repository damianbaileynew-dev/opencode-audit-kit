# 🔬 Araştırma Raporu: OpenCode Audit Kit Gerçekten Nasıl Çalışır?

> **Tarih:** 2026-06-11  
> **Soru:** "OpenCode'a MCP/plugin ekleyip çalıştırdığında tüm kodları tarayacak, frontend testi için senaryo yazacak bir sistem var mı? Sayfalardaki işleyişi, API yollarını, flow'u nereden bilecek de test edecek?"

---

## 📌 KISA CEVAP

**Evet, var. Ama sihirli değil — katmanlı bir sistem.** İşte gerçekte olan:

1. **OpenCode'un built-in tool'ları** (grep, glob, read, bash, LSP) kod tarama için **zaten yeterli**
2. **Playwright MCP** tarayıcı testi için eklenmeli (bir komutla)
3. **Ajanlarımız bu tool'ları kullanarak** projeyi keşfeder, test senaryoları yazar ve çalıştırır
4. **Flow'u "bilmesi" için** kod okur — route dosyalarını, import zincirlerini, API çağrılarını takip eder

---

## 1. OPENCODE'UN BUILT-IN TOOL'LARI (Zaten Var, Eklemeye Gerek Yok)

OpenCode'un **varsayılan olarak** gelen tool'ları:

| Tool | Ne Yapar | Audit'de Kullanımı |
|------|----------|-------------------|
| **`grep`** | Dosya içeriğinde regex arama (ripgrep) | `onClick` olan/olmayan butonları bul, TODO/FIXME tara |
| **`glob`** | Dosya ismi pattern arama | Tüm `*.jsx`, `*.tsx`, `*.py` dosyaları listele |
| **`read`** | Dosya okuma | Her sayfa/component dosyasını oku ve analiz et |
| **`list`** | Dizin listeleme | Proje klasör yapısını keşfet |
| **`bash`** | Shell komut çalıştırma | Dev server başlat, test çalıştır, `git log` vs. |
| **`edit`** | Dosya düzenleme | Fix'leri uygula |
| **`write`** | Dosya oluşturma | Rapor yaz, test dosyası oluştur |

### LSP (Deneysel — Açılması Gerekli)

| Tool | Ne Yapar | Audit'de Kullanımı |
|------|----------|-------------------|
| **`lsp`** | IDE seviyesinde kod analizi | goToDefinition: fonksiyon nerede tanımlı? |
| `lsp` | | findReferences: bu fonksiyon nerelerde çağrılıyor? |
| `lsp` | | diagnostics: compile hatası var mı? |
| `lsp` | | documentSymbol: dosyadaki tüm fonksiyon/class'ları listele |

**Açmak için:**
```json
// ~/.config/opencode/opencode.json
{
  "permission": { "lsp": "allow" }
}
```
Ve environment variable:
```bash
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
```

### Web Search (Koşullu)

| Tool | Ne Yapar |
|------|----------|
| **`websearch`** | Exa AI ile web arama (OpenCode provider veya OPENCODE_ENABLE_EXA=true gerekli) |
| **`webfetch`** | URL'den içerik çekme |

---

## 2. MCP SERVER'LAR (Eklenmeli — Tek Komutla)

### 🔥 Playwright MCP (EN KRİTİK — Tarayıcı Testi İçin)

**Bu olmadan dinamik test yapılamaz.** Bu, ajanın gerçek tarayıcıda sayfa açıp tıklayabilmesini sağlar.

**Kurulum:**
```bash
# Tek komut:
opencode mcp add playwright -- npx @playwright/mcp@latest
```

Veya manuel config:
```json
// ~/.config/opencode/opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest"],
      "enabled": true
    }
  }
}
```

**Playwright MCP ne yapabilir:**
- Sayfa açma: `http://localhost:3000`
- Element bulma ve tıklama (buton, link, input)
- Form doldurma (input'lara yazı yazma)
- Sayfa içeriğini okuma (DOM snapshot)
- Screenshot alma
- Bekleme (network idle, element görünür olana kadar)
- Assertion (metin var mı, element var mı)

**Örnek — Ajan şunu yapabilir:**
```
1. playwright: browser_navigate → http://localhost:3000
2. playwright: browser_snapshot → Sayfadaki tüm butonları gör
3. playwright: browser_click → "Save" butonuna tıkla
4. playwright: browser_snapshot → Sonucu kontrol et
5. playwright: browser_take_screenshot → Kanıt olarak kaydet
```

### Context7 MCP (Kütüphane Dökümantasyonu)

```bash
opencode mcp add context7 -- npx -y @upstash/context7-mcp
```

React, Vue, Next.js vs. için güncel API dökümantasyonu sağlar.

### GitHub MCP (Opsiyonel — Repo Geçmişi)

```bash
opencode mcp add github -- npx -y @modelcontextprotocol/server-github
```

Commit geçmişi, PR'lar, issue'lar için.

---

## 3. AJAN PROJENİN FLOW'UNU NASIL ANLAR?

İşte senin sorduğun kritik sorunun cevabı. Ajan sihirli olarak bilmez — **kod okuyarak keşfeder:**

### Adım 1: Proje Keşfi (Repo Keşfi)

```
Ajan şunları yapar:
├── glob("**/package.json") → Framework'ü anla
├── read("package.json") → Script'leri oku (npm run dev vs.)
├── glob("**/pages/**") veya glob("**/app/**") → Route yapısını bul
├── glob("**/api/**") veya glob("**/routes/**") → API endpoint'leri bul
├── read("README.md") → Proje hakkında bilgi al
└── list(".") → Dizin yapısını gör
```

**Sonuç:** "Bu bir Next.js projesi. 5 sayfa var: /, /login, /dashboard, /todos, /profile. 3 API route var: /api/auth, /api/todos, /api/users."

### Adım 2: Route/Sayfa Keşfi

```
Framework bazlı:

Next.js (App Router):
├── glob("app/**/page.tsx") → Her page.tsx bir route
├── read her page.tsx → Component ağacını çıkar
└── grep("fetch(", "app/**") → API çağrılarını bul

Next.js (Pages Router):
├── glob("pages/**/*.tsx") → Her dosya bir route
└── read her dosya → getServerSideProps / getStaticProps → API çağrıları

React (SPA):
├── grep("Route|path=", "src/**") → React Router route'ları
├── grep("useNavigate|navigate(") → Navigation akışı
└── read her sayfa → Hangi component'ler import edilmiş

Vue:
├── glob("src/views/**/*.vue") veya glob("src/pages/**/*.vue")
├── read("src/router/index.js") → Route tanımları
└── grep("$router.push|router.push") → Navigation

Django:
├── read("urls.py") → URL patterns
├── grep("path(", "**/urls.py") → Tüm route'lar
└── read("views.py") → View fonksiyonları

Express:
├── grep("app.get|app.post|router.get|router.post", "**/*.js")
└── read her route dosyası → Endpoint'ler
```

### Adım 3: Component Ağacı Çıkarma

```
Her sayfa için:
├── read("src/pages/LoginPage.tsx")
│   ├── import LoginForm → Bu component kullanılıyor
│   ├── import Button → Bu component kullanılıyor
│   ├── grep("onClick|onSubmit|onChange") → Event handler'lar
│   └── grep("useState|useEffect") → State'ler ve yan etkiler
│
├── read("src/components/LoginForm.tsx")
│   ├── <input type="email"> → Email input
│   ├── <input type="password"> → Password input
│   ├── <button type="submit"> → Submit butonu
│   └── onSubmit={handleSubmit} → Hangi fonksiyon çağrılıyor?
│
└── Flow haritası:
    Kullanıcı → Email gir → Şifre gir → "Giriş Yap" tıkla → handleSubmit çalışır
    → API çağrısı: POST /api/auth/login → Response kontrolü → Dashboard'a yönlendir
```

### Adım 4: API Yollarını Keşfetme

```
Frontend'den başla:
├── grep("fetch(|axios.|api.|http.") → Tüm API çağrıları
├── Her çağrı için: URL, method, body, response ne?
├── Backend'e git:
│   ├── grep("app.post('/api/auth/login'") → Endpoint tanımı
│   ├── read handler fonksiyon → Ne yapıyor?
│   └── grep("SELECT|INSERT|prisma.|mongoose.") → DB operasyonu
└── Zinciri çıkar:
    Frontend buton → API çağrısı → Backend handler → DB sorgusu → Response
```

### Adım 5: Test Senaryosu Üretme

```
Keşfedilen flow'dan test senaryosu çıkar:

FLOW: "Kullanıcı login formunda email/şifre girer → Giriş Yap tıkla → API'ye istek → Dashboard'a yönlendir"

TEST SENARYOSU (Playwright MCP ile):
1. browser_navigate → http://localhost:3000/login
2. browser_snapshot → Sayfa yüklendi mi kontrol et
3. browser_type → email input'una "test@test.com" yaz
4. browser_type → password input'una "password123" yaz
5. browser_click → "Giriş Yap" butonuna tıkla
6. browser_wait_for → URL değişikliği beklemesi
7. browser_snapshot → Dashboard yüklendi mi?
8. ASSERTION: URL "/dashboard" mı? → Evet/Hayır → BULGU

EĞER HAYIRSA (buton çalışmıyorsa):
→ FIND-FE-001: "Giriş Yap butonu tıklandığında dashboard'a yönlendirmiyor"
→ Muhtemel neden: onClick handler eksik
→ Önerilen fix: handleSubmit fonksiyonunu kontrol et
```

---

## 4. GERÇEKÇİ OLARAK NE YAPABİLİR, NE YAPAMAZ?

### ✅ Yapabilir (Gerçekten Çalışır)

| İşlem | Hangi Tool | Nasıl |
|-------|-----------|-------|
| Tüm sayfaları bulmak | `glob` + `read` | `glob("**/page.tsx")` |
| Tüm butonları bulmak | `grep` | `grep("<button", "src/**")` |
| Hangi butonların onClick'i yok | `grep` | Buton olan ama onClick olmayan satırlar |
| API endpoint'leri bulmak | `grep` | `grep("fetch(|axios.")` |
| Import zincirini takip etmek | `read` | Dosya → import → dosya → import... |
| Form validation var mı | `read` | Form component'ini oku, validate fonksiyonu var mı? |
| Loading state var mı | `grep` | `grep("loading|isLoading|spinner", "src/**")` |
| Error handling var mı | `grep` | `grep("catch|error|Error", "src/**")` |
| SQL injection riski | `grep` | `grep("SELECT.*\\${|INSERT.*\\${")` |
| Hardcoded secret | `grep` | `grep("password|secret|api_key.*=")` |
| Tüm route'ları listelemek | `grep` + `read` | Router dosyasını oku |
| Sayfa açıp tıklamak | `playwright MCP` | Tarayıcıda gerçek test |
| Screenshot almak | `playwright MCP` | Kanıt olarak |

### ⚠️ Sınırlı Yapabilir

| İşlem | Sınırlama |
|-------|-----------|
| Kullanıcı "deneyimini" anlamak | Statik analizle tahmin eder, gerçek test gerektirir |
| Backend mantığını tam test etmek | Endpoint'e istek atabilir ama DB'yi kontrol edemez (MCP yoksa) |
| Mobil responsive kontrol | Playwright ile viewport değiştirip bakabilir ama gerçek cihaz değil |
| Performans testi | Basit ölçümler yapabilir ama profesyonel değil |

### ❌ Yapamaz (Dış Yardım Gerekli)

| İşlem | Neden |
|-------|-------|
| Production ortamında test | Sadece local dev server'da çalışır |
| Gerçek kullanıcı verisiyle test | Test verisi veya kullanıcı onayı gerekli |
| Database migration test | Güvenli Fix Sınırları buna izin vermez |
| Auth flow'un tam testi | Test credential gerekli |

---

## 5. ÖNERİLEN opencode.json CONFIG

```json
{
  "$schema": "https://opencode.ai/config.json",
  
  "permission": {
    "bash": "allow",
    "edit": "allow",
    "write": "allow",
    "read": "allow",
    "grep": "allow",
    "glob": "allow",
    "lsp": "allow",
    "websearch": "allow",
    "webfetch": "allow",
    "question": "allow"
  },

  "tools": {
    "lsp": true,
    "websearch": true
  },

  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest"],
      "enabled": true
    },
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "enabled": true
    }
  }
}
```

**Bu config'i `~/.config/opencode/opencode.json`'a koy → her projede çalışır.**

---

## 6. AKIŞ ÖZETİ: "AJAN FLOW'U NEREDEN BİLİR?"

```
┌─────────────────────────────────────────┐
│ 1. KEŞİF (glob + read + grep)          │
│                                         │
│   package.json oku → Framework tespit   │
│   Klasör yapısını tara → Route'ları bul │
│   Her sayfa dosyasını oku → Component'ler│
│   API dosyalarını oku → Endpoint'ler    │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 2. HARİTALAMA (grep + read + LSP)      │
│                                         │
│   Import zincirini takip et             │
│   Event handler'ları bul                │
│   State'leri ve effect'leri analiz et   │
│   API çağrılarını çıkar                 │
│   Frontend → Backend → DB zinciri       │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 3. SENARYO ÜRETME (LLM akıl yürütme)   │
│                                         │
│   Her sayfa için:                       │
│   - Hangi butonlar var?                 │
│   - Ne yapmaları gerekiyor?             │
│   - Hangi API'ye gitmesi lazım?         │
│   - Sonuç ne olmalı?                    │
│                                         │
│   → Test senaryoları üret               │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 4. TEST (Playwright MCP + bash)        │
│                                         │
│   Dev server başlat (bash)              │
│   Tarayıcıda sayfa aç (playwright)      │
│   Her senaryoyu çalıştır                │
│   Sonuçleri kaydet                      │
│   Screenshot al (kanıt)                 │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 5. RAPOR (write)                       │
│                                         │
│   Bulguları yaz                         │
│   Hangi butonlar çalışıyor/hayır        │
│   Hangi API'ler doğru/yanlış dönüyor    │
│   Öncelik sırasına göre listele         │
└─────────────────────────────────────────┘
```

---

## 7. SONUÇ VE EKSİKLERİMİZ

### ✅ Mevcut Pakette İyi Olan:
- Ajan tanımları ve frontmatter yapısı doğru
- Güvenli Fix Sınırları net
- Handoff sistemi çalışıyor
- Rapor şablonları hazır

### ❌ Eksik Olan (Bu Araştırma Sonrası Eklenmeli):

1. **`opencode.json` config dosyası** — MCP ve tool ayarları pakete dahil değil
2. **Ajanlardaki MCP referansları güncellenmeli** — `ast_grep`, `grep_app`, `sequential-thinking` gibi şeyler OpenCode'da MCP değil, ya built-in ya da plugin. Ajanların "kullanılacak MCP'ler" kısmı gerçek tool isimlerine göre düzeltilmeli
3. **Repo keşif talimatı framework bazlı olmalı** — Her framework için farklı keşif yolu var (Next.js vs React SPA vs Vue vs Django)
4. **Playwright test senaryosu şablonu** — Ajanlara Playwright MCP ile nasıl test yazacaklarını gösteren örnek eklenmeli

### 🔧 Yapılması Gerekenler:

1. `opencode.json` config dosyasını pakete ekle
2. Ajanların "Kullanılacak Tool'lar" kısmını düzelt:
   - ~~`ast_grep`~~ → `grep` (built-in) + LSP
   - ~~`grep_app`~~ → `grep` (built-in)
   - ~~`sequential-thinking`~~ → LLM'nin kendi akıl yürütme yeteneği
   - `playwright` → Playwright MCP
3. Frontend audit ajanına framework bazlı keşif talimatı ekle
4. Playwright MCP test örnekleri ekle
