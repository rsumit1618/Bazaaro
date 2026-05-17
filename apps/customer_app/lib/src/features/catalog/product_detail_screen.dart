import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'catalog_providers.dart';
import '../customer/customer_state.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));
    return product.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          title: 'Product unavailable',
          message: error.toString(),
        ),
      ),
      data: (product) {
        if (product == null) {
          return const Scaffold(
            body: EmptyState(
              title: 'Product unavailable',
              message: 'This product may be inactive or out of stock.',
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(product.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 420,
                child: ProductCard(
                  product: product,
                  onAddToCart: () =>
                      ref.read(cartProvider.notifier).add(product),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.shortDescription,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(product.description),
              const SizedBox(height: 16),
              Text(
                'Delivery info',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Text(
                'Fast delivery, COD and online payment supported. Returns are available according to product policy.',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).add(product);
                  context.go('/cart');
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to cart and checkout'),
              ),
            ],
          ),
        );
      },
    );
  }
}
