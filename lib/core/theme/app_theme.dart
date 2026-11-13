import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color background = Color(0xFF090A0F);
  static const Color cardSurface = Color(0xFF14161F);
  static const Color elevatedSurface = Color(0xFF191C27);
  static const Color gold = Color(0xFFFFC857);

  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ).copyWith(
          primary: gold,
          onPrimary: const Color(0xFF2A1B00),
          surface: cardSurface,
          surfaceContainerHighest: elevatedSurface,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x14FFFFFF)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0D0F16),
        indicatorColor: gold.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: elevatedSurface,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIconColor: Colors.white54,
        suffixIconColor: Colors.white54,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x14FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.7)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: gold.withValues(alpha: 0.10),
        side: BorderSide(color: gold.withValues(alpha: 0.22)),
        labelStyle: TextStyle(
          color: gold.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: elevatedSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x14FFFFFF)),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: gold.withValues(alpha: 0.15),
      ),
    );
  }
}
