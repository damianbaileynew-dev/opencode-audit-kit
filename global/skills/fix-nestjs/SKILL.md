---
name: fix-nestjs
description: >-
  NestJS/TypeScript projesindeki tüm 10 boyuttaki sorunları düzeltir.
  Trigger: "fix nestjs", "nestjs fix", "nest fix"
  Framework: NestJS + TypeScript + @nestjs/core
---

# Skill: NestJS Full Audit & Fix

**Amaç:** NestJS/TypeScript projesindeki tüm güvenlik, performans, kod kalitesi, mimari, test, erişilebilirlik, UX, DevOps, SEO ve dokümantasyon sorunlarını düzeltmek.

## Framework Tespiti

Eğer `package.json`'da `@nestjs/core` veya `@nestjs/common` varsa, BU skill kullanılmalıdır.
NestJS pattern'ları: Decorator (`@Controller`, `@Get`), Guard (`@UseGuards`), Module (`@Module`), Service (`@Injectable`), DTO (`class-validator`).

---

## ADIM 1: Mevcut Durumu Oku

```
read("src/main.ts")
read("src/app.module.ts")
read("package.json")
read("tsconfig.json")
read("Dockerfile")
read(".github/workflows/ci.yml")
```

---

## ADIM 2: Güvenlik Fixleri (12 bug)

### S1: Helmet Ekle (ZORUNLU)
```typescript
// npm install helmet
import helmet from 'helmet';

// src/main.ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(helmet());
  await app.listen(3000);
}
```

### S2: Rate Limiting (ZORUNLU)
```typescript
// npm install @nestjs/throttler
// src/app.module.ts
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Module({
  imports: [
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 10 }]),
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
```

### S3: CORS Restricted (ZORUNLU)
```typescript
// src/main.ts
app.enableCors({
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
  credentials: true,
});
```
🚨 `origin: "*"` ASLA kullanma!

### S4: JWT Secret Environment Variable'a Taşı
```typescript
// src/config/env.ts
export const env = {
  JWT_SECRET: process.env.JWT_SECRET || 'dev-only-secret-change-in-prod',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '30m',
  BCRYPT_ROUNDS: Number(process.env.BCRYPT_ROUNDS || '12'),
  PORT: Number(process.env.PORT || '3000'),
  CORS_ORIGIN: process.env.CORS_ORIGIN || 'http://localhost:3000',
};
```
🚨 Hardcoded `SECRET = "secret"` ASLA olmamalı!

### S5: bcrypt Salt Rounds ≥ 10 (ZORUNLU)
```typescript
import * as bcrypt from 'bcrypt';
const salt = bcrypt.genSaltSync(env.BCRYPT_ROUNDS); // 12
const hash = bcrypt.hashSync(password, salt);
```

### S6: Password Hash Response'dan Çıkar (ZORUNLU)
```typescript
function sanitizeUser(user: any) {
  const { password, ...safe } = user;
  return safe;
}

// Login/Register
return { user: sanitizeUser(user), token };
```

### S7: Logout Endpoint Ekle (ZORUNLU)
```typescript
@Post('logout')
logout(@Req() req: any, @Res() res: Response) {
  res.clearCookie('token');
  return { message: 'Logged out' };
}
```

### S8: httpOnly Cookie Kullan (ZORUNLU)
```typescript
@Post('login')
login(@Body() body: LoginDto, @Res({ passthrough: true }) res: Response) {
  const { token, user } = this.authService.login(body.email, body.password);
  res.cookie('token', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000,
  });
  return { user: sanitizeUser(user) };
}
```
🚨 localStorage.setItem('token') YANLIŞ! httpOnly cookie ZORUNLU!

### S9: Admin Route'larda Guard (ZORUNLU)
```typescript
// src/common/guards/roles.guard.ts
import { CanActivate, ExecutionContext, Injectable, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}
  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!roles) return true;
    const request = context.switchToHttp().getRequest();
    if (!roles.includes(request.user?.role)) throw new ForbiddenException('FORBIDDEN');
    return true;
  }
}

// src/common/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// Admin controller
@Controller('api/admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
export class AdminController { ... }
```
🚨 `@Roles('admin')` + `@UseGuards(JwtAuthGuard, RolesGuard)` ZORUNLU!

### S10: Admin Response'dan Password Çıkar (ZORUNLU)
```typescript
@Get('users')
adminUsers() {
  return { users: _users.map(sanitizeUser) };
}
```

### S11: Mass Assignment — Whitelist DTO (ZORUNLU)
```typescript
// npm install class-validator class-transformer
import { IsString, IsOptional, IsNotEmpty, MinLength } from 'class-validator';

export class CreateTaskDto {
  @IsString() @IsNotEmpty() @MinLength(1)
  title: string;

  @IsString() @IsOptional()
  description?: string;

  @IsString() @IsOptional()
  priority?: string;

  @IsOptional()
  assigneeId?: number;
  // role, is_admin, user_id YOK!
}

// main.ts — enable global validation
import { ValidationPipe } from '@nestjs/common';
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,        // Strip unknown properties
  forbidNonWhitelisted: true, // Throw error for unknown props
  transform: true,
}));
```
🚨 `whitelist: true` + `forbidNonWhitelisted: true` ZORUNLU!

### S12: XSS Prevention (Frontend — textContent)
```javascript
// innerHTML yerine textContent kullan
tasks.forEach(function(t) {
  var div = document.createElement('div');
  var h3 = document.createElement('h3');
  h3.textContent = t.title;  // innerHTML DEĞİL!
  div.appendChild(h3);
  document.getElementById('task-list').appendChild(div);
});
```

---

## ADIM 3-8: Performance, Code Quality, Architecture, Test, Accessibility, UX, DevOps, SEO, Documentation

Bu boyutlar Express/TypeScript ile aynı kalıpları kullanır. Detaylar için `fix-fastapi/SKILL.md` ve `fix-backend/SKILL.md`'deki pattern'ları referans alın. NestJS-specific farklar:

### Architecture
- **AR1-AR2-AR5:** Service layer → `*.service.ts` dosyaları oluşturun, `@Injectable()` ile işaretleyin
- **AR3-AR4:** Config → `src/config/env.ts` + `process.env` kullanın
- **AR6:** Exception Filter → `@Catch()` ile global filter oluşturun

### Test
- Jest + Supertest → `@nestjs/testing` Test module kullanın
- `npm install --save-dev @nestjs/testing jest supertest`
- E2E test: `test/*.e2e-spec.ts`
- Unit test: `tests/unit/*.spec.ts`

### DevOps
- D6: Graceful shutdown → `app.enableShutdownHooks()` NestJS'de

---

## ADIM 9: Doğrulama (ZORUNLU)

```bash
# NestJS-specific checks
grep -rq "helmet" src/ || echo "❌ HELMET YOK!"
grep -rq "ThrottlerModule\|throttler" src/ || echo "❌ RATE LIMIT YOK!"
grep -rq "process\.env\|config\.env" src/ || echo "❌ ENV CONFIG YOK!"
grep -rq "BCRYPT_ROUNDS.*1[0-9]\|genSaltSync.*1[0-9]" src/ || echo "❌ BCRYPT < 10!"
grep -rq "sanitizeUser\|sanitize.*user" src/ || echo "❌ PASSWORD SANITIZATION YOK!"
grep -rq "logout\|Logout" src/ || echo "❌ LOGOUT YOK!"
grep -rq "httpOnly\|set_cookie\|res\.cookie" src/ || echo "❌ HTTPONLY COOKIE YOK!"
grep -rq "@Roles\|RolesGuard" src/ || echo "❌ ADMIN AUTH YOK!"
grep -rq "Whitelist\|forbidNonWhitelisted\|whitelist.*true" src/ || echo "❌ MASS ASSIGNMENT KORUMASI YOK!"
find src/ -name "*.service.ts" | grep -q . || echo "❌ SERVICE LAYER YOK!"
grep -rq "enableShutdownHooks\|SIGTERM\|shutdown" src/ || echo "❌ GRACEFUL SHUTDOWN YOK!"
test -f .env.example || echo "❌ .env.example YOK!"
test -f README.md || echo "❌ README.md YOK!"
```

🚨🚨🚨 EĞER herhangi bir kontrol başarısız olursa → HEMEN düzelt! ATLAMA!

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Decorators handle everything" | Decorators only work if they're applied. Missing @UseGuards() on a controller means no auth. Verify every endpoint. |
| "NestJS is secure by default" | NestJS provides tools, not defaults. You must add Guards, ValidationPipes, DTOs, and ThrottlerModule explicitly. |
| "DTO validation is overkill for internal APIs" | Internal APIs get called from compromised hosts. Validate everywhere with class-validator decorators. |
| "Guards are too verbose" | Verbose but correct beats concise but vulnerable. Apply @UseGuards() consistently on all protected routes. |

## Red Flags

- 🔴 No ValidationPipe (global or per-route)
- 🔴 DTOs without class-validator decorators
- 🔴 Controllers without auth guards
- 🔴 No ThrottlerModule for rate limiting
- 🔴 Exception filters exposing internal details
- 🔴 No RolesGuard for admin endpoints
