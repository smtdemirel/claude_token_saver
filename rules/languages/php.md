## PHP — Modern PHP (8.2+)
- `declare(strict_types=1)` in every file — no exceptions
- Named arguments for boolean/null params to clarify intent
- Readonly classes for value objects; readonly properties for immutable data
- Match expressions over switch — no implicit fallthrough
- First-class callables (`strlen(...)`) over `Closure::fromCallable` or string callbacks

## PHP — Types
- Type declarations on all properties, parameters, and return types
- Union types: `int|string`; intersection types: `Countable&Iterator`; never rely on implicit coercion
- Enums over class constants for fixed value sets; backed enums for serialization
- Nullsafe operator `?->` over manual null checks
- `never` return type for functions that always throw or exit

## PHP — Patterns
- Constructor promotion for simple value objects
- Dependency injection over service locator or `new` in business logic
- Attributes (`#[Attribute]`) over docblock annotations
- Named constructors (`User::fromEmail()`) for domain-specific creation
- Fibers for cooperative multitasking in async libraries — wrap with `Revolt\EventLoop` for event-driven code

## PHP — Errors
- Custom exception hierarchy extending `\RuntimeException`
- Never catch `\Throwable` without rethrowing or specific handling
- Log with context arrays — not string interpolation
- Convert legacy `E_WARNING`/`E_NOTICE` to exceptions via `set_error_handler` in application bootstrap

## PHP — Security
- Parameterized queries always — never string-concatenated SQL
- `password_hash(PASSWORD_BCRYPT)` / `password_verify()` — never MD5/SHA1 for passwords
- `htmlspecialchars($val, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')` for all HTML output
- `random_bytes()` / `random_int()` for cryptographic randomness — never `rand()` or `mt_rand()`

## PHP — Tooling
- `PHP-CS-Fixer` for formatting
- `PHPStan` level 8 or `Psalm` in CI — zero errors policy
- `PHPUnit` with data providers for parameterized tests; `Pest` for expressive BDD-style tests
- Composer for all dependencies; commit `composer.lock`
- `rector` for automated PHP version upgrades and refactoring
