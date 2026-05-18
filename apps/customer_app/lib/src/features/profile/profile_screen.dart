import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../customer/customer_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(customerSessionProvider);
    return BazaaroFeaturePage(
      title: 'Profile',
      maxWidth: 720,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BazaaroTheme.app.brandInk,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: BazaaroTheme.app.brandAccent,
                  child: Icon(
                    session.isLoggedIn ? Icons.person : Icons.login,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.isLoggedIn
                            ? session.name
                            : 'Login or create account',
                        style: TextStyle(
                          color: BazaaroTheme.app.brandOnInk,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        session.isLoggedIn
                            ? session.email
                            : BazaaroBrand.tagline,
                        style: TextStyle(
                          color: BazaaroTheme.app.brandOnInk.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => session.isLoggedIn
                      ? ref.read(customerSessionProvider.notifier).logout()
                      : context.go('/login'),
                  child: Text(session.isLoggedIn ? 'Logout' : 'Login'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ProfileTile(
            icon: Icons.favorite_border,
            title: 'Wishlist',
            subtitle: 'Saved products and price drops',
          ),
          const _ProfileTile(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle: 'Home, office, and delivery instructions',
          ),
          const _ProfileTile(
            icon: Icons.notifications_outlined,
            title: 'Push notifications',
            subtitle: 'Deals, delivery updates, and offers',
          ),
          const _ProfileTile(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            subtitle: 'Returns, refunds, and help center',
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
