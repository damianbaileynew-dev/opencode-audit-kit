---
name: code-review-graph
description: "Knowledge graph tabanlı kod review. Tree-sitter ile kodu parse eder, impact analizi, risk scoring, blast radius hesaplar. 19 dil desteği, 22 MCP tool."
model: opencode/deepseek-v4-flash-free
tools:
  read: true
  glob: true
  grep: true
  bash: true
  write: true
  edit: true
  todowrite: true
  todoread: true
  question: true
permission:
  bash: allow
  edit: allow
  write: allow
  read: allow
---

# 📊 Skill: Code Review Graph

**Kaynak:** tirth8205/code-review-graph — 17.9K GitHub stars
**Teknoloji:** Tree-sitter + SQLite + Knowledge Graph
**MCP Tool Sayısı:** 22
**Dil Desteği:** JavaScript, TypeScript, Python, Rust, Go, Java, C#, Ruby, PHP, Lua, Vue, Solidity, Perl, Erlang, Julia, Zig, Swift, Kotlin, Dart

---

## Ne Yapar?

Bu skill, kod değişikliklerinin **etki alanını (blast radius)** hesaplar:
1. Kodu Tree-sitter ile parse eder → Knowledge Graph oluşturur
2. Değişen dosyaları tespit eder
3. Etkilenen execution flow'ları izler
4. Risk seviyesi hesaplar
5. Test kapsamını kontrol eder
6. Structured review raporu oluşturur

**Sonuç:** %82-90 daha az token tüketimi, daha iyi yapısal anlayış

---

## MCP Tools (22 adet)

### Core Tools (8)
| Tool | İşlev |
|------|-------|
| `build_or_update_graph_tool` | Graph oluştur veya güncelle (incremental) |
| `get_impact_radius_tool` | Değişikliğin etki alanını hesapla |
| `query_graph_tool` | Graph'ta sorgula (callers_of, callees_of, imports_of, etc.) |
| `get_review_context_tool` | Review bağlamını getir |
| `semantic_search_nodes_tool` | Anlamsal arama |
| `embed_graph_tool` | Graph embedding oluştur |
| `list_graph_stats_tool` | Graph istatistikleri |
| `find_large_functions_tool` | Büyük fonksiyonları bul |

### Flow Tools (4)
| Tool | İşlev |
|------|-------|
| `list_flows_tool` | Execution flow'ları listele |
| `get_flow_tool` | Tek bir flow detayı |
| `get_affected_flows_tool` | Değişiklikten etkilenen flow'lar |
| `get_architecture_overview_tool` | Mimari genel görünüm |

### Community Tools (3)
| Tool | İşlev |
|------|-------|
| `list_communities_tool` | Kod community'leri listele |
| `get_community_tool` | Community detayı |
| `get_architecture_overview_tool` | Mimari özet |

### Change & Refactoring Tools (5)
| Tool | İşlev |
|------|-------|
| `detect_changes_tool` | Değişiklikleri tespit et |
| `refactor_tool` | Refactoring önerisi oluştur |
| `apply_refactor_tool` | Refactoring uygula |
| `generate_wiki_tool` | Wiki sayfası oluştur |
| `get_wiki_page_tool` | Wiki sayfası oku |

### Utility Tools (2)
| Tool | İşlev |
|------|-------|
| `list_repos_tool` | Multi-repo registry |
| `cross_repo_search_tool` | Cross-repo arama |

---

## Çalışma Akışı

### Adım 1: Graph Oluştur
```bash
# İlk kez çalıştırıyorsan
pip install code-review-graph
code-review-graph build

# Sonraki çalıştırmalarda (incremental)
code-review-graph update
```

Veya MCP tool ile:
```
build_or_update_graph_tool(full_rebuild: false)
```

### Adım 2: Değişiklikleri Tespit Et
```
detect_changes_tool(base: "HEAD~1")
```

### Adım 3: Etki Alanını Hesapla
```
get_impact_radius_tool(
  changed_files: [...],  # otomatik tespit
  max_depth: 2           # 2-hop blast radius
)
```

### Adım 4: Review Bağlamını Al
```
get_review_context_tool(
  changed_files: [...],
  max_depth: 2,
  include_source: true,
  max_lines_per_file: 200
)
```

### Adım 5: Etkilenen Flow'ları Kontrol Et
```
get_affected_flows_tool(
  changed_files: [...],
  base: "HEAD~1"
)
```

### Adım 6: Rapor Oluştur

```markdown
# 📊 Code Review Graph Raporu

## Özet
- **Değişen Dosya Sayısı:**
- **Etkilenen Node Sayısı:**
- **Blast Radius (max_depth: 2):**
- **Yüksek Riskli Değişiklikler:**

## Risk Matrisi
| Dosya | Fonksiyon | Risk Seviyesi | Test Kapsamı | Çağıranlar |
|-------|-----------|:------------:|:------------:|:----------:|

## Etkilenen Execution Flow'lar
| Flow | Adım Sayısı | Kırılma Riski |
|------|:-----------:|:------------:|

## Öneriler
1. ...
2. ...

## Detaylı Analiz
<details>
<summary>Her dosya için detaylı analiz</summary>

### [DOSYA ADI]
- **Değişiklik Tipi:**
- **Etki Alanı:**
- **Çağıran Fonksiyonlar:**
- **Test Kapsamı:**
</details>
```

---

## Audit Entegrasyonu

### Frontend Audit
```
query_graph_tool(pattern: "callers_of", target: "Component")
find_large_functions_tool(min_lines: 50)
get_architecture_overview_tool()
```

### Backend Audit
```
get_impact_radius_tool(changed_files: ["src/api/server.js"])
detect_changes_tool(base: "HEAD~1")
semantic_search_nodes_tool(query: "authentication login", kind: "Function")
```

### Innovation
```
list_communities_tool()
get_flow_tool(flow_name: "checkout")
list_flows_tool(sort_by: "criticality")
```

---

## Kurulum Gereksinimleri

```bash
# Python ile (tavsiye edilen)
pip install code-review-graph

# uvx ile (OpenCode MCP için)
# opencode.json'da zaten tanımlı: uvx code-review-graph serve

# Embedding desteği (opsiyonel)
pip install code-review-graph[embeddings]
```

---

## Başla
1. `list_graph_stats_tool()` ile mevcut graph durumunu kontrol et
2. Graph yoksa → `build_or_update_graph_tool(full_rebuild: true)`
3. `detect_changes_tool()` ile değişiklikleri tespit et
4. Impact analizi ve review raporu oluştur
5. Raporu `reports/backend/code-review-graph-*.md` dosyasına yaz
