import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFF9A825);
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color cardBorder = Color(0xFF30363D);
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color missed = Color(0xFFE53935);
  static const Color saved = Color(0xFF4CAF50);
  static const Color neutral = Color(0xFF484F58);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: accent,
        surface: surface,
        error: missed,
        onPrimary: Color(0xFF003300),
        onSecondary: Color(0xFF3E2723),
        onSurface: textPrimary,
        outline: cardBorder,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
          displayMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 28),
          headlineLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
          headlineMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w500, fontSize: 20),
          titleLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          titleMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
          bodyLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w400, fontSize: 16),
          bodyMedium:
              TextStyle(color: textSecondary, fontWeight: FontWeight.w400, fontSize: 14),
          labelLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: surface,
        collapsedBackgroundColor: surface,
        iconColor: textSecondary,
        collapsedIconColor: textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: cardBorder, width: 1),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textSecondary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        dividerColor: cardBorder,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
      ),
    );
  }
}
