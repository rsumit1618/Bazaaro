import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_catalog_repository.dart';
import 'firebase_commerce_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return FirebaseCatalogRepository(ref.watch(firestoreProvider));
});

final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  return FirebaseCommerceRepository(ref.watch(firestoreProvider));
});

final getHomeFeedUseCaseProvider = Provider(
  (ref) => GetHomeFeedUseCase(ref.watch(catalogRepositoryProvider)),
);
final searchProductsUseCaseProvider = Provider(
  (ref) => SearchProductsUseCase(ref.watch(catalogRepositoryProvider)),
);
final addToCartUseCaseProvider = Provider(
  (ref) => AddToCartUseCase(ref.watch(commerceRepositoryProvider)),
);
