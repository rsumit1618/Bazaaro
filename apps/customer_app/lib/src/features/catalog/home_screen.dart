import 'dart:async';

import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'catalog_providers.dart';
import '../customer/customer_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(homeFeedProvider),
      child: feed.when(
        loading: () => const _HomeSkeleton(),
        error: (error, _) => EmptyState(
          title: 'Something went wrong',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
        data: (data) => _BazaaroHome(feed: data),
      ),
    );
  }
}

class _BazaaroHome extends StatelessWidget {
  const _BazaaroHome({required this.feed});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroBand(banners: feed.banners),
        const SizedBox(height: 18),
        _ConstrainedHome(child: const _SearchStrip()),
        const SizedBox(height: 18),
        _ConstrainedHome(child: _CategoryRail(categories: feed.categories)),
        const SizedBox(height: 10),
        _ConstrainedHome(
          child: _DealTiles(products: feed.bestSellers.take(3).toList()),
        ),
        const SizedBox(height: 16),
        _ProductSection(
          title: 'Featured for you',
          action: 'Curated picks',
          products: feed.featured,
          forceGrid: isWide,
        ),
        _ProductSection(
          title: 'Trending now',
          action: 'Hot deals',
          products: feed.trending,
          forceGrid: false,
        ),
        _ProductSection(
          title: 'Best sellers',
          action: 'Most loved',
          products: feed.bestSellers,
          forceGrid: isWide,
        ),
        _ProductSection(
          title: 'Explore more',
          action: 'Local DB picks',
          products: feed.bestSellers,
          forceGrid: true,
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _ConstrainedHome extends StatelessWidget {
  const _ConstrainedHome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}

class _HeroBand extends StatefulWidget {
  const _HeroBand({required this.banners});

  final List<MarketingBanner> banners;

  @override
  State<_HeroBand> createState() => _HeroBandState();
}

class _HeroBandState extends State<_HeroBand> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.banners.isEmpty) return;
      final bannerCount = widget.banners.length >= 5
          ? widget.banners.length
          : 5;
      _page = (_page + 1) % bannerCount;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width >= 900 ? 320.0 : 250.0;

    // Ensure slider has at least 5 items for a richer/attractive experience.
    final banners = widget.banners.length >= 5
        ? widget.banners
        : widget.banners.isEmpty
        ? <MarketingBanner>[]
        : List<MarketingBanner>.generate(
            5,
            (i) => widget.banners[i % widget.banners.length],
          );

    return Container(
      color: BazaaroTheme.ocean,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                if (banners.isNotEmpty)
                  PageView.builder(
                    controller: _controller,
                    itemCount: banners.length,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (context, index) =>
                        _HeroSlide(banner: banners[index]),
                  ),
                Positioned(
                  left: 32,
                  bottom: 28,
                  child: Row(
                    children: [
                      for (
                        var i = 0;
                        i <
                            (widget.banners.length >= 5
                                ? widget.banners.length
                                : 5);
                        i++
                      )
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: i == _page ? 26 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? BazaaroTheme.sunshine
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.banner});

  final MarketingBanner banner;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 250.0;

        // Scale values to prevent bottom overflow on smaller mobile heights.
        final horizontalPad = (maxW * 0.04).clamp(12.0, 20.0);
        final verticalPad = (maxH * 0.07).clamp(12.0, 20.0);

        final buttonH = (maxH * 0.17).clamp(34.0, 46.0);
        final cornerW = (maxW * 0.42).clamp(120.0, 180.0);
        final cornerH = (maxH * 0.34).clamp(64.0, 100.0);

        final textBottomPad = (maxH * 0.09).clamp(14.0, 28.0);

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              verticalPad,
              horizontalPad,
              verticalPad,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: BazaaroTheme.ink,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(banner.imageUrl),
                  fit: BoxFit
                      .cover, // robust to different image sizes/aspect ratios
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: .36),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: cornerW,
                      height: cornerH,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: BazaaroTheme.sunshine,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad * 1.4,
                      textBottomPad,
                      horizontalPad * 1.4,
                      textBottomPad * 0.55,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          BazaaroBrand.tagline,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: BazaaroTheme.sunshine,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: (maxH * 0.035).clamp(6.0, 10.0)),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Text(
                            banner.title,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        SizedBox(height: (maxH * 0.045).clamp(10.0, 18.0)),
                        SizedBox(
                          height: buttonH,
                          child: FilledButton.icon(
                            onPressed: () => context.push('/search'),
                            icon: const Icon(Icons.flash_on_rounded),
                            label: const Text('Shop deals'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchStrip extends StatelessWidget {
  const _SearchStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search products, brands, categories',
            ),
            onTap: () => context.push('/search'),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Filters',
        ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return SizedBox(
            width: 112,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withValues(alpha: .06)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: category.imageUrl == null
                            ? null
                            : NetworkImage(category.imageUrl!),
                        backgroundColor: BazaaroTheme.sunshine,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        category.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DealTiles extends StatelessWidget {
  const _DealTiles({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final children = products
            .map((product) => _DealTile(product: product))
            .toList();
        if (isWide) {
          return Row(
            children: [
              for (final child in children)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: child,
                  ),
                ),
            ],
          );
        }
        return SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) =>
                SizedBox(width: 260, child: children[index]),
          ),
        );
      },
    );
  }
}

class _DealTile extends StatelessWidget {
  const _DealTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BazaaroTheme.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.categoryName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: BazaaroTheme.sunshine,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'INR ${product.price}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 30,
            backgroundImage: product.images.isEmpty
                ? null
                : NetworkImage(product.images.first),
          ),
        ],
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.action,
    required this.products,
    required this.forceGrid,
  });

  final String title;
  final String action;
  final List<Product> products;
  final bool forceGrid;

  @override
  Widget build(BuildContext context) {
    return _ConstrainedHome(
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  action,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (forceGrid)
              _ProductGrid(products: products)
            else
              _ProductRail(products: products),
          ],
        ),
      ),
    );
  }
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 326,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 178,
            child: Consumer(
              builder: (context, ref, _) => ProductCard(
                product: product,
                onTap: () => context.push('/product/${product.id}'),
                onAddToCart: () {
                  ref.read(cartProvider.notifier).add(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.title} added to cart')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
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
        return Consumer(
          builder: (context, ref, _) => ProductCard(
            product: product,
            onTap: () => context.push('/product/${product.id}'),
            onAddToCart: () {
              ref.read(cartProvider.notifier).add(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.title} added to cart')),
              );
            },
          ),
        );
      },
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SkeletonBox(height: 250),
        SizedBox(height: 16),
        SkeletonBox(height: 54),
        SizedBox(height: 16),
        SkeletonBox(height: 118),
        SizedBox(height: 16),
        SkeletonBox(height: 285),
      ],
    );
  }
}
