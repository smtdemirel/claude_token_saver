## JavaScript — Fundamentals
- `const` always; `let` only when reassignment is required; never `var`
- Arrow functions for callbacks; named `function` declarations for methods and top-level functions
- Template literals over string concatenation
- Destructuring for multi-value returns and named params
- Nullish coalescing `??` and optional chaining `?.` over manual null/undefined checks
- `Array.at(-1)` over `arr[arr.length - 1]`
- `structuredClone()` for deep copying plain objects; avoid JSON.parse/JSON.stringify roundtrip

## JavaScript — Async
- `async/await` over `.then()` chains
- `Promise.all()` for parallel async operations; `Promise.allSettled()` when partial failure is acceptable
- Never swallow errors in `catch` — log or rethrow
- `AbortController` for cancellable fetch/async operations
- `Promise.race()` for timeout patterns; wrap external calls with a timeout helper

## JavaScript — Modules
- ES modules (`import/export`) — never `require()` in new code
- Named exports preferred; default export only for the file's primary concern
- No barrel `index.js` in large projects — hurts tree-shaking and discoverability
- `import.meta.url` for file-relative paths in ESM Node code

## JavaScript — Quality
- `===` always; never `==`
- No `eval`, `with`, or `arguments` object
- `for...of` over index loops; `for...in` only for own-enumerable properties with `hasOwn` guard
- `Object.hasOwn(obj, key)` over `obj.hasOwnProperty(key)`
- Immutable updates: spread operator or `structuredClone` — never mutate function parameters

## JavaScript — Node.js
- `node:` prefix for built-in imports: `import fs from 'node:fs/promises'`
- Use built-in `fetch`, `crypto`, `test` (Node 20+) — avoid polyfill packages
- `process.env` validation at startup; fail fast on missing required variables
- `--env-file=.env` flag (Node 20.6+) over `dotenv` for local dev

## JavaScript — Tooling
- `eslint` with `eslint:recommended`
- `prettier` for formatting
- `vitest` or `node:test` for unit tests — no Jest for new projects
- `publint` for library packages to verify exports are correct
