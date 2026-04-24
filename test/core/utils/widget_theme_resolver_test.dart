import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/utils/widget_theme_resolver.dart';

void main() {
  group('WidgetThemeResolver', () {
    test('resolve returns correct colors for standard preset', () {
      final colors = WidgetThemeResolver.resolve(
        themePresetId: 'emerald',
        brightness: Brightness.dark,
      );

      expect(colors.primary, startsWith('#'));
      expect(colors.background, startsWith('#'));
    });

    test('resolve returns themed colors for custom seed', () {
      final colors = WidgetThemeResolver.resolve(
        themePresetId: 'custom',
        customColors: {'primary': '#FF0000'},
        brightness: Brightness.light,
      );

      // Material 3 transforms seed colors, so we check format instead of exact value
      expect(colors.primary, startsWith('#'));
      expect(colors.primary, isNot(equals('#000000')));
    });

    test('hexToColor converts correctly', () {
      expect(WidgetThemeResolver.hexToColor('#FF0000'), equals(const Color(0xFFFF0000)));
      expect(WidgetThemeResolver.hexToColor('00FF00'), equals(const Color(0xFF00FF00)));
    });

    test('colorToHex converts correctly', () {
      expect(WidgetThemeResolver.colorToHex(const Color(0xFFFF0000)), equals('#FF0000'));
    });
  });
}
