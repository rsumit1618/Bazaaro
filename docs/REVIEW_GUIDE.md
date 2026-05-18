# Reviewer Guide

Use this guide to review the Bazaaro project quickly.

## What To Review First

1. `melos.yaml` for workspace layout and scripts.
2. `packages/bazaaro_domain` for entities, repository contracts, and use cases.
3. `packages/bazaaro_ui` for theme, responsive system, and shared widgets.
4. `packages/bazaaro_firebase` for Firebase Realtime Database integration.
5. `apps/customer_app/lib/src/features/catalog` for local-first catalog implementation.
6. `apps/customer_app/lib/src/features/customer/customer_state.dart` for session, cart, and orders.
7. `apps/customer_app/lib/src/app.dart` for routing and shell navigation.

## Code Organization Rules

- App-specific UI stays in `apps/*`.
- Shared UI stays in `packages/bazaaro_ui`.
- Business contracts stay in `packages/bazaaro_domain`.
- Firebase implementation stays in `packages/bazaaro_firebase`.
- Local/demo data code stays behind repository interfaces.
- Do not make screens depend directly on Firebase SDKs.

## Naming Expectations

- Avoid temporary prefixes like `Dummy`, `Test`, or `Sample` in production-facing classes.
- Prefer domain names such as `Product`, `HomeFeed`, `CatalogRepository`, `CustomerSession`.
- Keep feature-specific private widgets private with `_WidgetName`.

## Responsive Expectations

Desktop:

- Wide content rail.
- 4-column product grid.
- Desktop footer.
- Header navigation.

Mobile:

- Safe horizontal padding.
- Bottom navigation.
- Horizontal rails where better than dense grids.
- Compact bottom brand/support panel instead of desktop footer.

## Offline Expectations

The app should never fail into a blank screen because Firebase is offline.

Expected fallback:

- Local seed or SQLite catalog.
- Friendly empty/error states.
- Retry actions.
- Checkout/network-only actions should explain the problem.

## Firebase Expectations

- Realtime Database reads should be scoped.
- User-owned data should be under user IDs.
- Role rules should protect admin/seller/staff operations.
- Do not store large product images as base64 in production.

## Final Review Checklist

- App runs on Chrome and Android.
- Home, categories, search, cart, orders, profile, login, checkout routes open.
- Product cards do not overflow.
- Mobile footer is not shown as desktop footer.
- Firebase unavailable state falls back to local catalog.
- Shared packages contain reusable logic rather than copied code.
- Docs match actual implementation.
