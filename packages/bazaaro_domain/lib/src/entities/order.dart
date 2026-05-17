import 'package:bazaaro_core/bazaaro_core.dart';

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderStatus,
    required this.createdAt,
  });

  final String id;
  final String orderNo;
  final String userId;
  final String customerName;
  final String customerPhone;
  final List<Map<String, Object?>> items;
  final num totalAmount;
  final PaymentStatus paymentStatus;
  final PaymentProvider paymentMethod;
  final OrderStatus orderStatus;
  final DateTime createdAt;
}
