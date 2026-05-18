# Challenges Faced

This document captures important issues faced during development and the solution used.

## 1. Missing Android Platform Folder

Problem:

```text
AndroidManifest.xml could not be found
```

Cause:

The app folder did not have complete Android platform files.

Resolution:

Regenerate platform support with `flutter create .` inside the app folder when needed, while preserving existing `lib` code.

## 2. Firebase Permission Denied

Problem:

```text
Listen at / failed: DatabaseError: Permission denied
```

Cause:

Realtime Database rules or selected Firebase project did not allow reads at the requested path.

Resolution:

- Use proper `database.rules.json`.
- Avoid listening to `/` directly in production.
- Scope reads by public catalog paths or authenticated user paths.
- Keep local fallback so the UI still opens.

## 3. Firebase Startup Blocking UI

Problem:

Firebase configuration issues could block or crash the customer app startup.

Resolution:

Firebase bootstrap is non-blocking. The app starts immediately and repositories use local fallback when Firebase is unavailable.

## 4. Stream Already Listened To

Problem:

```text
Bad state: Stream has already been listened to
```

Cause:

The same single-subscription stream was watched by multiple widgets/providers.

Resolution:

Use RxDart `shareReplay(maxSize: 1)` for shared streams.

## 5. Web And Mobile Layout Differences

Problem:

Desktop layouts looked too wide or mobile layouts felt squeezed.

Resolution:

Use a shared responsive helper:

- Compact: mobile-first spacing and horizontal rails.
- Medium: tablet grids.
- Expanded: 4-column web grid and desktop footer.

## 6. Footer On Mobile

Problem:

The desktop footer consumed too much space on mobile.

Resolution:

Render a compact mobile bottom panel with brand identity and quick actions instead of the full footer.

## 7. Product Card Overflow

Problem:

Some text and prices overflowed in product cards.

Resolution:

Use fixed grid extents, max lines, ellipsis, and consistent card dimensions.

## 8. No Firebase Storage

Problem:

The project intentionally avoids Firebase Storage for now.

Resolution:

Use local seed data and remote image URLs. Avoid base64 for large production images.

## 9. Dart Telemetry Permission Error

Problem:

`dart format` completed but then failed to write:

```text
AppData\Roaming\.dart-tool\dart-flutter-telemetry-session.json
```

Cause:

Local Windows permission issue for Dart telemetry file.

Resolution:

Formatting still completed. Fix by adjusting permissions, disabling telemetry, or deleting/recreating the telemetry folder.

## 10. Multi-App Consistency

Problem:

Customer, admin, seller, and staff apps need different workflows but one product/order model.

Resolution:

Keep domain entities and repository contracts in shared packages; keep app-specific presentation inside `apps/*`.
