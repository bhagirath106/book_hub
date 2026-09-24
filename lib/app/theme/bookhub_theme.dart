import 'package:flutter/material.dart';

abstract final class BookHubColors {
  static const violet = Color(0xffefa936);
  static const lavender = Color(0xffffca68);
  static const ink = Color(0xff221a14);
  static const muted = Color(0xff8c7b66);
  static const canvas = Color(0xfff8f0e4);
  static const darkCanvas = Color(0xff120e0b);
  static const cardDark = Color(0xff1f1a15);
  static const gold = Color(0xffffc857);
  static const terracotta = Color(0xff985544);
  static const sage = Color(0xff4a7238);
}

abstract final class BookHubTheme {
  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);
  static ThemeData amoled() => _theme(Brightness.dark, amoled: true);

  static ThemeData _theme(Brightness brightness, {bool amoled = false}) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: BookHubColors.violet,
      brightness: brightness,
      surface: dark
          ? (amoled ? Colors.black : BookHubColors.darkCanvas)
          : BookHubColors.canvas,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? BookHubColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? BookHubColors.cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? BookHubColors.cardDark : Colors.white,
        indicatorColor: BookHubColors.violet.withValues(alpha: .18),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
          fontFamily: 'Georgia',
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800,
          fontFamily: 'Georgia',
        ),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
