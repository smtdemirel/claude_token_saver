# Claude Token Saver

A portable, token-efficient rule set for AI coding agents.
Drop it into any project and Claude follows consistent, professional engineering practices from day one.

---

## What's Included

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Master agent rules — Claude reads this automatically |
| `PROJECT_RULES.md` | Your project-specific overrides (fill this in) |
| `docs/` | Extended rules loaded on demand via FTS5 |
| `db/` | SQLite FTS5 index — token-efficient rule lookup |
| `install.sh` | One-command setup for any project |
| `templates/` | Minimal starters for new projects |

---

## Quick Start (5 minutes)

### Option A — Install into an existing project

```bash
# Clone this repo somewhere permanent
git clone https://github.com/smtdemirel/claude_token_saver.git ~/claude-token-saver

# Install into your project
bash ~/claude-token-saver/install.sh /path/to/your/project

# Edit project overrides
nano /path/to/your/project/PROJECT_RULES.md

# Rebuild index after editing
/path/to/your/project/db/build-index.sh
```

### Option B — Git submodule (stays updatable)

```bash
cd your-project
git submodule add https://github.com/smtdemirel/claude_token_saver.git .claude-token-saver
bash .claude-token-saver/install.sh .
```

### Option C — Manual copy

```bash
cp CLAUDE.md /path/to/your/project/
cp -r docs/ db/ /path/to/your/project/
cp templates/PROJECT_RULES.template.md /path/to/your/project/PROJECT_RULES.md
# Edit PROJECT_RULES.md, then rebuild:
/path/to/your/project/db/build-index.sh
```

---

## How It Works

### 1. Claude reads `CLAUDE.md` automatically

Claude Code discovers `CLAUDE.md` in the project root and follows its rules in every conversation. The file is kept short (~200 lines) — it covers all disciplines without bloating context.

### 2. `PROJECT_RULES.md` overrides the base rules

Fill in your stack, team conventions, and any rule overrides. Claude checks this file and gives it precedence over `CLAUDE.md`.

### 3. `docs/` is loaded on demand via SQLite FTS5

The `docs/` folder contains detailed rule sections (~2000 tokens per file). Claude **never reads them proactively**. Instead:

```bash
# Claude (or you) runs:
db/query-rules.sh "security"        # → returns only auth/SQL/OWASP sections
db/query-rules.sh "test mock"       # → returns mock policy section
db/query-rules.sh "naming boolean"  # → returns naming conventions
```

This saves **60-70% of token consumption** from rule loading.

---

## Keeping Rules Up to Date

```bash
# Pull latest base rules
git -C ~/claude-token-saver pull

# Re-install (PROJECT_RULES.md is preserved)
bash ~/claude-token-saver/install.sh /path/to/your/project
```

---

## Customizing

1. **Do NOT edit `CLAUDE.md` directly** — use `PROJECT_RULES.md` for overrides.
2. Add project-specific rules under the appropriate section in `PROJECT_RULES.md`.
3. Add domain-specific docs to `docs/your-topic.md` — they'll be auto-indexed.
4. Re-run `db/build-index.sh` after any docs change.

---

## File Structure

```
claude-token-saver/
├── CLAUDE.md                    ← Master rules (always read)
├── PROJECT_RULES.md             ← Your overrides (always read)
├── README.md                    ← This file
├── install.sh                   ← Setup script
├── docs/
│   ├── code-style.md           ← Code style (query on demand)
│   ├── architecture.md         ← Architecture patterns
│   ├── testing.md              ← Testing discipline
│   ├── security.md             ← OWASP checklist + rules
│   └── token-budget.md        ← Token optimization guide
├── db/
│   ├── schema.sql              ← FTS5 table definition
│   ├── build-index.sh          ← Parses .md files into rules.db
│   └── query-rules.sh          ← Search rules by keyword
└── templates/
    ├── AGENTS.template.md      ← Minimal starter
    └── PROJECT_RULES.template.md
```

---

## Why SQLite FTS5?

- **Zero dependencies**: `sqlite3` ships with macOS and is one `apt install` on Linux.
- **Fast**: FTS5 full-text search returns results in milliseconds.
- **Token-efficient**: Returns only matching paragraphs (~100-200 tokens) instead of full files (~2000 tokens each).
- **Offline**: No API calls, no network, no cost.
- **Portable**: The `rules.db` file travels with the project.

See [SQLite FTS5 documentation](https://www.sqlite.org/fts5.html) for advanced query syntax.

---

## Contributing

1. Fork and clone.
2. Edit rule files in `docs/` or `CLAUDE.md`.
3. Run `db/build-index.sh` to verify indexing works.
4. Run `db/query-rules.sh "your topic"` to verify search works.
5. Submit a PR with a clear description of what rule was added/changed and why.
