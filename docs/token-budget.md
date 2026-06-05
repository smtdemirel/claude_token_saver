# Token Budget
# Extended reference. Query: db/query-rules.sh "token budget"

---

## The Core Problem

Reading entire rule files at session start wastes context window space with content irrelevant to the current task. A 200-line docs file = ~2000 tokens. Multiply by 5 files = 10,000 tokens consumed before writing a single line of code.

## Rule Loading Strategy

| Source | When to load |
|--------|-------------|
| `AGENTS.md` | Always (it is short by design) |
| `PROJECT_RULES.md` | Once at session start |
| `docs/*.md` | On demand via `db/query-rules.sh` only |

```bash
# Load only what's relevant to the current task:
db/query-rules.sh "authentication"   # → security sections on auth (~200 tokens)
db/query-rules.sh "refactor"        # → refactor discipline only
db/query-rules.sh "test mock"       # → testing mock policy
db/query-rules.sh "naming variable" # → naming conventions
```

Savings: ~60-70% fewer tokens from rule loading.

## File Reading Strategy

Before opening a file:
1. `grep -r "keyword" src/` to locate the right file.
2. `find . -name "*.ts" -path "*/auth/*"` to narrow scope.
3. Open only the file you need, with `offset`+`limit` if it's large.
4. Do not re-read a file you just edited — the edit is already in context.

## Response Length Discipline

| Task type | Response length |
|-----------|----------------|
| Simple question | 1-2 sentences |
| Code change | Diff summary + 1 sentence |
| Investigation | Findings only, no restating of facts already in context |
| Error debugging | Root cause + fix, not the full stack trace echoed back |

## Context Pruning Rules

- Do not echo tool results back verbatim. Summarize.
- When context is long, state what you know rather than re-reading files.
- Avoid "let me also check…" chains when the primary source already answered the question.
- Stop after the task is complete. No trailing analysis or unsolicited suggestions.

## What Inflates Context (avoid)

- Reading entire files when only a function is needed.
- Re-reading files to verify edits (trust the Edit tool).
- Explaining plan before executing simple tasks.
- Restating the user's request back to them.
- Listing alternatives not asked for.
- Summarizing what you just did (the diff already shows it).

## FTS5 Query Reference

```bash
# Syntax: db/query-rules.sh "<search terms>" [limit]
db/query-rules.sh "security auth jwt"
db/query-rules.sh "architecture service boundary"
db/query-rules.sh "testing integration mock" 3
db/query-rules.sh "performance cache"
db/query-rules.sh "naming convention boolean"
```

Default limit: 5 sections. Override with second arg.
