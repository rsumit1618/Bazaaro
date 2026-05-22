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

## Phase 6: GitHub Pages readiness + demo polish
- [x] Confirm completed vs pending work with the project owner before starting
- [x] Make the GitHub Pages live link visible from the root README
- [x] Add demo users for customer, admin, seller, and staff roles to database seed data
- [x] Document demo role users in the root README for immediate reviewer access
- [x] Fix cart navigation so users can clearly return home from the cart screen
- [x] Improve initial tab/route rendering so a grey blank screen does not flash before UI
- [x] Keep screenshots and first-use docs visible from root project documentation
- [x] Remove known analyzer cleanup items related to this work
- [x] Ask for confirmation before running any build, test, analyze, or deploy command
- [x] Push source changes after owner review
- [ ] Publish/update GitHub Pages after owner approval for build/deploy commands

