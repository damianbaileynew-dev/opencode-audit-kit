---
name: temporal-memory
description: "Temporal Knowledge Graph ile kalıcı hafıza. Graphiti tabanlı, zaman bazlı ilişki takibi, semantic + keyword hybrid arama, otomatik context injection, multi-tenant scoping."
model: opencode/deepseek-v4-flash-free
tools:
  read: true
  glob: true
  grep: true
  write: true
  bash: true
  todowrite: true
  todoread: true
  question: true
permission:
  bash: allow
  edit: allow
  write: allow
  read: allow
---

# 🕐 Skill: Temporal Memory (Graphiti)

**Kaynak:** happycastle114/opencode-graphiti — OpenCode plugin
**Backend:** Graphiti MCP Server (FalkorDB veya Neo4j)
**Özellikler:** Temporal Knowledge Graph, Hybrid Search, Multi-Tenant Scoping

---

## Ne Farkı Var?

| Özellik | MCP Memory | local-memory | cavemem | **Graphiti** |
|---------|:----------:|:------------:|:-------:|:------------:|
| Knowledge Graph | ✅ (basit) | ✅ (SQLite) | ❌ | ✅ (temporal) |
| Temporal Tracking | ❌ | ❌ | ✅ (session) | ✅ (tüm zaman) |
| Semantic Search | ❌ | ❌ | ❌ | ✅ |
| Hybrid Search | ❌ | ✅ (FTS5) | ❌ | ✅ |
| Duplicate Guard | ❌ | ✅ | ❌ | ✅ |
| Multi-Tenant | ❌ | ❌ | ❌ | ✅ |
| Context Injection | ❌ | ✅ | ❌ | ✅ (auto) |
| External DB | ❌ | ❌ | ❌ | ✅ (Docker) |

---

## Mimari

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│  OpenCode Agent  │───▶│  Graphiti    │───▶│  FalkorDB   │
│  (audit agents)  │    │  MCP Server  │    │  / Neo4j    │
└─────────────────┘    └──────────────┘    └─────────────┘
```

---

## Kurulum (Opsiyonel — Docker gerekli)

### FalkorDB ile (Tavsiye)
```bash
export OPENAI_API_KEY=your_key
docker compose --profile falkordb up -d
```

### Neo4j ile
```bash
git clone https://github.com/getzep/graphiti.git
cd graphiti/mcp_server
cp .env.example .env
docker compose up -d
```

### OpenCode Plugin
```bash
npm install @happycastle/opencode-graphiti
```

---

## Özellikler

### 1. Automatic Context Injection
- Session başlangıcında: user profile + project knowledge + relevant memories otomatik yüklenir
- Context window sınırına yaklaştığında: session summary otomatik kaydeder

### 2. Temporal Knowledge Graph
- Entity'ler zaman içinde değişir → eski ve yeni değerler birlikte saklanır
- "Bu fonksiyon 2 hafta önce nasıldı?" sorusuna cevap verir
- İlişkiler temporal olarak izlenir (oluşturma, değişiklik, sonlandırma)

### 3. Multi-Tenant Scoping
- `group_id` ile user-scope ve project-scope izolasyonu
- Farklı projelerin hafızası birbirine karışmaz

### 4. Remember Trigger Detection
- Kullanıcı "bunu hatırla", "remember this" dediğinde otomatik kaydeder
- Agent'a "save this for later" talimatı verilebilir

### 5. Hybrid Search
- Semantic (anlamsal) + Keyword (anahtar kelime) arama
- BM25 + embedding kombinasyonu
- En alakalı sonuçları önceliklendirir

---

## Audit Kit Entegrasyonu

Bu skill, `project-memory` agent'ı tarafından kullanılır:

```markdown
## Temporal Memory Kullanım Senaryoları

### "2 hafta önce bu API nasıl çalışıyordu?"
→ Temporal graph'tan eski state'i getir

### "Bu bug daha önce raporlandı mı?"
→ Semantic search ile ilgili hafızayı ara

### "Proje boyunca hangi kararlar alındı?"
→ Decision entity'lerini listele (tarihsel)

### "Bu session'da ne öğrendik?"
→ Context compaction sonucunu getir

### "Geçen audit'ten bu yana ne değişti?"
→ Temporal diff hesapla
```

---

## Alternatif: Graphiti Yoksa

Eğer Docker/FalkorDB/Neo4j kurulmamışsa, bu skill şu MCP'leri fallback olarak kullanır:
1. **MCP Memory** (Knowledge Graph) — zaten kurulu
2. **local-memory** (SQLite + FTS5) — zaten kurulu
3. **cavemem** (Session tracker) — zaten kurulu

Temporal özellikler olmadan da temel hafıza çalışır.

---

## Başla
1. Docker'ın çalışıp çalışmadığını kontrol et
2. Graphiti MCP server'ın yanıt verip vermediğini test et
3. Yanıt veriyorsa → temporal memory kullan
4. Yanıt vermiyorsa → fallback MCP'leri kullan
5. Session context'ini oluştur
