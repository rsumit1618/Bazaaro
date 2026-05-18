# Bazaaro Refactor TODO

## Phase 1: Theme + reusable UI foundation
- [ ] Update `packages/bazaaro_ui/lib/src/theme/bazaaro_theme.dart` to expose UI tokens (no hardcoded UI colors in apps)
- [ ] Add reusable widgets in `packages/bazaaro_ui`:
  - [ ] Customer scaffold shell (header/drawer/bottom nav)
  - [ ] Cart badge widget
  - [ ] Header nav button widget
- [ ] Refactor `apps/customer_app/lib/src/app.dart` to use new reusable widgets + theme tokens
- [ ] Add route-aware back leading when `/search` is open

## Phase 2: Streams/error handling
- [ ] Locate implementation of `AppStreamBuilder`
- [ ] Optimize unified loading/empty/error/retry handling
- [ ] Update customer screens using `AppStreamBuilder` as needed

## Phase 3: Feature base + scalability
- [ ] Add `BazaaroFeaturePage` base class
- [ ] Convert a small set of feature screens to use it

## Phase 4: Admin/seller/staff + inventory flow
- [ ] Scan admin/seller/staff apps for hardcoded UI chrome
- [ ] Refactor those flows to use shared UI foundation

## Phase 5: Analysis/testing
- [ ] Run `flutter analyze`
- [ ] Run `dart format` / `flutter format`

