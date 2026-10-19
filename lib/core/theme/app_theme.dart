import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core colors
  static const Color background = Color(0xFF0A0E0D);
  static const Color primary = Color(0xFF123D2A);
  static const Color accent = Color(0xFF4CE05A);

  // Surface colors
  static const Color surface = Color(0xFF18221E);
  static const Color surfaceLight = Color(0xFF222B27);
  static const Color divider = Color(0xFF1F2924);

  // Text colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF9AA59F);

  // Glow and neon effects
  static const Color glow = Color(0xFF2F7A3E);
  static const Color neon = Color(0xFF7CFF3A);

  // Semantic colors
  static const Color income = Color(0xFF4CE05A);
  static const Color expense = Color(0xFFFF6B6B);

  // Balance card gradient
  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0x992F7A3E)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.neon,
        selectionColor: Color(0x997CFF3A),
        selectionHandleColor: AppColors.neon,
      ),

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.expense,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
      ),
    );
  }
}
