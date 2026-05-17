import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../customer/customer_state.dart';
import 'catalog_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  String? _categoryId;
  String _sort = 'featured';

  @override
  void dispose() {
    _query.dispose();
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
          final products = _filter(data.bestSellers);
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
                    onChanged: (_) => setState(() {}),
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
                            onSelected: (_) =>
                                setState(() => _categoryId = null),
                          );
                        }
                        final category = data.categories[index - 1];
                        return ChoiceChip(
                          selected: _categoryId == category.id,
                          label: Text(category.name),
                          onSelected: (_) =>
                              setState(() => _categoryId = category.id),
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
                    onSelectionChanged: (value) =>
                        setState(() => _sort = value.first),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${products.length} products found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.gridColumns(context),
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
                            SnackBar(content: Text('${product.title} added')),
                          );
                        },
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

  List<Product> _filter(List<Product> products) {
    final search = _query.text.trim().toLowerCase();
    final result = products.where((product) {
      final matchesSearch =
          search.isEmpty ||
          product.title.toLowerCase().contains(search) ||
          product.brandName.toLowerCase().contains(search) ||
          product.categoryName.toLowerCase().contains(search);
      final matchesCategory =
          _categoryId == null || product.categoryId == _categoryId;
      return matchesSearch && matchesCategory;
    }).toList();
    switch (_sort) {
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
