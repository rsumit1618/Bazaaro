import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../customer/customer_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(customerSessionProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF080A0F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFFFD400),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          session.isLoggedIn
                              ? session.email
                              : BazaaroBrand.tagline,
                          style: const TextStyle(color: Colors.white70),
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
