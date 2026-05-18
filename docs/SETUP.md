# Bazaaro Setup Guide

This guide explains how to run Bazaaro locally and how to connect it to Firebase.

## Prerequisites

- Flutter stable SDK
- Dart SDK from Flutter
- Firebase CLI
- FlutterFire CLI
- Melos
- Chrome for web debug
- Android Studio or a connected Android device for mobile debug

## Install Tools

```bash
dart pub global activate melos
dart pub global activate flutterfire_cli
npm install -g firebase-tools
```

## Bootstrap Workspace

From the repository root:

```bash
melos bootstrap
```

If packages are missing:

```bash
flutter pub get
melos bootstrap
```

## Run Customer App

Web:

```bash
cd apps/customer_app
flutter run -d chrome
```

Android:

```bash
cd apps/customer_app
flutter devices
flutter run -d <device-id>
```

## Useful Melos Commands

```bash
melos run customer
melos run admin
melos run seller
melos run staff
melos run format
melos run analyze
melos run test
```

## Firebase Setup

Bazaaro currently uses Firebase Realtime Database for free-tier-friendly data sync. Firebase Storage is intentionally not required for the current demo because product images are loaded from local seed/image URLs. If image upload is needed later, use Storage or a dedicated image CDN instead of storing large base64 payloads in the database.

### 1. Login

```bash
firebase login
```

### 2. Select Existing Project

If you are using the existing Echo Firebase project because a new project cannot be created:

```bash
firebase use --add
```

Choose the existing project and give it an alias such as:

```text
bazaaro
```

### 3. Init Firebase

From the repository root:

```bash
firebase init
```

Select:

- Realtime Database
- Hosting
- Emulators, optional for local testing

Do not select Storage if you want to avoid Storage billing/configuration.

### 4. Realtime Database Rules

The repo contains:

```text
database.rules.json
```

Deploy rules:

```bash
firebase deploy --only database
```

### 5. FlutterFire Configure

Run from the repository root:

```bash
flutterfire configure --project=<firebase-project-id>
```

Use Android package:

```text
com.sr.bazaaro
```

For web, select/create a web app named:

```text
Bazaaro Web
```

Generated options can be wired through `packages/bazaaro_firebase`.

## Web Build

For normal hosting:

```bash
cd apps/customer_app
flutter build web --release
```

For GitHub Pages under a repo path, use:

```bash
cd apps/customer_app
flutter build web --release --base-href /bazaaro/
```

The output is:

```text
apps/customer_app/build/web
```

For GitHub Pages deployment, see [Commands And Deployment](COMMANDS_AND_DEPLOYMENT.md).

## Android Build

Debug:

```bash
cd apps/customer_app
flutter run -d <device-id>
```

Release signing must be configured in:

```text
apps/customer_app/android/app/build.gradle.kts
```

Keep release keystore files out of git.
