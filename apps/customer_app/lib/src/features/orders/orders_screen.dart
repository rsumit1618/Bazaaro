import 'package:app_stream_kit/app_stream_kit.dart';
import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../customer/customer_state.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordersProvider.notifier);
    return AppStreamBuilder<List<StoreOrder>>(
      stream: controller.stream,
      initialData: ref.watch(ordersProvider),
      emptyBuilder: (_) => const EmptyState(
        title: 'No orders yet',
        message:
            'Placed, shipped, delivered, cancelled, and return timelines will appear here.',
        icon: Icons.receipt_long_outlined,
      ),
      builder: (context, orders) {
        final items = orders ?? const <StoreOrder>[];
        if (items.isEmpty) {
          return const EmptyState(
            title: 'No orders yet',
            message:
                'Placed, shipped, delivered, cancelled, and return timelines will appear here.',
            icon: Icons.receipt_long_outlined,
          );
        }
        return BazaaroFeaturePage(
          title: 'Orders',
          child: Column(
            children: items.map((order) => _OrderCard(order: order)).toList(),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final StoreOrder order;

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
            Text('${BazaaroBrand.currency} ${order.total} | ${order.address}'),
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
                  ? BazaaroTheme.app.brandAccent
                  : null,
              avatar: const Icon(Icons.done, size: 16),
              label: Text(step),
            ),
          )
          .toList(),
    );
  }
}
