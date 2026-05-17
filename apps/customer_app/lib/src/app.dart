import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/cart/cart_screen.dart';
import 'features/catalog/categories_screen.dart';
import 'features/catalog/home_screen.dart';
import 'features/catalog/product_detail_screen.dart';
import 'features/catalog/search_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/customer/customer_state.dart';
import 'features/orders/orders_screen.dart';
import 'features/profile/login_screen.dart';
import 'features/profile/profile_screen.dart';

class BazaaroCustomerApp extends StatelessWidget {
  const BazaaroCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '${BazaaroBrand.appName} - ${BazaaroBrand.tagline}',
      theme: BazaaroTheme.light(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => CustomerScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/categories',
          builder: (_, __) => const CategoriesScreen(),
        ),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) =>
          ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
  ],
);

class CustomerScaffold extends ConsumerWidget {
  const CustomerScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isWide = MediaQuery.sizeOf(context).width >= 820;
    final cartCount = ref.watch(cartProvider).itemCount;
    final session = ref.watch(customerSessionProvider);
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
    final routes = ['/', '/categories', '/cart', '/orders', '/profile'];
    final index = routes
        .indexWhere((route) => route == location)
        .clamp(0, routes.length - 1);
    return Scaffold(
      drawer: isWide ? null : _CustomerDrawer(session: session),
      appBar: AppBar(
        toolbarHeight: isWide ? 72 : null,
        leading: isWide
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.go('/'),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF10B8D4),
                      Color(0xFFFFD400),
                      Color(0xFFFF2E00),
                    ],
                  ),
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
                Text(BazaaroBrand.appName),
                Text(
                  BazaaroBrand.tagline,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: isWide
            ? [
                _HeaderNav(
                  label: 'Home',
                  selected: location == '/',
                  onTap: () => context.go('/'),
                ),
                _HeaderNav(
                  label: 'Categories',
                  selected: location == '/categories',
                  onTap: () => context.go('/categories'),
                ),
                _HeaderNav(
                  label: 'Search',
                  selected: location == '/search',
                  onTap: () => context.go('/search'),
                ),
                _HeaderNav(
                  label: 'Orders',
                  selected: location == '/orders',
                  onTap: () => context.go('/orders'),
                ),
                _CartIconButton(cartCount: cartCount),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: () => context.go('/profile'),
                    icon: Icon(session.isLoggedIn ? Icons.person : Icons.login),
                    label: Text(
                      session.isLoggedIn
                          ? session.name.split(' ').first
                          : 'Login',
                    ),
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
              selectedIndex: index,
              destinations: destinations,
              onDestinationSelected: (value) => context.go(routes[value]),
            ),
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
        if (cartCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFF2E00),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$cartCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CustomerDrawer extends StatelessWidget {
  const _CustomerDrawer({required this.session});

  final CustomerSession session;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
            decoration: const BoxDecoration(color: Color(0xFF080A0F)),
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
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF10B8D4),
                            Color(0xFFFFD400),
                            Color(0xFFFF2E00),
                          ],
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
                            session.isLoggedIn
                                ? session.email
                                : BazaaroBrand.tagline,
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
        color: Colors.white.withValues(alpha: .1),
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

class _HeaderNav extends StatelessWidget {
  const _HeaderNav({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}
