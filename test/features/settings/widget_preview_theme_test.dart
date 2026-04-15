import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/settings/domain/entities/widget_preview_theme.dart';

void main() {
  group('WidgetPreviewTheme', () {
    group('Default values', () {
      test('has expected primary color', () {
        const theme = WidgetPreviewTheme();
        expect(theme.primaryColorHex, '#2E7D32');
      });

      test('has expected accent color', () {
        const theme = WidgetPreviewTheme();
        expect(theme.accentColorHex, '#FFD54F');
      });

      test('has expected background color', () {
        const theme = WidgetPreviewTheme();
        expect(theme.backgroundColorHex, '#0D1117');
      });

      test('has expected surface color', () {
        const theme = WidgetPreviewTheme();
        expect(theme.surfaceColorHex, '#161B22');
      });

      test('has expected text color', () {
        const theme = WidgetPreviewTheme();
        expect(theme.textColorHex, '#FFFFFF');
      });

      test('has expected secondary text color', () {
        const theme = WidgetPreviewTheme();
        expect(theme.textSecondaryColorHex, '#8B949E');
      });
    });

    group('copyWith', () {
      test('only modifies specified field', () {
        const theme = WidgetPreviewTheme();
        final modified = theme.copyWith(primaryColorHex: '#FF0000');

        expect(modified.primaryColorHex, '#FF0000');
        expect(modified.accentColorHex, '#FFD54F'); // Unchanged
        expect(modified.backgroundColorHex, '#0D1117'); // Unchanged
        expect(modified.surfaceColorHex, '#161B22'); // Unchanged
        expect(modified.textColorHex, '#FFFFFF'); // Unchanged
        expect(modified.textSecondaryColorHex, '#8B949E'); // Unchanged
      });

      test('can modify multiple fields', () {
        const theme = WidgetPreviewTheme();
        final modified = theme.copyWith(
          primaryColorHex: '#FF0000',
          accentColorHex: '#00FF00',
          backgroundColorHex: '#0000FF',
        );

        expect(modified.primaryColorHex, '#FF0000');
        expect(modified.accentColorHex, '#00FF00');
        expect(modified.backgroundColorHex, '#0000FF');
        expect(modified.textColorHex, '#FFFFFF'); // Unchanged
      });
    });

    group('toMap and fromMap', () {
      test('toMap produces correct map structure', () {
        const theme = WidgetPreviewTheme();
        final map = theme.toMap();

        expect(map.keys, contains('primaryColorHex'));
        expect(map.keys, contains('accentColorHex'));
        expect(map.keys, contains('backgroundColorHex'));
        expect(map.keys, contains('surfaceColorHex'));
        expect(map.keys, contains('textColorHex'));
        expect(map.keys, contains('textSecondaryColorHex'));
        expect(map['primaryColorHex'], '#2E7D32');
        expect(map['accentColorHex'], '#FFD54F');
      });

      test('fromMap correctly parses map', () {
        final map = {
          'primaryColorHex': '#FF0000',
          'accentColorHex': '#00FF00',
          'backgroundColorHex': '#0000FF',
          'surfaceColorHex': '#FFFF00',
          'textColorHex': '#FF00FF',
          'textSecondaryColorHex': '#00FFFF',
        };

        final theme = WidgetPreviewTheme.fromMap(map);

        expect(theme.primaryColorHex, '#FF0000');
        expect(theme.accentColorHex, '#00FF00');
        expect(theme.backgroundColorHex, '#0000FF');
        expect(theme.surfaceColorHex, '#FFFF00');
        expect(theme.textColorHex, '#FF00FF');
        expect(theme.textSecondaryColorHex, '#00FFFF');
      });

      test('fromMap uses defaults for missing keys', () {
        final map = <String, String>{};

        final theme = WidgetPreviewTheme.fromMap(map);

        expect(theme.primaryColorHex, '#2E7D32');
        expect(theme.accentColorHex, '#FFD54F');
        expect(theme.backgroundColorHex, '#0D1117');
      });

      test('round-trip produces identical theme', () {
        const originalTheme = WidgetPreviewTheme(
          primaryColorHex: '#FF0000',
          accentColorHex: '#00FF00',
          backgroundColorHex: '#0000FF',
          surfaceColorHex: '#FFFF00',
          textColorHex: '#FF00FF',
          textSecondaryColorHex: '#00FFFF',
        );

        final map = originalTheme.toMap();
        final restoredTheme = WidgetPreviewTheme.fromMap(map);

        expect(restoredTheme, equals(originalTheme));
      });
    });

    group('toColors (hex to Color conversion)', () {
      test('converts 6-digit hex to Color', () {
        const theme = WidgetPreviewTheme(primaryColorHex: '#FF0000');
        final colors = theme.toColors();
        expect(colors.primary, equals(const Color(0xFFFF0000)));
      });

      test('converts default primary color', () {
        const theme = WidgetPreviewTheme();
        final colors = theme.toColors();
        expect(colors.primary.toARGB32().toRadixString(16).toUpperCase(), 'FF2E7D32');
      });

      test('handles lowercase hex', () {
        const theme = WidgetPreviewTheme(primaryColorHex: '#2e7d32');
        final colors = theme.toColors();
        expect(colors.primary, equals(const Color(0xFF2E7D32)));
      });
    });

    group('Color to Hex conversion via toColors', () {
      test('converts Color to 8-digit uppercase hex', () {
        const theme = WidgetPreviewTheme(primaryColorHex: '#00FF0000');
        // Test the round-trip through toMap
        final map = theme.toMap();
        expect(map['primaryColorHex'], '#00FF0000');
      });

      test('preserves alpha channel in toMap', () {
        const theme = WidgetPreviewTheme(primaryColorHex: '#80FF0000');
        final map = theme.toMap();
        expect(map['primaryColorHex'], '#80FF0000');
      });
    });

    group('Equality and hashCode', () {
      test('identical themes are equal', () {
        const theme1 = WidgetPreviewTheme();
        const theme2 = WidgetPreviewTheme();

        expect(theme1, equals(theme2));
        expect(theme1.hashCode, equals(theme2.hashCode));
      });

      test('themes with different primary colors are not equal', () {
        const theme1 = WidgetPreviewTheme(primaryColorHex: '#FF0000');
        const theme2 = WidgetPreviewTheme(primaryColorHex: '#00FF00');

        expect(theme1, isNot(equals(theme2)));
      });

      test('themes with different accent colors are not equal', () {
        const theme1 = WidgetPreviewTheme(accentColorHex: '#FF0000');
        const theme2 = WidgetPreviewTheme(accentColorHex: '#00FF00');

        expect(theme1, isNot(equals(theme2)));
      });

      test('copyWith produces equal theme when all values restored', () {
        const theme = WidgetPreviewTheme();
        final modified = theme.copyWith(primaryColorHex: '#FF0000');
        final restored = modified.copyWith(primaryColorHex: '#2E7D32');

        expect(restored, equals(theme));
        expect(restored.hashCode, equals(theme.hashCode));
      });
    });

    group('fromColorScheme', () {
      test('creates valid theme from ColorScheme', () {
        final colorScheme = ColorScheme.dark(
          primary: const Color(0xFFFF0000),
          secondary: const Color(0xFF00FF00),
          surface: const Color(0xFF0000FF),
          surfaceContainerHighest: const Color(0xFFFFFF00),
          onSurface: const Color(0xFFFF00FF),
          onSurfaceVariant: const Color(0xFF00FFFF),
        );

        final theme = WidgetPreviewTheme.fromColorScheme(colorScheme);

        expect(theme.primaryColorHex, '#FFFF0000');
        expect(theme.accentColorHex, '#FF00FF00');
        expect(theme.backgroundColorHex, '#FF0000FF');
        expect(theme.surfaceColorHex, '#FFFFFF00');
        expect(theme.textColorHex, '#FFFF00FF');
        expect(theme.textSecondaryColorHex, '#FF00FFFF');
      });
    });

    group('toColors', () {
      test('resolves hex strings to Color objects', () {
        const theme = WidgetPreviewTheme(
          primaryColorHex: '#FF0000',
          accentColorHex: '#00FF00',
          backgroundColorHex: '#0000FF',
          surfaceColorHex: '#FFFF00',
          textColorHex: '#FF00FF',
          textSecondaryColorHex: '#00FFFF',
        );

        final colors = theme.toColors();

        expect(colors.primary, equals(const Color(0xFFFF0000)));
        expect(colors.accent, equals(const Color(0xFF00FF00)));
        expect(colors.background, equals(const Color(0xFF0000FF)));
        expect(colors.surface, equals(const Color(0xFFFFFF00)));
        expect(colors.text, equals(const Color(0xFFFF00FF)));
        expect(colors.textSecondary, equals(const Color(0xFF00FFFF)));
      });
    });
  });

  group('WidgetColors', () {
    test('stores all color values', () {
      const colors = WidgetColors(
        primary: Color(0xFFFF0000),
        accent: Color(0xFF00FF00),
        background: Color(0xFF0000FF),
        surface: Color(0xFFFFFF00),
        text: Color(0xFFFF00FF),
        textSecondary: Color(0xFF00FFFF),
      );

      expect(colors.primary, equals(const Color(0xFFFF0000)));
      expect(colors.accent, equals(const Color(0xFF00FF00)));
      expect(colors.background, equals(const Color(0xFF0000FF)));
      expect(colors.surface, equals(const Color(0xFFFFFF00)));
      expect(colors.text, equals(const Color(0xFFFF00FF)));
      expect(colors.textSecondary, equals(const Color(0xFF00FFFF)));
    });
  });

  group('WidgetPreviewType enum', () {
    test('has expected values', () {
      expect(WidgetPreviewType.prayerSchedule.index, 0);
      expect(WidgetPreviewType.countdown.index, 1);
    });
  });
}
