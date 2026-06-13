---
name: tdd
description: "Test-Driven Development: Red-Green-Refactor döngüsü ile özellik geliştirme veya hata düzeltme. Her adımda önce test yaz, sonra implement et, sonra refactor yap."
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

# 🧪 Skill: Test-Driven Development (TDD)

**Kaynak:** mattpocock/skills — 48K+ GitHub stars, production TDD skill
**Uyum:** OpenCode, Claude Code, Cursor, Gemini CLI

---

## Felsefe

Bu skill, **vibe coding'e karşı** disiplinli mühendislik yapar:
- Her özellik veya bug fix için **önce test yaz** (RED)
- Test'i geçecek **minimum kodu** yaz (GREEN)
- Testler yeşil kalırken **refactor yap** (REFACTOR)
- Her adımda **doğrulama** yap

## Kurallar

### ❌ Asla Yapma
- Test yazmadan implementasyon kodu yazma
- Birden fazla testi aynı anda kırmaya izin verme
- "Sonra test yazarım" deme
- Geçici olarak testleri skip etme
- Refactor sırasında davranış değiştirme

### ✅ Her Zaman Yap
- Test isimleri spesifik olsun: "should return 404 when user not found"
- Arrange / Act / Assert yapısı kullan
- Edge case'leri test et (null, undefined, empty, max, min)
- Her test tek bir şeyi doğrulasın
- Refactor sonrası tüm testleri tekrar çalıştır

---

## Adımlar

### Adım 1: Kapsamı Belirle (Scope)
1. Kullanıcıdan veya handoff'tan görevi al
2. `question` tool ile belirsizlikleri gider
3. Ne yapılacak ve ne yapılmayacak net sınırlar çiz
4. `todowrite` ile adımları planla

### Adım 2: Test Altyapısını Kontrol Et
```
glob("**/*.test.*") veya glob("**/*.spec.*")
glob("**/jest.config.*") veya glob("**/vitest.config.*")
read("package.json") → test script'leri
```
- Test framework'ü tespit et (Jest, Vitest, Mocha, Pytest, Go test, vs.)
- Mevcut test pattern'lerini analiz et
- Test komutunu tespit et (npm test, pytest, go test, vs.)

### Adım 3: RED — Test Yaz
1. **Hedef davranışı** tanımla (ne yapmalı, ne döndürmeli)
2. Test dosyasını oluştur veya mevcut dosyaya ekle
3. Test'i yaz — henüz implement edilmediği için **BAŞARISIZ OLMALI**
4. Test'i çalıştır → **RED** (başarısız) olmalı
5. Hata mesajını oku — anlamlı ve yönlendirici olmalı

```markdown
### Test Şablonu
describe('[MODULE/COMPONENT]', () => {
  describe('[FONKSİYON/METOD]', () => {
    it('should [EXPECTED BEHAVIOR] when [CONDITION]', () => {
      // Arrange
      const input = ...;
      
      // Act
      const result = ...;
      
      // Assert
      expect(result).toBe(expected);
    });
  });
});
```

### Adım 4: GREEN — Minimum Implementasyon
1. Sadece testi geçecek **minimum kodu** yaz
2. Over-engineering yapma
3. Testi çalıştır → **GREEN** (başarılı) olmalı
4. Başka testlerin bozulmadığını kontrol et

### Adım 5: REFACTOR — Temizle
1. Kodu oku — tekrar, karmaşıklık, isimlendirme sorunları var mı?
2. Refactor yap:
   - Magic number → constant
   - Tekrarlanan kod → fonksiyon
   - Uzun fonksiyon → parçala
   - Kötü isim → iyi isim
3. **Tüm testleri çalıştır** → hala GREEN mi?
4. GREEN değilse → refactor'i geri al, tekrar dene

### Adım 6: Sonraki Vertical Slice
1. Bir sonraki test senaryosunu seç
2. Adım 3'e dön (RED)
3. Tüm slice'lar tamamlanana kadar devam et

### Adım 7: Tamamlandı — Raporla
1. `reports/_state/handoff.md`'ye handoff bloğu ekle:
```markdown
## TDD - TAMAMLANDI
- **Tarih:** 
- **Özellik/Bug:**
- **Yazılan Test Sayısı:**
- **Tamamlanan Slice'lar:**
- **Refactoring Yapılanlar:**
- **Dokunulan Dosyalar:**
- **Son Test Sonucu:**
```
2. `bash: npm test` veya uygun test komutu ile tüm testleri çalıştır ve sonucu raporla

---

## Vertical Slice Örnekleri

| Slice | Test | Implementasyon |
|-------|------|----------------|
| 1 | "should render login form" | Form component oluştur |
| 2 | "should show error on empty email" | Email validasyonu ekle |
| 3 | "should call onSubmit with form data" | Submit handler ekle |
| 4 | "should show loading state during submit" | Loading state ekle |
| 5 | "should show success message after submit" | Success state ekle |
| 6 | "should handle API error gracefully" | Error handling ekle |

---

## Audit Entegrasyonu

Bu skill audit sürecinde şu durumlarda kullanılır:
1. **frontend-test-scenarios** ajanı test senaryoları yazarken
2. **frontend-fix** ajanı bug düzeltirken (önce regression test)
3. **backend-fix** ajanı güvenlik açığı kapatırken (önce exploit test)

---

## Başla
1. Görevi al (kullanıcıdan veya handoff'tan)
2. Test altyapısını kontrol et
3. RED → GREEN → REFACTOR döngüsüne başla
