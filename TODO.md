# TODO - Bazaaro app fixes & Firebase prep

## Step 1: Reproduce + locate stream error
- [ ] Search for the exact stack trace / offending code for: “Bad state: Stream has already been listened to”
- [ ] Identify category → home navigation widgets and provider subscriptions involved

## Step 2: Fix stream/listener issue (customer_app)
- [ ] Make streams multicast-safe where needed (shareReplay / avoid re-listening)
- [ ] Remove/adjust any UI-level cached streams that get listened multiple times during rebuild/navigation

## Step 3: Fix Search/back navigation + UI
- [ ] Ensure search route pushes correctly so system back button returns to previous screen
- [ ] Remove any unintended “black cards” (theme/UI assets) across the customer app

## Step 4: Fix home page product grid row coverage
- [ ] Update `_ProductGrid` so product cards cover the full row width
- [ ] Verify both wide and non-wide layouts

## Step 5: Theme refresh
- [ ] Apply consistent improved theme colors across the entire customer app

## Step 6: Firebase realtime integration + image chunking
- [ ] Implement upload/seed approach: store images in RTDB as base64 chunks array
- [ ] Implement realtime read: merge chunks -> decode -> show images
- [ ] Upload all seed data to Firebase in proper structure (realtime)

## Step 7: Run & fix app
- [ ] Run web app
- [ ] Fix remaining runtime/layout issues

