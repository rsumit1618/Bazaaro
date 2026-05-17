import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerSessionProvider =
    StateNotifierProvider<CustomerSessionController, CustomerSession>((ref) {
      return CustomerSessionController();
    });

final cartProvider = StateNotifierProvider<CartController, List<CartLine>>((
  ref,
) {
  return CartController();
});

final ordersProvider = StateNotifierProvider<OrderController, List<DemoOrder>>((
  ref,
) {
  return OrderController();
});

class CustomerSession {
  const CustomerSession({
    this.isLoggedIn = false,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
  });

  final bool isLoggedIn;
  final String name;
  final String email;
  final String phone;
  final String address;
}

class CustomerSessionController extends StateNotifier<CustomerSession> {
  CustomerSessionController() : super(const CustomerSession());

  void login({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) {
    state = CustomerSession(
      isLoggedIn: true,
      name: name,
      email: email,
      phone: phone,
      address: address,
    );
  }

  void logout() => state = const CustomerSession();
}

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  num get total => product.price * quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(product: product, quantity: quantity ?? this.quantity);
  }
}

class CartController extends StateNotifier<List<CartLine>> {
  CartController() : super(const []);

  void add(Product product) {
    final index = state.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      state = [...state, CartLine(product: product, quantity: 1)];
      return;
    }
    final next = [...state];
    next[index] = next[index].copyWith(quantity: next[index].quantity + 1);
    state = next;
  }

  void decrement(String productId) {
    final next = <CartLine>[];
    for (final line in state) {
      if (line.product.id != productId) {
        next.add(line);
      } else if (line.quantity > 1) {
        next.add(line.copyWith(quantity: line.quantity - 1));
      }
    }
    state = next;
  }

  void remove(String productId) {
    state = state.where((line) => line.product.id != productId).toList();
  }

  void clear() => state = const [];
}

class DemoOrder {
  const DemoOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.address,
  });

  final String id;
  final List<CartLine> items;
  final num total;
  final String status;
  final DateTime createdAt;
  final String address;
}

class OrderController extends StateNotifier<List<DemoOrder>> {
  OrderController()
    : super([
        DemoOrder(
          id: 'BZ25051601',
          items: const [],
          total: 2298,
          status: 'Delivered',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          address: 'Demo address, Bengaluru, Karnataka',
        ),
      ]);

  DemoOrder placeOrder({
    required List<CartLine> items,
    required String address,
  }) {
    final subtotal = items.fold<num>(0, (sum, line) => sum + line.total);
    final delivery = subtotal >= 999 ? 0 : 49;
    final order = DemoOrder(
      id: 'BZ${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      total: subtotal + delivery,
      status: 'Delivered',
      createdAt: DateTime.now(),
      address: address,
    );
    state = [order, ...state];
    return order;
  }
}

extension CartTotals on List<CartLine> {
  int get itemCount => fold(0, (sum, line) => sum + line.quantity);
  num get subtotal => fold<num>(0, (sum, line) => sum + line.total);
  num get delivery => subtotal >= 999 || isEmpty ? 0 : 49;
  num get total => subtotal + delivery;
}
