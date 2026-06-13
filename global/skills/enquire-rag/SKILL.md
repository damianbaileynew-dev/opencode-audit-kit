---
name: enquire-rag
description: "Obsidian Vault RAG: Hybrid retrieval (BM25 + embeddings + BGE reranker) ile proje dokümantasyonu arama. 45 tool, GraphRAG-light, PDF+OCR desteği, zero cloud."
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

# 📚 Skill: Enquire RAG (Obsidian Vault)

**Kaynak:** oomkapwn/enquire-mcp — Obsidian Vault RAG
**Özellikler:** BM25 + Embeddings + BGE Reranker, 45 tool, PDF+OCR
**Cloud:** Zero — tamamen local

---

## Ne Yapar?

Proje dokümantasyonunu (Obsidian vault veya markdown dosyaları) okur, indexler ve AI'a sorgulanabilir hale getirir:

1. **BM25 Keyword Search** → klasik arama
2. **Embedding Semantic Search** → anlamsal arama
3. **BGE Reranker** → sonuçları yeniden sırala
4. **GraphRAG-light** → belgeler arası ilişkileri çıkar
5. **PDF + OCR** → PDF'lerden metin çıkar

---

## MCP Konfigürasyonu (Opsiyonel)

```json
{
  "enquire": {
    "type": "local",
    "command": ["npx", "-y", "@oomkapwn/enquire-mcp", "serve", "--vault", "/path/to/docs"],
    "enabled": true
  }
}
```

> **Not:** İlk çalıştırmada vault indexlenmelidir. Bu işlem büyük vault'lar için birkaç dakika sürebilir.

---

## Kullanım Senaryoları

### Audit Sırasında
```
# Proje dokümantasyonundan API spec'ini bul
enquire_search(query: "authentication API specification")

# Tasarım kararlarını bul
enquire_search(query: "database schema design decisions")

# README veya CONTRIBUTING'den proje kurallarını al
enquire_search(query: "coding standards linting rules")
```

### Audit Sonrası
```
# Audit sonuçlarını vault'a kaydet
→ reports/ altındaki markdown dosyalarını Obsidian vault'a kopyala
→ Gelecekteki session'larda erişilebilir olur
```

---

## Audit Kit Entegrasyonu

Bu skill OPsiYONELDIR. Eğer projede Obsidian vault veya zengin dokümantasyon varsa kullanılır:

1. **master-orchestrator** → Proje dokümantasyonunu anlamak için
2. **backend-audit** → API spec'leri ve design decision'ları bulmak için
3. **innovation-agent** → Rakip analizi ve trend araştırması için

---

## Fallback

Enquire MCP kurulmamışsa:
- `glob("docs/**/*.md")` + `read()` ile dokümantasyon okunur
- `glob("README.md")` ile proje bilgisi alınır
- `websearch` ile harici dokümanlar aranır

---

## Başla
1. Enquire MCP'nin çalışıp çalışmadığını kontrol et
2. Çalışıyorsa → vault'u sorgula
3. Çalışmıyorsa → fallback yöntemleri kullan
