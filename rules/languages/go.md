## Go — Errors
- Errors are values — always check; never `_` on errors that matter
- Wrap with context: `fmt.Errorf("operation failed: %w", err)`
- `errors.Is` / `errors.As` — never string-match error messages
- Return early on error; no nested error-handling blocks
- Sentinel errors as `var ErrXxx = errors.New("...")` in package scope — unexported unless API contract

## Go — Interfaces
- Accept interfaces, return concrete types (structs)
- Keep interfaces small: 1–3 methods
- Define interfaces at the point of use, not implementation
- Compose standard library interfaces: `io.Reader`, `io.Writer`, `http.Handler`

## Go — Context
- `context.Context` as first parameter, named `ctx`, always
- Respect `ctx.Done()` in long-running loops and blocking calls
- Never store context in a struct field
- `context.WithTimeout` / `context.WithDeadline` for all external calls (DB, HTTP, gRPC)

## Go — Patterns
- Table-driven tests with `t.Run` subtests
- `defer` for cleanup immediately after resource acquisition
- No global mutable variables; use dependency injection
- Short variable names in small scopes (`i`, `n`, `err`); descriptive in package scope
- Struct embedding for composition, not inheritance simulation
- Functional options pattern for optional config: `func WithTimeout(d time.Duration) Option`

## Go — Concurrency
- `sync.Mutex` for shared mutable state; prefer channels for communication
- `errgroup` for concurrent error propagation
- Always document goroutine ownership and lifetime
- Buffered channels when sender must not block on slow consumers — size intentionally
- `sync.Once` for lazy initialization; `sync.Pool` for high-churn allocations

## Go — Package Layout
- `internal/` for packages not meant to be imported externally
- `cmd/` for binary entry points; keep `main()` thin — delegate to `internal/`
- Package names: lowercase, single word, no stutter (`user.User` → `user.Record`)
- Group imports: stdlib → external → internal (goimports enforces this)

## Go — Tooling
- `golangci-lint` with `errcheck`, `govet`, `staticcheck`, `gosec`
- `go test -race ./...` always in CI
- `go mod tidy` before every commit
- `go generate` for codegen — document required tools in a `tools.go` file
