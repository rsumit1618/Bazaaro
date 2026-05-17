import '../entities/order.dart';
import '../entities/product.dart';
import '../entities/user_profile.dart';

abstract interface class ManagementRepository {
  Stream<List<UserProfile>> watchUsers();
  Stream<List<Product>> watchSellerProducts(String sellerId);
  Stream<List<CustomerOrder>> watchOrdersForRole(UserProfile profile);
  Future<void> updateProductStatus(String productId, String status);
  Future<void> updateStock(String productId, int stock);
  Future<void> updateOrderStatus(String orderId, String status);
}
