## Gin — Structure
- Handler functions accept `*gin.Context` only — zero business logic inside
- Router groups for versioning and logical grouping: `v1 := r.Group("/v1")`
- Middleware via `r.Use()` for cross-cutting concerns (auth, logging, recovery)
- Dependency injection: pass services as closure captures or via `*gin.Context` keys

## Gin — Input Handling
- `c.ShouldBindJSON` over `c.BindJSON` — does not abort on validation error, allows custom response
- Struct validation tags (`binding:"required,email"`) using `go-playground/validator`
- `c.ShouldBindQuery` / `c.ShouldBindUri` for query params and path params
- Always validate before accessing `c.Param` or `c.Query` values

## Gin — Responses
- Consistent response envelope: `{ "data": ..., "error": null }` across all endpoints
- `c.JSON(http.StatusOK, ...)` — always explicit status code
- `c.AbortWithStatusJSON` for early exits in middleware
- Never expose internal error messages — log internally, return generic message to client

## Gin — Middleware
- JWT validation in middleware — not in individual handlers
- Request ID middleware (UUID per request) for log correlation
- Structured logging middleware with `zap` or `zerolog` — log method, path, status, latency
- `gin.Recovery()` always in production — wraps panics before they kill the process

## Gin — Testing
- `net/http/httptest.NewRecorder()` + `gin.New()` for unit testing handlers without a running server
- Table-driven tests per handler; test all status code branches
- Mock services via interfaces — inject via closures in test setup

## Gin — Patterns
- Graceful shutdown with `net/http.Server` + `context.WithTimeout`
- `zap` or `zerolog` for structured logging — not `log.Printf`
- `embed.FS` for static assets bundled into the binary
