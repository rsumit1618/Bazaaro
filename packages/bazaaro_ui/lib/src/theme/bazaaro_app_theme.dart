import 'package:flutter/material.dart';

/// UI tokens used by reusable app chrome, feature pages, badges, and cards.
class BazaaroAppTheme {
  const BazaaroAppTheme({
    required this.brandGradient,
    required this.primary,
    required this.primaryDark,
    required this.orange,
    required this.pink,
    required this.text,
    required this.muted,
    required this.softSurface,
    required this.border,
    required this.heroGradient,
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
    required this.shadow,
    required this.softShadow,
    required this.cardBackground,
    required this.scaffoldBackground,
  });

  final List<Color> brandGradient;
  final Color primary;
  final Color primaryDark;
  final Color orange;
  final Color pink;
  final Color text;
  final Color muted;
  final Color softSurface;
  final Color border;
  final List<Color> heroGradient;

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
  final List<BoxShadow> shadow;
  final List<BoxShadow> softShadow;

  final Color cardBackground;
  final Color scaffoldBackground;

  static const light = BazaaroAppTheme(
    brandGradient: [Color(0xFF7C3AED), Color(0xFFEC4899), Color(0xFFF97316)],
    primary: Color(0xFF7C3AED),
    primaryDark: Color(0xFF5B21B6),
    orange: Color(0xFFF97316),
    pink: Color(0xFFEC4899),
    text: Color(0xFF27272A),
    muted: Color(0xFF71717A),
    softSurface: Color(0xFFF4F4F5),
    border: Color(0xFFE4E4E7),
    heroGradient: [Color(0xFFFFFFFF), Color(0xFFFDF4FF), Color(0xFFEEF2FF)],
    drawerBackground: Color(0xFF09090B),
    drawerHeaderGradient: [
      Color(0xFF7C3AED),
      Color(0xFFEC4899),
      Color(0xFFF97316),
    ],
    badgeBackground: Color(0xFFF97316),
    badgeForeground: Colors.white,
    menuPillBackground: Color(0x19FFFFFF),
    menuPillForeground: Colors.white,
    menuPillIcon: Color(0xFFFACC15),
    brandInk: Color(0xFF09090B),
    brandOnInk: Colors.white,
    brandAccent: Color(0xFFFACC15),
    shadow: [
      BoxShadow(
        color: Color(0x2410172A),
        blurRadius: 70,
        offset: Offset(0, 24),
      ),
    ],
    softShadow: [
      BoxShadow(
        color: Color(0x1410172A),
        blurRadius: 35,
        offset: Offset(0, 14),
      ),
    ],
    cardBackground: Colors.white,
    scaffoldBackground: Color(0xFFFAFAFA),
  );
}
