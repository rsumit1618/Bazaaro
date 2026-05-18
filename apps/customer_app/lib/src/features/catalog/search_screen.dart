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
  const SearchScreen({super.key});

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
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search Bazaaro')),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            EmptyState(title: 'Search failed', message: error.toString()),
        data: (data) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ChoiceChip(
                            selected: _categoryId == null,
                            label: const Text('All'),
                            onSelected: (_) {
                              setState(() => _categoryId = null);
                              _emitCriteria();
                            },
                          );
                        }
                        final category = data.categories[index - 1];
                        return ChoiceChip(
                          selected: _categoryId == category.id,
                          label: Text(category.name),
                          onSelected: (_) {
                            setState(() => _categoryId = category.id);
                            _emitCriteria();
                          },
                        );
                      },
                    ),
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
                                  crossAxisCount: Responsive.gridColumns(
                                    context,
                                  ),
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
      ),
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
