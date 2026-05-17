# Bazaaro - Implementation TODO

## Step 1: Offline-first Catalog
- [ ] Extend `apps/customer_app/lib/src/features/catalog/local_bazaaro_database.dart`
  - add upsert/update logic for category/banner/product tables
  - add indexed pagination-friendly queries (by createdAt/totalSold/price) if needed
- [ ] Add new cached repository implementation
  - `apps/customer_app/lib/src/features/catalog/offline_first_catalog_repository.dart`
  - behavior:
    - emit cached data immediately (local DB)
    - listen for connectivity, and when online refresh from Firebase
    - persist refreshed data into local DB
    - keep streams in sync with local DB after refresh

## Step 2: Wire repository
- [ ] Update `apps/customer_app/lib/src/features/catalog/catalog_providers.dart`
  - swap LocalDummyCatalogRepository -> OfflineFirst repository
  - keep `homeFeedProvider`, `productDetailProvider`, and search view model working

## Step 3: Pagination + smooth list
- [ ] Add `PaginatedProductsList` widget (pageSize=20)
  - load-on-scroll-bottom
  - “load once” behavior per query when returning from top (no repeated prompt/fetch loop)
- [ ] Update `HomeScreen` product sections to use pagination
  - featured, trending, best sellers, local picks (as per available fields)
- [ ] Update `CategoriesScreen` and `SearchScreen` product grids to use pagination for long lists

## Step 4: Image handling
- [ ] Update `packages/bazaaro_ui/lib/src/widgets/product_card.dart`
  - keep CachedNetworkImage caching
  - apply decode sizing hints to reduce memory without visible quality loss

## Step 5: UI re-skin (premium, not full-black)
- [ ] Update `apps/customer_app/lib/src/app.dart`
  - adjust drawer header/background + tile styling using `BazaaroTheme` / gradient accents
- [ ] Re-check any other “complete black” screens and replace with premium non-black palette

## Step 6: Test checklist
- [ ] Online: UI updates and local DB is updated
- [ ] Offline: UI still shows cached home/search/categories/product detail
- [ ] Pagination: 20 rows per batch, smooth scroll, no repeated “load” on revisit
- [ ] Images: no flicker, cached behavior, no visible quality degradation
