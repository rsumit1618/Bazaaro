import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_catalog_repository.dart';
import 'firebase_commerce_repository.dart';

import 'firebase_bootstrap.dart';

final realtimeDatabaseProvider = Provider<FirebaseDatabase?>((ref) {
  if (!BazaaroFirebaseBootstrap.isReady || Firebase.apps.isEmpty) {
    return null;
  }
  return FirebaseDatabase.instance;
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final database = ref.watch(realtimeDatabaseProvider);
  if (database == null) {
    throw StateError('Firebase is not initialized');
  }
  return FirebaseCatalogRepository(database);
});

final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  final database = ref.watch(realtimeDatabaseProvider);
  if (database == null) {
    throw StateError('Firebase is not initialized');
  }
  return FirebaseCommerceRepository(database);
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
