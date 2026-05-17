import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../customer/customer_state.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    if (orders.isEmpty) {
      return const EmptyState(
        title: 'No orders yet',
        message:
            'Placed, shipped, delivered, cancelled, and return timelines will appear here.',
        icon: Icons.receipt_long_outlined,
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Orders',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...orders.map((order) => _OrderCard(order: order)),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final DemoOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(
                  label: Text(order.status),
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${BazaaroBrand.currency} ${order.total} • ${order.address}'),
            const SizedBox(height: 14),
            const _Timeline(),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Placed',
      'Packed',
      'Shipped',
      'Out for delivery',
      'Delivered',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: steps
          .map(
            (step) => Chip(
              backgroundColor: step == 'Delivered'
                  ? const Color(0xFFFFD400)
                  : null,
              avatar: const Icon(Icons.done, size: 16),
              label: Text(step),
            ),
          )
          .toList(),
    );
  }
}
