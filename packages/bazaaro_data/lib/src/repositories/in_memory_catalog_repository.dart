import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';

class InMemoryCatalogRepository implements CatalogRepository {
  InMemoryCatalogRepository();

  final _categories = const [
    Category(
      id: 'mobiles',
      name: 'Mobiles',
      slug: 'mobiles',
      order: 1,
      isActive: true,
    ),
    Category(
      id: 'fashion',
      name: 'Fashion',
      slug: 'fashion',
      order: 2,
      isActive: true,
    ),
    Category(id: 'home', name: 'Home', slug: 'home', order: 3, isActive: true),
    Category(
      id: 'beauty',
      name: 'Beauty',
      slug: 'beauty',
      order: 4,
      isActive: true,
    ),
  ];

  late final List<Product> _products = List.generate(24, (index) {
    final category = _categories[index % _categories.length];
    return Product(
      id: 'product-$index',
      title: [
        'Smart Fitness Watch',
        'Cotton Kurta Set',
        'Ceramic Cookware',
        'Wireless Earbuds',
      ][index % 4],
      slug: 'bazaaro-product-$index',
      shortDescription: 'Daily value pick from Bazaaro.',
      categoryId: category.id,
      categoryName: category.name,
      brandId: 'bazaaro-select',
      brandName: 'Bazaaro Select',
      images: const [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
      ],
      price: 799 + index * 61,
      mrp: 1299 + index * 75,
      discountPercent: 28,
      taxPercent: 18,
      sku: 'BZ-$index',
      stock: 20 + index,
      status: ProductStatus.active,
      sellerId: 'seller-bazaaro-select',
      ratingAvg: 4.1 + (index % 8) / 10,
      ratingCount: 80 + index,
      totalSold: 300 - index,
      isFeatured: index.isEven,
      isTrending: index % 3 == 0,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
    );
  });

  @override
  Stream<HomeFeed> watchHomeFeed() {
    final bestSellers = [..._products]
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
    return Stream.value(
      HomeFeed(
        banners: const [
          MarketingBanner(
            id: 'launch-sale',
            title: 'Bazaaro Launch Sale',
            imageUrl:
                'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=1400',
            redirectType: 'category',
            placement: 'homeTop',
            isActive: true,
          ),
        ],
        categories: _categories,
        featured: _products
            .where((product) => product.isFeatured)
            .take(8)
            .toList(),
        trending: _products
            .where((product) => product.isTrending)
            .take(8)
            .toList(),
        bestSellers: bestSellers.take(8).toList(),
      ),
    );
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    for (final product in _products) {
      if (product.id == id) return Success(product);
    }
    return const FailureResult(Failure('Product not found'));
  }

  @override
  Stream<List<Category>> watchCategories() => Stream.value(_categories);

  @override
  Stream<List<Product>> watchProducts(ProductQuery query) {
    Iterable<Product> products = _products;
    final search = query.search?.trim().toLowerCase();
    if (search != null && search.isNotEmpty) {
      products = products.where((product) {
        return product.title.toLowerCase().contains(search) ||
            product.categoryName.toLowerCase().contains(search) ||
            product.brandName.toLowerCase().contains(search);
      });
    }
    if (query.categoryId != null) {
      products = products.where(
        (product) => product.categoryId == query.categoryId,
      );
    }
    return Stream.value(products.take(query.limit).toList());
  }
}
