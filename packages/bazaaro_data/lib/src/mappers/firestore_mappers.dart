import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';

DateTime dateFromJson(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  final dynamic maybeTimestamp = value;
  try {
    return maybeTimestamp.toDate() as DateTime;
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

Product productFromMap(String id, Map<String, Object?> json) {
  return Product(
    id: id,
    title: json['title'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    description: json['description'] as String? ?? '',
    shortDescription: json['shortDescription'] as String? ?? '',
    categoryId: json['categoryId'] as String? ?? '',
    categoryName: json['categoryName'] as String? ?? '',
    brandId: json['brandId'] as String? ?? '',
    brandName: json['brandName'] as String? ?? '',
    images: List<String>.from(json['images'] as List? ?? const []),
    price: json['price'] as num? ?? 0,
    mrp: json['mrp'] as num? ?? 0,
    discountPercent: json['discountPercent'] as num? ?? 0,
    taxPercent: json['taxPercent'] as num? ?? 0,
    sku: json['sku'] as String? ?? '',
    stock: json['stock'] as int? ?? 0,
    minStockAlert: json['minStockAlert'] as int? ?? 5,
    status: ProductStatus.values.byName(
      json['status'] as String? ?? ProductStatus.draft.name,
    ),
    sellerId: json['sellerId'] as String? ?? '',
    ratingAvg: (json['ratingAvg'] as num? ?? 0).toDouble(),
    ratingCount: json['ratingCount'] as int? ?? 0,
    totalSold: json['totalSold'] as int? ?? 0,
    isFeatured: json['isFeatured'] as bool? ?? false,
    isTrending: json['isTrending'] as bool? ?? false,
    createdAt: dateFromJson(json['createdAt']),
    updatedAt: dateFromJson(json['updatedAt']),
  );
}

Category categoryFromMap(String id, Map<String, Object?> json) {
  return Category(
    id: id,
    name: json['name'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    parentId: json['parentId'] as String?,
    imageUrl: json['imageUrl'] as String?,
    order: json['order'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? true,
  );
}

MarketingBanner bannerFromMap(String id, Map<String, Object?> json) {
  return MarketingBanner(
    id: id,
    title: json['title'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    redirectType: json['redirectType'] as String? ?? 'url',
    redirectId: json['redirectId'] as String?,
    placement: json['placement'] as String? ?? 'homeTop',
    isActive: json['isActive'] as bool? ?? true,
  );
}
