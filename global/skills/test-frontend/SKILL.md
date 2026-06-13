---
name: test-frontend
description: >-
  Frontend test senaryosu skill. Her sayfa için test senaryoları yazar ve Playwright ile çalıştırır.
  Trigger: "test frontend", "playwright test", "browser test", "sayfa test et", "senaryo yaz"
---

# Skill: Frontend Test Senaryosu

**Amaç:** Her sayfadaki interaktif element için test senaryoları üret ve Playwright MCP ile çalıştır.
**Kısıtlar:** Kodu değiştirme, sadece test et ve raporla.

---

## Adım 1: Dev Server Hazırlığı

```bash
# Dev server'ı başlat (eğer çalışmıyorsa)
npm run dev &

# Erişilebilirliği kontrol et
curl -s http://localhost:3000 || curl -s http://localhost:5173 || curl -s http://localhost:8080
```

## Adım 2: Frontend Audit Raporunu Oku

```
read("reports/frontend/frontend-audit-*-summary.md")
```

Bulunan sorunlu elementleri not et.

## Adım 3: Playwright MCP ile Test Et

Her sayfa için şu testleri çalıştır:

### Navigation Test
```
1. browser_navigate("http://localhost:PORT/sayfa")
2. browser_snapshot() → Element ref'lerini al
3. Her navigation butonuna browser_click() yap
4. browser_snapshot() ile sonucu kontrol et
```

### Form Test
```
1. browser_snapshot() → Form elementlerini tespit et
2. browser_type(target, text) ile her input'u doldur
3. browser_click(target) ile submit butonuna bas
4. browser_snapshot() ile sonucu kontrol et
5. browser_console_messages(level="error") ile hata var mı?
```

### Visual Test
```
1. Her sayfa için browser_take_screenshot(type="png", filename="reports/screenshots/page-XXX.png")
```

### Network Test
```
1. browser_network_requests(static=false) → API çağrılarını kontrol et
2. 404/500 response'ları tespit et
```

## Adım 4: Rapor Yaz

`reports/frontend/test-scenarios-YYYYMMDD.md` dosyasını oluştur:

```markdown
# 🧪 Frontend Test Sonuçları
- **Tarih:**
- **Toplam Senaryo:**
- **Pass:** ✅ X
- **Fail:** ❌ Y

## Test Sonuçları
### [Sayfa Adı]
#### Test 1: Navigation
- **Durum:** ✅ PASS / ❌ FAIL
- **Adımlar:** ...
- **Beklenen:** ...
- **Gerçekleşen:** ...

## Hatalar
| # | Sayfa | Element | Sorun | Severity |
|---|-------|---------|-------|:--------:|
```

## Adım 5: Handoff Güncelle

`reports/_state/handoff.md`'e ekle:
```markdown
## Frontend Test - TAMAMLANDI
- **Toplam Senaryo:**
- **Pass Rate:**
- **Ana Bulgular:**
```
