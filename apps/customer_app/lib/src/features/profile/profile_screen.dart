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
    final compact =
        Responsive.breakpointOf(context) == BazaaroBreakpoint.compact;

    return BazaaroFeaturePage(
      title: 'Profile',
      maxWidth: 980,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHero(session: session),
          const SizedBox(height: 16),
          if (compact)
            const _MobileProfileSummary()
          else
            const Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    value: '12',
                    label: 'Orders',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ProfileStat(
                    value: '5',
                    label: 'Wishlist',
                    icon: Icons.favorite_border,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ProfileStat(
                    value: '3',
                    label: 'Addresses',
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: 'Shopping',
            children: [
              _ProfileTile(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                subtitle: 'Saved products and price drops',
                tint: BazaaroTheme.app.pink,
              ),
              _ProfileTile(
                icon: Icons.receipt_long_outlined,
                title: 'My orders',
                subtitle: 'Track, cancel, return and reorder',
                tint: BazaaroTheme.app.primary,
                onTap: () => context.go('/orders'),
              ),
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                subtitle: 'Home, office, and delivery instructions',
                tint: BazaaroTheme.app.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileSection(
            title: 'Account',
            children: [
              _ProfileTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Deals, delivery updates, and offers',
                tint: BazaaroTheme.app.primaryDark,
              ),
              _ProfileTile(
                icon: Icons.payment_outlined,
                title: 'Payments',
                subtitle: 'UPI, cards, wallets and COD options',
                tint: Colors.teal,
              ),
              _ProfileTile(
                icon: Icons.support_agent_outlined,
                title: 'Support',
                subtitle: 'Returns, refunds, and help center',
                tint: Colors.indigo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends ConsumerWidget {
  const _ProfileHero({required this.session});

  final CustomerSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = BazaaroTheme.app;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appTheme.brandInk,
            appTheme.primaryDark,
            appTheme.pink.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: appTheme.shadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final avatar = _ProfileAvatar(session: session);
          final details = _ProfileHeroDetails(
            session: session,
            centered: compact,
          );
          final action = FilledButton.icon(
            onPressed: () => session.isLoggedIn
                ? ref.read(customerSessionProvider.notifier).logout()
                : context.go('/login'),
            icon: Icon(session.isLoggedIn ? Icons.logout : Icons.login),
            label: Text(session.isLoggedIn ? 'Logout' : 'Login'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(height: 14),
                details,
                const SizedBox(height: 16),
                action,
              ],
            );
          }
          return Row(
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(child: details),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.session});

  final CustomerSession session;

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;
    final initial = session.isLoggedIn && session.name.trim().isNotEmpty
        ? session.name.trim().substring(0, 1).toUpperCase()
        : 'B';
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: appTheme.brandGradient),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appTheme.brandOnInk.withValues(alpha: 0.18)),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: appTheme.brandOnInk,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ProfileHeroDetails extends StatelessWidget {
  const _ProfileHeroDetails({required this.session, required this.centered});

  final CustomerSession session;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          session.isLoggedIn ? session.name : 'Welcome to Bazaaro',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: appTheme.brandOnInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          session.isLoggedIn
              ? session.email
              : 'Login to sync cart, wishlist, orders and delivery updates.',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: appTheme.brandOnInk.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ProfileBadge(label: 'Smart deals'),
            _ProfileBadge(label: 'Fast checkout'),
            _ProfileBadge(label: 'Order tracking'),
          ],
        ),
      ],
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BazaaroTheme.app.brandOnInk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: BazaaroTheme.app.brandOnInk,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MobileProfileSummary extends StatelessWidget {
  const _MobileProfileSummary();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          SizedBox(
            width: 150,
            child: _ProfileStat(
              value: '12',
              label: 'Orders',
              icon: Icons.receipt_long_outlined,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: _ProfileStat(
              value: '5',
              label: 'Wishlist',
              icon: Icons.favorite_border,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: _ProfileStat(
              value: '3',
              label: 'Addresses',
              icon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: appTheme.border),
        boxShadow: appTheme.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: appTheme.primary.withValues(alpha: 0.1),
            foregroundColor: appTheme.primary,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: appTheme.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BazaaroTheme.app.cardBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: BazaaroTheme.app.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          ...children,
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
    required this.tint,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: BazaaroTheme.app.softSurface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: tint.withValues(alpha: 0.12),
                  foregroundColor: tint,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BazaaroTheme.app.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
