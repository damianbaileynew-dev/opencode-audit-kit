---
name: security-audit-full
description: >-
  Comprehensive security audit. OWASP Top 10, CWE Top 25, 17 ecosystem support, cloud (AWS/Azure/GCP).
  Triggers: "full security audit", "OWASP audit", "CWE scan", "security hardening"
---
---
name: security-audit
description: "Use when conducting security assessments — OWASP Top 10 / API / LLM, CWE Top 25, CVSS scoring — auditing PHP/TYPO3 (v14.3 LTS: #109585, HashService removal, Authorize/RateLimit), APIs, frontend, Terraform/K8s/Docker IaC, AWS/Azure/GCP cloud, AI agent configs, or scanning dependencies."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires grep, jq, gh CLI."
metadata:
  author: Netresearch DTT GmbH
  version: "2.10.1"
  repository: https://github.com/netresearch/security-audit-skill
allowed-tools: Bash(grep:*) Bash(jq:*) Bash(gh:*) Read Glob Grep
---

# Security Audit Skill

Security audit patterns (OWASP Top 10, LLM Top 10 2025, CWE Top 25 2025, CVSS v4.0), cloud/IaC, GitHub security. 80+ PHP/TYPO3 checkpoints (v14.3 LTS in `typo3-security.md`).

## Expertise Areas

- **Vulnerabilities**: XXE, SQLi, XSS, CSRF, command injection, path traversal, file upload, deserialization, SSRF, SSTI, JWT, type juggling
- **Standards**: OWASP Top 10 / API / LLM (2025), CWE Top 25, CVSS v3.1/v4.0, OWASP ASVS
- **Cloud & IaC**: AWS, Azure, GCP; Terraform, Kubernetes, Docker, Helm
- **API & Frontend**: REST/GraphQL authZ, rate limits, mass assignment, CSP, DOM-XSS
- **AI Agents**: SKILL.md/AGENTS.md/CLAUDE.md/mcp.json/hooks.json audit; prompt injection; excessive agency

## Reference Files (in `references/`, `.md` implied)

- **Core**: owasp-top10, cwe-top25, xxe-prevention, cvss-scoring, api-key-encryption
- **Prevention**: deserialization-prevention, path-traversal-prevention, file-upload-security, input-validation, error-message-sanitization
- **Architecture**: authentication-patterns, security-headers, security-logging, cryptography-guide, security-invariants
- **Language features** (`*-security-features`): php, python, javascript-typescript, nodejs, java, csharp, go, rust, ruby
- **Frameworks** (`*-security`): typo3, typo3-fluid, typo3-typoscript, symfony, laravel, django, flask, fastapi, spring, dotnet, blazor, rails, gin, react, vue, angular, nextjs, nuxt, express, nestjs
- **Mobile**: android-sdk-security, ios-sdk-security
- **Cloud & IaC**: aws-security, azure-security, gcp-security, iac-security
- **API & Frontend**: api-security, frontend-security
- **AI Agent**: llm-security (OWASP LLM Top 10 2025)
- **Shared**: framework-security
- **Threats**: modern-attacks, cve-patterns, cve-database
- **DevSecOps**: ci-security-pipeline, supply-chain-security, automated-scanning, gha-security, git-history-secrets
- **Incident**: supply-chain-incident-response

## Quick Patterns

**XML parsing (prevent XXE):**
```php
$doc->loadXML($input, LIBXML_NONET);
```

**SQL (prevent injection):**
```php
$stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
$stmt->execute([$id]);
```

**Output (prevent XSS):**
```php
echo htmlspecialchars($input, ENT_QUOTES | ENT_HTML5, 'UTF-8');
```

**API keys, passwords, randomness:**
```php
$n = random_bytes(SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
$enc = 'enc:' . base64_encode($n . sodium_crypto_secretbox($apiKey, $n, $key));
password_hash($pw, PASSWORD_ARGON2ID);
bin2hex(random_bytes(32));   // never mt_rand/rand
```

Automated scanners: `references/automated-scanning.md`.

## Security Checklist

- [ ] `semgrep`/`opengrep`, `trivy fs --severity HIGH,CRITICAL`, `gitleaks` clean
- [ ] bcrypt/Argon2 passwords, CSRF on state changes, TLS 1.2+
- [ ] Server-side input validation; parameterized SQL; XML entities off
- [ ] Output encoding + CSP; no unserialize() on user input
- [ ] API keys encrypted; exception messages sanitized
- [ ] Secrets out of VCS; audit logging on
- [ ] Uploads validated, renamed, outside web root
- [ ] Headers HSTS + X-Content-Type-Options; dependencies scanned

## GitHub Actions Security

- **NEVER** interpolate `${{ inputs.* }}` / `${{ github.event.* }}` in `run:` — use `env:`
- Dependency triage: upgrade > override > dismiss. Full patterns: `references/gha-security.md`.

## STRIDE Threat Modeling (Start Every Audit)

Before scanning for patterns, spend 5 minutes thinking like an attacker. Controls without a threat model are guesses.

**Step 1: Map Trust Boundaries** — Where does untrusted data enter?
- HTTP requests, form fields, file uploads, webhooks, third-party APIs, message queues, **LLM output**
- Every boundary is attack surface

**Step 2: Name the Assets** — What's worth stealing or breaking?
- Credentials, PII, payment data, admin actions, money movement

**Step 3: Run STRIDE per boundary:**

| Threat | Ask | Typical Mitigation |
|--------|-----|--------------------|
| **S**poofing | Can someone impersonate a user/service? | Authentication, signature verification |
| **T**ampering | Can data be altered in transit or at rest? | Integrity checks, parameterized queries, HTTPS |
| **R**epudiation | Can an action be denied later? | Audit logging of security events |
| **I**nformation disclosure | Can data leak? | Encryption, field allowlists, generic errors |
| **D**enial of service | Can it be overwhelmed? | Rate limiting, input size caps, timeouts |
| **E**levation of privilege | Can a user gain rights they shouldn't? | Authorization checks, least privilege |

**Step 4: Write abuse cases next to use cases.** For each feature ask: "How would I misuse this?" — make that your first test.

If you can't name the trust boundaries for a feature, you're not ready to secure it. This is OWASP **A04: Insecure Design**.

## Three-Tier Boundary System

### Always Do (No Exceptions)
- Validate all external input at the system boundary
- Parameterize all database queries — never concatenate user input into SQL
- Encode output to prevent XSS (use framework auto-escaping, don't bypass it)
- Use HTTPS for all external communication
- Hash passwords with bcrypt/scrypt/argon2 (never store plaintext)
- Set security headers (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
- Use httpOnly, secure, sameSite cookies for sessions
- Run `npm audit` (or equivalent) before every release

### Ask First (Requires Human Approval)
- Adding new authentication flows or changing auth logic
- Storing new categories of sensitive data (PII, payment info)
- Adding new external service integrations
- Changing CORS configuration
- Adding file upload handlers
- Modifying rate limiting or throttling
- Granting elevated permissions or roles

### Never Do
- Never commit secrets to version control (API keys, passwords, tokens)
- Never log sensitive data (passwords, tokens, full credit card numbers)
- Never trust client-side validation as a security boundary
- Never disable security headers for convenience
- Never use `eval()` or `innerHTML` with user-provided data
- Never store sessions in client-accessible storage (localStorage for auth tokens)
- Never expose stack traces or internal error details to users

## Reference Files

For detailed checklists, see:
- **Security Checklist**: `references/security-checklist.md` — OWASP Top 10, LLM Top 10, pre-commit checks, auth, CORS
- **Testing Patterns**: `references/testing-patterns.md` — Test doubles, edge cases, naming conventions

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Input validation isn't needed on internal APIs" | Internal APIs get called from compromised hosts, SSRF, or are exposed accidentally. Validate everywhere. |
| "We'll add security headers later" | Later never comes. One missing header can enable clickjacking or XSS. Add them now. |
| "This endpoint doesn't handle sensitive data" | Today it doesn't. Tomorrow it will. Secure by default. |
| "The framework handles XSS automatically" | Framework escaping only works if you don't bypass it with `innerHTML`, `v-html`, or `dangerouslySetInnerHTML`. |
| "Rate limiting isn't needed for this scale" | Rate limiting prevents abuse at any scale. 10 requests/second from one IP is abuse. |
| "OWASP is overkill for this project" | OWASP patterns are minimal viable security. Skipping them means accepting known vulnerabilities. |

## Red Flags

- 🔴 Unparameterized SQL queries with string concatenation
- 🔴 Passwords stored in plaintext or with weak hashing (MD5, SHA-1)
- 🔴 `eval()`, `innerHTML`, or `dangerouslySetInnerHTML` with user input
- 🔴 CORS set to `*` in production
- 🔴 Secrets hardcoded in source code
- 🔴 No authentication check on sensitive endpoints
- 🔴 Stack traces exposed in error responses
- 🔴 No rate limiting on login/auth endpoints
- 🔴 File uploads without type/size validation
- 🔴 Missing security headers (no helmet, no CSP)

## Verification

```bash
./scripts/security-audit-dispatcher.sh /path/to/project  # auto-detect stack
./scripts/security-audit.sh /path/to/project             # PHP-only
./scripts/github-security-audit.sh owner/repo            # GH repo
```

After automated scan, verify STRIDE coverage:
- [ ] All trust boundaries identified and documented
- [ ] Each boundary has controls for applicable STRIDE threats
- [ ] No "Never Do" patterns found in codebase
- [ ] All "Always Do" items confirmed present
- [ ] Abuse cases written for critical features

---

> Contributing: https://github.com/netresearch/security-audit-skill
