# Security
# Extended reference. Query: db/query-rules.sh "security"

---

## Input Validation (every system boundary)

- Validate type, format, length, and range of all incoming data.
- Reject unexpected/extra fields — no mass assignment.
- Sanitize HTML where display is required (use a proven library, not regex).
- Never trust client-provided IDs for authorization decisions.

## Authentication & Authorization

- Never roll your own auth algorithm. Use the framework's auth or a proven library.
- JWT: short expiry (15min access / 7d refresh). Validate signature AND claims (iss, aud, exp).
- Check authorization on every request. Never rely on client-side role state.
- Admin routes: require MFA. Rate-limit login endpoints.
- Session fixation: regenerate session ID after login.

## SQL & Query Safety

- Parameterized queries always. Zero exceptions. No string concatenation in SQL.
- No raw SQL outside of repository layer.
- Limit result sets: never `SELECT *` in production paths; always paginate.

## Secrets Management

- Never commit secrets to git — not even in history.
- `.env` for local development; secret manager (Vault, AWS SSM, GCP Secret Manager) for production.
- Rotate secrets immediately on suspected exposure.
- Secrets never appear in logs, error messages, or API responses.

## Dependencies

- Run audit before each release: `npm audit` / `composer audit` / `pip-audit` / `bundle audit`.
- No packages with known critical CVEs in production.
- Pin exact versions for production deps. Review diffs on version bumps.

## OWASP Top 10 Checklist

| # | Category | Check |
|---|----------|-------|
| 1 | Broken Access Control | Auth check on every endpoint; test with another user's token |
| 2 | Cryptographic Failures | HTTPS enforced; PII encrypted at rest |
| 3 | Injection | Parameterized queries; no eval/exec of user input |
| 4 | Insecure Design | Threat model before building auth or payment flows |
| 5 | Security Misconfiguration | Debug off in prod; no default credentials; headers set |
| 6 | Vulnerable Components | Dep audit in CI; no critical CVEs |
| 7 | Auth Failures | MFA for admins; rate-limit login; lockout policy |
| 8 | Integrity Failures | Verify package checksums in CI; sign releases |
| 9 | Logging Failures | Log auth events; no PII in logs; log errors with context |
| 10 | SSRF | Validate & whitelist all outbound URLs; no user-controlled fetch targets |

## Security Headers (HTTP APIs)

```
Content-Security-Policy
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: (restrict unused features)
```
