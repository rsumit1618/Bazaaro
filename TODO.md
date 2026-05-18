# Bazaaro Refactor TODO

## Phase 1: Theme + reusable UI foundation
- [x] Update `packages/bazaaro_ui/lib/src/theme/bazaaro_theme.dart` to expose UI tokens
- [x] Add reusable widgets in `packages/bazaaro_ui`:
  - [x] Customer scaffold shell (header/drawer/bottom nav)
  - [x] Cart badge widget
  - [x] Header nav button widget
- [x] Refactor `apps/customer_app/lib/src/app.dart` to use new reusable widgets + theme tokens
- [x] Add route-aware back leading when `/search` is open

## Phase 2: Streams/error handling
- [x] Locate implementation of `AppStreamBuilder`
- [x] Optimize unified loading/empty/error/retry handling
- [x] Update customer screens using `AppStreamBuilder` as needed

## Phase 3: Feature base + scalability
- [x] Add `BazaaroFeaturePage` base class
- [x] Convert a small set of feature screens to use it

## Phase 4: Admin/seller/staff + inventory flow
- [x] Scan admin/seller/staff apps for hardcoded UI chrome
- [x] Refactor those flows to use shared UI foundation

## Phase 5: Analysis/testing
- [x] Run `dart analyze`
- [x] Run `dart format`

