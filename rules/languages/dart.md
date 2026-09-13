## Dart — Null Safety
- Sound null safety always — no `!` operator without a proven-non-null invariant
- `?` for nullable types; prefer non-nullable by default
- `late` only for fields initialized before first use and provably non-null; document why
- `??` and `?.` over manual null checks; `??=` for lazy initialization

## Dart — Types
- Explicit return types on all public functions and methods
- `final` for variables that are assigned once; `const` for compile-time constants
- `typedef` for complex function types to improve readability
- Prefer named parameters for functions with more than 2 parameters
- `extension type` (Dart 3.3+) for zero-cost type wrappers around primitives

## Dart — Async
- `async`/`await` over raw `Future.then()` chains
- `Stream` for continuous data; `Future` for one-shot async values
- `StreamController` with `close()` in `dispose()` — never leak streams
- `unawaited()` (from `dart:async`) for intentionally fire-and-forget futures
- `Completer` only when bridging callback APIs to `Future` — prefer `async` otherwise

## Dart — Patterns
- `sealed` classes for exhaustive pattern matching (Dart 3+)
- Records for lightweight data grouping: `(String name, int age)`
- Pattern matching in `switch` — exhaustive on sealed types, no fall-through
- Extension methods for adding behavior to existing types without subclassing
- `const` constructors for immutable value objects
- `copyWith` pattern on data classes for immutable updates

## Dart — Errors
- Custom exception classes extending `Exception` or `Error`
- Never swallow exceptions silently — log or rethrow
- `Result` / `Either` pattern (via `fpdart`) for expected failure paths in domain logic
- `Zone.current.handleUncaughtError` for global error boundaries in production

## Dart — Tooling
- `dart analyze` with zero warnings in CI; `dart fix --apply` before committing
- `dart format` — no custom style overrides
- `dart pub upgrade --major-versions` periodically; check breaking changes
- `build_runner` for code generation; `freezed` + `json_serializable` for data classes
