## Next.js — App Router Architecture
- App Router by default; Pages Router only for brownfield migration
- Server Components for all data fetching and static content — default is server
- Push `"use client"` boundary as deep as possible in the component tree
- Route Handlers (`app/api/`) only for webhooks and third-party integrations; prefer Server Actions for form mutations

## Next.js — Data Fetching
- `fetch` with Next.js caching semantics directly in Server Components
- `cache()` (React) for request-scoped deduplication
- Parallel data fetching with `Promise.all` — never sequential awaits for independent data
- Streaming with `<Suspense>` for slow data; `loading.tsx` per route segment

## Next.js — Routing
- `loading.tsx` and `error.tsx` per route segment for granular UX
- `generateMetadata` for dynamic SEO — not hardcoded `<Head>`
- `redirect()` and `notFound()` from `next/navigation` — not manual responses
- Middleware for auth guards and i18n — never in Server Components
- Parallel routes (`@slot`) for simultaneous independent layouts; intercepting routes for modals

## Next.js — Server Actions
- Validate input with zod at the top of every Server Action — never trust form data
- `revalidatePath` / `revalidateTag` after mutations — keep UI consistent
- Return typed results: `{ success: true; data: T } | { success: false; error: string }`
- `"use server"` files only export async functions — no shared utility exports

## Next.js — Components
- `next/image` for all images — never bare `<img>`
- `next/link` for all internal links — never bare `<a>`
- `next/font` for web fonts — eliminates layout shift
- `dynamic()` with `{ ssr: false }` for browser-only libraries

## Next.js — Performance
- No `"use client"` on layout or page components unless truly interactive
- Bundle analysis: `@next/bundle-analyzer` before shipping large deps
- `unstable_cache` for caching expensive server-side computations across requests
- Colocate `opengraph-image.tsx` per route for automatic social previews

## Next.js — Config & Environment
- Validate all `process.env` at build time with `t3-env` or manual zod schema — crash early
- `NEXT_PUBLIC_` prefix only for values safe to expose to the browser
- `next.config.ts` (TypeScript) for type-safe configuration
