# Monorepo Interview Questions

These questions are tailored to Bazaaro: a Flutter Clean Architecture monorepo with multiple apps and role-based users.

## 1. Why did Bazaaro use a monorepo instead of separate repositories?

Because customer, admin, seller, and staff apps share domain entities, repositories, UI components, Firebase infrastructure, and brand tokens. A monorepo avoids duplicated models and keeps cross-app changes reviewable in one place.

## 2. What is Melos used for?

Melos manages the multi-package Flutter workspace. It bootstraps package links, runs commands across apps/packages, and keeps shared packages easy to develop locally.

## 3. How does Clean Architecture help this project?

It separates UI, domain rules, data access, and infrastructure. This lets the customer app use local data today and Firebase later without rewriting screens or use cases.

## 4. Where should business rules live?

Business rules should live in `bazaaro_domain` as entities, repository contracts, and use cases. UI screens should call use cases/providers rather than directly depending on Firebase.

## 5. How can multiple apps share the same product model?

The `Product` entity lives in `bazaaro_domain`. Each app imports that package and renders app-specific UI while using the same model contract.

## 6. How are user roles handled in a multi-app system?

Roles are represented in user profiles and route guards. Each app exposes only the features relevant to that role, and database rules must enforce the same restrictions server-side.

## 7. Why use Riverpod in this project?

Riverpod provides dependency injection, state management, StreamProvider support, and testable provider overrides. It also makes repository swapping simple.

## 8. Why use RxDart if Riverpod is already used?

Riverpod manages state ownership. RxDart is useful for stream transformations such as debounce, combine, switchMap, and shareReplay for search, cart, and realtime data flows.

## 9. How does Bazaaro avoid duplicate UI code?

Reusable widgets, theme tokens, responsive helpers, product cards, app shells, empty states, skeletons, and navigation components live in `bazaaro_ui`.

## 10. How would you add a new app to this monorepo?

Create a new app under `apps/`, add dependencies on shared packages, register it in Melos automatically through `apps/*`, add routes/screens, and reuse domain/use-case/provider patterns from existing apps.
