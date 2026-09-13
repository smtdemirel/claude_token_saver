## React — Components
- Function components only; no class components
- One component per file; filename matches component name (PascalCase)
- Destructure props in the function signature
- `key` must be stable and unique — never use array index for dynamic lists
- Lift state only as far as needed; colocate state with the component that owns it

## React — Hooks
- Custom hooks for reusable stateful logic — always prefix with `use`
- `useCallback` / `useMemo` only after profiling shows benefit; premature memoization adds noise
- `useEffect` with exhaustive deps — disabling the lint rule is a design smell
- Never pass async functions directly to `useEffect`; extract an inner async function
- `useId()` for stable IDs linking labels to inputs — not `Math.random()`

## React — State Management
- Local state: `useState` / `useReducer`
- Server/async state: TanStack Query or SWR
- Global client state: Zustand or Jotai (not Redux for new projects)
- URL state: router search params — not state for things that should be shareable

## React — Patterns
- Error boundaries around async, lazy, and data-fetching subtrees
- `React.lazy` + `Suspense` for route-level code splitting
- Compound components for complex UI with shared state (e.g., Tabs, Accordion)
- Render props only when hooks cannot express the pattern
- `forwardRef` + `useImperativeHandle` only for genuinely imperative APIs (focus, scroll)

## React — Forms
- Controlled inputs for simple forms; `react-hook-form` for complex/validated forms
- Schema validation with zod via `@hookform/resolvers` — never manual validation logic
- `fieldset` + `legend` for grouped inputs; `aria-describedby` for field-level error messages

## React — Accessibility
- Semantic HTML first: `<button>` not `<div onClick>`; `<nav>`, `<main>`, `<header>` landmarks
- All interactive elements keyboard-accessible and focus-visible
- `aria-label` or `aria-labelledby` on icon-only buttons
- Never convey information by color alone

## React — Performance
- Profile before adding memoization
- Avoid large anonymous objects/arrays in JSX props — they cause re-renders
- `useTransition` for non-urgent state updates that block rendering

## React — Testing
- React Testing Library — query by role, label, text (not test IDs or class names)
- `userEvent` over `fireEvent` for realistic interaction simulation
- `vitest` + `@testing-library/jest-dom` for assertions
- Test behavior, not implementation — never test internal state or refs
