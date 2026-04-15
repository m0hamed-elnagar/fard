import 'package:flutter/material.dart';

/// Widget preview theme data class for Flutter side.
/// Contains 6 color fields for complete widget theming.
class WidgetPreviewTheme {
  final String primaryColorHex;
  final String accentColorHex;
  final String backgroundColorHex;
  final String surfaceColorHex;
  final String textColorHex;
  final String textSecondaryColorHex;

  const WidgetPreviewTheme({
    this.primaryColorHex = '#2E7D32',
    this.accentColorHex = '#FFD54F',
    this.backgroundColorHex = '#0D1117',
    this.surfaceColorHex = '#161B22',
    this.textColorHex = '#FFFFFF',
    this.textSecondaryColorHex = '#8B949E',
  });

  /// Create from ColorScheme (app theme)
  factory WidgetPreviewTheme.fromColorScheme(ColorScheme colorScheme) {
    return WidgetPreviewTheme(
      primaryColorHex: _colorToHex(colorScheme.primary),
      accentColorHex: _colorToHex(colorScheme.secondary),
      backgroundColorHex: _colorToHex(colorScheme.surface),
      surfaceColorHex: _colorToHex(colorScheme.surfaceContainerHighest),
      textColorHex: _colorToHex(colorScheme.onSurface),
      textSecondaryColorHex: _colorToHex(colorScheme.onSurfaceVariant),
    );
  }

  /// Create from map (received from native)
  factory WidgetPreviewTheme.fromMap(Map<String, dynamic> map) {
    return WidgetPreviewTheme(
      primaryColorHex: map['primaryColorHex'] as String? ?? '#2E7D32',
      accentColorHex: map['accentColorHex'] as String? ?? '#FFD54F',
      backgroundColorHex: map['backgroundColorHex'] as String? ?? '#0D1117',
      surfaceColorHex: map['surfaceColorHex'] as String? ?? '#161B22',
      textColorHex: map['textColorHex'] as String? ?? '#FFFFFF',
      textSecondaryColorHex:
          map['textSecondaryColorHex'] as String? ?? '#8B949E',
    );
  }

  /// Convert to map for sending to native
  Map<String, String> toMap() {
    return {
      'primaryColorHex': primaryColorHex,
      'accentColorHex': accentColorHex,
      'backgroundColorHex': backgroundColorHex,
      'surfaceColorHex': surfaceColorHex,
      'textColorHex': textColorHex,
      'textSecondaryColorHex': textSecondaryColorHex,
    };
  }

  /// Create a copy with modified fields
  WidgetPreviewTheme copyWith({
    String? primaryColorHex,
    String? accentColorHex,
    String? backgroundColorHex,
    String? surfaceColorHex,
    String? textColorHex,
    String? textSecondaryColorHex,
  }) {
    return WidgetPreviewTheme(
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      surfaceColorHex: surfaceColorHex ?? this.surfaceColorHex,
      textColorHex: textColorHex ?? this.textColorHex,
      textSecondaryColorHex:
          textSecondaryColorHex ?? this.textSecondaryColorHex,
    );
  }

  /// Get Color objects from hex strings
  WidgetColors toColors() {
    return WidgetColors(
      primary: _hexToColor(primaryColorHex),
      accent: _hexToColor(accentColorHex),
      background: _hexToColor(backgroundColorHex),
      surface: _hexToColor(surfaceColorHex),
      text: _hexToColor(textColorHex),
      textSecondary: _hexToColor(textSecondaryColorHex),
    );
  }

  /// Helper: Convert Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Helper: Convert hex string to Color
  static Color _hexToColor(String hex) {
    try {
      String cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF2E7D32);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetPreviewTheme &&
          runtimeType == other.runtimeType &&
          primaryColorHex == other.primaryColorHex &&
          accentColorHex == other.accentColorHex &&
          backgroundColorHex == other.backgroundColorHex &&
          surfaceColorHex == other.surfaceColorHex &&
          textColorHex == other.textColorHex &&
          textSecondaryColorHex == other.textSecondaryColorHex;

  @override
  int get hashCode =>
      primaryColorHex.hashCode ^
      accentColorHex.hashCode ^
      backgroundColorHex.hashCode ^
      surfaceColorHex.hashCode ^
      textColorHex.hashCode ^
      textSecondaryColorHex.hashCode;
}

/// Resolved Color objects from hex strings.
class WidgetColors {
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;

  const WidgetColors({
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
  });
}

/// Widget types for preview
enum WidgetPreviewType {
  prayerSchedule,
  countdown,
}
