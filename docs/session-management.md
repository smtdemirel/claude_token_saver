# Session Management

## Context Rot — Why It Matters

Every token attends to every other token (n² attention). A 100K context costs 4× more compute than a 50K context per message. More critically:

- Accuracy follows a **U-curve**: models are strongest at the beginning and end of context, worst in the **middle**.
- With 100K+ tokens, content in the middle suffers a **30%+ accuracy drop**.
- This is an architectural property of transformers — a larger context window doesn't fix it.

**Implication**: a long-running session is not just more expensive — it's less accurate.

## Auto-Compaction Threshold

This project sets `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` in `.claude/settings.json`.

This means compaction triggers at 70% context fill instead of the default ~83.5%. The benefit:
- The worst 13% of context (where accuracy degrades most) is never reached.
- Each compacted session starts fresh with ~12% of the original token count.
- More frequent compaction → smaller sessions → more consistent accuracy.

To override for a project: edit `.claude/settings.json` and change the value under `"env"`.

## `/rewind` vs `/compact` — When to Use Each

### `/rewind` — roll back to a previous turn

Use when you want to undo a wrong direction without losing cache warmth.

- Truncates history to a previous turn.
- That turn's prefix is still **warm in the prompt cache** (kept warm by all intermediate turns).
- Rolling back is effectively **free** from a cache perspective.
- Next message hits the cache immediately — no reprocessing of history.

**When to use**: Claude went in the wrong direction, made a wrong assumption, or started an approach you want to abandon.

### `/compact` — summarize and continue

Use at a natural task breakpoint when context is getting large.

- Builds a new summary (~12% of original tokens).
- The new session does **not** share the cache of the old session.
- First message after `/compact` pays the full cost of re-warming the cache.
- Keeps task continuity within the same project.

**When to use**: You've completed a logical unit of work and are starting something new.

### New chat — recommended for distinct tasks

- Starts with only the project snapshot (~300 tokens) and `CLAUDE.md`.
- The **cheapest** starting point if the current task is unrelated to previous context.
- Prompted by the `context-guard.sh` hook when transcript exceeds 80KB.

**When to use**: Moving to a clearly different task, or when the context-guard recommends it.

## Session Handoff Pattern

When starting a new chat after complex work, paste this into the first message:

```
Continuing from previous session.

Task: <one line — what you're building>
Completed: <what's done>
In progress: <what's partially done>
Failed approaches: <what didn't work and why>
Key decisions: <architecture or design choices made>
Next step: <exactly what to do next>
```

This gives Claude a clean start with full context in ~100 tokens instead of reprocessing conversation history.

## Subagent Model Routing

Subagents doing routine work (searching files, running tests, formatting) don't need Opus-level reasoning.

Add to `.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  }
}
```

Or use the env var when launching: `CLAUDE_CODE_SUBAGENT_MODEL=haiku claude`

Reported cost reduction: **up to 75%** for subagent-heavy workflows.

## `.claudeignore` — Reducing Proactive Scan Cost

Claude Code can proactively scan the project structure to orient itself. `.claudeignore` de-prioritizes directories that are rarely useful:

- `node_modules/`, `dist/`, `build/`, `vendor/` — never need to scan these
- `*.lock` files — large, rarely useful to read directly
- Log directories — noisy, not helpful for code tasks

Copy the template into your project:
```bash
cp .claude-token-saver/templates/.claudeignore .claudeignore
```

Anthropic measured this at ~85.5% reduction in file scan tokens on projects with large dependency trees.

## Hard Output Caps (Environment Variables)

Set in `.claude/settings.json` under `"env"` (done automatically by `setup-hooks.sh`):

| Variable | Value | Effect |
|----------|-------|--------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `70` | Compact at 70% fill, not 83.5% |
| `BASH_MAX_OUTPUT_LENGTH` | `20000` | Truncates bash output before it enters context |
| `MAX_MCP_OUTPUT_TOKENS` | `8000` | Caps MCP tool responses |

These caps run **before** Claude sees the output — more effective than PostToolUse hooks alone.

## Commits as Context Reducers

`git diff` output is passively included in Claude's context awareness. Large diffs consume tokens on every message.

Commit completed work frequently:
```bash
git commit -m "feat: ..."  # clears the diff from passive context
```

After a commit, `git diff` is empty → passive overhead drops to near zero for subsequent messages.
