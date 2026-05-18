import 'dart:async';

import 'package:app_stream_kit/app_stream_kit.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';

import '../customer/customer_state.dart';
import 'catalog_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  final _criteria = BehaviorSubject<_SearchCriteria>.seeded(
    const _SearchCriteria(),
  );
  String? _categoryId;
  String _sort = 'featured';

  @override
  void dispose() {
    _query.dispose();
    unawaited(_criteria.close());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim();
    if (initial != null && initial.isNotEmpty) {
      _query.text = initial;
      _emitCriteria();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        title: 'Search failed',
        message: error.toString(),
        icon: Icons.error_outline,
        action: FilledButton.icon(
          onPressed: () {
            ref.invalidate(homeFeedStreamProvider);
            ref.invalidate(homeFeedProvider);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ),
      data: (data) {
        final compact =
            Responsive.breakpointOf(context) == BazaaroBreakpoint.compact;
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
                TextField(
                  controller: _query,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search watch, shoes, grocery, beauty...',
                  ),
                  onChanged: (_) => _emitCriteria(),
                ),
                const SizedBox(height: 12),
                _SearchCategoryBar(
                  categories: data.categories,
                  selectedCategoryId: _categoryId,
                  onAllSelected: () {
                    setState(() => _categoryId = null);
                    _emitCriteria();
                  },
                  onCategorySelected: (category) {
                    setState(() => _categoryId = category.id);
                    _emitCriteria();
                  },
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'featured',
                      label: Text('Popular'),
                      icon: Icon(Icons.local_fire_department_outlined),
                    ),
                    ButtonSegment(
                      value: 'priceLow',
                      label: Text('Low'),
                      icon: Icon(Icons.south_east),
                    ),
                    ButtonSegment(
                      value: 'priceHigh',
                      label: Text('High'),
                      icon: Icon(Icons.north_east),
                    ),
                  ],
                  selected: {_sort},
                  onSelectionChanged: (value) {
                    setState(() => _sort = value.first);
                    _emitCriteria();
                  },
                ),
                const SizedBox(height: 16),
                AppStreamBuilder<List<Product>>(
                  stream: _criteria
                      .debounceTime(const Duration(milliseconds: 220))
                      .map((criteria) => _filter(data.bestSellers, criteria))
                      .shareReplay(maxSize: 1),
                  initialData: _filter(data.bestSellers, _criteria.value),

                  emptyBuilder: (_) => const EmptyState(
                    title: 'No products found',
                    message: 'Try a different keyword or filter.',
                    icon: Icons.search_off,
                  ),
                  builder: (context, products) {
                    final items = products ?? const <Product>[];
                    if (items.isEmpty) {
                      return const EmptyState(
                        title: 'No products found',
                        message: 'Try a different keyword or filter.',
                        icon: Icons.search_off,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} products found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: Responsive.gridColumns(context),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 326,
                              ),
                          itemBuilder: (context, index) {
                            final product = items[index];
                            return ProductCard(
                              product: product,
                              onTap: () =>
                                  context.push('/product/${product.id}'),
                              onAddToCart: () {
                                ref.read(cartProvider.notifier).add(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.title} added'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _emitCriteria() {
    _criteria.add(
      _SearchCriteria(
        search: _query.text,
        categoryId: _categoryId,
        sort: _sort,
      ),
    );
  }

  List<Product> _filter(List<Product> products, _SearchCriteria criteria) {
    final search = criteria.search.trim().toLowerCase();
    final result = products.where((product) {
      final matchesSearch =
          search.isEmpty ||
          product.title.toLowerCase().contains(search) ||
          product.brandName.toLowerCase().contains(search) ||
          product.categoryName.toLowerCase().contains(search);
      final matchesCategory =
          criteria.categoryId == null ||
          product.categoryId == criteria.categoryId;
      return matchesSearch && matchesCategory;
    }).toList();
    switch (criteria.sort) {
      case 'priceLow':
        result.sort((a, b) => a.price.compareTo(b.price));
      case 'priceHigh':
        result.sort((a, b) => b.price.compareTo(a.price));
      default:
        result.sort((a, b) => b.totalSold.compareTo(a.totalSold));
    }
    return result;
  }
}

class _SearchCategoryBar extends StatelessWidget {
  const _SearchCategoryBar({
    required this.categories,
    required this.selectedCategoryId,
    required this.onAllSelected,
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final VoidCallback onAllSelected;
  final ValueChanged<Category> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final items =
        <({String label, IconData icon, bool selected, VoidCallback onTap})>[
          (
            label: 'All',
            icon: Icons.auto_awesome_rounded,
            selected: selectedCategoryId == null,
            onTap: onAllSelected,
          ),
          for (final category in categories)
            (
              label: category.name,
              icon: _iconFor(category),
              selected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category),
            ),
        ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useFullRow = constraints.maxWidth >= 820;
        if (!useFullRow) {
          return SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return _SearchCategoryPill(
                  label: item.label,
                  icon: item.icon,
                  selected: item.selected,
                  onTap: item.onTap,
                );
              },
            ),
          );
        }

        return Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: _SearchCategoryPill(
                  label: items[i].label,
                  icon: items[i].icon,
                  selected: items[i].selected,
                  onTap: items[i].onTap,
                ),
              ),
              if (i != items.length - 1) const SizedBox(width: 10),
            ],
          ],
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

class _SearchCategoryPill extends StatelessWidget {
  const _SearchCategoryPill({
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

class _SearchCriteria {
  const _SearchCriteria({
    this.search = '',
    this.categoryId,
    this.sort = 'featured',
  });

  final String search;
  final String? categoryId;
  final String sort;
}
