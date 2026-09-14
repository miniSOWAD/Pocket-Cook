import 'package:flutter/material.dart';

/// Pocket Cook visual system.
///
/// Cyan carries the brand and primary actions, light blue keeps the interface
/// airy, and light orange adds warmth to food-focused highlights without
/// overwhelming the content.
abstract final class AppTheme {
  static const cyan = Color(0xFF18C8D7);
  static const deepCyan = Color(0xFF087F91);
  static const brightCyan = Color(0xFF27D8E6);
  static const lightBlue = Color(0xFFDDF5FF);
  static const paleCyan = Color(0xFFEAFBFD);
  static const skyMist = Color(0xFFF2FAFF);
  static const lightOrange = Color(0xFFFFB56B);
  static const orangeWash = Color(0xFFFFE7CC);
  static const snow = Color(0xFFFCFEFF);
  static const ink = Color(0xFF173A45);
  static const mutedInk = Color(0xFF5E7780);
  static const lineBlue = Color(0xFFCFE9F1);

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: brightness,
    ).copyWith(
      primary: dark ? const Color(0xFF55DFE8) : deepCyan,
      onPrimary: dark ? const Color(0xFF00363D) : Colors.white,
      primaryContainer: dark ? const Color(0xFF0B535F) : lightBlue,
      onPrimaryContainer: dark ? const Color(0xFFD8FAFF) : ink,
      secondary: dark ? const Color(0xFFFFC485) : lightOrange,
      onSecondary: dark ? const Color(0xFF4E2B00) : const Color(0xFF5A2E00),
      secondaryContainer: dark ? const Color(0xFF674015) : orangeWash,
      onSecondaryContainer: dark ? const Color(0xFFFFE7C8) : ink,
      tertiary: dark ? const Color(0xFF89CFFF) : const Color(0xFF4AA8E8),
      tertiaryContainer: dark ? const Color(0xFF244E69) : const Color(0xFFE4F4FF),
      surface: dark ? const Color(0xFF11272D) : snow,
      onSurface: dark ? const Color(0xFFEAF9FC) : ink,
      onSurfaceVariant: dark ? const Color(0xFFB8D3DA) : mutedInk,
      outline: dark ? const Color(0xFF6A8992) : const Color(0xFFAFCFD8),
      outlineVariant: dark ? const Color(0xFF31525B) : lineBlue,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    final headingColor = dark ? const Color(0xFFE9FCFF) : ink;
    final background = dark ? const Color(0xFF0A1C21) : const Color(0xFFF5FCFF);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: headingColor,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.6,
          height: 1.02,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: headingColor,
          fontSize: 39,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          height: 1.08,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: headingColor,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          height: 1.12,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: headingColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
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
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: headingColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF17343B) : snow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.78)),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.primary,
        suffixIconColor: scheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.95)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.outlineVariant,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: dark ? const Color(0xFF17343B) : skyMist,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: dark ? const Color(0xFF11272D) : snow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: dark ? const Color(0xFF0B535F) : lightBlue,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
          color: scheme.onSurface,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: dark ? const Color(0xFF0B535F) : lightBlue,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.8),
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF165865) : ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightOrange,
        foregroundColor: const Color(0xFF4C2B00),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
