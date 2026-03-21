import 'package:flutter/material.dart';

class AppTheme {
  static CardTheme getCardTheme(colorScheme) {
    return CardTheme(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme(colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  static SwitchThemeData getSwitchTheme(colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withOpacity(0.5);
        }
        return null;
      }),
    );
  }

  static ProgressIndicatorThemeData getProgressIndicatorTheme(colorScheme) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
    );
  }

  static ThemeData get lightTheme {
    const lightColorScheme = ColorScheme.light(
      primary: Color(0xFFC1BAA1),
      onPrimary: Color(0xFFA59D84),
      secondary: Color(0xFFD7D3BF),
      onSecondary: Color(0xFFA59D84),
      surface: Color(0xFFECEBDE),
      onSurface: Color(0xFFA59D84),
      error: Color(0xFFD32F2F),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: getCardTheme(lightColorScheme),
      elevatedButtonTheme: getElevatedButtonTheme(lightColorScheme),
      switchTheme: getSwitchTheme(lightColorScheme),
      progressIndicatorTheme: getProgressIndicatorTheme(lightColorScheme),
    );
  }

  static ThemeData get darkTheme {
    const darkColorScheme = ColorScheme.dark(
      primary: Color(0xFFC9B194),
      onPrimary: Color(0xFFDBDBDB),
      secondary: Color(0xFFA08963),
      onSecondary: Color(0xFFDBDBDB),
      surface: Color(0xFF706D54),
      onSurface: Color(0xFFDBDBDB),
      error: Color(0xFFEF5350),
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: getCardTheme(darkColorScheme),
      elevatedButtonTheme: getElevatedButtonTheme(darkColorScheme),
      switchTheme: getSwitchTheme(darkColorScheme),
      progressIndicatorTheme: getProgressIndicatorTheme(darkColorScheme),
    );
  }
}
