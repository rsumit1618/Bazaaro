# Commands And Deployment

This document records the commands used to create, run, build, and deploy the Bazaaro Flutter monorepo.

## Create The Monorepo Folder

```bash
mkdir bazaaro
cd bazaaro
```

## Create Flutter Apps

```bash
mkdir apps
flutter create --org com.sr --project-name customer_app apps/customer_app
flutter create --org com.sr --project-name admin_panel apps/admin_panel
flutter create --org com.sr --project-name seller_panel apps/seller_panel
flutter create --org com.sr --project-name staff_app apps/staff_app
```

Customer Android package:

```text
com.sr.bazaaro
```

## Create Shared Packages

```bash
mkdir packages
flutter create --template=package packages/bazaaro_core
flutter create --template=package packages/bazaaro_auth
flutter create --template=package packages/bazaaro_data
flutter create --template=package packages/bazaaro_domain
flutter create --template=package packages/bazaaro_ui
flutter create --template=package packages/bazaaro_firebase
```

## Configure Melos

Create `melos.yaml` at the repo root:

```yaml
name: bazaaro_workspace
packages:
  - apps/*
  - packages/*
command:
  bootstrap:
    usePubspecOverrides: true
scripts:
  analyze:
    run: melos exec -- "flutter analyze"
  test:
    run: melos exec --dir-exists=test -- "flutter test"
  format:
    run: dart format .
  customer:
    run: melos exec --scope="customer_app" -- "flutter run"
  admin:
    run: melos exec --scope="admin_panel" -- "flutter run -d chrome"
  seller:
    run: melos exec --scope="seller_panel" -- "flutter run -d chrome"
  staff:
    run: melos exec --scope="staff_app" -- "flutter run"
```

Install and bootstrap:

```bash
dart pub global activate melos
melos bootstrap
```

## Run The Project

Customer app on Chrome:

```bash
cd apps/customer_app
flutter run -d chrome
```

Customer app on Android:

```bash
cd apps/customer_app
flutter devices
flutter run -d <device-id>
```

From repo root with Melos:

```bash
melos run customer
melos run admin
melos run seller
melos run staff
```

## Build The Project

Customer web release build:

```bash
cd apps/customer_app
flutter build web --release
```

Customer Android APK:

```bash
cd apps/customer_app
flutter build apk --release
```

Customer Android app bundle:

```bash
cd apps/customer_app
flutter build appbundle --release
```

Release signing must be configured before publishing Android release builds.

## Deploy Web App To GitHub Pages

GitHub Pages can host the Flutter web build as a static website.

### 1. Create GitHub Repository

Create a repository named:

```text
bazaaro
```

Push the code:

```bash
git init
git remote add origin https://github.com/<username>/bazaaro.git
git add .
git commit -m "Initial Bazaaro app"
git push -u origin main
```

### 2. Build With Correct Base Href

For a GitHub Pages URL like:

```text
https://<username>.github.io/bazaaro/
```

build with:

```bash
cd apps/customer_app
flutter build web --release --base-href /bazaaro/
```

If the repository name changes, replace `/bazaaro/` with `/<repo-name>/`.

### 3. Publish Build Folder To `gh-pages`

The build output is:

```text
apps/customer_app/build/web
```

One simple deployment option:

```bash
cd apps/customer_app/build/web
git init
git remote add origin https://github.com/<username>/bazaaro.git
git checkout -b gh-pages
git add .
git commit -m "Deploy Bazaaro web"
git push -f origin gh-pages
```

### 4. Enable GitHub Pages

In GitHub:

```text
Repository -> Settings -> Pages -> Deploy from branch -> gh-pages -> /root
```

After GitHub finishes deployment, the app opens at:

```text
https://<username>.github.io/bazaaro/
```

## GitHub Pages Notes

- GitHub Pages only hosts static files.
- Firebase Realtime Database still works from GitHub Pages if Firebase web config and rules allow it.
- Offline UI can work from local seed/cache.
- First visit needs internet to load the web app.
- Later visits can use browser/PWA cache if service worker caching is enabled.

## Firebase Hosting Alternative

Firebase Hosting is often simpler for Firebase apps:

```bash
cd apps/customer_app
flutter build web --release
cd ../..
firebase deploy --only hosting
```
