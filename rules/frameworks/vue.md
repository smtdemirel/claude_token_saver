## Vue — Components (Vue 3)
- Composition API with `<script setup>` — no Options API for new code
- Single-file components: `<script setup>` → `<template>` → `<style scoped>`
- `defineProps` with TypeScript types — no runtime-only prop declarations
- `defineEmits` for all custom events; typed in TypeScript
- `defineModel` (Vue 3.4+) for two-way binding instead of manual emit pattern

## Vue — Reactivity
- `ref` for primitives; `reactive` for objects (be consistent within a module)
- `computed` for all derived state — never compute in template expressions
- `watch` with `{ immediate: true }` instead of duplicating logic in `onMounted` + `watch`
- `watchEffect` for reactive side effects that track their own dependencies
- `shallowRef` / `shallowReactive` for large objects where deep reactivity is wasteful

## Vue — State
- Pinia for global state — no Vuex in new projects
- Store per domain concern, not one monolithic store
- `storeToRefs` to destructure store state while preserving reactivity
- `$patch` for batch mutations; `$reset()` on option stores for test teardown

## Vue — Routing (Vue Router 4)
- Named routes always; `router.push({ name: 'user', params: { id } })` over path strings
- Navigation guards via `router.beforeEach` for auth; `beforeEnter` for per-route guards
- Lazy-load routes: `component: () => import('./views/UserView.vue')`
- `useRoute()` / `useRouter()` composables — never access `$route` directly in `<script setup>`

## Vue — Patterns
- Composables (`use*.ts`) for reusable stateful logic — same principle as React hooks
- `v-for` always with `:key`; never array index for mutable or filtered lists
- `Teleport` for modals and toasts — avoids z-index and overflow issues
- Async components with `defineAsyncComponent` for route-level code splitting
- `provide` / `inject` for deep component communication — not prop drilling

## Vue — Tooling
- Vite as build tool; `@vitejs/plugin-vue`
- `vue-tsc` for TypeScript checking in CI
- `eslint-plugin-vue` with `vue3-recommended` ruleset
- `Vitest` + `@vue/test-utils` for unit tests; `mountStubs` for shallow rendering
