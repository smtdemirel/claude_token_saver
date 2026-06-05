# Testing
# Extended reference. Query: db/query-rules.sh "testing"

---

## Test Pyramid

```
      E2E (few)          ← critical user paths only; slow; fragile
   Integration (some)   ← service boundaries; real DB; medium speed
  Unit (many)           ← pure functions, domain rules; fast; stable
```

Run order in CI: unit → integration → e2e (fail fast).

## What to Test

| Layer | Test this | Skip this |
|-------|-----------|-----------|
| Unit | Pure functions, domain rules, edge cases | Framework glue, getters/setters |
| Integration | DB queries, repository methods, API contracts | Already-covered domain logic |
| E2E | Login flow, checkout, critical business paths | Every form validation edge case |

## Mock Policy

| Target | Mock? |
|--------|-------|
| External services (email, payment, S3, SMS) | YES |
| Your own repositories / services | NO |
| Database in unit tests | YES (in-memory or fake) |
| Database in integration tests | NO — use a real test DB |
| HTTP clients calling external APIs | YES |
| Clocks / random values | YES — always inject for determinism |

## Test File Structure

Mirror `src/` in `tests/`:
```
src/domain/order.ts       → tests/domain/order.test.ts
src/services/order.ts     → tests/services/order.test.ts
src/repositories/order.ts → tests/repositories/order.test.ts
```

## Test Quality Rules

- **Deterministic**: No `Math.random()` or `Date.now()` without injection.
- **No sleep**: Use event-driven waiting or polling with timeout — never `sleep(500)`.
- **Clean up**: Each test leaves no side effects. Use `beforeEach`/`afterEach` or transactions.
- **Naming**: `subjectOrMethod_condition_expectedOutcome` — readable on failure.
- **One assertion per test** where practical. One reason to fail.
- **No test dependencies**: Tests run in any order.

## CI Requirements

- All tests run on every PR.
- No skipped tests (`skip`, `xit`, `@Ignore`) on main branch — fix or delete.
- Test timeout: 30s per test, 5min per suite.
- Coverage gates enforced by CI (set thresholds in `PROJECT_RULES.md`).
