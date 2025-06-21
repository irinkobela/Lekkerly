// lib/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Colors ---
  static const Color primaryLight = Color(0xFFF96E46); // Warm Coral/Peach
  static const Color primaryDark = Color(0xFF0D1B2A); // Dark Navy
  static const Color accentLight = Color(0xFFFDC57B); // Soft Yellow
  static const Color accentDark = Color(0xFF41EAD4); // Vibrant Teal/Cyan
  static const Color backgroundLight = Color(0xFFFFF8F0); // Very Light Peach
  static const Color backgroundDark =
      Color(0xFF1B263B); // Another shade of Dark Blue

  // --- Light Theme ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: accentLight,
        background: backgroundLight,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onBackground: Colors.black87,
        onSurface: Colors.black87,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryLight,
      ),
      cardTheme: CardThemeData(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        ),
      ),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary:
            accentDark, // Use the vibrant accent as the primary action color
        secondary: primaryLight,
        background: primaryDark,
        surface: backgroundDark,
        onPrimary: Colors.black87,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
        error: Colors.red,
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: backgroundDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentDark,
          foregroundColor: Colors.black87,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        ),
      ),
    );
  }
}
