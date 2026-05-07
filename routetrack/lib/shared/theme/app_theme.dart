import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const bg       = Color(0xFFF0F4F8);
  static const surface  = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF8FAFC);

  // Borders & dividers
  static const border   = Color(0xFFE2E8F0);

  // Brand
  static const accent   = Color(0xFF1E3A8A);  // navy corporativo
  static const accent2  = Color(0xFF3B82F6);  // azul medio

  // Semánticos
  static const warn     = Color(0xFFD97706);
  static const danger   = Color(0xFFDC2626);
  static const green    = Color(0xFF059669);
  static const purple   = Color(0xFF7C3AED);

  // Texto
  static const textPrim  = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
}

final appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: const ColorScheme.light(
    primary: AppColors.accent,
    secondary: AppColors.accent2,
    surface: AppColors.surface,
    error: AppColors.danger,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrim,
  ),
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, color: AppColors.textPrim),
    titleLarge:   TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrim),
    titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrim),
    bodyLarge:    TextStyle(fontSize: 14, color: AppColors.textPrim),
    bodyMedium:   TextStyle(fontSize: 13, color: AppColors.textPrim),
    labelSmall:   TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.border),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrim,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
    hintStyle: const TextStyle(color: AppColors.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  ),
  dividerColor: AppColors.border,
  dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
);
