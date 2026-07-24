import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF2E7D32);
  static const secondaryColor = Color(0xFFFFA000);
  static const tertiaryColor = Color(0xFF1565C0);

  static final TextTheme _textTheme = TextTheme(
    displayLarge: const TextStyle(fontFamily: 'NotoSans'),
    displayMedium: const TextStyle(fontFamily: 'NotoSans'),
    displaySmall: const TextStyle(fontFamily: 'NotoSans'),
    headlineLarge: const TextStyle(fontFamily: 'NotoSans'),
    headlineMedium: const TextStyle(fontFamily: 'NotoSans'),
    headlineSmall: const TextStyle(fontFamily: 'NotoSans'),
    titleLarge: const TextStyle(fontFamily: 'NotoSans'),
    titleMedium: const TextStyle(fontFamily: 'NotoSans'),
    titleSmall: const TextStyle(fontFamily: 'NotoSans'),
    bodyLarge: const TextStyle(fontFamily: 'NotoSans'),
    bodyMedium: const TextStyle(fontFamily: 'NotoSans'),
    bodySmall: const TextStyle(fontFamily: 'NotoSans'),
    labelLarge: const TextStyle(fontFamily: 'NotoSans'),
    labelMedium: const TextStyle(fontFamily: 'NotoSans'),
    labelSmall: const TextStyle(fontFamily: 'NotoSans'),
  ).apply(
    fontFamily: 'NotoSans',
    fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansTelugu', 'NotoSansTamil'],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      textTheme: _textTheme,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      textTheme: _textTheme,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
