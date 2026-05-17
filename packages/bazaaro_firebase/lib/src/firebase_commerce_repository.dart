import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_data/bazaaro_data.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseCommerceRepository implements CommerceRepository {
  FirebaseCommerceRepository(this._db);

  final FirebaseDatabase _db;

  @override
  Stream<List<CartItem>> watchCart(String userId) {
    return _db.ref('${FirebaseRealtimePaths.carts}/$userId/items').onValue.map((
      event,
    ) {
      return _mapChildren(event.snapshot.value).map((entry) {
        final data = entry.value;
        return CartItem(
          id: entry.key,
          productId: data['productId'] as String? ?? '',
          variantId: data['variantId'] as String?,
          quantity: data['quantity'] as int? ?? 0,
          price: data['price'] as num? ?? 0,
        );
      }).toList();
    });
  }

  @override
  Future<void> addToCart(String userId, CartItem item) async {
    final ref = _db.ref(
      '${FirebaseRealtimePaths.carts}/$userId/items/${item.id}',
    );
    await ref.runTransaction((current) {
      final data = _asMap(current);
      final currentQuantity = data['quantity'] as int? ?? 0;
      return Transaction.success({
        ...data,
        'productId': item.productId,
        'variantId': item.variantId,
        'quantity': currentQuantity + item.quantity,
        'price': item.price,
        'updatedAt': ServerValue.timestamp,
        'addedAt': data['addedAt'] ?? ServerValue.timestamp,
      });
    });
  }

  @override
  Future<void> updateCartQuantity(String userId, String itemId, int quantity) {
    if (quantity <= 0) {
      return _db
          .ref('${FirebaseRealtimePaths.carts}/$userId/items/$itemId')
          .remove();
    }
    return _db
        .ref('${FirebaseRealtimePaths.carts}/$userId/items/$itemId')
        .update({'quantity': quantity, 'updatedAt': ServerValue.timestamp});
  }

  @override
  Stream<List<CustomerOrder>> watchOrders(String userId) {
    return _db.ref(FirebaseRealtimePaths.orders).onValue.map((event) {
      final orders =
          _mapChildren(
              event.snapshot.value,
            ).where((entry) => entry.value['userId'] == userId).map((entry) {
              final data = entry.value;
              return CustomerOrder(
                id: entry.key,
                orderNo: data['orderNo'] as String? ?? entry.key,
                userId: data['userId'] as String? ?? '',
                customerName: data['customerName'] as String? ?? '',
                customerPhone: data['customerPhone'] as String? ?? '',
                items: List<Map<String, Object?>>.from(
                  data['items'] as List? ?? const [],
                ),
                totalAmount: data['totalAmount'] as num? ?? 0,
                paymentStatus: PaymentStatus.values.byName(
                  data['paymentStatus'] as String? ??
                      PaymentStatus.pending.name,
                ),
                paymentMethod: PaymentProvider.values.byName(
                  data['paymentMethod'] as String? ?? PaymentProvider.cod.name,
                ),
                orderStatus: OrderStatus.values.byName(
                  data['orderStatus'] as String? ?? OrderStatus.placed.name,
                ),
                createdAt: dateFromJson(data['createdAt']),
              );
            }).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  @override
  Future<String> placeOrder(String userId, Address shippingAddress) async {
    final ref = _db.ref(FirebaseRealtimePaths.orders).push();
    final id = ref.key ?? DateTime.now().millisecondsSinceEpoch.toString();
    await ref.set({
      'orderNo': 'BZ${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'customerName': shippingAddress.name,
      'customerPhone': shippingAddress.phone,
      'items': <Map<String, Object?>>[],
      'subtotal': 0,
      'discount': 0,
      'tax': 0,
      'deliveryCharge': 0,
      'totalAmount': 0,
      'paymentStatus': PaymentStatus.pending.name,
      'paymentMethod': PaymentProvider.cod.name,
      'orderStatus': OrderStatus.placed.name,
      'shippingAddress': {
        'line1': shippingAddress.line1,
        'line2': shippingAddress.line2,
        'city': shippingAddress.city,
        'state': shippingAddress.state,
        'pincode': shippingAddress.pincode,
        'country': shippingAddress.country,
      },
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
    return id;
  }
}

List<MapEntry<String, Map<String, Object?>>> _mapChildren(Object? value) {
  final map = _asMap(value);
  return map.entries
      .where((entry) => entry.value is Map || entry.value is List)
      .map((entry) => MapEntry(entry.key, _asMap(entry.value)))
      .toList();
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return value.map((key, child) => MapEntry(key.toString(), child));
  }
  if (value is List) {
    return {
      for (var i = 0; i < value.length; i++)
        if (value[i] != null) i.toString(): value[i],
    };
  }
  return const {};
}
