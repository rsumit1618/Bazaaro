import 'package:flutter/material.dart';

/// UI tokens used by reusable app chrome, feature pages, badges, and cards.
class BazaaroAppTheme {
  const BazaaroAppTheme({
    required this.brandGradient,
    required this.drawerBackground,
    required this.drawerHeaderGradient,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.menuPillBackground,
    required this.menuPillForeground,
    required this.menuPillIcon,
    required this.brandInk,
    required this.brandOnInk,
    required this.brandAccent,
    required this.cardBackground,
    required this.scaffoldBackground,
  });

  final List<Color> brandGradient;

  final Color drawerBackground;
  final List<Color> drawerHeaderGradient;

  final Color badgeBackground;
  final Color badgeForeground;

  final Color menuPillBackground;
  final Color menuPillForeground;
  final Color menuPillIcon;

  final Color brandInk;
  final Color brandOnInk;
  final Color brandAccent;

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
    menuPillForeground: Colors.white,
    menuPillIcon: Color(0xFFFFD400),
    brandInk: Color(0xFF080A0F),
    brandOnInk: Colors.white,
    brandAccent: Color(0xFFFFD400),
    cardBackground: Colors.white,
    scaffoldBackground: Color(0xFFF6FAFB),
  );
}
