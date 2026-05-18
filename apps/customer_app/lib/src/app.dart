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
      builder: (context, state, child) => CustomerShellWrapper(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/categories',
          builder: (_, __) => const CategoriesScreen(),
        ),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => NoTransitionPage(
            child: SearchScreen(initialQuery: state.uri.queryParameters['q']),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) =>
          ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
  ],
);

class CustomerShellWrapper extends ConsumerWidget {
  const CustomerShellWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).itemCount;
    final session = ref.watch(customerSessionProvider);

    final profileLabel = session.isLoggedIn
        ? session.name.split(' ').first
        : 'Login';
    final profileIcon = session.isLoggedIn ? Icons.person : Icons.login;

    return CustomerAppScaffold(
      cartCount: cartCount,
      isLoggedIn: session.isLoggedIn,
      profileLabel: profileLabel,
      profileIcon: profileIcon,
      child: child,
    );
  }
}
