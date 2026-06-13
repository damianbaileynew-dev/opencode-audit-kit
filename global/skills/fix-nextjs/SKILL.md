---
name: fix-nextjs
mode: subagent
model: opencode/deepseek-v4-flash-free
permission:
  bash: allow
  edit: allow
  write: allow
  read: allow
---

# Next.js Bug Fix Skill — 13 Steps

You are a Next.js security & quality expert. Fix ALL bugs in this project across 10 dimensions.

## ADIM 1: Security — Security Headers + Rate Limiting

Add security headers in `next.config.js`:

```js
const securityHeaders = [
  { key: "X-Frame-Options", value: "DENY" },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "X-XSS-Protection", value: "1; mode=block" },
];

module.exports = {
  async headers() {
    return [{ source: "/(.*)", headers: securityHeaders }];
  },
};
```

Create `src/middleware.js` for rate limiting + CORS:

```js
import { NextResponse } from "next/server";

const rateLimitMap = new Map();

export function middleware(request) {
  const ip = request.ip || "unknown";
  const now = Date.now();
  const entry = rateLimitMap.get(ip);
  if (entry && entry.count >= 100 && now < entry.resetTime) {
    return NextResponse.json({ error: "Too many requests" }, { status: 429 });
  }
  rateLimitMap.set(ip, { count: (entry?.count || 0) + 1, resetTime: now + 60000 });

  // CORS check
  const origin = request.headers.get("origin");
  const allowed = [process.env.CORS_ORIGIN || "http://localhost:3000"];
  if (origin && !allowed.includes(origin)) {
    return NextResponse.json({ error: "CORS denied" }, { status: 403 });
  }

  return NextResponse.next();
}

export const config = { matcher: "/api/:path*" };
```

## ADIM 2: Security — JWT from env + bcrypt rounds

Move `const SECRET = "secret"` to `process.env.JWT_SECRET` in ALL route files.
Change bcrypt hash rounds from 5 to 12: `bcrypt.hash(password, 12)`.

## ADIM 3: Security — sanitizeUser + httpOnly cookie

```js
// src/lib/auth.js
export function sanitizeUser(user) {
  const { password, ...safeUser } = user;
  return safeUser;
}
```

In login/register: use `response.cookies.set("token", token, { httpOnly: true, secure: process.env.NODE_ENV === "production", maxAge: 86400, sameSite: "lax", path: "/" })`.
In logout: `response.cookies.set("token", "", { maxAge: 0, path: "/" })`.

## ADIM 4: Security — Admin auth + mass assignment + XSS fix

- Admin routes: verify JWT + check `role === "admin"`, return 403 if not admin
- Mass assignment: extract only allowed fields `const { title, desc, priority, assignee } = body;`
- XSS: Remove ALL `dangerouslySetInnerHTML`, use normal JSX `{t.title}` (React auto-escapes)

## ADIM 5: Performance — Pagination + N+1 fix

Add pagination to GET /api/tasks: `?page=1&limit=20`
Batch load comments using Map instead of per-task query.
Add pagination to search: `?q=keyword&page=1&limit=20`

## ADIM 6: Code Quality — Validation + Bearer strip + error handling

- Password: `if (password.length < 8) return 400`
- Title: `if (!title || title.trim().length === 0) return 400`
- Bearer strip: `const token = auth.startsWith("Bearer ") ? auth.slice(7) : auth;`
- Status codes: 201, 400, 401, 403, 404, 409, 500

## ADIM 7: Architecture — Service layer + config file

Create `src/lib/` directory with:
- `src/lib/auth.js` — hashPassword, sanitizeUser, verifyToken
- `src/lib/tasks.js` — task CRUD with pagination
- `src/lib/config.js` — `process.env.JWT_SECRET`, `BCRYPT_ROUNDS`, `CORS_ORIGIN`

## ADIM 8: Test — jest + integration

Create `__tests__/api.test.js` with:
- Register + login tests
- Short password rejection
- Duplicate user rejection
- Admin auth required
Install: `npm install -D jest @testing-library/react @types/jest`

## ADIM 9: Frontend — Full a11y/UX/SEO

layout.js: `lang="en"`, charset, viewport meta, `<header>`, `<main>`, meta description, OG tags, canonical, JSON-LD.
page.js: search input, filter select, error-message div, loading/Suspense, @media responsive, empty-state, label+aria, ESC close, focus management.
NO dangerouslySetInnerHTML — use React JSX auto-escaping.

## ADIM 10: DevOps — Dockerfile + CI + health + shutdown

- Dockerfile: FROM node:20-alpine, RUN useradd -m appuser, USER appuser
- .dockerignore: node_modules, .next, .git
- .github/workflows/ci.yml: checkout + npm ci + npm test
- /api/health route: `{ status: "ok" }`

## ADIM 11: SEO — robots + semantic HTML

- `public/robots.txt` or `src/app/robots.js`: User-agent: * Allow: /
- Semantic HTML: <header>, <main>, <nav>, <section>

## ADIM 12: Documentation — README + CONTRIBUTING + .env.example + comments

- README.md: API endpoints, npm install, npm run dev, npm test
- CONTRIBUTING.md: development guide
- .env.example: JWT_SECRET, BCRYPT_ROUNDS, CORS_ORIGIN
- Add inline comments (//) to all .js files (≥5 total)

## ADIM 13: DOĞRULAMA

After all fixes verify:
1. All API routes return correct status codes
2. No dangerouslySetInnerHTML
3. src/lib/ directory exists
4. src/middleware.js exists with rate limiting
5. next.config.js has security headers
6. public/robots.txt exists

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Next.js handles security automatically" | Next.js provides the framework, not security defaults. You must add middleware for rate limiting, security headers in next.config.js, and sanitize all user input. |
| "Server Components are secure by default" | Server Components run on the server but still handle user input. Validate and sanitize all props and searchParams. |
| "We don't need middleware — API routes handle auth" | Middleware runs before route handlers, enabling rate limiting, auth checks, and redirects at the edge. Without it, you're missing a critical defense layer. |
| "next.config headers are optional" | Security headers (CSP, HSTS, X-Frame-Options) prevent clickjacking, XSS, and MITM attacks. They're not optional in production. |

## Red Flags

- 🔴 No middleware.ts with rate limiting
- 🔴 No security headers in next.config.js
- 🔴 dangerouslySetInnerHTML with user data
- 🔴 No src/lib/ service layer (business logic in route handlers)
- 🔴 Missing robots.txt in public/
- 🔴 No metadata export for SEO (title, description, openGraph)
