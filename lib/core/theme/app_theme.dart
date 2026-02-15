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
  static const Color cardBorder = Color(0xFF3D444D); // Slightly lighter for visibility
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFFD1D5DA); // Brighter gray
  static const Color missed = Color(0xFFF85149); // Brighter red
  static const Color onMissed = Colors.white;
  static const Color saved = Color(0xFF3FB950); // Brighter green
  static const Color onSaved = Color(0xFF003300);
  static const Color onPrimary = Color(0xFF003300);
  static const Color neutral = Color(0xFF8B949E); // Much brighter neutral (GitHub's secondary text color)
  static const Color onAccent = Color(0xFF3E2723);

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
        onSecondary: onAccent,
        onSurface: textPrimary,
        outline: cardBorder,
        surfaceContainer: surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32.0),
          displayMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 28.0),
          headlineLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24.0),
          headlineMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w500, fontSize: 20.0),
          titleLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18.0),
          titleMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16.0),
          bodyLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w400, fontSize: 16.0),
          bodyMedium:
              TextStyle(color: textSecondary, fontWeight: FontWeight.w400, fontSize: 14.0),
          labelLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 14.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
                color: accent, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return GoogleFonts.outfit(
              color: textSecondary, fontWeight: FontWeight.w400, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: cardBorder, width: 1.0),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(fontSize: 14, color: textSecondary),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: surface,
        collapsedBackgroundColor: surface,
        iconColor: textSecondary,
        collapsedIconColor: textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: cardBorder, width: 1.0),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: cardBorder, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Color(0xFF003300), // High contrast on green
          elevation: 0.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
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
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: cardBorder, width: 1.0),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        dividerColor: cardBorder,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14.0),
        unselectedLabelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 14.0),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1.0,
      ),
    );
  }
}
