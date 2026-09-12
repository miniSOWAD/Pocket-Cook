import 'package:flutter/material.dart';

/// The visual language for Liza's Kitchen.
///
/// The palette is intentionally warm and tactile: baby pink for affection,
/// cream for warmth, and off-white for breathing room. Deeper rose/cocoa
/// tones are used for accessible text and controls.
abstract final class AppTheme {
  static const babyPink = Color(0xFFF4B8C8);
  static const softPink = Color(0xFFFBE1E8);
  static const blush = Color(0xFFFFEEF2);
  static const dustyRose = Color(0xFFB95F78);
  static const deepRose = Color(0xFF8D4258);
  static const cream = Color(0xFFFFF1DC);
  static const softCream = Color(0xFFFFF7EA);
  static const offWhite = Color(0xFFFFFCF8);
  static const cocoa = Color(0xFF5A3B43);
  static const mutedCocoa = Color(0xFF7C6268);
  static const line = Color(0xFFEED9DE);

  // Backwards-friendly aliases for code that previously referenced the old
  // green/terracotta palette. Keeping the aliases avoids needless churn while
  // ensuring every visible surface follows the new brand.
  static const forest = deepRose;
  static const clay = dustyRose;

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: babyPink,
      brightness: brightness,
    ).copyWith(
      primary: dark ? const Color(0xFFFFC8D6) : deepRose,
      onPrimary: dark ? const Color(0xFF512331) : Colors.white,
      primaryContainer: dark ? const Color(0xFF6D3445) : softPink,
      onPrimaryContainer: dark ? const Color(0xFFFFE8EE) : cocoa,
      secondary: dark ? const Color(0xFFF3B6C5) : dustyRose,
      onSecondary: dark ? const Color(0xFF4B2430) : Colors.white,
      secondaryContainer: dark ? const Color(0xFF623340) : cream,
      onSecondaryContainer: dark ? const Color(0xFFFFECF1) : cocoa,
      surface: dark ? const Color(0xFF2B2023) : offWhite,
      onSurface: dark ? const Color(0xFFFFF5F7) : cocoa,
      onSurfaceVariant: dark ? const Color(0xFFE8CED5) : mutedCocoa,
      outline: dark ? const Color(0xFF8E7179) : const Color(0xFFD8BAC2),
      outlineVariant: dark ? const Color(0xFF5A4148) : line,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    final headingColor = dark ? const Color(0xFFFFEDF2) : cocoa;
    final background = dark ? const Color(0xFF21181B) : const Color(0xFFFFF9F4);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: headingColor,
          fontSize: 44,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.02,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: headingColor,
          fontSize: 39,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.25,
          height: 1.08,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: headingColor,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
          height: 1.12,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: headingColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: headingColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          height: 1.55,
          fontSize: 16,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          height: 1.5,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.4,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF21181B) : const Color(0xFFFFF9F4),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: headingColor,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF302327) : offWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.78)),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.primary,
        suffixIconColor: scheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.95)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.outlineVariant,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: dark ? const Color(0xFF37272C) : softCream,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: dark ? const Color(0xFF2B2023) : offWhite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: dark ? const Color(0xFF6D3445) : softPink,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
          color: scheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: dark ? const Color(0xFF6D3445) : softPink,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.8),
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF5E3441) : cocoa,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
