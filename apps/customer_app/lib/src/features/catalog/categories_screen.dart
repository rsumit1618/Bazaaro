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
        final compact =
            Responsive.breakpointOf(context) == BazaaroBreakpoint.compact;
        final products = _selectedCategoryId == null
            ? data.bestSellers
            : data.bestSellers
                  .where((product) => product.categoryId == _selectedCategoryId)
                  .toList();
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 0,
                18,
                compact ? 14 : 0,
                28,
              ),
              children: [
                Text(
                  'Shop by category',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _CategoryFilterBar(
                  categories: data.categories,
                  selectedCategoryId: _selectedCategoryId,
                  iconFor: _iconFor,
                  onSelected: (category) {
                    final selected = category.id == _selectedCategoryId;
                    setState(
                      () => _selectedCategoryId = selected ? null : category.id,
                    );
                  },
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

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selectedCategoryId,
    required this.iconFor,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final IconData Function(Category category) iconFor;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useFullRow = constraints.maxWidth >= 760;
        if (!useFullRow) {
          return SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryFilterPill(
                  label: category.name,
                  icon: iconFor(category),
                  selected: category.id == selectedCategoryId,
                  onTap: () => onSelected(category),
                );
              },
            ),
          );
        }

        return Row(
          children: [
            for (var i = 0; i < categories.length; i++) ...[
              Expanded(
                child: _CategoryFilterPill(
                  label: categories[i].name,
                  icon: iconFor(categories[i]),
                  selected: categories[i].id == selectedCategoryId,
                  onTap: () => onSelected(categories[i]),
                ),
              ),
              if (i != categories.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryFilterPill extends StatelessWidget {
  const _CategoryFilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;
    return Material(
      color: selected
          ? appTheme.primary.withValues(alpha: 0.1)
          : appTheme.cardBackground,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? appTheme.primary : appTheme.border,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? appTheme.primary : null),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? appTheme.primaryDark : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
