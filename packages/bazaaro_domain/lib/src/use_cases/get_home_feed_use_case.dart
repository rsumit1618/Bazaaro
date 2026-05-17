import '../repositories/catalog_repository.dart';

class GetHomeFeedUseCase {
  const GetHomeFeedUseCase(this._repository);

  final CatalogRepository _repository;

  Stream<HomeFeed> call() => _repository.watchHomeFeed();
}
