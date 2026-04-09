import 'package:flutter/material.dart';

/// Application theme matching the JKR design system.
/// Primary color: Vesijärven sininen #004F71
class AppTheme {
  const AppTheme._();

  static const _primaryColor = Color(0xFF004F71);
  static const _primaryDark = Color(0xFF003552);
  static const _primaryMid = Color(0xFF1A6A8A);
  static const _primaryLight = Color(0xFFE0EFF5);

  static const _bg = Color(0xFFFFFFFF);
  static const _bg2 = Color(0xFFF4F5F7);
  static const _bg3 = Color(0xFFECEEF2);

  static const _t1 = Color(0xFF111827);
  static const _t2 = Color(0xFF4B5563);
  static const _t3 = Color(0xFF9CA3AF);

  static const _green = Color(0xFF166534);
  static const _greenBg = Color(0xFFDCFCE7);
  static const _amber = Color(0xFF92400E);
  static const _amberBg = Color(0xFFFEF3C7);
  static const _red = Color(0xFF991B1B);
  static const _redBg = Color(0xFFFEE2E2);

  static const fontFamily = 'DM Sans';

  // Expose colors for direct use in widgets
  static Color get primaryColor => _primaryColor;
  static Color get primaryDark => _primaryDark;
  static Color get primaryMid => _primaryMid;
  static Color get primaryLight => _primaryLight;
  static Color get background => _bg;
  static Color get background2 => _bg2;
  static Color get background3 => _bg3;
  static Color get textPrimary => _t1;
  static Color get textSecondary => _t2;
  static Color get textTertiary => _t3;
  static Color get green => _green;
  static Color get greenBg => _greenBg;
  static Color get amber => _amber;
  static Color get amberBg => _amberBg;
  static Color get red => _red;
  static Color get redBg => _redBg;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: _bg3,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: _primaryLight,
      onPrimaryContainer: _primaryDark,
      secondary: _primaryMid,
      onSecondary: Colors.white,
      surface: _bg,
      onSurface: _t1,
      onSurfaceVariant: _t2,
      outline: Color(0x1A000000),
      outlineVariant: Color(0x33000000),
      error: _red,
      errorContainer: _redBg,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _bg,
      foregroundColor: _t1,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black.withValues(alpha: 0.10),
      thickness: 0.5,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: const TextStyle(fontSize: 12, fontFamily: fontFamily),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: const TextStyle(fontSize: 12, fontFamily: fontFamily),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _t1,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.20)),
        textStyle: const TextStyle(fontSize: 12, fontFamily: fontFamily),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.20)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      filled: true,
      fillColor: _bg2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      isDense: true,
      hintStyle: const TextStyle(fontSize: 12, color: _t3),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _t2),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _t1),
      headlineMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _t1),
      titleMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _t1),
      titleSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _t3),
      bodyMedium: TextStyle(fontSize: 12, color: _t2),
      bodySmall: TextStyle(fontSize: 11, color: _t3),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _t3),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _bg2,
      labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static ThemeData get dark => light;
}
