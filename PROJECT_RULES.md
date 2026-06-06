# PROJECT_RULES.md
# Project-specific overrides for CLAUDE.md
# Rules here take precedence over CLAUDE.md.
# Delete any section you don't need — blank sections inherit CLAUDE.md defaults.

---

## Stack

- Language:       # e.g. TypeScript 5.x / PHP 8.3 / Python 3.12 / Dart 3.x
- Framework:      # e.g. Next.js 14 / Laravel 11 / FastAPI / Flutter 3.x
- Database:       # e.g. PostgreSQL 16 + Redis 7 / SQLite / MongoDB
- Test runner:    # e.g. Vitest / PHPUnit / pytest / flutter test
- Package manager:# e.g. pnpm / composer / pip / pub

---

## Team Conventions

# List team-specific naming or structural conventions here.
# e.g.:
# - Branch naming: feature/<ticket-id>-short-description
# - Commit format: Conventional Commits (feat/fix/chore/docs)
# - PR size: max 400 lines changed per PR

---

## Overrides

### Code Style
# e.g. "Turkish comments are acceptable in domain layer"
# e.g. "Max function length is 50 lines for this project"

### Architecture
# e.g. "All DB calls go through Repository pattern in src/repositories/"
# e.g. "Use CQRS — reads in src/queries/, writes in src/commands/"

### Testing
# e.g. "E2E tests use Playwright: pnpm test:e2e"
# e.g. "Minimum unit test coverage: 80% for src/domain/"

### Token Budget
# e.g. "Always read src/types/global.d.ts at session start"
# e.g. "Check CHANGELOG.md before touching auth module"

---

## Project-Specific Rules

# Rules that don't fit any category above.
# e.g.:
# - Never use `console.log` in production code; use the Logger service
# - All API responses follow the envelope pattern: {data, meta, errors}
# - Migrations are irreversible; always write a rollback plan in PR description

---

## Forbidden

# Things that must NEVER happen in this project.
# e.g.:
# - Never use raw SQL outside of src/repositories/
# - Never import from src/internal/ in test files
# - Never push directly to main/master
# - Never store PII in application logs
