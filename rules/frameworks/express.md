## Express — Structure
- Router modules per resource; mount under `/resource` prefix
- Error-handling middleware last: signature `(err, req, res, next)` — Express detects by arity
- Wrap async route handlers: `asyncHandler(fn)` or `try/catch` forwarding to `next(err)`
- Validation middleware (zod / joi) runs before the route handler

## Express — TypeScript
- Type `req.body`, `req.params`, `req.query` explicitly — never `any`
- `Request<Params, ResBody, ReqBody, Query>` generics for typed route handlers
- Zod middleware for end-to-end typed request/response contracts

## Express — Patterns
- No business logic in route handlers — call a service layer
- `res.status(201).json({...})` — always explicit status code, always JSON for APIs
- Centralized error handler formats all error responses consistently
- Application factory function (`createApp()`) for testability
- `process.env` validated at startup with zod — fail fast on missing config
- Health check endpoint (`GET /health`) returns 200 with no auth required

## Express — Security
- `helmet()` for all security headers — first middleware registered
- Rate limiting per IP with `express-rate-limit`
- Never trust `req.body` without schema validation
- `cors` configured with explicit origins — never `origin: '*'` in production
- `express-slow-down` for progressive delay on repeated requests

## Express — Testing
- `supertest` for HTTP integration tests against the `createApp()` factory
- Seed test DB and reset in `beforeEach`; never share state between tests
- Mock external services (email, payment) with `nock` or `msw`
