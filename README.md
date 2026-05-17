# Bazaaro

Bazaaro is a production-oriented Flutter e-commerce monorepo for `bazaaro.in`, `admin.bazaaro.in`, and `seller.bazaaro.in`.

Tagline: **Shop Smart. Live Better.**

## Workspace

```text
bazaaro/
  apps/
    customer_app/
    admin_panel/
    seller_panel/
    staff_app/
  packages/
    bazaaro_core/
    bazaaro_auth/
    bazaaro_data/
    bazaaro_domain/
    bazaaro_ui/
    bazaaro_firebase/
  firestore.rules
  firestore.indexes.json
  firebase.json
  seed/firestore_seed.json
```

## Stack

- Flutter Web, Android, iOS
- Melos monorepo
- Clean Architecture + MVVM
- Riverpod dependency injection and state management
- RxDart debounced search, stream composition, cart/filter flows
- GoRouter route structure
- Firebase Auth, Firestore, Storage, Cloud Messaging
- Responsive UI system and shared Bazaaro theme

## Quick Start

```bash
flutter pub global activate melos
melos bootstrap
melos run customer
melos run admin
melos run seller
melos run staff
```

On Windows, enable Developer Mode before bootstrapping because Flutter plugin packages require symlink support.

## Apps

- `customer_app`: shopping app for mobile and web with home feed, categories, product grid, cart, orders, profile, and product detail foundations.
- `admin_panel`: responsive web dashboard for analytics, users, sellers, products, orders, marketing, roles, and configuration.
- `seller_panel`: responsive seller dashboard for products, variants, stock, orders, earnings, and profile.
- `staff_app`: mobile/web staff app for inventory, orders, support, marketing, and content workflows.

## Firebase

Security rules, composite indexes, hosting targets, and seed data are included:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

See `docs/SETUP.md` for project creation commands, FlutterFire setup, hosting targets, and architecture notes.
