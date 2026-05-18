import 'package:flutter/material.dart';

/// UI tokens used by reusable app chrome (scaffolds, headers, drawers, badges).
///
/// Apps should not hardcode colors; instead read them from this theme.
class BazaaroAppTheme {
  const BazaaroAppTheme({
    required this.brandGradient,
    required this.drawerBackground,
    required this.drawerHeaderGradient,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.menuPillBackground,
    required this.cardBackground,
    required this.scaffoldBackground,
  });

  /// Brand gradient for small square logo and similar elements.
  final List<Color> brandGradient;

  final Color drawerBackground;
  final List<Color> drawerHeaderGradient;

  final Color badgeBackground;
  final Color badgeForeground;

  /// Background used for chips like “Deals / Free delivery / COD”.
  final Color menuPillBackground;

  final Color cardBackground;
  final Color scaffoldBackground;

  static const light = BazaaroAppTheme(
    brandGradient: [Color(0xFF10B8D4), Color(0xFFFFD400), Color(0xFFFF2E00)],
    drawerBackground: Color(0xFF080A0F),
    drawerHeaderGradient: [
      Color(0xFF10B8D4),
      Color(0xFFFFD400),
      Color(0xFFFF2E00),
    ],
    badgeBackground: Color(0xFFFF2E00),
    badgeForeground: Colors.white,
    menuPillBackground: Color(0x19FFFFFF),
    cardBackground: Colors.white,
    scaffoldBackground: Color(0xFFF6FAFB),
  );
}
