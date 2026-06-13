---
name: lsp-analysis
description: "LSP (Language Server Protocol) tabanlı derin kod analizi. Tip kontrolü, tanım-atıf takibi, hover bilgisi, diagnostic mesajları. Deneysel: OPENCODE_EXPERIMENTAL_LSP_TOOL=true gerekli."
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

# 🔬 Skill: LSP Analysis

**Kaynak:** OpenCode experimental LSP tool
**Gereksinim:** `OPENCODE_EXPERIMENTAL_LSP_TOOL=true` env var
**Özellikler:** Tip kontrolü, go-to-definition, find-references, hover, diagnostics

---

## Ne Yapar?

LSP (Language Server Protocol), IDE'lerin kullandığı aynı altyapıyı AI agent'a sunar:

1. **Diagnostics** → Derleme hataları, uyarılar, lint sorunları
2. **Go to Definition** → Bir sembolün tanımını bul
3. **Find References** → Bir sembolün tüm kullanımlarını bul
4. **Hover** → Tip bilgisi, dokümantasyon
5. **Rename** → Güvenli yeniden adlandırma
6. **Code Actions** → Otomatik düzeltme önerileri

---

## Kurulum

### Environment Variable
```bash
# .bashrc veya .zshrc'ye ekle
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true

# Veya OpenCode başlatırken
OPENCODE_EXPERIMENTAL_LSP_TOOL=true opencode
```

### Dil Desteği
LSP aracının çalışması için ilgili dil server'ının kurulu olması gerekir:

| Dil | LSP Server | Kurulum |
|-----|-----------|---------|
| TypeScript/JS | typescript-language-server | `npm i -g typescript-language-server typescript` |
| Python | pylsp / pyright | `pip install python-lsp-server` |
| Go | gopls | `go install golang.org/x/tools/gopls@latest` |
| Rust | rust-analyzer | `rustup component add rust-analyzer` |
| Java | jdtls | Eclipse JDT Language Server |
| C/C++ | clangd | `apt install clangd` |

---

## Audit Kullanımı

### Tip Kontrolü
```
# Tüm TypeScript diagnostic'leri al
lsp_diagnostics("src/**/*.ts")

# Belirli bir dosyanın diagnostic'leri
lsp_diagnostics("src/api/server.ts")
```

### Tanım ve Referans Takibi
```
# Bir fonksiyonun tanımını bul
lsp_definition("src/api/server.ts", line: 16, character: 5)

# Bir fonksiyonun tüm kullanımlarını bul
lsp_references("src/api/server.ts", line: 16, character: 5)

# Hover bilgisi al
lsp_hover("src/api/server.ts", line: 16, character: 5)
```

---

## Audit Senaryoları

### 1. Tip Güvenliği Kontrolü
```
# Tüm TypeScript hatalarını bul
lsp_diagnostics → tüm diagnostic'leri topla
→ error seviyindeki diagnostic'ler = BLOCKER
→ warning seviyeki diagnostic'ler = HIGH
```

### 2. Kullanılmayan Kod Tespiti
```
# Bir export'un referanslarını kontrol et
lsp_references → 0 referans = dead code
```

### 3. API Sözleşme Kontrolü
```
# Bir fonksiyonun tip imzasını kontrol et
lsp_hover → parametre tipleri ve dönüş tipi
→ any tipi = güvenlik riski
```

### 4. Breaking Change Tespiti
```
# Bir fonksiyonun tüm çağıranlarını bul
lsp_references → tüm kullanım yerleri
→ Her kullanım yerinde güncelleme gerekli mi?
```

---

## Rapor Formatı

```markdown
# 🔬 LSP Analysis Raporu

## Diagnostic Özeti
| Seviye | Sayı | Dosyalar |
|--------|:----:|----------|
| Error | | |
| Warning | | |
| Info | | |
| Hint | | |

## Tip Güvenlik Sorunları
| Dosya | Satır | Sorun | Seviye | Öneri |
|-------|:-----:|-------|:------:|-------|
| | | | | |

## Kullanılmayan Kod
| Dosya | Sembol | Tip | Son Kullanım |
|-------|--------|-----|-------------|
| | | | ❌ Hiçbir yerde |

## API Sözleşme İhlalleri
| Dosya | Fonksiyon | Beklenen Tip | Gerçek Tip |
|-------|-----------|-------------|-----------|
| | | | |

## Öneriler
1. 
```

---

## Başla
1. `OPENCODE_EXPERIMENTAL_LSP_TOOL=true` ortam değişkenini kontrol et
2. İlgili dil server'ının kurulu olduğunu doğrula
3. Diagnostic'leri topla
4. Tip güvenlik sorunlarını analiz et
5. Raporu `reports/*/lsp-analysis-*.md` dosyasına yaz
