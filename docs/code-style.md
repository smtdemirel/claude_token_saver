# Code Style
# Extended reference. Query: db/query-rules.sh "code style"

---

## Functions

- One purpose. One abstraction level. One return type.
- Side effects at the edges; pure logic in the center.
- Avoid boolean parameters — they hide branching. Split into two functions.
- Avoid output parameters. Return a value instead.
- Default parameter values over overloaded signatures where possible.

## State

- Prefer local state. Lift only when multiple components/services genuinely share it.
- Immutable by default. Mutate only when performance requires it.
- No global mutable state. Ever.

## Conditionals

- Early return to reduce nesting. No `else` after `return`.
- Complex conditions: extract to a named boolean variable or predicate function.
- No `switch` on type strings — use polymorphism or a map.

## Types (typed languages)

- Explicit types on public interfaces and function signatures.
- Infer inside function bodies.
- No `any` / `unknown` unless crossing a true unknown boundary (e.g. JSON parse).
- Prefer `type` for data shapes; `interface` for contracts that will be implemented.
- Generic constraints > `any`.

## Imports

- Group order: stdlib → external packages → internal modules → relative paths.
- Blank line between groups.
- No wildcard imports (`import * as`).
- Delete unused imports immediately; CI should enforce this.

## Formatting

- Delegate entirely to the project formatter (Prettier, gofmt, Black, php-cs-fixer).
- Never manually reformat what a tool does automatically.
- Formatting is enforced in CI. Do not bypass with `// prettier-ignore` unless there is a documented reason.

## Error Return Style

- Typed languages: use Result/Either types or typed exceptions — not untyped `Error`.
- Dynamic languages: return `{data, error}` tuples or raise specific exception classes.
- Never return `null` to indicate failure; return an error type.

## Concurrency

- Prefer async/await over raw callbacks or promise chains.
- No blocking calls on the main/event thread.
- Race conditions: protect shared state with locks or queues, not `setTimeout` workarounds.
