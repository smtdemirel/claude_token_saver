# CLAUDE.md
# AI Coding Agent Master Rules — v1.0
# Priority: CLAUDE.md > PROJECT_RULES.md > docs/ (query-on-demand)

---

## Identity & Priority

This file governs all agent behavior in this project. Reading order:
1. `CLAUDE.md` (this file) — baseline, always active
2. `PROJECT_RULES.md` — project overrides; take precedence over this file
3. `docs/` — extended reference; **do NOT read proactively**

To load relevant docs sections run:
```
db/query-rules.sh "<task keyword>"
```

---

## Core Principles

1. Do the minimum necessary. No extras, no future-proofing.
2. Prefer editing existing files over creating new ones.
3. Read before writing. Understand before changing.
4. One concern per change. Small, verifiable steps.
5. Trust the framework. Don't re-implement what the stack provides.
6. Three similar lines beat a premature abstraction.
7. Reversible first. Confirm before destructive actions.
8. Fail loudly at system boundaries. Trust internal code.

---

## Response Discipline

- Answer exactly what was asked. Nothing more.
- One-sentence updates while working. No running commentary.
- No trailing summaries after completing a task.
- No unnecessary headers or bullets for short answers.
- Code references: `[file.ts:42](file.ts#L42)` — always clickable.
- Never explain WHAT code does if the names already say it.
- Stop when the task is done.

---

## Prompting Discipline

- Confirm scope before writing code on ambiguous tasks.
- One focused question at a time — not five at once.
- Do not ask about optional parameters; infer or skip.
- Do not re-derive context already in the conversation.

---

## Folder / File Structure

```
project/
├── src/           # source code only
├── tests/         # mirrors src/ structure
├── docs/          # human-facing documentation
├── scripts/       # build, deploy, tooling
└── config/        # env config (no secrets committed)
```

- One concern per file. >300 lines → split it.
- Files: `kebab-case`. Classes/Components: `PascalCase`.
- No `utils.ts`, `helpers.js`, `misc/` — name by domain.

---

## Code Style

- Default: write no comments. Add one only when the WHY is non-obvious.
- No multi-line comment blocks. One short line max.
- Functions: one purpose, one abstraction level.
- Max function length: ~30 lines. If longer, extract.
- No magic numbers. Named constants only.
- No `any` types in typed languages.
- Prefer immutability. Avoid mutation unless performance demands it.
- Early returns. Avoid deep nesting.
- No `else` after a `return`.

---

## Architecture Discipline

- New abstraction only when the same pattern appears 3+ times.
- No cross-layer shortcuts (e.g., DB calls in controllers).
- Each service owns its data. No cross-service DB joins.
- No circular dependencies.
- Config via environment. No hardcoded URLs, ports, or credentials.
- Feature flags only when rollback is a real requirement.

---

## Dependency Discipline

- Add a new dependency only when: (a) building it takes >2 days, or (b) security/correctness is non-trivial.
- Pin versions. No `^` for production deps.
- Before adding: check license, maintenance status, bundle size.
- Remove unused dependencies immediately.

---

## Refactor Discipline

- Refactor only when: (a) required by the task, or (b) code is demonstrably fragile.
- Never refactor and change behavior in the same commit.
- No "cleanup while I'm here" unless it directly reduces risk.

---

## Documentation Discipline

- Document the WHY, not the WHAT.
- Public APIs: one-line description + parameter types.
- ADRs for non-obvious architectural decisions.
- No README sections for things evident from the code.
- Stale docs are worse than no docs. Delete or fix.

---

## Testing Discipline

- Unit: pure functions and domain logic.
- Integration: service boundaries and DB interactions (real DB, not mocks).
- E2E: critical user paths only.
- Do not mock what you own. Mock external services only.
- Test names: `[subject]_[condition]_[expected]`.
- One assertion per test where possible.
- All tests run in CI. No skipped tests on main.

---

## Error Handling

- Validate at system boundaries: user input, external APIs, file I/O.
- Do not validate internal function arguments unless they originate outside.
- Errors bubble up to the layer that can handle them.
- Log the cause, not just the effect.
- Never swallow exceptions silently.

---

## Naming Conventions

- Variables: intention-revealing nouns (`userCount`, not `cnt`).
- Booleans: `is`, `has`, `can` prefix (`isActive`, `hasPermission`).
- Functions: verb phrases (`fetchUser`, `calculateTotal`).
- Events: past tense (`userCreated`, `orderShipped`).
- Constants: `UPPER_SNAKE_CASE`.
- No abbreviations except universally known ones (`id`, `url`, `db`, `ctx`).

---

## Security Discipline

- Never commit secrets. `.env` locally; secret manager in production.
- Validate and sanitize all user input at the boundary.
- Parameterized queries always. Zero exceptions.
- HTTPS only in production.
- Least privilege: services and users get only what they need.
- Run dependency audit before each release.

See `docs/security.md` (OWASP checklist): `db/query-rules.sh "security"`

---

## Performance Discipline

- No premature optimization. Profile before changing.
- Optimize only when: (a) measured bottleneck exists, or (b) algorithm choice is obviously wrong.
- Cache at the right layer; don't cache prematurely.
- No `SELECT *` in production query paths.

---

## Token Budget Discipline

- Do NOT read `docs/` files proactively.
- Query first: `db/query-rules.sh "<task keyword>"` (returns ~200 tokens vs ~2000 for full file).
- Use `grep`/`find` before opening files.
- Read only the lines needed (use `offset` + `limit`).
- Summarize long tool outputs; do not echo verbatim.
- Do not re-read files just edited — the edit is already in context.

---

## Working Principles

1. Read the relevant file(s) first.
2. Understand what exists before adding anything.
3. Make the smallest change that solves the problem.
4. Verify: run tests or observe output.
5. Mark the task done. Stop.
