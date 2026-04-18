import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Mode Colors (Premium Indigo & Teal)
  static const Color lightBackground = Color(0xFFF8F9FA); // Cool light gray
  static const Color lightPrimary = Color(0xFF4F46E5); // Indigo 600
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1F2937); // Gray 800
  static const Color lightAccent = Color(0xFF10B981); // Emerald 500
  static const Color lightOutline = Color(0xFFE5E7EB); // Gray 200

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF111827); // Gray 900
  static const Color darkPrimary = Color(0xFF6366F1); // Indigo 500
  static const Color darkSurface = Color(0xFF1F2937); // Gray 800
  static const Color darkText = Color(0xFFF3F4F6); // Gray 100
  static const Color darkAccent = Color(0xFF34D399); // Emerald 400
  static const Color darkOutline = Color(0xFF374151); // Gray 700

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightAccent,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSurface: lightText,
        outline: lightOutline,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: lightText,
        displayColor: lightText,
        fontFamily: GoogleFonts.cairo().fontFamily,
      ).copyWith(
        displayLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        displayMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        displaySmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        headlineLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        headlineMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        headlineSmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        titleSmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        bodySmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        labelLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        labelMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
        labelSmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: lightText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightOutline, width: 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: lightPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkAccent,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSurface: darkText,
        outline: darkOutline,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkText,
        displayColor: darkText,
        fontFamily: GoogleFonts.cairo().fontFamily,
      ).copyWith(
        displayLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        displayMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        displaySmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        headlineLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        headlineMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        headlineSmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        titleSmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        bodySmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        labelLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        labelMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
        labelSmall: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: darkText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkOutline, width: 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: darkPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
