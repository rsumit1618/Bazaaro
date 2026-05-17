import 'package:bazaaro_core/bazaaro_core.dart';

import '../entities/banner.dart';
import '../entities/category.dart';
import '../entities/product.dart';

class ProductQuery {
  const ProductQuery({
    this.search,
    this.categoryId,
    this.brandId,
    this.sort = 'featured',
    this.limit = 20,
    this.startAfterId,
    this.tags = const [],
  });

  final String? search;
  final String? categoryId;
  final String? brandId;
  final String sort;
  final int limit;
  final String? startAfterId;
  final List<String> tags;
}

class HomeFeed {
  const HomeFeed({
    required this.banners,
    required this.categories,
    required this.featured,
    required this.trending,
    required this.bestSellers,
  });

  final List<MarketingBanner> banners;
  final List<Category> categories;
  final List<Product> featured;
  final List<Product> trending;
  final List<Product> bestSellers;
}

abstract interface class CatalogRepository {
  Stream<HomeFeed> watchHomeFeed();
  Stream<List<Product>> watchProducts(ProductQuery query);
  Future<Result<Product>> getProduct(String id);
  Stream<List<Category>> watchCategories();
}
