## TypeScript — Types
- `strict: true` always — no exceptions
- `unknown` over `any`; cast only after a runtime type check
- Discriminated unions over optional fields: `{ kind: "error"; message: string } | { kind: "ok"; data: T }`
- `readonly` on arrays and object properties that must not mutate
- `interface` for object shapes; `type` for unions, intersections, and aliases
- Runtime validation at I/O boundaries: zod / valibot — never trust bare `as`
- `noUncheckedIndexedAccess` in tsconfig for safer array/record access
- Type predicates (`is`) and assertion functions for narrowing in reusable guards

## TypeScript — Functions
- Return type annotations on all exported functions
- Generics over function overloads for reuse; overloads only for meaningfully different signatures
- Prefer `undefined` over `null` — aligns with optional chaining (`?.`)
- `infer` in conditional types for extracting nested types; keep conditional types in named utilities

## TypeScript — Patterns
- `satisfies` operator to validate literals without widening the type
- String unions over `const enum` for public APIs (const enum breaks declaration files)
- No `namespace` — ES modules only
- Avoid type assertions (`as`) in business logic — fix the type upstream instead
- `@ts-ignore` is always wrong; use `@ts-expect-error` with a comment explaining why
- Template literal types for strongly-typed string patterns: `` type Route = `/${string}` ``
- Mapped types for transformations; avoid complex nested mapped types — split into named steps

## TypeScript — Build
- `tsup` or `tsc` composite projects for libraries; `esbuild`/`vite` for apps
- `"moduleResolution": "bundler"` in tsconfig for modern bundlers
- Separate `tsconfig.json` per target (build, test) to avoid test types leaking into output
- `exports` field in `package.json` with explicit subpath conditions for library packages

## TypeScript — Tooling
- `eslint` with `@typescript-eslint/recommended-type-checked`
- `prettier` for formatting — no custom style rules
- `tsc --noEmit` in CI for type checking separate from build
- `vitest` for unit testing — native TS support, no transform config needed
