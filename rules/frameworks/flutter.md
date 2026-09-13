## Flutter — Widgets
- `StatelessWidget` by default; `StatefulWidget` only when local mutable state is needed
- One widget per file; filename matches widget name in snake_case
- `const` constructors always when widget has no runtime-variable data
- `const` keyword on widget instantiations — Flutter skips rebuilding const subtrees
- Never put business logic in `build()` — it runs on every rebuild

## Flutter — State Management
- Riverpod (code gen) for most projects — providers are testable, type-safe, and composable
- `StateNotifier` / `AsyncNotifier` for complex state; `StateProvider` for simple values
- Bloc for large teams or strict separation requirements
- `setState` only for purely local UI state (e.g., toggle, animation controller)
- Never store `BuildContext` across async gaps — check `mounted` before use

## Flutter — Navigation
- `go_router` for declarative, deep-link-friendly routing
- Named routes always — no anonymous `MaterialPageRoute` push
- Route guards via `redirect` in `GoRouter` — not inline `Navigator.push` conditions

## Flutter — Performance
- `const` constructors eliminate unnecessary rebuilds — use them everywhere possible
- `ListView.builder` / `SliverList` for long lists — never `Column` with mapped items
- `RepaintBoundary` around expensive-to-paint, frequently-animating widgets
- `compute()` for CPU-intensive work — keeps UI thread free
- Profile with `flutter run --profile` — not debug mode

## Flutter — Architecture
- Feature-first folder structure: `features/auth/`, `features/home/`
- Separate: `data/` (repositories, models), `domain/` (use cases, entities), `presentation/` (widgets, providers)
- Repositories abstract data sources — widgets never call `http` or `dio` directly
- Dependency injection via Riverpod providers — no service locators

## Flutter — Tooling
- `flutter analyze` with zero warnings in CI
- `flutter test` + `integration_test/` for critical flows
- `flutter_lints` or `very_good_analysis` lint package
- `flutter pub run build_runner build --delete-conflicting-outputs` for code gen
