import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const forest = Color(0xFF285B43);
  static const clay = Color(0xFFB85336);
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: forest, brightness: brightness).copyWith(
      primary: dark ? const Color(0xFFA6D8B8) : forest,
      secondary: dark ? const Color(0xFFF3AD93) : clay,
      surface: dark ? const Color(0xFF18211C) : const Color(0xFFFFFDF8),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
    return base.copyWith(
      scaffoldBackgroundColor: dark ? const Color(0xFF101813) : const Color(0xFFF8F7F2),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.1),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(fontSize: 29, fontWeight: FontWeight.w700, letterSpacing: -0.8),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      appBarTheme: AppBarTheme(backgroundColor: dark ? const Color(0xFF101813) : const Color(0xFFF8F7F2),
        elevation: 0, scrolledUnderElevation: 0, centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.primary, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      )),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer, elevation: 0),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5), space: 1),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}
