---
description: "Tüm projeyi denetle, raporla ve güvenli şekilde iyileştir. Frontend, Backend, UX, Innovation, Design ve Memory sürecini başlatır."
agent: master-orchestrator
---

# Komut: Tüm Proje Denetimi ve Geliştirme Döngüsü

**Görev:** Projeyi aşağıdaki sıra ile analiz et, raporla ve güvenli şekilde iyileştir.

## Sıra
1. Master Orchestrator ajanını çalıştır (agents dosyalarında tanımlı)
2. Orkestratör, sırasıyla aşağıdaki ajanları koordine etsin:
   - `skill:brainstorming` veya `skill:grill-me` → Planı netleştir (belirsiz görevlerde)
   - @frontend-audit → @frontend-test-scenarios → `skill:impeccable-audit` → @frontend-fix
   - `skill:tdd` → Test-driven fix
   - @backend-audit → `skill:code-review-graph` → `skill:lsp-analysis` → @backend-fix
   - `skill:diagnose` → Root cause analizi
   - @ux-critic → @ux-polish
   - @innovation-agent
   - @project-memory → `skill:hivemind-kb` → `skill:temporal-memory`
   - Final Rapor

**Not:** Eğer @mention ile subagent çağırma çalışmazsa, `skill` tool'unu kullan:
- `skill("audit-frontend")`, `skill("test-frontend")`, `skill("fix-frontend")`
- `skill("audit-backend")`, `skill("fix-backend")`
- `skill("critique-ux")`, `skill("polish-ux")`
- `skill("suggest-innovation")`
- `skill("tdd")`, `skill("diagnose")`, `skill("grill-me")`
- `skill("impeccable-audit")`, `skill("code-review-graph")`, `skill("lsp-analysis")`
- `skill("manage-memory")`, `skill("hivemind-kb")`, `skill("temporal-memory")`

Eğer skill de çalışmazsa, tüm adımları tek oturumda kendin yap.

## Kurallar
- Her ajan `reports/` altına çıktı versin
- Her ajan `reports/_state/handoff.md`'ye handoff bloğu eklesin
- Fix yapan ajanlar "Güvenli Fix Sınırları" dışına çıkarsa onay isteyerek çıksın
- **Öncelikli hedef:** Tüm component'lerin söylediklerini yapması
- Teknoloji fark etmeksizin çalış: HTML, Node, TS, Python, Go, Rust, vs.

## Kullanılabilir Tool'lar
- `glob`, `grep`, `read`, `write`, `edit` → Dosya işlemleri
- `bash` → Shell komutları, dev server, curl
- `todowrite`, `todoread` → İlerleme takibi
- `question` → Kullanıcıya soru sor
- `websearch`, `webfetch` → Araştırma
- `skill` → Skill yükle

### MCP Tool'lar (opencode.json'da tanımlı)
- **Playwright** (22 tool): browser_navigate, browser_snapshot, browser_click, browser_type, browser_fill_form, browser_take_screenshot, browser_network_requests, browser_console_messages, browser_wait_for
- **CodeGraph** (8 tool): codegraph_explore, codegraph_impact, codegraph_status, codegraph_files, codegraph_callers
- **Context7** (2 tool): resolve-library-id, query-docs — Framework dokümantasyonu
- **Memory** (9 tool): create_entities, create_relations, search_nodes, read_graph — Knowledge Graph
- **cavemem** (4 tool): search, list_sessions, timeline, get_observations — Session tracker
- **Local Memory** (13 tool): memory_save, memory_recall, memory_search, memory_session_start/end, memory_list_entities, memory_entity_detail, memory_add_observations, memory_create_relation, memory_search_relations, memory_list_decisions, memory_save_decision, memory_stats — SQLite + FTS5 + KG
- **Hivemind** (opsiyonel): Obsidian vault knowledge base — entity types, canon workflow
- **Code Review Graph** (22 tool): build_or_update_graph, get_impact_radius, query_graph, get_review_context, semantic_search_nodes, list_flows, get_flow, get_affected_flows, list_communities, detect_changes, refactor, apply_refactor, generate_wiki, find_large_functions + 8 daha — Tree-sitter KG, 19 dil
- **Enquire** (opsiyonel, 45 tool): Obsidian vault RAG — BM25 + embeddings + BGE reranker
- **LSP** (deneysel): goToDefinition, findReferences, hover, diagnostics — OPENCODE_EXPERIMENTAL_LSP_TOOL=true gerekli

Başla.
