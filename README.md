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
| `hooks/` | Claude Code hooks — guaranteed rule injection + context management |
| `scripts/` | Project snapshot generator for session continuity |
| `install.sh` | One-command setup for any project |
| `update.sh` | One-command update (preserves your PROJECT_RULES.md) |
| `uninstall.sh` | One-command removal (asks before deleting customized files) |
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

To update at any time:
```bash
git submodule update --remote .claude-token-saver
bash .claude-token-saver/update.sh .
```

`update.sh` copies all files, preserves `PROJECT_RULES.md`, and rebuilds the FTS5 index.

### Option C — Manual copy

```bash
cp CLAUDE.md /path/to/your/project/
cp -r docs/ db/ hooks/ scripts/ /path/to/your/project/
cp templates/PROJECT_RULES.template.md /path/to/your/project/PROJECT_RULES.md
# Edit PROJECT_RULES.md, then rebuild:
/path/to/your/project/db/build-index.sh
```

---

## How It Works

### 1. Claude reads `CLAUDE.md` automatically

Claude Code discovers `CLAUDE.md` in the project root and follows its rules in every conversation. The file is kept short (~200 words) — it covers all disciplines without bloating context.

### 2. `PROJECT_RULES.md` overrides the base rules

Fill in your stack, team conventions, and any rule overrides. Claude checks this file and gives it precedence over `CLAUDE.md`.

### 3. Five hooks guarantee rule injection and context management

`install.sh` registers five Claude Code hooks in `.claude/settings.json`. These hooks run **outside Claude's decision loop** — they fire automatically, before Claude even sees the message.

| Hook | Event | What it does |
|------|-------|--------------|
| `session-start.sh` | SessionStart | Injects project snapshot on every new chat (~300 tokens) |
| `inject-rules.sh` | UserPromptSubmit | Queries FTS5 → injects matching rule sections (~150 tokens) |
| `pre-tool-guard.sh` | PreToolUse | Intercepts expensive Bash commands, suggests token-efficient alternatives |
| `post-tool-trim.sh` | PostToolUse | Reminds Claude to extract only what's needed from large outputs |
| `pre-compact.sh` | PreCompact | Refreshes project snapshot before compaction so context stays accurate |
| `context-guard.sh` | Stop | Monitors transcript size, nudges Claude to recommend a new chat |

**Why hooks are reliable:** Unlike CLAUDE.md instructions (which Claude may or may not follow), hooks execute deterministically at the OS level — Claude has no say in whether they run.

**Token flow on a new chat:**
```
New chat opens
       ↓
SessionStart hook fires
       ↓
session-start.sh reads project snapshot (~300 tokens)
       ↓
Claude knows project state without reading any files
```

**Token flow on every prompt:**
```
User types a prompt
       ↓
UserPromptSubmit hook fires (guaranteed)
       ↓
inject-rules.sh extracts keywords from the prompt
       ↓
Queries FTS5 index → returns only relevant rule sections (~150 tokens)
       ↓
Claude sees prompt + relevant rules together
```

**Token savings from context management:**
```
End of Claude's turn
       ↓
Stop hook fires
       ↓
context-guard.sh checks transcript file size
       ↓
> 80KB: suggests new chat | > 200KB: strongly recommends new chat
       ↓
New chat starts fresh with only the project snapshot (~300 tokens)
instead of full conversation history
```

---

## Getting Notified of Updates

### GitHub Watch (everyone)

On the GitHub repo page, click **Watch → Custom → Releases**. You'll get an email when a new release is published.

### Dependabot (Option B — submodule users)

Copy `templates/dependabot.yml` to your project's `.github/dependabot.yml`:

```bash
mkdir -p .github
cp .claude-token-saver/templates/dependabot.yml .github/dependabot.yml
git add .github/dependabot.yml && git commit -m "chore: add dependabot for claude-token-saver"
```

Dependabot checks the submodule weekly and opens a PR automatically when there are new commits. After merging the PR:

```bash
bash .claude-token-saver/update.sh .
```

---

## Keeping Rules Up to Date

### Option A — Standalone clone

```bash
# Pull latest rules
git -C ~/claude-token-saver pull

# Apply to your project (PROJECT_RULES.md is preserved)
bash ~/claude-token-saver/update.sh /path/to/your-project
```

### Option B — Git submodule

```bash
# 1. Pull submodule to latest commit
git submodule update --remote .claude-token-saver

# 2. Apply to project (PROJECT_RULES.md is preserved)
bash .claude-token-saver/update.sh .
```

`PROJECT_RULES.md` is never overwritten in either case.

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
├── VERSION                      ← Current version
├── install.sh                   ← Setup script (copies files + registers hooks)
├── update.sh                    ← Update script (preserves PROJECT_RULES.md)
├── uninstall.sh                 ← Removal script (asks before deleting customized files)
├── hooks/
│   ├── session-start.sh        ← SessionStart: injects project snapshot
│   ├── inject-rules.sh         ← UserPromptSubmit: FTS5 → additionalContext
│   ├── pre-tool-guard.sh       ← PreToolUse: blocks expensive Bash patterns
│   ├── post-tool-trim.sh       ← PostToolUse: brevity reminder on large outputs
│   ├── pre-compact.sh          ← PreCompact: refreshes snapshot before compaction
│   ├── context-guard.sh        ← Stop: monitors transcript size
│   └── setup-hooks.sh          ← Registers all hooks + env vars in .claude/settings.json
├── scripts/
│   └── snapshot.sh             ← Generates .claude/project-snapshot.md
├── docs/
│   ├── code-style.md           ← Code style (query on demand)
│   ├── architecture.md         ← Architecture patterns
│   ├── testing.md              ← Testing discipline
│   ├── security.md             ← OWASP checklist + rules
│   ├── token-budget.md         ← Token optimization guide
│   ├── error-handling.md       ← Error handling patterns
│   ├── git-workflow.md         ← Git workflow rules
│   └── session-management.md   ← Context rot, /rewind, handoff patterns
├── db/
│   ├── schema.sql              ← FTS5 table definition
│   ├── build-index.sh          ← Parses .md files into rules.db
│   └── query-rules.sh          ← Search rules by keyword
└── templates/
    ├── PROJECT_RULES.template.md
    └── dependabot.yml
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

## Requirements

- `bash` 3.2+
- `python3` (for hooks and hook registration)
- `sqlite3` (for FTS5 index — ships with macOS, `apt install sqlite3` on Linux)
- `git` (optional — for snapshot git state)

---

## Contributing

1. Fork and clone.
2. Edit rule files in `docs/` or `CLAUDE.md`.
3. Run `db/build-index.sh` to verify indexing works.
4. Run `db/query-rules.sh "your topic"` to verify search works.
5. Submit a PR with a clear description of what rule was added/changed and why.
