---
name: hivemind-kb
description: "Canonical Knowledge Base: Obsidian vault tabanlı yapılandırılmış bilgi bankası. Entity types, canon workflow (draft→pending→approved), wikilinks, local-first. AI'ın gerçek belgeleri sorgulamasını sağlar."
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

# 🏗️ Skill: Hivemind Knowledge Base

**Kaynak:** hiveforge-sh/hivemind — Canonical Knowledge Base MCP
**Yapı:** Obsidian vault + YAML frontmatter + wikilinks
**Workflow:** Draft → Pending → Approved (Canon)

---

## Ne Yapar?

Hivemind, Obsidian vault'unuzu bir **kanonik bilgi bankasına** dönüştürür:
- AI'ın gerçek belgeleri sorgulamasını sağlar (hallucination önler)
- Entity type sistemi ile yapılandırılmış bilgi saklar
- Canon workflow ile hangi bilginin otorite olduğunu takip eder
- Timeline ve Graph view ile görselleştirme

---

## Entity Types

### Yazılım Projesi İçin
| Entity Type | Açıklama | Örnek |
|------------|----------|-------|
| `component` | UI component | LoginPage, TodoList |
| `api-endpoint` | API endpoint | POST /api/login |
| `service` | Backend servis | AuthService, DatabaseService |
| `bug` | Tespit edilen hata | SQL Injection in /api/login |
| `decision` | Alınan karar | Use parameterized queries |
| `pattern` | Öğrenilen pattern | Express routes follow /api/resource |
| `page` | Sayfa/route | /dashboard, /todos |

### Frontmatter Örneği
```yaml
---
entity_type: bug
canon_status: approved
severity: blocker
discovered: 2026-06-12
file: src/api/server.js
line: 16
status: open
---
# BUG-001: SQL Injection in /api/login
...detaylar...
```

---

## Canon Workflow

```
📝 DRAFT → ⏳ PENDING → ✅ APPROVED (Canon)
                     ↘ ❌ REJECTED
```

- **Draft:** İlk kayıt, henüz doğrulanmamış
- **Pending:** İnceleme bekliyor
- **Approved:** Otorite kabul edilmiş (AI buna güvenebilir)
- **Rejected:** Yanlış veya güncel olmayan bilgi

---

## MCP Konfigürasyonu

```json
{
  "hivemind": {
    "type": "local",
    "command": ["npx", "-y", "hivemind-mcp", "start"],
    "enabled": true
  }
}
```

### Init
```bash
npx hivemind-mcp init
# → config.json oluşturur
# → vault yolunu sorar
```

### Validate
```bash
npx hivemind-mcp validate
```

---

## Audit Kit Kullanımı

### 1. Audit Bulgularını Kaydet
Her bulgu için bir entity oluştur:
```markdown
---
entity_type: bug
canon_status: draft
severity: P0
discovered_date: 2026-06-12
discovered_by: frontend-audit
file: src/pages/LoginPage.jsx
---

# BUG-005: Login butonu disabled state göstermiyor

## Semptom
...
## Root Cause
...
## Fix Planı
...
```

### 2. Kararları Kaydet
```markdown
---
entity_type: decision
canon_status: approved
decision_date: 2026-06-12
decided_by: master-orchestrator
affects: BUG-005
---

# DECISION-005: Login butonuna disabled prop ekle

## Gerekçe
...
## Etki
...
```

### 3. Vault Sorgula
```
# Hivemind MCP tool'ları ile
→ Entity'leri ara
→ Timeline'da görüntüle
→ Graph'ta ilişkileri gör
```

---

## Audit Entegrasyonu

1. **project-memory** → Hivemind vault'una bulgu/decision yazar
2. **master-orchestrator** → Vault'tan geçmiş audit sonuçlarını okur
3. **innovation-agent** → Vault'tan proje context'ini alır
4. **frontend-audit/backend-audit** → Vault'ta bilinen bug'ları kontrol eder

---

## Başla
1. `npx hivemind-mcp init` ile vault yapılandır
2. `npx hivemind-mcp validate` ile doğrula
3. Entity type template'lerini oluştur
4. Audit bulgularını vault'a yaz
