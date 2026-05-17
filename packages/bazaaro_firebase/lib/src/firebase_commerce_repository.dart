import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_data/bazaaro_data.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCommerceRepository implements CommerceRepository {
  FirebaseCommerceRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<List<CartItem>> watchCart(String userId) {
    return _db
        .collection(FirestoreCollections.carts)
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return CartItem(
              id: doc.id,
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
    await _db
        .collection(FirestoreCollections.carts)
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .set({
          'productId': item.productId,
          'variantId': item.variantId,
          'quantity': FieldValue.increment(item.quantity),
          'price': item.price,
          'updatedAt': FieldValue.serverTimestamp(),
          'addedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<void> updateCartQuantity(String userId, String itemId, int quantity) {
    return _db
        .collection(FirestoreCollections.carts)
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .update({
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Stream<List<CustomerOrder>> watchOrders(String userId) {
    return _db
        .collection(FirestoreCollections.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return CustomerOrder(
              id: doc.id,
              orderNo: data['orderNo'] as String? ?? doc.id,
              userId: data['userId'] as String? ?? '',
              customerName: data['customerName'] as String? ?? '',
              customerPhone: data['customerPhone'] as String? ?? '',
              items: List<Map<String, Object?>>.from(
                data['items'] as List? ?? const [],
              ),
              totalAmount: data['totalAmount'] as num? ?? 0,
              paymentStatus: PaymentStatus.values.byName(
                data['paymentStatus'] as String? ?? PaymentStatus.pending.name,
              ),
              paymentMethod: PaymentProvider.values.byName(
                data['paymentMethod'] as String? ?? PaymentProvider.cod.name,
              ),
              orderStatus: OrderStatus.values.byName(
                data['orderStatus'] as String? ?? OrderStatus.placed.name,
              ),
              createdAt: dateFromJson(data['createdAt']),
            );
          }).toList();
        });
  }

  @override
  Future<String> placeOrder(String userId, Address shippingAddress) async {
    final doc = _db.collection(FirestoreCollections.orders).doc();
    await doc.set({
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
        'city': shippingAddress.city,
        'state': shippingAddress.state,
        'pincode': shippingAddress.pincode,
        'country': shippingAddress.country,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
