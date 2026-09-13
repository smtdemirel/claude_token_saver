## Laravel — Architecture
- Form Requests for all validation — never `$request->validate()` inline in controllers
- Eloquent models contain relationships and scopes only — no business logic
- Service classes for business logic; injected via constructor type-hinting
- Resource classes (`JsonResource`) for all API response transformation
- Actions (single-method invokable classes) for complex operations: `(new CreateOrder)($data)`

## Laravel — Eloquent
- `with()` for eager loading — never trigger N+1 queries
- `chunk()` or `lazy()` for large dataset processing
- `firstOrCreate` / `updateOrCreate` for upsert patterns
- `$hidden` on models for sensitive fields (passwords, tokens, secrets)
- `$fillable` always defined — never leave both `$fillable` and `$guarded` empty
- Model observers for lifecycle hooks that don't belong in the model itself

## Laravel — Database
- Migrations are immutable once merged — never edit, only add new migrations
- `foreign()->constrained()->cascadeOnDelete()` — always explicit constraint behavior
- Index every foreign key and frequently-filtered column explicitly
- `DB::transaction()` for multi-step writes; `lockForUpdate()` to prevent race conditions

## Laravel — Authorization
- Gates for simple boolean checks; Policies for model-scoped authorization
- `$this->authorize()` in controllers — never inline permission checks in views
- `can` / `cannot` middleware on route groups for coarse-grained access control

## Laravel — Patterns
- Events + Listeners for decoupled side effects (email, notifications, audit log)
- Jobs + Queues for all background work; `ShouldBeUnique` for idempotent jobs
- `php artisan make:*` for all scaffolding — maintain consistency
- API versioning via route groups: `Route::prefix('v1')`
- `Cache::remember()` for expensive queries; tag caches by model for targeted invalidation

## Laravel — Security
- `$fillable` or `$guarded` — never both empty (mass assignment vulnerability)
- `encrypt()` for sensitive data at rest
- CSRF protection on all web routes — API routes use Sanctum tokens
- `sanctum` for SPA auth; `passport` for full OAuth2
- Input sanitization via Form Request rules — never trust raw input

## Laravel — Testing
- `Pest` PHP for expressive test syntax; `php artisan test --parallel` in CI
- `RefreshDatabase` for test isolation; `DatabaseTransactions` for speed when data doesn't cross requests
- `Http::fake()` for mocking outbound HTTP; `Queue::fake()` for asserting dispatched jobs
- Factory states for variation: `User::factory()->admin()->create()`
