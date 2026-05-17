import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../customer/customer_state.dart';
import 'catalog_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    return feed.when(
      loading: () => const _CategorySkeleton(),
      error: (error, _) => EmptyState(
        title: 'Could not load categories',
        message: error.toString(),
      ),
      data: (data) {
        final products = _selectedCategoryId == null
            ? data.bestSellers
            : data.bestSellers
                  .where((product) => product.categoryId == _selectedCategoryId)
                  .toList();
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Shop by category',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final category = data.categories[index];
                      final selected = category.id == _selectedCategoryId;
                      return ChoiceChip(
                        selected: selected,
                        avatar: Icon(_iconFor(category), size: 18),
                        label: Text(category.name),
                        onSelected: (_) => setState(
                          () => _selectedCategoryId = selected
                              ? null
                              : category.id,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: data.categories.length,
                  ),
                ),
                const SizedBox(height: 14),
                _ProductWrap(products: products),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(Category category) {
    return switch (category.id) {
      'mobiles' => Icons.phone_android,
      'fashion' => Icons.checkroom,
      'home-kitchen' => Icons.kitchen,
      'beauty' => Icons.spa_outlined,
      'grocery' => Icons.local_grocery_store_outlined,
      _ => Icons.devices_other,
    };
  }
}

class _ProductWrap extends ConsumerWidget {
  const _ProductWrap({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = Responsive.gridColumns(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 326,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/product/${product.id}'),
          onAddToCart: () {
            ref.read(cartProvider.notifier).add(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.title} added to cart')),
            );
          },
        );
      },
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SkeletonBox(height: 48),
        SizedBox(height: 12),
        SkeletonBox(height: 52),
        SizedBox(height: 12),
        SkeletonBox(height: 480),
      ],
    );
  }
}
