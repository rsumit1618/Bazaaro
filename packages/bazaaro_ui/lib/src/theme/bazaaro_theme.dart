import 'package:flutter/material.dart';

import 'bazaaro_app_theme.dart';

/// Base Material theme used by all apps.
///
/// Role-specific layout should be handled by app shells,
/// not by hardcoded colors spread across widgets.
class BazaaroTheme {
  /// Legacy color tokens kept for compatibility.
  /// New widgets should use [BazaaroAppTheme] instead.
  static const ocean = Color(0xFF10B8D4);
  static const sunshine = Color(0xFFFFD400);
  static const ember = Color(0xFFFF8A00);
  static const ink = Color(0xFF080A0F);

  static ThemeData light() {
    const appTheme = BazaaroAppTheme.light;
    final scheme = ColorScheme.fromSeed(seedColor: ocean, secondary: ember);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: appTheme.scaffoldBackground,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        color: appTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static BazaaroAppTheme get app => BazaaroAppTheme.light;
}
