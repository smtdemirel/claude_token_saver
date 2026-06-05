# Architecture
# Extended reference. Query: db/query-rules.sh "architecture"

---

## Standard Layering

```
HTTP / CLI / Queue
      ↓
Controller / Handler      ← request parsing, response shaping only
      ↓
Service / Use Case        ← business logic lives here exclusively
      ↓
Repository / Gateway      ← data access and external I/O
      ↓
Database / External API
```

Rules:
- Each layer talks only to the layer directly below it.
- Business logic never leaks into controllers or repositories.
- Controllers are thin: validate input, call service, return response.

## Service Boundaries

- Each service owns its schema. No cross-service DB joins.
- Communicate between services via interfaces, events, or HTTP — not shared DB tables.
- No shared mutable state between services.
- Public interface = stable contract. Internal implementation = private.

## Change Isolation

- High-frequency changes belong in modules with small surface areas.
- Configuration is separate from logic.
- Infrastructure is separate from domain (no ORM models in domain layer).
- Domain events decouple side effects from business rules.

## When to Create a New Module

Create a module when all three are true:
1. The domain concept is clearly distinct from existing modules.
2. It can be tested in isolation.
3. Multiple other modules will import it.

Do NOT create a module just to organize files — use folders instead.

## Dependency Direction

Dependencies point inward:
```
Infra → Application → Domain
```
Domain has zero dependencies on frameworks, ORMs, or external libs.

## Anti-Patterns (reject immediately)

- **God class/module**: one file that does everything → split by responsibility.
- **Anemic domain model**: data bags with no behavior → move logic into domain objects.
- **Leaky abstraction**: internals exposed through the interface → enforce encapsulation.
- **Shotgun surgery**: one change requires edits in 10+ files → consolidate the concept.
- **Ping-pong layers**: controller calls service calls controller → detect and break the cycle.
