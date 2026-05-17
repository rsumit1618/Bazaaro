import 'package:bazaaro_core/bazaaro_core.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.categoryId,
    required this.categoryName,
    required this.brandId,
    required this.brandName,
    required this.images,
    required this.price,
    required this.mrp,
    required this.discountPercent,
    required this.taxPercent,
    required this.sku,
    required this.stock,
    required this.status,
    required this.sellerId,
    required this.ratingAvg,
    required this.ratingCount,
    required this.totalSold,
    required this.isFeatured,
    required this.isTrending,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.minStockAlert = 5,
  });

  final String id;
  final String title;
  final String slug;
  final String description;
  final String shortDescription;
  final String categoryId;
  final String categoryName;
  final String brandId;
  final String brandName;
  final List<String> images;
  final num price;
  final num mrp;
  final num discountPercent;
  final num taxPercent;
  final String sku;
  final int stock;
  final int minStockAlert;
  final ProductStatus status;
  final String sellerId;
  final double ratingAvg;
  final int ratingCount;
  final int totalSold;
  final bool isFeatured;
  final bool isTrending;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInStock => stock > 0 && status == ProductStatus.active;
}
