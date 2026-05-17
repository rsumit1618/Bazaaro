# Bazaaro Setup

## Project Commands

```bash
flutter pub global activate melos
melos bootstrap
melos analyze
melos test
melos run customer
melos run admin
melos run seller
melos run staff
```

## Flutter Project Creation Commands

```bash
flutter create --org com.sr --project-name customer_app apps/customer_app
flutter create --org com.sr --project-name admin_panel apps/admin_panel
flutter create --org com.sr --project-name seller_panel apps/seller_panel
flutter create --org com.sr --project-name staff_app apps/staff_app
flutter create --template=package packages/bazaaro_core
flutter create --template=package packages/bazaaro_domain
flutter create --template=package packages/bazaaro_data
flutter create --template=package packages/bazaaro_ui
flutter create --template=package packages/bazaaro_auth
flutter create --template=package packages/bazaaro_firebase
```

## Firebase Setup

```bash
firebase login
firebase init firestore hosting storage messaging
flutterfire configure --project=bazaaro --out=packages/bazaaro_firebase/lib/firebase_options.dart
firebase deploy --only firestore:rules,firestore:indexes
```

Configure hosting targets:

```bash
firebase target:apply hosting customer bazaaro-in
firebase target:apply hosting admin admin-bazaaro-in
firebase target:apply hosting seller seller-bazaaro-in
```

Replace the placeholder web Firebase options in `packages/bazaaro_firebase/lib/src/firebase_bootstrap.dart` with generated values or import the generated FlutterFire options.

## Architecture

Bazaaro uses Clean Architecture with MVVM:

- `bazaaro_core`: branding, enums, failures, result helpers.
- `bazaaro_domain`: entities, repository contracts, use cases.
- `bazaaro_data`: Firestore keys, mappers, local development repositories.
- `bazaaro_firebase`: Firebase repository implementations and providers.
- `bazaaro_auth`: Firebase Auth providers and role guards.
- `bazaaro_ui`: theme, responsive system, reusable widgets.
- `apps/*`: presentation, GoRouter routes, Riverpod providers, ViewModels.

Riverpod owns dependency injection. RxDart powers debounced search, combined Firestore streams, cart updates, filters, and realtime UI streams.
