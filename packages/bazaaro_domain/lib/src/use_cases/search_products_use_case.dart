import 'package:rxdart/rxdart.dart';

import '../entities/product.dart';
import '../repositories/catalog_repository.dart';

class SearchProductsUseCase {
  SearchProductsUseCase(this._repository);

  final CatalogRepository _repository;

  Stream<List<Product>> call(Stream<ProductQuery> queries) {
    return queries
        .debounceTime(const Duration(milliseconds: 350))
        .distinct(
          (a, b) =>
              a.search == b.search &&
              a.categoryId == b.categoryId &&
              a.brandId == b.brandId &&
              a.sort == b.sort,
        )
        .switchMap(_repository.watchProducts);
  }
}
