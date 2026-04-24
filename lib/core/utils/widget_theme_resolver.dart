import 'package:flutter/material.dart';
import 'package:fard/features/settings/domain/entities/theme_preset.dart';
import 'package:fard/core/theme/theme_presets.dart';
import 'dart:developer' as developer;

class WidgetThemeColors {
  final String primary;
  final String accent;
  final String background;
  final String surface;
  final String text;
  final String textSecondary;

  WidgetThemeColors({
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
  });
}

class WidgetThemeResolver {
  static WidgetThemeColors resolve({
    required String themePresetId,
    Map<String, String>? customColors,
    required Brightness brightness,
  }) {
    ThemePreset? currentPreset;

    if (themePresetId != 'custom') {
      try {
        currentPreset = ThemePresets.getById(themePresetId);
      } catch (e) {
        developer.log('WidgetThemeResolver: Theme preset not found: $themePresetId', error: e);
      }
    }

    if (currentPreset != null) {
      return WidgetThemeColors(
        primary: colorToHex(currentPreset.primaryColor),
        accent: colorToHex(currentPreset.accentColor),
        background: colorToHex(currentPreset.backgroundColor),
        surface: colorToHex(currentPreset.surfaceColor),
        text: colorToHex(currentPreset.textColor),
        textSecondary: colorToHex(currentPreset.textSecondaryColor),
      );
    } else {
      Color seedColor = const Color(0xFF2E7D32);

      if (themePresetId == 'custom' && customColors != null && customColors['primary'] != null) {
        seedColor = hexToColor(customColors['primary']!);
      }

      final colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      );

      return WidgetThemeColors(
        primary: colorToHex(colorScheme.primary),
        accent: colorToHex(colorScheme.secondary),
        background: colorToHex(colorScheme.surface),
        surface: colorToHex(colorScheme.surfaceContainerHighest),
        text: colorToHex(colorScheme.onSurface),
        textSecondary: colorToHex(colorScheme.onSurfaceVariant),
      );
    }
  }

  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
