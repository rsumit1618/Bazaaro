import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_catalog_repository.dart';
import 'firebase_commerce_repository.dart';

final realtimeDatabaseProvider = Provider<FirebaseDatabase>(
  (ref) => FirebaseDatabase.instance,
);

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return FirebaseCatalogRepository(ref.watch(realtimeDatabaseProvider));
});

final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  return FirebaseCommerceRepository(ref.watch(realtimeDatabaseProvider));
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
