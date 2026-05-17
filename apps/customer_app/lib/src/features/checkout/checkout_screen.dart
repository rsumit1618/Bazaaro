import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../customer/customer_state.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(customerSessionProvider);
    final cart = ref.watch(cartProvider);
    if (!session.isLoggedIn) {
      return const LoginRequiredPanel();
    }
    if (cart.isEmpty) {
      return const Scaffold(
        body: EmptyState(
          title: 'Cart is empty',
          message: 'Add products before checkout.',
          icon: Icons.shopping_bag_outlined,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Review your order',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deliver to',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text('${session.name} • ${session.phone}'),
                      Text(session.address),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...cart.map(
                (line) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(line.product.images.first),
                    ),
                    title: Text(line.product.title),
                    subtitle: Text(
                      'Qty ${line.quantity} • ${BazaaroBrand.currency} ${line.product.price}',
                    ),
                    trailing: Text(
                      '${BazaaroBrand.currency} ${line.total}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PriceCard(cart: cart),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  final order = ref
                      .read(ordersProvider.notifier)
                      .placeOrder(items: cart, address: session.address);
                  ref.read(cartProvider.notifier).clear();
                  context.go('/orders?placed=${order.id}');
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text('Place order with COD'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginRequiredPanel extends StatelessWidget {
  const LoginRequiredPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login required')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_outlined, size: 54),
                const SizedBox(height: 12),
                Text(
                  'Login to checkout',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Email, password, phone, and delivery details are required before purchase.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Login now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.cart});

  final List<CartLine> cart;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF080A0F),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PriceRow(
              label: 'Subtotal',
              value: '${BazaaroBrand.currency} ${cart.subtotal}',
            ),
            _PriceRow(
              label: 'Delivery',
              value: cart.delivery == 0
                  ? 'Free'
                  : '${BazaaroBrand.currency} ${cart.delivery}',
            ),
            const Divider(color: Colors.white24),
            _PriceRow(
              label: 'Total',
              value: '${BazaaroBrand.currency} ${cart.total}',
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
