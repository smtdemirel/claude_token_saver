## Python — Types
- Type hints always (3.10+ syntax: `str | None` not `Optional[str]`)
- `dataclass` or Pydantic `BaseModel` for structured data — no plain dicts at I/O boundaries
- `Protocol` for structural typing; `ABC` only when shared state or default methods are needed
- Runtime validation with Pydantic at external boundaries; never trust raw input dicts
- `TypeVar` bound to a protocol for generic functions; `ParamSpec` for decorator type safety

## Python — Style
- f-strings for all string formatting; `str.join` for building from sequences
- `pathlib.Path` over `os.path`
- `logging` module not `print`; never log to stdout in libraries
- Context managers (`with`) for all file, socket, and lock resources
- Guard clauses and early returns — no deeply nested `if` trees
- `match` statement (3.10+) for multi-branch structural pattern matching

## Python — Async
- `async/await` with `asyncio`; never mix sync blocking I/O inside `async def`
- `asyncio.gather()` for concurrent coroutines; `asyncio.TaskGroup` (3.11+) for structured concurrency
- `async with` for async context managers; `async for` for async iterators
- CPU-bound work → `asyncio.run_in_executor(None, fn)` or dedicated process pool
- `anyio`-compatible code when building libraries — avoid raw `asyncio` internals

## Python — Patterns
- Generator expressions for large dataset processing (memory efficient)
- `functools.cache` / `@lru_cache` for pure function memoization
- Raise specific exceptions; never `except Exception: pass`
- List/dict/set comprehensions over `map`/`filter` when readable in one line
- `__slots__` on data-heavy classes for memory efficiency

## Python — Errors
- Custom exception hierarchy inheriting from a project base exception
- Log the cause (`exc_info=True`), not just the effect
- `contextlib.suppress` only for genuinely ignorable errors — document why
- `ExceptionGroup` (3.11+) for propagating multiple errors from concurrent tasks

## Python — Tooling
- `pyproject.toml` for all project config — no `setup.py` or `setup.cfg`
- `uv` for dependency management and virtual envs — fastest, lock-file based
- `ruff` for linting + formatting (replaces black + flake8 + isort)
- `pytest` with fixtures — no `setUp`/`tearDown` unittest patterns
- `mypy --strict` or `pyright` in CI; `pytest-cov` for coverage reporting
- `hypothesis` for property-based testing of pure functions
