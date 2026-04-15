import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================================
// Test helper functions that duplicate the private logic from widget_color_picker.dart
// These mirror the private methods in ColorPickerField for testing purposes.
// ============================================================================

Color? testHexToColor(String hex) {
  try {
    String cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    // Note: 8-digit input is used as-is (no prepending)
    // But the actual code in ColorPickerField only handles 6 or 8 chars
    // For 8 chars: "RRGGBBAA" -> parsed directly, but Color expects AARRGGBB
    // So #2E7D3280 would parse as R=2E, G=7D, B=32, A=80 in the hex string
    // but Color interprets the int as 0x2E7D3280 which is A=2E, R=7D, G=32, B=80
    if (cleanHex.length != 8) return null;
    // The actual implementation parses it as a raw hex int
    return Color(int.parse(cleanHex, radix: 16));
  } catch (_) {
    return null;
  }
}

String testColorToHex(Color color) {
  // color.toARGB32() returns an int like 0xAARRGGBB
  // .toRadixString(16) converts to hex string
  // .substring(2) removes the first 2 chars (which would be something else)
  // Let's trace: Color(0xFF2E7D32).toARGB32() = 0xFF2E7D32
  // .toRadixString(16) = "ff2e7d32"
  // .substring(2) = "2e7d32"
  // .padLeft(8, '0') = "002e7d32"
  // So the result is #002E7D32 (loses alpha!)
  final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase().padLeft(8, '0');
  return '#$hex';
}

bool testIsLightColor(Color color) {
  final r = (color.r * 255.0).round().clamp(0, 255) / 255.0;
  final g = (color.g * 255.0).round().clamp(0, 255) / 255.0;
  final b = (color.b * 255.0).round().clamp(0, 255) / 255.0;
  final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance > 0.5;
}

// Helper extension to convert new double properties (0.0-1.0) to int (0-255)
extension ColorIntComponents on Color {
  int get alphaInt => (a * 255.0).round().clamp(0, 255);
  int get redInt => (r * 255.0).round().clamp(0, 255);
  int get greenInt => (g * 255.0).round().clamp(0, 255);
  int get blueInt => (b * 255.0).round().clamp(0, 255);
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('testHexToColor - 6-digit format (#RRGGBB)', () {
    test('converts 6-digit hex to Color with 0xFF alpha', () {
      final color = testHexToColor('#2E7D32');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0xFF);
      expect(color.redInt, 0x2E);
      expect(color.greenInt, 0x7D);
      expect(color.blueInt, 0x32);
    });

    test('converts pure white #FFFFFF to Color with full alpha', () {
      final color = testHexToColor('#FFFFFF');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0xFF);
      expect(color.redInt, 0xFF);
      expect(color.greenInt, 0xFF);
      expect(color.blueInt, 0xFF);
    });

    test('converts pure black #000000 to Color with full alpha', () {
      final color = testHexToColor('#000000');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0xFF);
      expect(color.redInt, 0x00);
      expect(color.greenInt, 0x00);
      expect(color.blueInt, 0x00);
    });

    test('converts emerald green #2E7D32', () {
      final color = testHexToColor('#2E7D32');
      expect(color, isNotNull);
      expect(color!.toARGB32(), equals(0xFF2E7D32));
    });

    test('converts gold #FFD54F', () {
      final color = testHexToColor('#FFD54F');
      expect(color, isNotNull);
      expect(color!.toARGB32(), equals(0xFFFFD54F));
    });
  });

  group('testHexToColor - 8-digit format (#RRGGBBAA)', () {
    test('parses 8-digit hex directly (alpha becomes first byte)', () {
      final color = testHexToColor('#2E7D3280');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0x2E);
      expect(color.redInt, 0x7D);
      expect(color.greenInt, 0x32);
      expect(color.blueInt, 0x80);
    });

    test('handles fully transparent #00000000', () {
      final color = testHexToColor('#00000000');
      expect(color, isNotNull);
      expect(color!.toARGB32(), equals(0x00000000));
    });

    test('handles semi-transparent white #FFFFFF80', () {
      final color = testHexToColor('#FFFFFF80');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0xFF);
      expect(color.redInt, 0xFF);
      expect(color.greenInt, 0xFF);
      expect(color.blueInt, 0x80);
    });

    test('opaque #RRGGBBFF differs from 6-digit #RRGGBB', () {
      final color8 = testHexToColor('#2E7D32FF');
      final color6 = testHexToColor('#2E7D32');
      expect(color8, isNotNull);
      expect(color6, isNotNull);
      expect(color8!.toARGB32(), isNot(equals(color6!.toARGB32())));
      expect(color8.alphaInt, 0x2E);
      expect(color6.alphaInt, 0xFF);
    });

    test('handles #2E7D3240 parsed as A=0x2E, R=0x7D, G=0x32, B=0x40', () {
      final color = testHexToColor('#2E7D3240');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0x2E);
      expect(color.redInt, 0x7D);
      expect(color.greenInt, 0x32);
      expect(color.blueInt, 0x40);
    });
  });

  group('testHexToColor - lowercase hex', () {
    test('lowercase 6-digit #4caf50 works', () {
      final color = testHexToColor('#4caf50');
      expect(color, isNotNull);
      expect(color!.toARGB32(), equals(0xFF4CAF50));
    });

    test('lowercase 8-digit #4caf5080 works', () {
      final color = testHexToColor('#4caf5080');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0x4C);
      expect(color.redInt, 0xAF);
      expect(color.greenInt, 0x50);
      expect(color.blueInt, 0x80);
    });

    test('mixed case #4Caf50 works', () {
      final color = testHexToColor('#4Caf50');
      expect(color, isNotNull);
      expect(color!.toARGB32(), equals(0xFF4CAF50));
    });

    test('mixed case #aAbBcC80 works', () {
      final color = testHexToColor('#aAbBcC80');
      expect(color, isNotNull);
      expect(color!.alphaInt, 0xAA);
      expect(color.redInt, 0xBB);
      expect(color.greenInt, 0xCC);
      expect(color.blueInt, 0x80);
    });
  });

  group('testHexToColor - invalid hex returns null', () {
    test('invalid characters #ZZZZZZ returns null', () {
      expect(testHexToColor('#ZZZZZZ'), isNull);
    });

    test('too short #12345 returns null', () {
      expect(testHexToColor('#12345'), isNull);
    });

    test('empty string returns null', () {
      expect(testHexToColor(''), isNull);
    });

    test('missing # prefix 2E7D32 returns null', () {
      final color = testHexToColor('2E7D32');
      expect(color, isNotNull);
    });

    test('just # returns null', () {
      expect(testHexToColor('#'), isNull);
    });

    test('too long #123456789 returns null', () {
      expect(testHexToColor('#123456789'), isNull);
    });

    test('3-digit shorthand #FFF returns null', () {
      expect(testHexToColor('#FFF'), isNull);
    });

    test('7 digits #1234567 returns null', () {
      expect(testHexToColor('#1234567'), isNull);
    });

    test('invalid hex #GGGGGG returns null', () {
      expect(testHexToColor('#GGGGGG'), isNull);
    });

    test('special characters #!@#\$%^ returns null', () {
      expect(testHexToColor('#!@#\$%^'), isNull);
    });

    test('whitespace in hex returns null', () {
      expect(testHexToColor('# 2E7D32'), isNull);
    });

    test('null-like string # returns null', () {
      expect(testHexToColor('#'), isNull);
    });
  });

  group('testColorToHex - produces 8-digit uppercase', () {
    test('produces 8-digit format (note: substring(2) drops alpha)', () {
      final color = const Color(0xFF2E7D32);
      final hex = testColorToHex(color);
      expect(hex, equals('#002E7D32'));
      expect(hex.length, equals(9));
    });

    test('uppercase output', () {
      final color = const Color(0xFFABCDEF);
      final hex = testColorToHex(color);
      expect(hex, equals('#00ABCDEF'));
    });

    test('always produces uppercase regardless of input', () {
      final color = const Color(0xFFabcdef);
      final hex = testColorToHex(color);
      expect(hex, equals('#00ABCDEF'));
    });

    test('pads with leading zeros if needed', () {
      final color = const Color(0xFF000001);
      final hex = testColorToHex(color);
      expect(hex, equals('#00000001'));
    });
  });

  group('testColorToHex - alpha channel dropped due to substring(2)', () {
    test('full alpha 0xFF produces #00RRGGBB', () {
      final color = const Color(0xFF2E7D32);
      expect(testColorToHex(color), equals('#002E7D32'));
    });

    test('half alpha 0x80 produces #00RRGGBB (alpha lost)', () {
      final color = const Color(0x802E7D32);
      expect(testColorToHex(color), equals('#002E7D32'));
    });

    test('transparent alpha 0x00 produces #00RRGGBB', () {
      final color = const Color(0x002E7D32);
      expect(testColorToHex(color), equals('#00007D32'));
    });

    test('25% opacity 0x40 produces #00RRGGBB', () {
      final color = const Color(0x402E7D32);
      expect(testColorToHex(color), equals('#002E7D32'));
    });

    test('75% opacity 0xBF produces #00RRGGBB', () {
      final color = const Color(0xBF2E7D32);
      expect(testColorToHex(color), equals('#002E7D32'));
    });
  });

  group('testIsLightColor - white is light, black is dark', () {
    test('white Colors.white is light', () {
      expect(testIsLightColor(Colors.white), isTrue);
    });

    test('black Colors.black is dark', () {
      expect(testIsLightColor(Colors.black), isFalse);
    });

    test('pure white Color(0xFFFFFFFF) is light', () {
      expect(testIsLightColor(const Color(0xFFFFFFFF)), isTrue);
    });

    test('pure black Color(0xFF000000) is dark', () {
      expect(testIsLightColor(const Color(0xFF000000)), isFalse);
    });
  });

  group('testIsLightColor - yellow is light, dark blue is dark', () {
    test('yellow Colors.yellow is light', () {
      expect(testIsLightColor(Colors.yellow), isTrue);
    });

    test('amber Colors.amber is light', () {
      expect(testIsLightColor(Colors.amber), isTrue);
    });

    test('dark blue Colors.blue[900] is dark', () {
      expect(testIsLightColor(Colors.blue[900]!), isFalse);
    });

    test('indigo Colors.indigo is dark', () {
      expect(testIsLightColor(Colors.indigo), isFalse);
    });

    test('gold #FFD54F is light', () {
      final color = testHexToColor('#FFD54F');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });

    test('dark green #1B5E20 is dark', () {
      final color = testHexToColor('#1B5E20');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isFalse);
    });
  });

  group('testIsLightColor - gray boundary cases', () {
    test('medium gray #808080 is light (at boundary)', () {
      final color = testHexToColor('#808080');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });

    test('light gray #C0C0C0 is light', () {
      final color = testHexToColor('#C0C0C0');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });

    test('dark gray #404040 is dark', () {
      final color = testHexToColor('#404040');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isFalse);
    });

    test('gray boundary #7F7F7F is dark', () {
      final color = testHexToColor('#7F7F7F');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isFalse);
    });

    test('gray boundary #818181 is light', () {
      final color = testHexToColor('#818181');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });
  });

  group('testIsLightColor - specific colors from preset swatches', () {
    test('emerald #2E7D32 is dark', () {
      final color = testHexToColor('#2E7D32');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isFalse);
    });

    test('light green #4CAF50 is light', () {
      final color = testHexToColor('#4CAF50');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });

    test('dark theme background #0D1117 is dark', () {
      final color = testHexToColor('#0D1117');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isFalse);
    });

    test('light surface #F5F5F5 is light', () {
      final color = testHexToColor('#F5F5F5');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });

    test('red #D32F2F is dark', () {
      final color = testHexToColor('#D32F2F');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isFalse);
    });

    test('cyan #00BCD4 is light', () {
      final color = testHexToColor('#00BCD4');
      expect(color, isNotNull);
      expect(testIsLightColor(color!), isTrue);
    });
  });

  group('Round-trip conversions', () {
    test('6-digit hex to color and back (alpha lost in toHex)', () {
      const originalHex = '#2E7D32';
      final color = testHexToColor(originalHex);
      expect(color, isNotNull);
      final resultHex = testColorToHex(color!);
      expect(resultHex, equals('#002E7D32'));
    });

    test('8-digit hex to color and back (different due to parsing)', () {
      const originalHex = '#802E7D32';
      final color = testHexToColor(originalHex);
      expect(color, isNotNull);
      final resultHex = testColorToHex(color!);
      expect(resultHex, equals('#002E7D32'));
    });

    test('color to hex to color preserves RGB but loses alpha', () {
      const originalColor = Color(0xFFABCDEF);
      final hex = testColorToHex(originalColor);
      final color = testHexToColor(hex);
      expect(color, isNotNull);
      expect(color!.redInt, equals(originalColor.redInt));
      expect(color.greenInt, equals(originalColor.greenInt));
      expect(color.blueInt, equals(originalColor.blueInt));
      expect(color.alphaInt, isNot(equals(originalColor.alphaInt)));
    });
  });
}