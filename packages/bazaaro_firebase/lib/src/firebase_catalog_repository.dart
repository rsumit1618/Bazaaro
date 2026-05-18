import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_data/bazaaro_data.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseCatalogRepository implements CatalogRepository {
  FirebaseCatalogRepository(this._db);

  final FirebaseDatabase _db;

  @override
  Stream<HomeFeed> watchHomeFeed() {
    final banners = _db.ref(FirebaseRealtimePaths.banners).onValue.map((event) {
      return _mapChildren(event.snapshot.value)
          .map((entry) => bannerFromMap(entry.key, entry.value))
          .where((banner) => banner.isActive && banner.placement == 'homeTop')
          .toList();
    });

    final categories = watchCategories();

    final products = _db.ref(FirebaseRealtimePaths.products).onValue.map((
      event,
    ) {
      return _activeProductsFromValue(event.snapshot.value);
    });

    return Rx.combineLatest3<
      List<MarketingBanner>,
      List<Category>,
      List<Product>,
      HomeFeed
    >(banners, categories, products, (banners, categories, products) {
      final featured = products.where((p) => p.isFeatured).take(12).toList();
      final trending = products.where((p) => p.isTrending).take(12).toList();
      final bestSellers = [...products]
        ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

      return HomeFeed(
        banners: banners,
        categories: categories,
        featured: featured,
        trending: trending,
        bestSellers: bestSellers.take(12).toList(),
      );
    });
  }

  @override
  Stream<List<Product>> watchProducts(ProductQuery query) {
    return _db.ref(FirebaseRealtimePaths.products).onValue.map((event) {
      Iterable<Product> products = _mapChildren(event.snapshot.value)
          .map((entry) => productFromMap(entry.key, entry.value))
          .where((product) => product.status == ProductStatus.active);

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

      return sorted.take(query.limit).toList();
    });
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    final snapshot = await _db
        .ref('${FirebaseRealtimePaths.products}/$id')
        .get();
    final data = _asMap(snapshot.value);
    if (!snapshot.exists || data.isEmpty) {
      return const FailureResult(Failure('Product not found'));
    }
    return Success(productFromMap(id, data));
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _db.ref(FirebaseRealtimePaths.categories).onValue.map((event) {
      final categories =
          _mapChildren(event.snapshot.value)
              .map((entry) => categoryFromMap(entry.key, entry.value))
              .where((category) => category.isActive)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      return categories;
    });
  }

  List<Product> _activeProductsFromValue(Object? value) {
    return _mapChildren(value)
        .map((entry) => productFromMap(entry.key, entry.value))
        .where((product) => product.status == ProductStatus.active)
        .toList();
  }
}

List<MapEntry<String, Map<String, Object?>>> _mapChildren(Object? value) {
  final map = _asMap(value);
  return map.entries
      .where((entry) => entry.value is Map || entry.value is List)
      .map((entry) => MapEntry(entry.key, _asMap(entry.value)))
      .toList();
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return value.map((key, child) => MapEntry(key.toString(), child));
  }
  if (value is List) {
    return {
      for (var i = 0; i < value.length; i++)
        if (value[i] != null) i.toString(): value[i],
    };
  }
  return const {};
}
