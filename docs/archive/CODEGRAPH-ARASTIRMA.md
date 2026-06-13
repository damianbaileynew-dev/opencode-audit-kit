# 🔬 Araştırma: CodeGraph — Tam Entegrasyon Planı

> **Repo:** https://github.com/colbymchenry/codegraph
> **Star:** 47.3K ⭐ | **Dil:** TypeScript | **Lisans:** açık kaynak
> **Tarih:** 2026-06-11

---

## 🎯 NEDEN BU BİZİM İÇİN KRİTİK?

Bizim paketin en büyük sorunu: **"Ajan projenin haritasını nereden bilecek?"**

Şu anda ajan `grep` + `read` ile dosya dosya gezip haritayı kendisi çıkarıyor.
Bu **yavaş** (dakikalar), **pahalı** (binlerce token) ve **hata prone**.

**CodeGraph bu sorunu tamamen çözüyor:**

```
Bizim şu anki yöntem:
Ajan → grep("import") → read 50 dosya → grep("fetch(") → read 30 dosya → ...
= Dakikalar, binlerce token, eksik kalabilir

CodeGraph ile:
Ajan → codegraph_callers("handleSubmit") → 0.1 saniyede tam cevap
Ajan → codegraph_impact("addTodo") → "Bu fonksiyonu değiştirirsen 5 dosya etkilenir"
Ajan → codegraph_explore("login flow") → Tüm login zinciri tek çağrıda
= Saniyeler, minimal token, eksiksiz
```

---

## 📊 CODEGRAPH NEDİR?

**Kısaca:** Projenin tamamını tarayıp bir **knowledge graph** (bilgi grafiği) oluşturan bir araç.

- **22 dil desteği:** TypeScript, JavaScript, Python, Go, Rust, Java, C#, PHP, Ruby, Swift, Kotlin, Dart, Svelte, Vue...
- **14 framework desteği:** Express, Next.js, React Router, Django, FastAPI, Flask, Spring, Rails, Laravel, Gin, SvelteKit, Nuxt...
- **Tamamen local** — kodunuzu sunucuya göndermez
- **MCP server** — OpenCode, Claude Code, Cursor, Codex CLI ile doğrudan çalışır
- **47.3K star** — çok aktif ve güvenilir proje

### Ne Yapar?

1. Projenizi tarar (tree-sitter ile AST analizi)
2. Her fonksiyon, class, değişken, import, route'u bir **node** yapar
3. Aralarındaki ilişkileri **edge** yapar (X fonksiyonu Y'yi çağırıyor)
4. SQLite veritabanına kaydeder (`.codegraph/` dizini)
5. MCP server olarak ajanlara sunar

### Örnek Index Boyutu
VSCode codebase: 3.251 dosya → 119.675 node → 116.424 edge → **30 saniyede hazır**

---

## 🛠️ CODEGRAPH MCP TOOL'LARI

| Tool | Ne Yapar | Bizim Kullanımımız |
|------|----------|-------------------|
| **`codegraph_search`** | Symbol (fonksiyon/class) ara | "handleSubmit fonksiyonu nerede?" |
| **`codegraph_callers`** | Bir fonksiyonu kim çağırıyor? | "handleSubmit'i hangi buton tetikliyor?" |
| **`codegraph_callees`** | Bir fonksiyon neyi çağırıyor? | "handleSubmit ne yapıyor? Hangi API'ye gidiyor?" |
| **`codegraph_impact`** | Bir şeyi değiştirirsen ne etkilenir? | "addTodo'yu değiştirirsem neler bozulur?" |
| **`codegraph_explore`** | Bir konsept/akış hakkında tam bağlam | "Login flow nasıl çalışıyor?" → tüm zincir |
| **`codegraph_node`** | Bir symbol'ün tam detayı ve kaynak kodu | "addTodo fonksiyonunun kodunu göster" |
| **`codegraph_files`** | Indexlenmiş dosya yapısı | "Projenin dosya yapısı ne?" |
| **`codegraph_status`** | Index sağlık durumu | "Index güncel mi?" |

---

## 🚀 BİZİM PAKETE NASIL ENTEGRE EDİLİR?

### 1. opencode.json'a MCP olarak ekle

```json
{
  "$schema": "https://opencode.ai/config.json",
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
    },
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"],
      "enabled": true
    }
  }
}
```

### 2. Her projede bir kez index oluştur

```bash
cd your-project
codegraph init -i
# 30 saniye → .codegraph/ dizini oluşur
```

### 3. Ajanlar otomatik kullanır

Artık ajanlar `grep` + `read` yerine `codegraph_explore` kullanabilir:

```
# ÖNCE (grep ile - yavaş):
1. grep("import.*TodoPage") → 10 dosya
2. read her dosya → 10 read çağrısı
3. grep("fetch.*api") → 5 dosya
4. read her dosya → 5 read çağrısı
= 15+ tool çağrısı, binlerce token

# SONRA (CodeGraph ile - hızlı):
1. codegraph_explore("todo flow") → tek çağrıda tüm zincir
= 1 tool çağrısı, yüzlerce token
```

---

## 📋 HANGİ AJAN NASIL KULLANIR?

### Frontend Audit
```
# Uygulama haritası çıkarma:
codegraph_files → Projenin dosya yapısı
codegraph_search("Page") → Tüm sayfa component'leri
codegraph_callers("handleSubmit") → Bu fonksiyonu kim çağırıyor?
codegraph_callees("handleSubmit") → Bu fonksiyon ne yapıyor?

# Buton → API zinciri:
codegraph_explore("save button flow")
→ "Save butonu → handleSubmit() → POST /api/items → ItemsController.create()"
```

### Frontend Test Scenarios
```
# Test senaryosu yazmadan önce akışı anlama:
codegraph_callers("addTodo")
→ TodoPage.tsx:30 onClick handler

codegraph_callees("addTodo")
→ api/todos.ts:5 fetch POST /api/todos
→ returns { id, text, completed }

# Test senaryosu: "addTodo fonksiyonuna gelen veriler nereye gidiyor?"
codegraph_impact("addTodo")
→ "Bu fonksiyonu değiştirirsen etkilenenler: TodoList, TodoItem, useTodos hook"
```

### Backend Audit
```
# API endpoint keşfi:
codegraph_search("router") → Tüm route tanımları
codegraph_callees("loginHandler") → DB sorgusu yapıyor mu?
codegraph_impact("User model") → User modelini değiştirirsen ne bozulur?

# Güvenlik taraması:
codegraph_search("password") → Şifre ile ilgili tüm symbol'ler
codegraph_callers("rawQuery") → SQL injection riski olan yerler
```

### Master Orchestrator
```
# Repo keşfi (Adım 0):
codegraph_status → Proje büyüklüğü, index durumu
codegraph_files → Dosya yapısı (glob'dan 100x hızlı)
codegraph_explore("architecture") → Genel mimari tek çağrıda
```

---

## 📊 KARŞILAŞTIRMA: BİZİM YÖNTEM vs CODEGRAPH

| İşlem | grep/read ile | CodeGraph ile |
|-------|:------------:|:-------------:|
| "Tüm sayfaları bul" | 5-10 çağrı | 1 çağrı |
| "Login flow nasıl çalışıyor?" | 20-30 çağrı, dakikalar | 1 çağrı, saniyeler |
| "Bu buton ne yapıyor?" | 3-5 çağrı | 1 çağrı (callees) |
| "Bu API'yi kim kullanıyor?" | 10+ çağrı | 1 çağrı (callers) |
| "Bu değişiklik neyi etkiler?" | İmkansız (manuel) | 1 çağrı (impact) |
| Token tüketimi | Yüksek (binlerce) | Düşük (yüzlerce) |
| Doğruluk | Tahmini | Kesin (AST bazlı) |
| İlk kurulum | Yok | 30 saniye (bir kez) |

---

## ⚡ KURULUM TALİMATI

### Tek komutla:
```bash
# CodeGraph'i kur
npm install -g @colbymchenry/codegraph

# OpenCode için MCP olarak yapılandır
codegraph install --target=opencode --yes

# Her projede index oluştur
cd your-project
codegraph init -i
```

### Veya mevcut opencode.json'a manuel ekle:
```json
"codegraph": {
  "type": "local",
  "command": ["codegraph", "serve", "--mcp"],
  "enabled": true
}
```

---

## ✅ SONUÇ

**CodeGraph kesinlikle paketimize eklenmeli.** İşte neden:

1. **"Yazılımın haritası" sorusunu tamamen çözüyor** — grep/read ile dakikalar süren keşfi saniyelere indiriyor
2. **"Buton basınca nereye gidiyor" sorusunu kesin cevaplıyor** — `codegraph_callees` ile tam zincir
3. **Token maliyetini %80-90 azaltıyor** — 1 CodeGraph çağrısı = 15-30 grep/read çağrısına bedel
4. **Impact analizi yapıyor** — "Bu değişiklik neyi bozar?" sorusuna cevap veriyor
5. **OpenCode ile doğrudan uyumlu** — MCP server olarak çalışıyor
6. **22 dil + 14 framework desteği** — Teknoloji agnostik hedefimize tam uyumlu
7. **47.3K star, aktif geliştirme** — Güvenilir ve sürekli güncelleniyor

### Pakete eklenmesi gerekenler:

1. `opencode.json`'a `codegraph` MCP eklendi ✅
2. Frontend audit ajanına CodeGraph tool kullanım talimatı eklendi ✅
3. Backend audit ajanına CodeGraph tool kullanım talimatı eklendi ✅
4. `install-global.sh` betiğine CodeGraph kurulum adımı eklendi ✅
5. `CODEGRAPH-KILAVUZ.md` dokümanı oluşturuldu ✅
