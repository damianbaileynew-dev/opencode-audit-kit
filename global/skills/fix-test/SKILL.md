---
name: fix-test
description: >-
  Test fix skill. Test audit'ten gelen sorunları düzeltir.
  Test framework kurulumu, test script ekleme, unit + integration test yazma, CI fix.
  Trigger: "fix test", "test fix", "düzelt test", "onar test", "test ekle"
---

# Skill: Test Fix

**Amaç:** Eksik veya bozuk test altyapısını düzelt, test coverage'ı artır.

## Güvenli Fix Sınırları

### ✅ Otomatik Yapılabilir
- **Test framework kurulumu** — Jest veya Vitest konfigürasyonu
- **Test script ekleme** — `package.json`'a `"test": "jest"` ekleme
- **Unit test yazma** — Service/helper fonksiyonlar için test dosyaları oluşturma
- **Integration test yazma** — API endpoint'leri için HTTP testleri (supertest)
- **Edge case testleri ekleme** — Boş input, null, boundary değerler
- **CI pipeline fix** — `.github/workflows/ci.yml` düzeltme
- **Test setup dosyası** — `jest.config.js`, `setup.js` oluşturma

### ❌ Onay Gerekli
- Test coverage threshold zorlama (%80+ requirement)
- Mock strategy değiştirme
- Farklı test framework'e geçiş

---

## Adım 1: Raporları Oku

```
read("reports/test/test-audit-*.md")
read("reports/_state/handoff.md")
```

## Adım 2: Önceliklendir

- **P0:** Test script eksik/broken (CI blocking), test framework yok
- **P1:** Integration testler eksik (supertest ZORUNLU), unit testler eksik
- **P2:** Edge case testleri, CI optimizasyonu

## Adım 3: Fix Şablonları

### Test Framework Kurulumu (Jest)
```json
// package.json
{
  "scripts": {
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "test:ci": "jest --ci --coverage --maxWorkers=2"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3"
  }
}
```

### jest.config.js
```javascript
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/config/**',
    '!src/**/*.test.js'
  ],
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50
    }
  }
};
```

### Unit Test Örneği (Service Fonksiyon)
```javascript
// tests/services/orderService.test.js
const { calculateDiscount } = require('../../src/services/orderService');

describe('calculateDiscount', () => {
  test('should apply bulk discount for orders over 1000', () => {
    const result = calculateDiscount(1500, 'user');
    expect(result.discount).toBe(150);
    expect(result.finalTotal).toBe(1350);
  });

  test('should apply premium discount for premium users', () => {
    const result = calculateDiscount(500, 'premium');
    expect(result.discount).toBe(25);
    expect(result.finalTotal).toBe(475);
  });

  test('should apply both discounts for premium bulk orders', () => {
    const result = calculateDiscount(2000, 'premium');
    expect(result.discount).toBe(300);
    expect(result.finalTotal).toBe(1700);
  });

  test('should return zero discount for small orders by regular users', () => {
    const result = calculateDiscount(100, 'user');
    expect(result.discount).toBe(0);
    expect(result.finalTotal).toBe(100);
  });
});
```

### Integration Test Örneği (API Endpoint — ZORUNLU: supertest)
```javascript
// tests/integration/api.test.js
const request = require('supertest');
const app = require('../../src/server');

// 🚨 SUPERTEST İLE INTEGRATION TEST ZORUNLU!
// Sadece unit test YETERSİZDIR — HTTP seviyesinde test YAPILMALIDIR.
// Unit testler service fonksiyonlarını test eder ama HTTP request/response zincirini test ETMEZ.
// Integration testler: status code, response body, headers, cookie, auth tam zinciri test eder.

describe('Products API', () => {
  test('GET /api/products should return products array', async () => {
    const res = await request(app).get('/api/products');
    expect(res.status).toBe(200);
    expect(res.body.products).toBeDefined();
    expect(Array.isArray(res.body.products)).toBe(true);
  });

  test('GET /api/products should support pagination', async () => {
    const res = await request(app).get('/api/products?page=1&limit=5');
    expect(res.status).toBe(200);
    expect(res.body.page).toBe(1);
    expect(res.body.total).toBeDefined();
  });

  test('POST /api/products/:id/reviews should reject invalid rating', async () => {
    const res = await request(app)
      .post('/api/products/1/reviews')
      .set('Cookie', 'token=valid-token')
      .send({ rating: 6, comment: 'Great' });
    expect(res.status).toBe(400);
  });
});

describe('Auth API', () => {
  test('POST /api/auth/register should validate required fields', async () => {
    const res = await request(app).post('/api/auth/register').send({});
    expect(res.status).toBe(400);
  });

  test('POST /api/auth/register should validate password length', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({ username: 'test', email: 'test@test.com', password: '123' });
    expect(res.status).toBe(400);
  });
});
```

🚨 **SUPERTEST INTEGRATION TEST ZORUNLU:**
- **Sadece `expect()` ile unit test yazmak YETERSİZDİR**
- **`request(app).get('/api/...')` şeklinde HTTP-level test YAPILMALIDIR**
- **En az 1 integration test dosyası oluşturulmalı: `tests/integration/api.test.js`**
- **supertest dependency'si package.json'da OLMALIDIR**

### Edge Case Testleri
```javascript
describe('Edge Cases', () => {
  test('should handle empty product list', async () => {
    const res = await request(app).get('/api/products');
    expect(res.status).toBe(200);
    expect(res.body.products).toEqual([]);
  });

  test('should handle non-existent product', async () => {
    const res = await request(app).get('/api/products/99999');
    expect(res.status).toBe(404);
  });

  test('should reject unauthenticated access to protected routes', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.status).toBe(401);
  });
});
```

### CI Pipeline Fix
```yaml
# .github/workflows/ci.yml
name: CI
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:ci
```

## Adım 4: Fix Uygula

1. `read("package.json")` → Mevcut test script'leri kontrol et
2. Test framework'ü yoksa: `bash("npm install --save-dev jest supertest")`
3. `write()` ile test dosyalarını oluştur
4. `edit()` ile package.json'ı güncelle
5. Test çalıştır: `bash("npm test")` — **Tüm testler geçmeli**
6. CI fix için `write()` veya `edit()` ile workflow dosyasını düzelt

### 🚨 ADIM 4.5: Integration Test Doğrulama (ZORUNLU — ATLAMA!)

Fix'ler uygulandıktan sonra, aşağıdaki kontrolü MUTLAKA yap. .js VE .ts uzantılarını kontrol et!

```bash
# Integration test dosyası var mı? (.js ve .ts)
ls src/__tests__/integration*.ts src/__tests__/integration*.js tests/integration/*.test.js tests/integration/*.test.ts 2>/dev/null || echo "❌ KRİTİK: Integration test dosyası YOK! HEMEN oluştur!"

# Supertest kullanılıyor mu?
grep -rq "supertest\|request(app)" src/__tests__/ tests/ 2>/dev/null || echo "❌ KRİTİK: Hiçbir test supertest kullanmıyor — integration test YOK!"

# HTTP-level test var mı?
grep -rq "request(app)\.\(get\|post\|put\|delete\)" src/__tests__/ tests/ 2>/dev/null || echo "❌ KRİTİK: HTTP-level integration test YOK!"

# supertest package.json'da mı?
grep -q "supertest" package.json || echo "❌ KRİTİK: supertest dependency YOK! HEMEN npm install --save-dev supertest çalıştır!"

# Edge case testleri var mı?
grep -rq "describe.*edge\|describe.*invalid\|describe.*boundary\|describe.*error\|test.*invalid\|test.*empty\|test.*short\|test.*null" src/__tests__/ tests/ 2>/dev/null || echo "❌ KRİTİK: Edge case testleri YOK! HEMEN ekle!"

# Test dosyalarında kaç test var?
grep -c "test(\|it(" src/__tests__/*.ts src/__tests__/*.js tests/**/*.test.js tests/**/*.test.ts 2>/dev/null
```

🚨🚨🚨 **EĞER integration test YOKSA → HEMEN oluştur!**
🚨🚨🚨 **EĞER supertest dependency YOKSA → HEMEN ekle!**
🚨🚨🚨 **EĞER edge case testleri YOKSA → HEMEN ekle!**

**Integration test şablonu — HEMEN uygula:**

```typescript
// src/__tests__/integration.test.ts
import request from 'supertest';
import app from '../server';

describe('API Integration Tests', () => {
  describe('Auth', () => {
    test('POST /api/register should require username and password', async () => {
      const res = await request(app).post('/api/register').send({});
      expect(res.status).toBe(400);
    });

    test('POST /api/register should validate password length', async () => {
      const res = await request(app).post('/api/register').send({ username: 'test', password: '123' });
      expect(res.status).toBe(400);
    });

    test('POST /api/login should reject invalid credentials', async () => {
      const res = await request(app).post('/api/login').send({ username: 'nonexistent', password: 'wrong' });
      expect(res.status).toBe(401);
    });

    test('POST /api/login should reject missing fields', async () => {
      const res = await request(app).post('/api/login').send({});
      expect(res.status).toBe(400);
    });
  });

  describe('Edge Cases', () => {
    test('GET /api/tasks should reject unauthenticated request', async () => {
      const res = await request(app).get('/api/tasks');
      expect(res.status).toBe(401);
    });

    test('POST /api/tasks should reject empty title', async () => {
      // Register first
      const regRes = await request(app).post('/api/register').send({ username: 'edgetest', password: 'password123' });
      const token = regRes.body.token;
      const res = await request(app).post('/api/tasks')
        .set('Authorization', `Bearer ${token}`)
        .send({ title: '' });
      expect(res.status).toBe(400);
    });

    test('GET /api/admin/users should reject non-admin', async () => {
      const regRes = await request(app).post('/api/register').send({ username: 'normaluser', password: 'password123' });
      const token = regRes.body.token;
      const res = await request(app).get('/api/admin/users')
        .set('Authorization', `Bearer ${token}`);
      expect(res.status).toBe(403);
    });

    test('PUT /api/tasks/:id should protect against mass assignment', async () => {
      const regRes = await request(app).post('/api/register').send({ username: 'masstest', password: 'password123' });
      const token = regRes.body.token;
      const taskRes = await request(app).post('/api/tasks')
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'Test Task' });
      const res = await request(app).put(`/api/tasks/${taskRes.body.id}`)
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'Updated', role: 'admin' });
      expect(res.body.role).toBeUndefined();
    });
  });
});
```

**Test fix'in tamamlanmış sayılması için:**
1. ✅ Jest/Vitest kurulu ve `npm test` çalışıyor
2. ✅ En az 1 unit test dosyası mevcut
3. ✅ En az 1 integration test dosyası (`src/__tests__/integration*.ts` veya `tests/integration/*.test.js`) mevcut ve supertest kullanıyor
4. ✅ Edge case testleri mevcut (empty input, invalid, boundary, unauthorized)
5. ✅ CI pipeline düzgün çalışıyor
6. ✅ `supertest` package.json'da mevcut

## The Prove-It Pattern (from Addy Osmani agent-skills)

When a bug is reported, **do not start by trying to fix it.** Start by writing a test that reproduces it.

```
Bug report arrives
      │
      ▼
Write a test that demonstrates the bug
      │
      ▼
Test FAILS (confirming the bug exists)
      │
      ▼
Implement the fix
      │
      ▼
Test PASSES (proving the fix works)
      │
      ▼
Run full test suite (no regressions)
```

**Example:**
```javascript
// Bug: "Completing a task doesn't update the completedAt timestamp"

// Step 1: Write the reproduction test (it should FAIL)
it('sets completedAt when task is completed', async () => {
  const task = await taskService.createTask({ title: 'Test' });
  const completed = await taskService.completeTask(task.id);

  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date); // This fails → bug confirmed
});

// Step 2: Fix the bug
export async function completeTask(id) {
  return db.tasks.update(id, {
    status: 'completed',
    completedAt: new Date(), // This was missing
  });
}

// Step 3: Test passes → bug fixed, regression guarded
```

## The Test Pyramid

```
     ╱╲
    ╱  ╲  E2E Tests (~5%)
   ╱    ╲ Full user flows, real browser
  ╱──────╲
 ╱        ╲ Integration Tests (~15%)
╱          ╲ Component interactions, API boundaries
╱────────────╲
╱              ╲ Unit Tests (~80%)
╱                ╲ Pure logic, isolated, milliseconds each
╱──────────────────╲
```

### Test Sizes (Resource Model)

| Size | Constraints | Speed | Example |
|------|-------------|-------|---------|
| **Small** | Single process, no I/O, no network, no DB | Milliseconds | Pure function tests, data transforms |
| **Medium** | Multi-process OK, localhost only, no external services | Seconds | API tests with test DB, component tests |
| **Large** | Multi-machine OK, external services allowed | Minutes | E2E tests, performance benchmarks |

### DAMP Over DRY in Tests

In production code, DRY (Don't Repeat Yourself) is usually right. In tests, **DAMP** (Descriptive And Meaningful Phrases) is better. Each test should tell a complete story without requiring the reader to trace through shared helpers.

```javascript
// DAMP: Each test is self-contained and readable
it('rejects tasks with empty titles', () => {
  const input = { title: '', assignee: 'user-1' };
  expect(() => createTask(input)).toThrow('Title is required');
});

it('trims whitespace from titles', () => {
  const input = { title: ' Buy groceries ', assignee: 'user-1' };
  const task = createTask(input);
  expect(task.title).toBe('Buy groceries');
});
```

### Preference Order for Test Doubles

```
1. Real implementation → Highest confidence, catches real bugs
2. Fake → In-memory version of a dependency (e.g., fake DB)
3. Stub → Returns canned data, no behavior
4. Mock (interaction) → Verifies method calls — use sparingly
```

**The Beyonce Rule:** If you liked it, you should have put a test on it. Infrastructure changes, refactoring, and migrations are not responsible for catching your bugs — your tests are. If a change breaks your code and you didn't have a test for it, that's on you.

## Reference Files

For detailed checklists, see:
- **Testing Patterns**: `references/testing-patterns.md` — Test doubles, edge cases, naming conventions, mock strategies
- **Performance Checklist**: `references/performance-checklist.md` — Performance testing patterns

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "We'll add tests later" | Later never comes. Code without tests is a liability. Write tests now. |
| "Integration tests are too slow" | Slow tests that catch real bugs beat fast tests that catch nothing. Use the test pyramid: 80% unit, 15% integration, 5% E2E. |
| "This code is too simple to test" | Simple code breaks too. Off-by-one errors, null checks, edge cases happen in "simple" code. |
| "We don't have time for TDD" | TDD saves time by preventing bugs and reducing debugging. Red-Green-Refactor is faster than code-then-debug. |
| "Mocks are sufficient" | Over-mocking creates tests that pass while production breaks. Prefer real implementations and fakes. |
| "100% coverage is the goal" | Coverage measures quantity, not quality. Meaningful tests on critical paths beat 100% coverage on trivial code. |

## Red Flags

- 🔴 No test script in package.json
- 🔴 No integration tests (only unit tests)
- 🔴 Tests that mock everything and test nothing real
- 🔴 No edge case tests (empty input, null, boundary values)
- 🔴 Tests that are tightly coupled to implementation details
- 🔴 No CI pipeline running tests on every push
- 🔴 Bug fixes without regression tests

## Adım 5: Rapor Yaz

`reports/test/test-fix-YYYYMMDD.md`:

```markdown
# 🧪 Test Fix Raporu
- **Test Framework:**
- **Oluşturulan Test Dosyaları:**
- **Test Coverage:**

## Test Sonuçları
| Suite | Tests | Passed | Failed |
|-------|:-----:|:------:|:------:|

## Oluşturulan Dosyalar
| # | Dosya | Test Sayısı |
|---|-------|:-----------:|

## CI Durumu
- Pipeline fixed: ✅/❌
```

## Adım 6: Handoff Güncelle
```markdown
## Test Fix - TAMAMLANDI
- **Test Framework:** Jest
- **Test Sayısı:** X test, X suite
- **Coverage:** X%
- **CI Pipeline:** Fixed / Not fixed
- **Sonraki Ajan İçin Öneri:** Accessibility audit'e geç
```
