import 'package:flutter/material.dart';

import '../theme/bazaaro_theme.dart';

class BazaaroCartBadge extends StatelessWidget {
  const BazaaroCartBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final appTheme = BazaaroTheme.app;

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.badgeBackground,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: appTheme.badgeForeground,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
