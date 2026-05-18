import 'package:flutter/material.dart';

import 'bazaaro_app_theme.dart';

/// Base Material theme used by all apps.
///
/// Role-specific layout should be handled by app shells,
/// not by hardcoded colors spread across widgets.
class BazaaroTheme {
  /// Legacy color tokens kept for compatibility.
  /// New widgets should use [BazaaroAppTheme] instead.
  static const ocean = Color(0xFF7C3AED);
  static const sunshine = Color(0xFFFACC15);
  static const ember = Color(0xFFF97316);
  static const ink = Color(0xFF09090B);

  static ThemeData light() {
    const appTheme = BazaaroAppTheme.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: appTheme.primary,
      secondary: appTheme.pink,
      surface: appTheme.cardBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: appTheme.scaffoldBackground,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: appTheme.cardBackground.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: appTheme.cardBackground,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: appTheme.cardBackground,
          foregroundColor: appTheme.brandInk,
          shape: const CircleBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appTheme.softSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: appTheme.primary, width: 1.2),
        ),
      ),
    );
  }

  static BazaaroAppTheme get app => BazaaroAppTheme.light;
}
