import 'dart:async';

import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'package:bazaaro_firebase/bazaaro_firebase.dart' as bb_firebase;

import 'local_bazaaro_database.dart';
import 'local_dummy_catalog_repository.dart';
import 'offline_first_catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final localDb = LocalBazaaroDatabase();
  final remoteRepo = bb_firebase.FirebaseCatalogRepository(
    ref.watch(bb_firebase.firestoreProvider),
  );

  // If Firebase is not configured/available, the remote repo will fail during sync.
  // The offline repository will still work from local DB.
  return OfflineFirstCatalogRepository(
    localDatabase: localDb,
    remoteRepository: remoteRepo,
  );
});
final homeFeedProvider = StreamProvider<HomeFeed>(
  (ref) => ref.watch(catalogRepositoryProvider).watchHomeFeed(),
);

final productDetailProvider = FutureProvider.family<Product?, String>((
  ref,
  productId,
) async {
  final result = await ref
      .watch(catalogRepositoryProvider)
      .getProduct(productId);
  return result.when(success: (product) => product, failure: (_) => null);
});

final productSearchViewModelProvider =
    Provider.autoDispose<ProductSearchViewModel>((ref) {
      final vm = ProductSearchViewModel(ref.watch(catalogRepositoryProvider));
      ref.onDispose(vm.dispose);
      return vm;
    });

class ProductSearchViewModel {
  ProductSearchViewModel(CatalogRepository repository)
    : _repository = repository {
    products = _query
        .distinct()
        .debounceTime(const Duration(milliseconds: 350))
        .switchMap(_repository.watchProducts)
        .shareReplay(maxSize: 1);
    updateQuery(const ProductQuery());
  }

  final CatalogRepository _repository;
  final _query = BehaviorSubject<ProductQuery>();
  late final Stream<List<Product>> products;

  void updateQuery(ProductQuery query) => _query.add(query);
  void search(String value) => updateQuery(ProductQuery(search: value));
  void dispose() => unawaited(_query.close());
}
