import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HijriDateTimeExtension', () {
    test('converts Gregorian date to Hijri string (EN)', () {
      // 2026-02-14 is approx 26 Shaban 1447
      final date = DateTime(2026, 2, 14);
      final hijri = date.toHijriDate('en');
      expect(hijri, contains('1447'));
      expect(hijri.toLowerCase(), anyOf(contains('sha\'ban'), contains('sha\'aban')));
      expect(hijri, contains('26'));
    });

    test('converts Gregorian date to Hijri string (AR)', () {
      final date = DateTime(2026, 2, 14);
      final hijri = date.toHijriDate('ar');
      // The package seems to use Western numerals and sometimes English month names even in AR 
      // depends on how getLongMonthName is implemented in the version.
      // But it should have the Hijri suffix.
      expect(hijri, anyOf(contains('1447'), contains('١٤٤٧')));
      expect(hijri, contains('هـ'));
    });
  });
}
