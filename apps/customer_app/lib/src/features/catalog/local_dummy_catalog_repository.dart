import 'dart:convert';

import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:flutter/services.dart';

import 'local_bazaaro_database.dart';

class LocalDummyCatalogRepository implements CatalogRepository {
  LocalDummyCatalogRepository({AssetBundle? bundle})
    : _database = LocalBazaaroDatabase(bundle: bundle ?? rootBundle);

  final LocalBazaaroDatabase _database;
  HomeFeed? _feed;
  List<Product>? _products;

  Future<void> _ensureLoaded() async {
    if (_feed != null && _products != null) {
      return;
    }
    final categoryRows = await _database.records('category');
    final bannerRows = await _database.records('banner');
    final productRows = await _database.records('product');
    Map<String, Object?> payload(Map<String, Object?> row) {
      return jsonDecode(row['payload']! as String) as Map<String, Object?>;
    }

    final categories = categoryRows.map(payload).map((item) {
      return Category(
        id: item['id'] as String,
        name: item['name'] as String,
        slug: item['slug'] as String,
        imageUrl: item['imageUrl'] as String?,
        order: item['order'] as int? ?? 0,
        isActive: item['isActive'] as bool? ?? true,
      );
    }).toList()..sort((a, b) => a.order.compareTo(b.order));
    final banners = bannerRows.map(payload).map((item) {
      return MarketingBanner(
        id: item['id'] as String,
        title: item['title'] as String,
        imageUrl: item['imageUrl'] as String,
        redirectType: item['redirectType'] as String? ?? 'category',
        redirectId: item['redirectId'] as String?,
        placement: item['placement'] as String? ?? 'homeTop',
        isActive: item['isActive'] as bool? ?? true,
      );
    }).toList();
    final now = DateTime.now();
    final products = productRows.map(payload).map((item) {
      return Product(
        id: item['id'] as String,
        title: item['title'] as String,
        slug: item['slug'] as String,
        description: item['description'] as String? ?? '',
        shortDescription: item['shortDescription'] as String? ?? '',
        categoryId: item['categoryId'] as String,
        categoryName: item['categoryName'] as String,
        brandId: item['brandId'] as String,
        brandName: item['brandName'] as String,
        images: List<String>.from(item['images'] as List? ?? const []),
        price: item['price'] as num? ?? 0,
        mrp: item['mrp'] as num? ?? 0,
        discountPercent: item['discountPercent'] as num? ?? 0,
        taxPercent: item['taxPercent'] as num? ?? 0,
        sku: item['sku'] as String? ?? '',
        stock: item['stock'] as int? ?? 0,
        status: ProductStatus.values.byName(
          item['status'] as String? ?? ProductStatus.active.name,
        ),
        sellerId: item['sellerId'] as String? ?? 'seller-demo',
        ratingAvg: (item['ratingAvg'] as num? ?? 0).toDouble(),
        ratingCount: item['ratingCount'] as int? ?? 0,
        totalSold: item['totalSold'] as int? ?? 0,
        isFeatured: item['isFeatured'] as bool? ?? false,
        isTrending: item['isTrending'] as bool? ?? false,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
    final bestSellers = [...products]
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
    _products = products;
    _feed = HomeFeed(
      banners: banners,
      categories: categories,
      featured: products.where((product) => product.isFeatured).toList(),
      trending: products.where((product) => product.isTrending).toList(),
      bestSellers: bestSellers,
    );
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    await _ensureLoaded();
    for (final product in _products!) {
      if (product.id == id) {
        return Success(product);
      }
    }
    return const FailureResult(Failure('Product not found'));
  }

  @override
  Stream<HomeFeed> watchHomeFeed() async* {
    await _ensureLoaded();
    yield _feed!;
  }

  @override
  Stream<List<Category>> watchCategories() async* {
    await _ensureLoaded();
    yield _feed!.categories;
  }

  @override
  Stream<List<Product>> watchProducts(ProductQuery query) async* {
    await _ensureLoaded();
    Iterable<Product> products = _products!;
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
      products = products.where(
        (product) => product.categoryId == query.categoryId,
      );
    }
    final sorted = products.toList();
    switch (query.sort) {
      case 'priceLow':
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case 'priceHigh':
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      default:
        sorted.sort((a, b) => b.totalSold.compareTo(a.totalSold));
    }
    yield sorted.take(query.limit).toList();
  }
}
