## Flask — Structure
- Application factory pattern (`create_app()`) always — no module-level `app = Flask()`
- Blueprints for route grouping per domain; register in `create_app`
- Config classes (`DevelopmentConfig`, `ProductionConfig`) loaded by environment
- `extensions.py` for initializing Flask extensions to avoid circular imports

## Flask — Patterns
- `flask-sqlalchemy` with scoped sessions; `db.session.commit()` only in the view or service layer
- `flask-login` for authentication — never custom session management
- `marshmallow` or Pydantic for request validation and response serialization
- `flask-migrate` (Alembic) for all schema migrations — never `db.create_all()` in production
- `flask-caching` with Redis backend for view and query caching

## Flask — Error Handling
- `@app.errorhandler(HTTPException)` for consistent JSON error responses across all HTTP errors
- `abort(404)` / `abort(403)` — not manual `Response` construction
- Domain exceptions map to HTTP status codes via `errorhandler`
- `@app.errorhandler(Exception)` as catch-all; log full traceback, return generic 500 JSON

## Flask — Security
- `SECRET_KEY` from environment — never hardcoded; fail at startup if missing
- `flask-talisman` for security headers and HTTPS enforcement in production
- `flask-wtf` CSRF protection for all form submissions
- Rate limiting: `flask-limiter` on auth and sensitive endpoints
- `flask-cors` configured with explicit origins — never wildcard in production

## Flask — Testing
- `pytest` with `app.test_client()` fixture; `app.test_request_context()` for unit testing helpers
- `pytest-flask` for convenient `client` and `live_server` fixtures
- `factory_boy` for model creation; separate test database with `TESTING=True`
- `monkeypatch` / `unittest.mock` for external services — never hit real APIs in tests
