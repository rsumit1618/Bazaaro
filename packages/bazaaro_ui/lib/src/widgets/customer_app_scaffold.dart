import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/bazaaro_theme.dart';
import 'cart_badge.dart';
import 'header_nav_item.dart';

/// Reusable customer scaffold shell (app bar + drawer + bottom navigation).
class CustomerAppScaffold extends StatelessWidget {
  const CustomerAppScaffold({
    super.key,
    required this.child,
    required this.cartCount,
    required this.isLoggedIn,
    required this.profileLabel,
    required this.profileIcon,
    this.showBackLeadingOnSearch = true,
  });

  final Widget child;

  final int cartCount;

  final bool isLoggedIn;
  final String profileLabel;
  final IconData profileIcon;

  /// When true, uses a route-aware back leading on `/search`.
  final bool showBackLeadingOnSearch;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isWide = MediaQuery.sizeOf(context).width >= 820;

    const routes = ['/', '/categories', '/cart', '/orders', '/profile'];
    final index = routes.indexWhere((route) => route == location);
    final safeIndex = index >= 0 ? index : 0;

    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.category_outlined),
        selectedIcon: Icon(Icons.category),
        label: 'Categories',
      ),
      NavigationDestination(
        icon: Icon(Icons.shopping_cart_outlined),
        selectedIcon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      drawer: isWide ? null : _CustomerDrawer(isLoggedIn: isLoggedIn),
      appBar: AppBar(
        toolbarHeight: isWide ? 72 : null,
        leading: _leadingForLocation(
          context: context,
          isWide: isWide,
          location: location,
        ),
        title: _BrandTitle(onTapHome: () => context.go('/')),
        actions: isWide
            ? [
                BazaaroHeaderNavItem(
                  label: 'Home',
                  selected: location == '/',
                  onTap: () => context.go('/'),
                ),
                BazaaroHeaderNavItem(
                  label: 'Categories',
                  selected: location == '/categories',
                  onTap: () => context.go('/categories'),
                ),
                BazaaroHeaderNavItem(
                  label: 'Search',
                  selected: location == '/search',
                  onTap: () => context.go('/search'),
                ),
                BazaaroHeaderNavItem(
                  label: 'Orders',
                  selected: location == '/orders',
                  onTap: () => context.go('/orders'),
                ),
                _CartIconButton(cartCount: cartCount),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: () => context.go('/profile'),
                    icon: Icon(profileIcon),
                    label: Text(profileLabel),
                  ),
                ),
              ]
            : [
                IconButton(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                ),
                _CartIconButton(cartCount: cartCount),
              ],
      ),
      body: child,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: safeIndex,
              destinations: destinations,
              onDestinationSelected: (value) => context.go(routes[value]),
            ),
    );
  }

  Widget? _leadingForLocation({
    required BuildContext context,
    required bool isWide,
    required String location,
  }) {
    if (showBackLeadingOnSearch && location == '/search') {
      return IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back',
        onPressed: () => context.pop(),
      );
    }

    if (isWide) return null;

    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Menu',
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.onTapHome});

  final VoidCallback onTapHome;

  @override
  Widget build(BuildContext context) {
    // Uses only theme tokens for colors; brand text itself can be app-specific.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTapHome,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: BazaaroTheme.app.brandGradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bazaaro'),
            Text(
              'Buy & sell with confidence',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => context.go('/cart'),
          icon: const Icon(Icons.shopping_bag_outlined),
          tooltip: 'Cart',
        ),
        BazaaroCartBadge(count: cartCount),
      ],
    );
  }
}

class _CustomerDrawer extends StatelessWidget {
  const _CustomerDrawer({required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
            decoration: BoxDecoration(color: BazaaroTheme.app.drawerBackground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: BazaaroTheme.app.drawerHeaderGradient,
                        ),
                      ),
                      child: const Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bazaaro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            isLoggedIn
                                ? 'Account'
                                : 'Buy & sell with confidence',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _MenuPill(
                      label: 'Deals',
                      icon: Icons.local_fire_department,
                    ),
                    _MenuPill(
                      label: 'Free delivery',
                      icon: Icons.local_shipping_outlined,
                    ),
                    _MenuPill(label: 'COD', icon: Icons.payments_outlined),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                _DrawerTile(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  route: '/',
                ),
                _DrawerTile(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  route: '/categories',
                ),
                _DrawerTile(
                  icon: Icons.search,
                  label: 'Search and filters',
                  route: '/search',
                ),
                _DrawerTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  route: '/cart',
                ),
                _DrawerTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders',
                  route: '/orders',
                ),
                _DrawerTile(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  route: '/profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuPill extends StatelessWidget {
  const _MenuPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BazaaroTheme.app.menuPillBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFD400), size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
