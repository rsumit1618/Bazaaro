import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_data/bazaaro_data.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseCatalogRepository implements CatalogRepository {
  FirebaseCatalogRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<HomeFeed> watchHomeFeed() {
    final banners = _db
        .collection(FirestoreCollections.banners)
        .where('isActive', isEqualTo: true)
        .where('placement', isEqualTo: 'homeTop')
        .snapshots();
    final categories = _db
        .collection(FirestoreCollections.categories)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots();
    final featured = _activeProducts()
        .where('isFeatured', isEqualTo: true)
        .limit(12)
        .snapshots();
    final trending = _activeProducts()
        .where('isTrending', isEqualTo: true)
        .limit(12)
        .snapshots();
    final bestSellers = _activeProducts()
        .orderBy('totalSold', descending: true)
        .limit(12)
        .snapshots();

    return Rx.combineLatest5(
      banners,
      categories,
      featured,
      trending,
      bestSellers,
      (b, c, f, t, s) {
        return HomeFeed(
          banners: b.docs
              .map((doc) => bannerFromMap(doc.id, doc.data()))
              .toList(),
          categories: c.docs
              .map((doc) => categoryFromMap(doc.id, doc.data()))
              .toList(),
          featured: f.docs
              .map((doc) => productFromMap(doc.id, doc.data()))
              .toList(),
          trending: t.docs
              .map((doc) => productFromMap(doc.id, doc.data()))
              .toList(),
          bestSellers: s.docs
              .map((doc) => productFromMap(doc.id, doc.data()))
              .toList(),
        );
      },
    );
  }

  @override
  Stream<List<Product>> watchProducts(ProductQuery query) {
    Query<Map<String, dynamic>> ref = _activeProducts().limit(query.limit);
    if (query.categoryId != null) {
      ref = ref.where('categoryId', isEqualTo: query.categoryId);
    }
    if (query.brandId != null) {
      ref = ref.where('brandId', isEqualTo: query.brandId);
    }
    ref = switch (query.sort) {
      'priceLow' => ref.orderBy('price'),
      'priceHigh' => ref.orderBy('price', descending: true),
      'newest' => ref.orderBy('createdAt', descending: true),
      _ => ref.orderBy('totalSold', descending: true),
    };
    return ref.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) => productFromMap(doc.id, doc.data()))
          .toList();
      final search = query.search?.trim().toLowerCase();
      if (search == null || search.isEmpty) return products;
      return products.where((product) {
        return product.title.toLowerCase().contains(search) ||
            product.categoryName.toLowerCase().contains(search) ||
            product.brandName.toLowerCase().contains(search);
      }).toList();
    });
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    final doc = await _db
        .collection(FirestoreCollections.products)
        .doc(id)
        .get();
    if (!doc.exists) return const FailureResult(Failure('Product not found'));
    return Success(productFromMap(doc.id, doc.data()!));
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _db
        .collection(FirestoreCollections.categories)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => categoryFromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Query<Map<String, dynamic>> _activeProducts() {
    return _db
        .collection(FirestoreCollections.products)
        .where('status', isEqualTo: ProductStatus.active.name);
  }
}
