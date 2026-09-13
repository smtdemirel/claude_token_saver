## FastAPI — Structure
- Routers in separate modules per domain; `include_router` in `main.py`
- Pydantic v2 models for all request/response schemas
- Separate schemas for input (`CreateUser`, `UpdateUser`) and output (`UserResponse`)
- `Annotated` types for reusable field validation: `UserId = Annotated[int, Field(gt=0)]`

## FastAPI — Dependency Injection
- `Depends()` for database sessions, auth context, and shared business logic
- Yield dependencies for resource management: `yield db; db.close()`
- `lifespan` context manager for startup/shutdown — not deprecated `@app.on_event`
- Cache pure dependencies with `@lru_cache` on the factory function

## FastAPI — Async
- `async def` for I/O-bound endpoints; `def` + `run_in_threadpool` for CPU-bound
- SQLAlchemy 2.0 async engine + `asyncpg` for database access
- `httpx.AsyncClient` over `requests` for outbound HTTP

## FastAPI — Security
- OAuth2 with JWT: `OAuth2PasswordBearer` + `python-jose` or `python-jwt`
- `Depends(get_current_user)` on all protected routes — never inline auth checks
- `bcrypt` for password hashing via `passlib`; never store plain or MD5-hashed passwords
- Rate limiting with `slowapi`; apply to auth and mutation endpoints at minimum

## FastAPI — Database
- SQLAlchemy 2.0 with `DeclarativeBase`; Alembic for all migrations
- Session per request via `Depends`; never use a module-level session
- Repository pattern for DB access — routers never call ORM directly
- `select()` over legacy `query()` API; always specify columns in bulk queries

## FastAPI — Error Handling
- `HTTPException` with specific status codes and descriptive `detail`
- Custom exception handlers via `@app.exception_handler` for domain errors
- Never expose stack traces or internal error details in responses
- Customize the 422 handler for clean, client-friendly validation error output

## FastAPI — Patterns
- `BackgroundTasks` for fire-and-forget side effects (email, logging)
- Response model on every endpoint — never return ORM objects directly
- Versioned routers: `app.include_router(router, prefix="/v1")`
- `pytest-asyncio` with `asyncio_mode = "auto"` for async test functions
- `TestClient` for synchronous tests; `httpx.AsyncClient` for async test suites
