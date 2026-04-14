import 'package:flutter/material.dart';

/// Represents a theme preset with a complete color palette.
///
/// This is a simple data class that can be safely imported
/// in background isolates without depending on presentation-layer types.
class ThemePreset {
  final String id;
  final String name;
  final String nameAr;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color surfaceLightColor;
  final Color cardBorderColor;
  final Color textColor;
  final Color textSecondaryColor;
  final IconData icon;
  final bool isDark;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.surfaceLightColor,
    required this.cardBorderColor,
    required this.textColor,
    required this.textSecondaryColor,
    required this.icon,
    required this.isDark,
  });

  /// Converts the preset colors to a hex string map for storage.
  Map<String, String> toHexMap() {
    return {
      'primary': primaryColor.toHex(),
      'accent': accentColor.toHex(),
      'background': backgroundColor.toHex(),
      'surface': surfaceColor.toHex(),
      'surfaceLight': surfaceLightColor.toHex(),
      'cardBorder': cardBorderColor.toHex(),
      'text': textColor.toHex(),
      'textSecondary': textSecondaryColor.toHex(),
    };
  }

  /// Creates a ThemePreset from a hex string map.
  factory ThemePreset.fromHexMap(Map<String, String> hexMap, {
    required String id,
    required String name,
    required String nameAr,
    required IconData icon,
    required bool isDark,
  }) {
    return ThemePreset(
      id: id,
      name: name,
      nameAr: nameAr,
      primaryColor: Color(
        int.parse(hexMap['primary']!.replaceFirst('#', '0xFF'), radix: 16),
      ),
      accentColor: Color(
        int.parse(hexMap['accent']!.replaceFirst('#', '0xFF'), radix: 16),
      ),
      backgroundColor: Color(
        int.parse(
          hexMap['background']!.replaceFirst('#', '0xFF'),
          radix: 16,
        ),
      ),
      surfaceColor: Color(
        int.parse(hexMap['surface']!.replaceFirst('#', '0xFF'), radix: 16),
      ),
      surfaceLightColor: Color(
        int.parse(
          hexMap['surfaceLight']!.replaceFirst('#', '0xFF'),
          radix: 16,
        ),
      ),
      cardBorderColor: Color(
        int.parse(hexMap['cardBorder']!.replaceFirst('#', '0xFF'), radix: 16),
      ),
      textColor: Color(
        int.parse(hexMap['text']!.replaceFirst('#', '0xFF'), radix: 16),
      ),
      textSecondaryColor: Color(
        int.parse(
          hexMap['textSecondary']!.replaceFirst('#', '0xFF'),
          radix: 16,
        ),
      ),
      icon: icon,
      isDark: isDark,
    );
  }
}

/// Extension to convert Color to hex string for storage.
extension ColorHexExtension on Color {
  String toHex() {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }
}

/// Extension to parse hex string to Color.
extension ColorParseExtension on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
