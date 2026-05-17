import 'dart:async';
import 'dart:convert';

import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:bazaaro_firebase/bazaaro_firebase.dart';
import 'package:rxdart/rxdart.dart';

import 'local_bazaaro_database.dart';

class OfflineFirstCatalogRepository implements CatalogRepository {
  OfflineFirstCatalogRepository({
    required LocalBazaaroDatabase localDatabase,
    required CatalogRepository remoteRepository,
    Duration refreshInterval = const Duration(seconds: 20),
  }) : _localDatabase = localDatabase,
       _remoteRepository = remoteRepository,
       _refreshInterval = refreshInterval;

  final LocalBazaaroDatabase _localDatabase;
  final CatalogRepository _remoteRepository;
  final Duration _refreshInterval;

  final _refreshTrigger = BehaviorSubject<void>();
  Timer? _refreshTimer;

  Future<void> _ensureRefresherStarted() async {
    if (_refreshTimer != null) return;

    // Poll remote periodically to keep local db in sync.
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshTrigger.add(null);
    });

    // Also trigger once on startup.
    _refreshTrigger.add(null);
  }

  Future<void> _tryRefreshOnce() async {
    try {
      final remoteFeed = await _remoteRepository
          .watchHomeFeed()
          .first; // latest combined snapshot

      // Upsert local DB types.
      await _localDatabase.replaceTypeRecords(
        'banner',
        remoteFeed.banners
            .map(
              (b) => {
                'id': b.id,
                'title': b.title,
                'imageUrl': b.imageUrl,
                'redirectType': b.redirectType,
                'redirectId': b.redirectId,
                'placement': b.placement,
                'isActive': true,
                'order': 0,
              },
            )
            .toList(),
      );

      await _localDatabase.replaceTypeRecords(
        'category',
        remoteFeed.categories
            .map(
              (c) => {
                'id': c.id,
                'name': c.name,
                'slug': c.slug,
                'imageUrl': c.imageUrl,
                'order': c.order,
                'isActive': c.isActive,
              },
            )
            .toList(),
      );

      // Products:
      // Remote feed only includes featured/trending/bestSellers.
      // For now, we sync those as a local catalog subset.
      final syncedProducts = <Product>[
        ...remoteFeed.featured,
        ...remoteFeed.trending,
        ...remoteFeed.bestSellers,
      ].toSetBy((p) => p.id);

      await _localDatabase.replaceTypeRecords(
        'product',
        syncedProducts
            .map(
              (p) => {
                'id': p.id,
                'title': p.title,
                'slug': p.slug,
                'description': p.description,
                'shortDescription': p.shortDescription,
                'categoryId': p.categoryId,
                'categoryName': p.categoryName,
                'brandId': p.brandId,
                'brandName': p.brandName,
                'images': p.images,
                'price': p.price,
                'mrp': p.mrp,
                'discountPercent': p.discountPercent,
                'taxPercent': p.taxPercent,
                'sku': p.sku,
                'stock': p.stock,
                'status': p.status.name,
                'sellerId': p.sellerId,
                'ratingAvg': p.ratingAvg,
                'ratingCount': p.ratingCount,
                'totalSold': p.totalSold,
                'isFeatured': p.isFeatured,
                'isTrending': p.isTrending,
              },
            )
            .toList(),
      );
    } catch (_) {
      // Network errors should not break the UI.
    }
  }

  @override
  Stream<HomeFeed> watchHomeFeed() {
    return Rx.defer(() async* {
      await _ensureRefresherStarted();

      // Always yield cached local first.
      yield await _loadHomeFeedFromLocal();

      // Then keep yielding whenever refresher triggers.
      await for (final _ in _refreshTrigger.stream) {
        await _tryRefreshOnce();
        yield await _loadHomeFeedFromLocal();
      }
    });
  }

  @override
  Stream<List<Category>> watchCategories() {
    return Rx.defer(() async* {
      await _ensureRefresherStarted();
      yield await _localDatabase
          .records('category')
          .then((rows) => rows.map(_decodeCategory).toList());
      await for (final _ in _refreshTrigger.stream) {
        await _tryRefreshOnce();
        yield await _localDatabase
            .records('category')
            .then((rows) => rows.map(_decodeCategory).toList());
      }
    });
  }

  @override
  Stream<List<Product>> watchProducts(ProductQuery query) {
    return Rx.defer(() async* {
      await _ensureRefresherStarted();

      Future<List<Product>> load() async {
        final rows = await _localDatabase.records('product');
        Iterable<Product> products = rows.map(_decodeProduct);

        final search = query.search?.trim().toLowerCase();
        if (search != null && search.isNotEmpty) {
          products = products.where((product) {
            return product.title.toLowerCase().contains(search) ||
                product.categoryName.toLowerCase().contains(search) ||
                product.brandName.toLowerCase().contains(search) ||
                product.shortDescription.toLowerCase().contains(search);
          });
        }

        if (query.categoryId != null) {
          products = products.where((p) => p.categoryId == query.categoryId);
        }
        if (query.brandId != null) {
          products = products.where((p) => p.brandId == query.brandId);
        }

        final sorted = products.toList();
        switch (query.sort) {
          case 'priceLow':
            sorted.sort((a, b) => a.price.compareTo(b.price));
            break;
          case 'priceHigh':
            sorted.sort((a, b) => b.price.compareTo(a.price));
            break;
          case 'newest':
            sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          default:
            sorted.sort((a, b) => b.totalSold.compareTo(a.totalSold));
        }

        final limited = sorted.take(query.limit).toList();
        return limited;
      }

      yield await load();

      await for (final _ in _refreshTrigger.stream) {
        await _tryRefreshOnce();
        yield await load();
      }
    });
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    final rows = await _localDatabase.records('product');
    for (final row in rows) {
      final p = _decodeProduct(row);
      if (p.id == id) return Success(p);
    }
    return const FailureResult(Failure('Product not found'));
  }

  Category _decodeCategory(Map<String, Object?> row) {
    final payload =
        jsonDecode(row['payload']! as String) as Map<String, Object?>;
    return Category(
      id: payload['id'] as String,
      name: payload['name'] as String,
      slug: payload['slug'] as String,
      imageUrl: payload['imageUrl'] as String?,
      order: payload['order'] as int? ?? 0,
      isActive: payload['isActive'] as bool? ?? true,
    );
  }

  Product _decodeProduct(Map<String, Object?> row) {
    final payload =
        jsonDecode(row['payload']! as String) as Map<String, Object?>;
    final now = DateTime.now();
    return Product(
      id: payload['id'] as String,
      title: payload['title'] as String,
      slug: payload['slug'] as String,
      description: payload['description'] as String? ?? '',
      shortDescription: payload['shortDescription'] as String? ?? '',
      categoryId: payload['categoryId'] as String,
      categoryName: payload['categoryName'] as String,
      brandId: payload['brandId'] as String,
      brandName: payload['brandName'] as String,
      images: List<String>.from(payload['images'] as List? ?? const []),
      price: payload['price'] as num? ?? 0,
      mrp: payload['mrp'] as num? ?? 0,
      discountPercent: payload['discountPercent'] as num? ?? 0,
      taxPercent: payload['taxPercent'] as num? ?? 0,
      sku: payload['sku'] as String? ?? '',
      stock: payload['stock'] as int? ?? 0,
      status: ProductStatus.values.byName(
        payload['status'] as String? ?? ProductStatus.active.name,
      ),
      sellerId: payload['sellerId'] as String? ?? 'seller-demo',
      ratingAvg: (payload['ratingAvg'] as num? ?? 0).toDouble(),
      ratingCount: payload['ratingCount'] as int? ?? 0,
      totalSold: payload['totalSold'] as int? ?? 0,
      isFeatured: payload['isFeatured'] as bool? ?? false,
      isTrending: payload['isTrending'] as bool? ?? false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<HomeFeed> _loadHomeFeedFromLocal() async {
    final categoryRows = await _localDatabase.records('category');
    final bannerRows = await _localDatabase.records('banner');
    final productRows = await _localDatabase.records('product');

    final categories = categoryRows.map(_decodeCategory).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Banners are optional for the demo screens; if missing, keep empty.
    final banners = bannerRows.map((row) {
      final payload =
          jsonDecode(row['payload']! as String) as Map<String, Object?>;
      return MarketingBanner(
        id: payload['id'] as String,
        title: payload['title'] as String,
        imageUrl: payload['imageUrl'] as String,
        redirectType: payload['redirectType'] as String? ?? 'category',
        redirectId: payload['redirectId'] as String?,
        placement: payload['placement'] as String? ?? 'homeTop',
        isActive: payload['isActive'] as bool? ?? true,
      );
    }).toList();

    final products = productRows.map(_decodeProduct).toList();
    final featured = products.where((p) => p.isFeatured).toList();
    final trending = products.where((p) => p.isTrending).toList();

    final bestSellers = [...products]
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

    return HomeFeed(
      banners: banners,
      categories: categories,
      featured: featured,
      trending: trending,
      bestSellers: bestSellers,
    );
  }
}

extension _ToSetBy<T> on Iterable<T> {
  List<T> toSetBy(String Function(T) keyFn) {
    final map = <String, T>{};
    for (final item in this) {
      map[keyFn(item)] = item;
    }
    return map.values.toList();
  }
}
