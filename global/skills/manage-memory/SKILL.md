---
name: manage-memory
description: >-
  Proje hafıza skill'i. Knowledge graph oluşturur, session'ları kaydeder, proje bağlamını korur.
  Trigger: "hafıza", "memory", "graph", "session log", "proje geçmişi", "ne biliyoruz", "nerede kaldık"
---

# Skill: Proje Hafıza Yönetimi

**Amaç:** Projenin tüm bilgi birikimini kalıcı olarak kaydetmek ve gelecekteki session'larda erişilebilir kılmak.

---

## MCP Tool'lar

### Knowledge Graph (MCP Memory)
- `create_entities` → Proje, sayfa, bug, decision entity'leri oluştur
- `create_relations` → Entity'ler arası ilişkiler (contains, depends-on, found-bug)
- `add_observations` → Mevcut entity'lere yeni gözlem ekle
- `search_nodes` → Knowledge graph'ta ara
- `open_nodes` → Belirli node'ları aç
- `read_graph` → Tüm graph'ı oku

### Session Tracker (cavemem)
- `search` → Bellekte ara
- `list_sessions` → Geçmiş session'ları listele
- `timeline` → Session timeline'ını gör
- `get_observations` → Gözlem detayları

---

## Adım 1: Mevcut Durumu Oku

```
# Knowledge graph'ı kontrol et
read_graph()

# Handoff'u oku
read("reports/_state/handoff.md")

# Tüm raporları bul
glob("reports/**/*.md")
```

## Adım 2: Raporlardan Bilgi Çıkar

Her rapor dosyasını oku ve önemli bulguları entity olarak kaydet:

```
# Frontend bulguları
read("reports/frontend/*.md") → Her bulgu için bug entity oluştur

# Backend bulguları  
read("reports/backend/*.md") → Her güvenlik açığı için vulnerability entity oluştur

# UX bulguları
read("reports/ux/*.md") → Her sürtünme noktası için observation ekle

# Innovation önerileri
read("reports/innovation/*.md") → Her öneri için decision entity oluştur
```

## Adım 3: Knowledge Graph Güncelle

```
# Entity'leri oluştur
create_entities([{
  name: "BUG-001: SQL Injection",
  entityType: "vulnerability",
  observations: ["Blocker severity", "server.js line 16", "Fix: parameterized queries"]
}])

# İlişkileri kur
create_relations([
  {from: "BUG-001", to: "POST /api/login", relationType: "found-bug-in"}
])
```

## Adım 4: Bellek Raporu Yaz

`reports/_memory/project-graph.md` oluştur:

```markdown
# 🧠 Proje Hafıza Grafi
- **Son güncelleme:**
- **Toplam entity:**
- **Toplam ilişki:**

## Kritik Bulgular (Açık)
...

## Çözülen Bulgular
...

## Alınan Kararlar
...
```

## Adım 5: Handoff Güncelle

```markdown
## Memory Update - TAMAMLANDI
- **Toplam Entity:**
- **Toplam İlişki:**
- **Yeni Eklenen Bulgular:**
```

---

## Hızlı Komutlar

| Ne istiyorsun? | Ne yapmalısın? |
|----------------|----------------|
| "Bu projeyi hatırla" | Tüm raporları oku, knowledge graph oluştur |
| "Ne biliyoruz?" | `read_graph()` + `search_nodes("project")` |
| "Nerede kaldık?" | `list_sessions()` + `read("reports/_state/handoff.md")` |
| "Hangi bug'lar açık?" | `search_nodes("bug not-fixed vulnerability")` |
| "Bu sayfada sorun var mı?" | `open_nodes(["LoginPage"])` |
| "Session geçmişi" | `list_sessions()` + `timeline()` |
