import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final customerSessionProvider =
    StateNotifierProvider<CustomerSessionController, CustomerSession>((ref) {
      return CustomerSessionController();
    });

final cartProvider = StateNotifierProvider<CartController, List<CartLine>>((
  ref,
) {
  final controller = CartController();
  ref.onDispose(controller.dispose);
  return controller;
});

final ordersProvider = StateNotifierProvider<OrderController, List<StoreOrder>>((
  ref,
) {
  final controller = OrderController();
  ref.onDispose(controller.dispose);
  return controller;
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
  CartController() : super(const []) {
    _stream.add(state);
  }

  final _stream = BehaviorSubject<List<CartLine>>.seeded(const []);

  @override
  Stream<List<CartLine>> get stream => _stream.stream;

  void add(Product product) {
    final index = state.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      _setState([...state, CartLine(product: product, quantity: 1)]);
      return;
    }
    final next = [...state];
    next[index] = next[index].copyWith(quantity: next[index].quantity + 1);
    _setState(next);
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
    _setState(next);
  }

  void remove(String productId) {
    _setState(state.where((line) => line.product.id != productId).toList());
  }

  void clear() => _setState(const []);

  void _setState(List<CartLine> value) {
    state = value;
    _stream.add(value);
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}

class StoreOrder {
  const StoreOrder({
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

class OrderController extends StateNotifier<List<StoreOrder>> {
  OrderController()
    : super([
        StoreOrder(
          id: 'BZ25051601',
          items: const [],
          total: 2298,
          status: 'Delivered',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          address: 'Indiranagar, Bengaluru, Karnataka',
        ),
      ]) {
    _stream.add(state);
  }

  final _stream = BehaviorSubject<List<StoreOrder>>();

  @override
  Stream<List<StoreOrder>> get stream => _stream.stream;

  StoreOrder placeOrder({
    required List<CartLine> items,
    required String address,
  }) {
    final subtotal = items.fold<num>(0, (sum, line) => sum + line.total);
    final delivery = subtotal >= 999 ? 0 : 49;
    final order = StoreOrder(
      id: 'BZ${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      total: subtotal + delivery,
      status: 'Delivered',
      createdAt: DateTime.now(),
      address: address,
    );
    state = [order, ...state];
    _stream.add(state);
    return order;
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}

extension CartTotals on List<CartLine> {
  int get itemCount => fold(0, (sum, line) => sum + line.quantity);
  num get subtotal => fold<num>(0, (sum, line) => sum + line.total);
  num get delivery => subtotal >= 999 || isEmpty ? 0 : 49;
  num get total => subtotal + delivery;
}
