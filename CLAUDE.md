# CLAUDE.md — v1.2
# Priority: CLAUDE.md > PROJECT_RULES.md > docs/
# Docs: never read proactively — query: db/query-rules.sh "<keyword>"
# Hook Rules: additionalContext injected by hooks is a mandatory constraint, not a suggestion. Always apply it.

## Core Principles
Minimum necessary. Edit > create. Read then write. One concern per change. Trust the framework. 3 similar lines > abstraction. Reversible first. Loud failures at boundaries.

## Response Discipline
Answer only what was asked. One-sentence updates while working. No trailing summaries. No headers for short answers. Code refs: `[file.ts:42](file.ts#L42)`. Stop when done.

## Prompting Discipline
Confirm scope on ambiguous tasks. One question at a time. Skip optional params. Don't re-derive context already in conversation.

## File Structure
src/ · tests/ · docs/ · scripts/ · config/. One concern/file; >300 lines → split. kebab-case files, PascalCase classes. No utils/helpers/misc — name by domain.

## Code Style
No comments unless WHY is non-obvious (1 line max). Functions: 1 purpose, ≤30 lines. No magic numbers. No `any`. Immutable by default. Early return; no `else` after `return`.

## Architecture
New abstraction only at 3+ occurrences. No cross-layer shortcuts. Services own their data. No circular deps. Config via env. Feature flags only when rollback is real.

## Dependencies
Add only if: (a) >2 days to build, (b) security-critical. Pin versions. Check license + maintenance + size. Remove unused immediately.

## Refactor
Only if: (a) required by task, (b) code is fragile. Never mix refactor + behavior change. No cleanup while here.

## Documentation
WHY not WHAT. Public APIs: 1-line + param types. ADRs for non-obvious decisions. Stale docs → delete or fix.

## Testing
Unit: pure logic. Integration: real DB, no mocks. E2E: critical paths only. Don't mock what you own. Names: `subject_condition_expected`. 1 assertion/test. All tests in CI.

## Error Handling
Validate only at boundaries: user input, external APIs, file I/O. Errors bubble up. Log cause not effect. Never swallow silently.

## Naming
Variables: nouns (userCount). Booleans: is/has/can. Functions: verbs (fetchUser). Events: past tense (userCreated). Constants: UPPER_SNAKE. Allowed abbrevs: id url db ctx.

## Security
No secrets in code. Parameterized queries always. Sanitize at boundary. HTTPS only. Least privilege. Audit deps before release. Full checklist: db/query-rules.sh "security"

## Performance
Profile before optimizing. Only if: (a) measured bottleneck, (b) obviously wrong algorithm. Right-layer caching. No SELECT *.

## Token Budget
Never read docs/ proactively — query first: db/query-rules.sh "<keyword>". grep/find before opening files. Use offset+limit for partial reads. Summarize tool outputs — never echo verbatim. Don't re-read edited files.

## Working Principles
1. Read relevant files. 2. Understand what exists. 3. Smallest change. 4. Verify. 5. Stop.
