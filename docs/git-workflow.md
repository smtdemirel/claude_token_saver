# Git Workflow

## Commit Rules

- Imperative mood: "Add feature" not "Added feature".
- One logical change per commit. Never mix refactor + behavior change.
- Never commit secrets, credentials, or `.env` files.
- Never amend published commits (use a new fixup commit instead).
- Never skip hooks (`--no-verify`) unless explicitly asked.

## Branch Strategy

- `main` / `master` — always deployable; no direct pushes.
- `feature/<slug>` — one feature or fix per branch.
- `fix/<slug>` — bug fix branches.
- `chore/<slug>` — tooling, dependencies, CI changes.
- Delete branches after merge.

## Pull Request Rules

- PR title: imperative mood, under 70 characters.
- PR body: what changed and why — not a list of file names.
- Every PR needs: passing CI, at least one reviewer.
- Keep PRs small. Split large changes into sequential PRs.
- Prefer one bundled PR over many tiny ones for related refactors.

## Merge Strategy

- Prefer squash merge for feature branches (clean history on main).
- Use merge commit for long-lived branches where individual commits matter.
- Never force-push to `main` or `master`.

## Commit Message Format

```
<type>(<scope>): <subject>

<body — optional, explains WHY not WHAT>
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`

Examples:
```
feat(auth): add refresh token rotation
fix(payments): handle idempotency key collision on retry
chore(deps): pin stripe to 5.4.0
```

## Pre-commit Checklist

1. `git diff --staged` — review exactly what's going in.
2. Tests pass locally.
3. No debug logs, commented-out code, or `TODO` left in staged files.
4. Commit message is accurate and complete.

## What NOT to Commit

- `.env`, `*.pem`, `*.key`, `credentials.*`
- Build artifacts: `dist/`, `build/`, `*.pyc`, `__pycache__/`
- IDE config: `.vscode/settings.json` (unless intentional), `.idea/`
- Generated files that are rebuilt from source (e.g., `db/rules.db`)
