import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available Quran-appropriate fonts with their exact Google Fonts family names.
class QuranFonts {
  QuranFonts._();

  /// Whitelist of valid font family names (exact Google Fonts names)
  static const List<String> availableFonts = [
    'Amiri',
    'Amiri Quran',
    'Noto Naskh Arabic',
    'Scheherazade New',
    'Lateef',
    'Tajawal',
  ];

  /// Default fallback font
  static const String defaultFont = 'Amiri';

  /// Validates and returns a safe font name.
  /// Returns [defaultFont] if the input is null, empty, or not in the whitelist.
  static String safeFont(String? fontFamily) {
    if (fontFamily == null || fontFamily.isEmpty) return defaultFont;
    if (availableFonts.contains(fontFamily)) return fontFamily;
    return defaultFont;
  }

  /// Gets a TextStyle from Google Fonts with fallback to default on error.
  /// Never throws - always returns a valid TextStyle.
  static TextStyle getFontStyle({
    String? fontFamily,
    required double fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
    double? wordSpacing,
  }) {
    final safeName = safeFont(fontFamily);
    try {
      return GoogleFonts.getFont(
        safeName,
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
        wordSpacing: wordSpacing,
      );
    } catch (_) {
      // Ultimate fallback: Amiri (should always be available)
      return GoogleFonts.amiri(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
        wordSpacing: wordSpacing,
      );
    }
  }

  /// Gets the font family string for use in StrutStyle.
  /// Returns the fontFamily of the resolved font.
  static String getFontFamilyName(String? fontFamily) {
    final safeName = safeFont(fontFamily);
    try {
      return GoogleFonts.getFont(safeName).fontFamily ?? 'Amiri';
    } catch (_) {
      return 'Amiri';
    }
  }
}
