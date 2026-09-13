## Django — Models
- `Meta.db_table` with explicit names — no auto-generated plural snake_case surprises
- `select_related` / `prefetch_related` always — never N+1 queries
- Model managers for common querysets; never filter in views
- `F()` expressions for atomic field updates; `Q()` for complex lookups
- `bulk_create` / `bulk_update` for batch operations
- `UUIDField` as primary key for publicly-exposed resources

## Django — Views
- Class-based views for standard CRUD; function views for genuinely complex custom flows
- `LoginRequiredMixin` / `PermissionRequiredMixin` — never inline auth checks in view methods
- `get_object_or_404` — never bare `Model.objects.get()` in views
- Keep views thin: validate input → call service → return response

## Django — REST Framework (DRF)
- `ModelSerializer` for standard CRUD; `Serializer` for custom input/output shapes
- `perform_create` / `perform_update` for attaching request context to saves
- `IsAuthenticated` as default permission class in `DEFAULT_PERMISSION_CLASSES`
- Pagination on all list endpoints: `PageNumberPagination` or `CursorPagination` for large datasets
- `throttle_classes` on auth and sensitive endpoints

## Django — Security
- `SECURE_HSTS_SECONDS`, `SECURE_SSL_REDIRECT`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE` in production
- Never `mark_safe` arbitrary strings — use `bleach` for user-generated HTML
- `django-axes` for brute-force protection on login
- `ALLOWED_HOSTS` always set — never `['*']` in production

## Django — Patterns
- `django-environ` for settings with `.env` file
- Apps per domain concern — not one monolithic app
- Celery + Redis for background tasks; `django-celery-beat` for scheduling
- `django.core.cache` with Redis backend; `cache_page` for view-level caching; invalidate on write

## Django — Testing
- `pytest-django` with `@pytest.mark.django_db`
- `factory_boy` factories over fixtures
- `Client` for view tests; `APIClient` (DRF) for API tests
- `assertNumQueries` to lock in query counts and catch N+1 regressions
