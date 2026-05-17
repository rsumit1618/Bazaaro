import '../entities/address.dart';
import '../entities/cart_item.dart';
import '../entities/order.dart';

abstract interface class CommerceRepository {
  Stream<List<CartItem>> watchCart(String userId);
  Future<void> addToCart(String userId, CartItem item);
  Future<void> updateCartQuantity(String userId, String itemId, int quantity);
  Stream<List<CustomerOrder>> watchOrders(String userId);
  Future<String> placeOrder(String userId, Address shippingAddress);
}
