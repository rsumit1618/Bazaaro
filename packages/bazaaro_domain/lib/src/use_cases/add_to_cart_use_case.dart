import '../entities/cart_item.dart';
import '../repositories/commerce_repository.dart';

class AddToCartUseCase {
  const AddToCartUseCase(this._repository);

  final CommerceRepository _repository;

  Future<void> call(String userId, CartItem item) =>
      _repository.addToCart(userId, item);
}
