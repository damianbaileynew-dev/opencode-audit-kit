# 🔍 OpenCode Audit Kit v2.0

**10-dimension automated code audit kit** for OpenCode AI. Works **inside OpenCode** — score results appear as markdown in your chat.

## 📦 Kurulum

### Yöntem 1: OpenCode Plugin (Önerilen)
```bash
npx opencode-ai plugin /path/to/opencode-audit-kit
# VEYA global:
npx opencode-ai plugin /path/to/opencode-audit-kit --global
```

### Yöntem 2: npm install (Tarball)
```bash
# Tarball'dan kurulum (npm publish gerektirmez)
npm install ./dejavuxer-opencode-audit-kit-2.0.0.tgz
npx opencode-audit --help
```

### Yöntem 3: GitHub'dan kurulum
```bash
npm install git+https://github.com/dejavuxer/opencode-audit-kit.git
npx opencode-audit --help
```

### Yöntem 4: Manuel kopyalama
```bash
git clone https://github.com/dejavuxer/opencode-audit-kit.git
cd opencode-audit-kit
bash install-project.sh /senin/projen
```

## 🚀 OpenCode İçinde Kullanım

```bash
# 1. Install into your project
npx opencode-ai plugin opencode-audit-kit

# 2. Run full 10-dimension audit
npx opencode-ai run "10 boyut audit yap ve TÜM bulguları düzelt"

# 3. Score report inside OpenCode
npx opencode-ai run "skill:score-report"
```

`npx opencode-ai run` ile çalıştırdığınızda:
- **Master Orchestrator** 10 boyutu sırayla tarar
- Her boyut için önce **audit** yapar, sonra **fix** uygular
- Sonunda **score-report skill** ile score'ları markdown tablo olarak gösterir
- Eksik boyutlar varsa, ilgili fix skill'leri tekrar çağırır

### CLI (Standalone)

```bash
opencode-audit score ./my-project      # Score from terminal
opencode-audit auto-audit ./my-project 3  # Audit with retry
opencode-audit validate                 # Validate kit (299 checks)
```

## 📊 10 Dimensions × 67 Checks

| # | Dimension | Checks | Key Fixes |
|---|-----------|:------:|-----------|
| 1 | 🔒 Security | 12 | Helmet, rate-limit, CORS, JWT env, bcrypt≥12, httpOnly cookie, sanitize user, @Roles Guard, mass assignment, XSS |
| 2 | ⚡ Performance | 6 | Pagination, N+1 batch Map, async writes, search pagination |
| 3 | 🔍 Code Quality | 6 | @MinLength password, status codes, ExceptionFilter, @IsNotEmpty title, Bearer strip, no var |
| 4 | 🏗️ Architecture | 6 | *.service.ts, config from env, @Catch filter |
| 5 | 🧪 Test | 6 | jest/supertest, edge cases, integration, CI |
| 6 | ♿ Accessibility | 7 | lang, charset, viewport, label, aria, ESC close, focus |
| 7 | 🎨 UX | 7 | search, filter, error-message, loading, @media, empty-state |
| 8 | 🚀 DevOps | 6 | USER appuser, .dockerignore, /health, npm ci, enableShutdownHooks |
| 9 | 🔎 SEO | 6 | meta desc, canonical, OG tags, JSON-LD, semantic HTML, robots.txt |
| 10 | 📚 Documentation | 5 | README, API docs, inline comments, CONTRIBUTING, .env.example |

## 🛠️ Supported Frameworks

| Framework | Buggy | Fixed | Detection | Status |
|-----------|:-----:|:-----:|-----------|:------:|
| **Express.js (JS)** | ~5% | 100% | package.json → express | ✅ |
| **TypeScript/Express** | ~5% | 100% | package.json → express + tsconfig | ✅ |
| **FastAPI (Python)** | 5% | 100% | requirements.txt → fastapi | ✅ |
| **NestJS (TypeScript)** | 7% | 100% | package.json → @nestjs | ✅ |
| **Next.js** | — | — | package.json → next | 🔄 |

## 📁 Architecture

```
opencode-audit-kit/
├── global/
│   ├── skills/            # 37 audit + fix skills
│   │   ├── score-report/  # OpenCode score skill (markdown rapor)
│   │   ├── fix-fastapi/   # FastAPI fix (13 steps)
│   │   ├── fix-nestjs/    # NestJS fix (Decorator/Guard/Module)
│   │   ├── fix-backend/   # Express backend fix
│   │   └── ...            # 32 more skills
│   ├── agents/
│   │   └── master-orchestrator.md  # 10-dimension coordinator
│   └── opencode.json
├── score.sh               # Auto-Scorer (Multi-Framework)
├── auto-audit.sh          # Audit + Retry Pipeline
├── validate.sh            # 299 integrity checks
├── cli.js                 # CLI entry point
├── package.json           # npm package (v2.0.0)
└── README.md
```

## 🤖 Model Desteği

| Model | Model ID | Ücret | Durum |
|-------|----------|:-----:|:-----:|
| DeepSeek V4 Flash | `opencode/deepseek-v4-flash-free` | Ücretsiz | ✅ Varsayılan |
| MiMo V2.5 | `opencode/mimo-v2.5-free` | Ücretsiz | ✅ |
| Qwen 3.7 Plus | (varsayılan) | Ücretsiz | ✅ |

Auto-audit varsayılan olarak **DeepSeek V4 Flash** kullanır.

```bash
# Özel model ile çalıştır
npx opencode-ai run "10 boyut audit yap" --model "opencode/deepseek-v4-flash-free"
```

## 📈 Test Results

| Framework | Buggy → Fixed |
|-----------|:-------------:|
| Express.js (JS) | 5% → **100%** |
| TypeScript/Express | 5% → **100%** |
| FastAPI (Python) | 5% → **100%** |
| NestJS | 7% → **100%** |

## 📝 License

MIT
