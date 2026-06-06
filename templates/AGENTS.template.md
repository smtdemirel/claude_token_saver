# CLAUDE.md
# Minimal starter template — copy to your project root.
# Extend with PROJECT_RULES.md for project-specific overrides.

---

## Priority

1. `CLAUDE.md` (this file) — always active
2. `PROJECT_RULES.md` — project overrides; take precedence
3. `docs/` — extended reference; query on demand: `db/query-rules.sh <keyword>`

---

## Core Rules

1. Read before writing. Understand before changing.
2. Smallest change that solves the problem. Nothing more.
3. No over-engineering. No future-proofing.
4. No comments unless the WHY is non-obvious.
5. Validate at system boundaries only.
6. Trust the framework. Don't re-implement what it provides.
7. Confirm before destructive actions.

---

## Response Discipline

- Answer what was asked. Stop there.
- No trailing summaries. No running commentary.
- Code refs: `[file.ts:42](file.ts#L42)`.

---

## Token Budget

- Do NOT read `docs/` proactively.
- Query first: `db/query-rules.sh "<keyword>"` → returns only relevant sections.
- Use `grep`/`find` before opening files.

---

<!-- Add project-specific rules below, or use PROJECT_RULES.md for overrides -->
