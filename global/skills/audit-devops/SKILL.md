---
name: audit-devops
description: >-
  DevOps audit skill. Dockerfile, CI/CD, config, deployment, infrastructure güvenlik ve best practice taraması.
  Trigger: "devops audit", "audit devops", "docker audit", "ci audit", "infra audit"
---

# Skill: DevOps Audit

**Amaç:** Projenin DevOps altyapısını denetle — Dockerfile, CI/CD, config, health check, deployment.

## Kısıtlar
**Sadece oku ve raporla.** Dosya değiştirme. Raporu `reports/devops/` dizinine yaz.

---

## Adım 1: Dockerfile Denetimi

### Kontroller
1. **Root user:** Image root olarak mı çalışıyor? `USER` directive var mı?
2. **COPY . .** — Hassas dosyalar (.env, .git) kopyalanıyor mu? `.dockerignore` var mı?
3. **Base image** — Alpine veya slim image mi? Full image gereksiz mi?
4. **Build stages** — Multi-stage build kullanılıyor mu?
5. **Layer caching** — `package.json` COPY → npm install → COPY source sırası doğru mu?
6. **HEALTHCHECK** — Docker healthcheck tanımlı mı?
7. **Exposed ports** — Sadece gerekli port暴露 mu?
8. **apt/apk** — Gereksiz paket kurulumu var mı?

```bash
# Kontrol komutları
read("Dockerfile")
glob(".dockerignore")
glob("docker-compose*.yml")
```

## Adım 2: CI/CD Pipeline Denetimi

### Kontroller
1. **Test step** — Pipeline'da test çalışıyor mu? `npm test` geçerli mi?
2. **Node version** — Güncel Node.js versiyonu kullanılıyor mu?
3. **Cache** — npm cache kullanılıyor mu? Build hızlı mı?
4. **Branch rules** — Sadece main'de mi çalışıyor? PR'larda da çalışmalı.
5. **Artifacts** — Coverage/build artifact'leri saklanıyor mu?
6. **Security scan** — Dependency audit (npm audit) var mı?
7. **Deploy step** — Deployment yapılandırılmış mı?

```bash
glob(".github/workflows/*.yml")
glob(".gitlab-ci.yml")
glob("Jenkinsfile")
```

## Adım 3: Config & Environment Denetimi

### Kontroller
1. **.env dosyası** — Hassas veriler (.env) `.gitignore`'da mı?
2. **.env.example** — Gerekli env variable'lar dokümante edilmiş mi?
3. **Config separation** — Dev/staging/prod config'leri ayrı mı?
4. **Secret management** — Secret'lar hardcoded mi, env'de mi?
5. **Environment validation** — Startup'ta env'ler kontrol ediliyor mu?

```bash
read(".env")
read(".gitignore")
glob(".env.example")
glob("config/**")
```

## Adım 4: Health & Monitoring Denetimi

### Kontroller
1. **Health check endpoint** — `/health` veya `/readiness` var mı?
2. **Graceful shutdown** — SIGTERM handler var mı?
3. **Process management** — PM2, forever, veya systemd kullanılıyor mu?
4. **Logging** — Structured logging var mı? Log seviyeleri doğru mu?
5. **Error tracking** — Sentry veya benzeri entegrasyon var mı?

```bash
grep("health|readiness|liveness", "src/**")
grep("SIGTERM|SIGINT|gracefulShutdown", "src/**")
```

## Adım 5: Staging/Production Hazırlık Denetimi

### Kontroller
1. **NODE_ENV** — Production'da `NODE_ENV=production` set mi?
2. **Source maps** — Production'da source map'ler devre dışı mı?
3. **Minification** — Static dosyalar minified mı?
4. **CDN** — Static dosyalar CDN'den mi sunuluyor?
5. **Rate limiting** — Production'da rate limiting aktif mi?
6. **HTTPS** — TLS zorunlu mu?
7. **Backup strategy** — Veritabanı yedekleme var mı?

## Adım 6: Rapor Yaz

`reports/devops/devops-audit-YYYYMMDD.md`:

```markdown
# 🚀 DevOps Audit Raporu

## Dockerfile
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|
| 1 | Non-root user | ✅/❌ | |
| 2 | .dockerignore | ✅/❌ | |
| 3 | COPY scope | ✅/❌ | |
| 4 | Base image | ✅/❌ | |
| 5 | HEALTHCHECK | ✅/❌ | |
| 6 | Layer caching | ✅/❌ | |

## CI/CD Pipeline
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|

## Config & Environment
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|

## Health & Monitoring
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|

## Production Readiness
| # | Kontrol | Durum | Açıklama |
|---|---------|:-----:|----------|

## Önceliklendirme
### P0 — Hemen Düzeltilmeli
### P1 — Planla ve Düzelt
### P2 — İyileştirme
```
