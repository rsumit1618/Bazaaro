import 'dart:async';

import 'package:app_stream_kit/app_stream_kit.dart';
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
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(homeFeedStreamProvider);
        ref.invalidate(homeFeedProvider);
      },
      child: AppStreamBuilder<HomeFeed>(
        stream: ref.watch(homeFeedStreamProvider),
        loadingBuilder: (_) => const _HomeSkeleton(),
        emptyBuilder: (_) => const EmptyState(
          title: 'No products yet',
          message: 'Bazaaro products from local DB will appear here.',
          icon: Icons.storefront_outlined,
        ),
        errorBuilder: (context, error, _) => EmptyState(
          title: 'Something went wrong',
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
        builder: (context, data) {
          if (data == null) {
            return const _HomeSkeleton();
          }
          return _BazaaroHome(feed: data);
        },
      ),
    );
  }
}

class _BazaaroHome extends StatelessWidget {
  const _BazaaroHome({required this.feed});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    final compact =
        Responsive.breakpointOf(context) == BazaaroBreakpoint.compact;
    final featuredProducts = feed.featured.length >= 8
        ? feed.featured.take(8).toList()
        : feed.bestSellers.take(8).toList();
    final categoryCards = _preferredCategories(feed.categories);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroBand(banners: feed.banners),
        const _BrandStrip(),
        SizedBox(height: compact ? 22 : 28),
        _ConstrainedHome(
          child: _SectionHeader(
            title: 'Shop by category',
            subtitle:
                'Premium image-based sections for a clean ecommerce experience.',
            action: 'View All',
            onTap: () => context.go('/categories'),
          ),
        ),
        const SizedBox(height: 14),
        _ConstrainedHome(child: _CategoryRail(categories: categoryCards)),
        _ProductSection(
          title: 'Featured products',
          subtitle:
              'Modern product cards with brand, price, rating, badges and cart action.',
          products: featuredProducts,
          forceGrid: true,
        ),
        SizedBox(height: compact ? 22 : 28),
        _ConstrainedHome(child: _DealBanner(products: featuredProducts)),
        SizedBox(height: compact ? 24 : 34),
        const _FeatureStrip(),
        SizedBox(height: compact ? 24 : 34),
        const _NewsletterBand(),
        SizedBox(height: compact ? 24 : 34),
        if (compact) const _MobileHomeBottom() else const _BazaaroFooter(),
      ],
    );
  }

  List<Category> _preferredCategories(List<Category> categories) {
    const preferred = ['fashion', 'electronics', 'home-kitchen', 'beauty'];
    final byId = {for (final category in categories) category.id: category};
    return [
      for (final id in preferred)
        if (byId[id] != null) byId[id]!,
    ].take(4).toList();
  }
}

class _BrandStrip extends StatelessWidget {
  const _BrandStrip();

  @override
  Widget build(BuildContext context) {
    const brands = ['NIKE', 'APPLE', 'ZARA', 'ADIDAS', 'PUMA', 'SONY'];
    return ColoredBox(
      color: BazaaroTheme.app.cardBackground,
      child: _ConstrainedHome(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  Responsive.breakpointOf(context) == BazaaroBreakpoint.compact;
              if (compact) {
                return SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: brands.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 116,
                        child: _BrandPill(label: brands[index]),
                      );
                    },
                  ),
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < brands.length; i++) ...[
                    Expanded(child: _BrandPill(label: brands[i])),
                    if (i != brands.length - 1) const SizedBox(width: 14),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandPill extends StatefulWidget {
  const _BrandPill({required this.label});

  final String label;

  @override
  State<_BrandPill> createState() => _BrandPillState();
}

class _BrandPillState extends State<_BrandPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: _hovered ? const Offset(0, -0.08) : Offset.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: BazaaroTheme.app.cardBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: BazaaroTheme.app.border),
            boxShadow: _hovered
                ? BazaaroTheme.app.softShadow
                : const <BoxShadow>[],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: BazaaroTheme.app.text,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: BazaaroTheme.app.brandInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BazaaroTheme.app.muted),
              ),
            ],
          ),
        ),
        if (action != null)
          FilledButton.tonal(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class _ConstrainedHome extends StatelessWidget {
  const _ConstrainedHome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        Responsive.breakpointOf(context) == BazaaroBreakpoint.compact
        ? 14.0
        : 0.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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

    final appTheme = BazaaroTheme.app;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appTheme.heroGradient,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
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
                                ? appTheme.primary
                                : appTheme.primary.withValues(alpha: 0.18),
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

  ImageProvider _safeNetworkImage(String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage('assets/data/bazaaro_catalog_seed.json');
    }
    return NetworkImage(url);
  }

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
          borderRadius: BorderRadius.circular(34),
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
                color: BazaaroTheme.app.brandInk,
                borderRadius: BorderRadius.circular(34),
                boxShadow: BazaaroTheme.app.shadow,
                image: DecorationImage(
                  image: _safeNetworkImage(banner.imageUrl),
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
                        decoration: BoxDecoration(
                          color: BazaaroTheme.app.orange,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(26),
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
                                color: BazaaroTheme.app.brandAccent,
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
                                  color: BazaaroTheme.app.brandOnInk,
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

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useFullRow = constraints.maxWidth >= 720;
        if (useFullRow) {
          return SizedBox(
            height: 255,
            child: Row(
              children: [
                for (var i = 0; i < categories.length; i++) ...[
                  Expanded(child: _CategoryCard(category: categories[i])),
                  if (i != categories.length - 1) const SizedBox(width: 14),
                ],
              ],
            ),
          );
        }

        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 260,
                child: _CategoryCard(category: categories[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Material(
        color: BazaaroTheme.app.cardBackground,
        child: InkWell(
          onTap: () {},
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                Image.network(category.imageUrl!, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      BazaaroTheme.app.brandInk.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _categoryTitle(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: BazaaroTheme.app.brandOnInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categorySubtitle(category),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BazaaroTheme.app.brandOnInk.withValues(
                          alpha: 0.78,
                        ),
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
  }

  String _categoryTitle(Category category) {
    return switch (category.id) {
      'home-kitchen' => 'Home Decor',
      _ => category.name,
    };
  }

  String _categorySubtitle(Category category) {
    return switch (category.id) {
      'fashion' => 'Clothes, shoes and accessories',
      'electronics' => 'Phones, headphones and gadgets',
      'home-kitchen' => 'Modern furniture and interiors',
      'beauty' => 'Makeup, skincare and grooming',
      _ => 'Curated picks and daily essentials',
    };
  }
}

class _DealBanner extends StatelessWidget {
  const _DealBanner({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final imageUrl = products.isEmpty || products.first.images.isEmpty
        ? null
        : products.first.images.first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(44),
      child: Container(
        constraints: const BoxConstraints(minHeight: 270),
        decoration: BoxDecoration(
          color: BazaaroTheme.app.brandInk,
          boxShadow: BazaaroTheme.app.shadow,
          image: imageUrl == null
              ? null
              : DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    BazaaroTheme.app.brandInk.withValues(alpha: 0.56),
                    BlendMode.darken,
                  ),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Luxury fashion sale is live',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: BazaaroTheme.app.brandOnInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Premium clothing, watches, bags, sneakers and accessories at limited-time prices.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _TimeBox(value: '02', label: 'Days'),
                    _TimeBox(value: '14', label: 'Hours'),
                    _TimeBox(value: '36', label: 'Minutes'),
                    _TimeBox(value: '20', label: 'Seconds'),
                  ],
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.local_fire_department_rounded),
                  label: const Text('Shop Sale Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: BazaaroTheme.app.brandOnInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.local_shipping_outlined,
        'Fast Delivery',
        'Real-time order status.',
      ),
      (Icons.lock_outline, 'Secure Payment', 'Cards, UPI and wallets.'),
      (
        Icons.assignment_return_outlined,
        'Easy Returns',
        'Customer-friendly flow.',
      ),
      (
        Icons.support_agent_outlined,
        'Live Support',
        'Quick ecommerce assistance.',
      ),
    ];
    return _ConstrainedHome(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              Responsive.breakpointOf(context) == BazaaroBreakpoint.compact;
          if (compact) {
            return SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: features.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return SizedBox(
                    width: 230,
                    child: _FeatureCard(
                      icon: feature.$1,
                      title: feature.$2,
                      subtitle: feature.$3,
                      compact: true,
                    ),
                  );
                },
              ),
            );
          }
          final wide = constraints.maxWidth >= 820;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: features.map((feature) {
              return SizedBox(
                width: wide ? (constraints.maxWidth - 48) / 4 : double.infinity,
                child: _FeatureCard(
                  icon: feature.$1,
                  title: feature.$2,
                  subtitle: feature.$3,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: BazaaroTheme.app.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BazaaroTheme.app.border),
        boxShadow: BazaaroTheme.app.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: compact ? 17 : 20,
            backgroundColor: const Color(0xFFF5F3FF),
            foregroundColor: BazaaroTheme.app.primary,
            child: Icon(icon, size: compact ? 18 : 24),
          ),
          SizedBox(height: compact ? 9 : 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: compact ? 3 : 6),
          Text(
            subtitle,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BazaaroTheme.app.muted),
          ),
        ],
      ),
    );
  }
}

class _NewsletterBand extends StatelessWidget {
  const _NewsletterBand();

  @override
  Widget build(BuildContext context) {
    return _ConstrainedHome(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          return Container(
            padding: EdgeInsets.all(compact ? 20 : 28),
            decoration: BoxDecoration(
              color: BazaaroTheme.app.cardBackground,
              borderRadius: BorderRadius.circular(compact ? 28 : 44),
              boxShadow: BazaaroTheme.app.softShadow,
            ),
            child: Column(
              children: [
                Text(
                  'Join premium shoppers club',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: BazaaroTheme.app.brandInk,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get early access to new arrivals, brand drops and exclusive deals.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BazaaroTheme.app.muted,
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Subscribe'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Subscribe'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileHomeBottom extends StatelessWidget {
  const _MobileHomeBottom();

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;
    return _ConstrainedHome(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.brandInk,
                borderRadius: BorderRadius.circular(28),
                boxShadow: appTheme.shadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: appTheme.brandGradient),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'B',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bazaaro',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: appTheme.brandOnInk,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          BazaaroBrand.tagline,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: appTheme.brandOnInk.withValues(
                                  alpha: 0.68,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _MobileQuickAction(
                    icon: Icons.support_agent_outlined,
                    label: 'Help',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MobileQuickAction(
                    icon: Icons.local_shipping_outlined,
                    label: 'Track',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MobileQuickAction(
                    icon: Icons.assignment_return_outlined,
                    label: 'Returns',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileQuickAction extends StatelessWidget {
  const _MobileQuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;
    return Material(
      color: appTheme.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: appTheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BazaaroFooter extends StatelessWidget {
  const _BazaaroFooter();

  @override
  Widget build(BuildContext context) {
    final linkStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.78),
    );
    return ColoredBox(
      color: BazaaroTheme.app.brandInk,
      child: _ConstrainedHome(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 42),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;
                  return Wrap(
                    spacing: 48,
                    runSpacing: 28,
                    children: [
                      SizedBox(
                        width: wide ? 330 : constraints.maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bazaaro',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: BazaaroTheme.app.brandOnInk,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Premium responsive ecommerce UI with brand images, animated sections and mobile-first experience.',
                              style: linkStyle,
                            ),
                          ],
                        ),
                      ),
                      _FooterColumn(
                        title: 'Shop',
                        links: const [
                          'New Arrivals',
                          'Best Sellers',
                          'Luxury Deals',
                        ],
                        style: linkStyle,
                      ),
                      _FooterColumn(
                        title: 'Support',
                        links: const [
                          'Help Center',
                          'Shipping Info',
                          'Return Policy',
                        ],
                        style: linkStyle,
                      ),
                      _FooterColumn(
                        title: 'Social',
                        links: const ['Instagram', 'LinkedIn', 'YouTube'],
                        style: linkStyle,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Divider(
                color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 18),
              Text(
                '© 2026 Bazaaro. Designed for premium ecommerce web and mobile UI.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.links,
    required this.style,
  });

  final String title;
  final List<String> links;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BazaaroTheme.app.brandOnInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final link in links) ...[
            Text(link, style: style),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.subtitle,
    required this.products,
    required this.forceGrid,
  });

  final String title;
  final String subtitle;
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
            _SectionHeader(title: title, subtitle: subtitle),
            const SizedBox(height: 16),
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
