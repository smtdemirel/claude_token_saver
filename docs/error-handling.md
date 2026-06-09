# Error Handling

## Principles

- Validate at system boundaries only: user input, external APIs, file I/O, env vars.
- Do not validate internal function arguments unless they originate outside the system.
- Fail loudly at the boundary; trust internal code.
- Log the cause, not just the effect.
- Never swallow exceptions silently.

## Patterns

### Fail Fast at Boundaries

```python
# Good — validate at the entry point, trust the rest
def handle_request(raw_body: bytes) -> Response:
    data = parse_json(raw_body)  # raises on invalid JSON
    return process(data)         # trusts that data is valid

# Bad — defensive checks inside trusted code
def process(data: dict) -> Response:
    if data is None: ...  # impossible; parse_json never returns None
```

### Custom Errors with Context

Define domain errors that carry enough context to diagnose without reading logs:

```python
class PaymentError(Exception):
    def __init__(self, reason: str, order_id: str):
        super().__init__(f"Payment failed for order {order_id}: {reason}")
        self.order_id = order_id
```

### Let Errors Bubble Up

Catch only where you can handle. Don't catch-and-rethrow unless adding context:

```python
# Bad — catches and loses context
try:
    result = fetch_user(user_id)
except Exception:
    return None  # caller doesn't know why

# Good — let it propagate; log at the handler that can act
result = fetch_user(user_id)  # raises if not found; caller decides
```

### Add Context When Rethrowing

```python
try:
    order = db.find_order(order_id)
except DBError as e:
    raise OrderNotFoundError(order_id) from e  # preserves original cause
```

## Error Classification

| Type | When to use |
|------|-------------|
| `ValueError` | Invalid input at a boundary |
| `RuntimeError` | Unexpected internal state (should never happen) |
| Domain error | Expected failure in business logic |
| HTTP error code | API boundary — 400 for client errors, 500 for server errors |

## Logging Rules

- Log at the layer that handles the error, not where it originates.
- Include enough context: user ID, request ID, relevant IDs.
- Error logs must answer: what failed, why, and what to look at next.
- Do not log full stack traces at INFO level — only at ERROR or above.
