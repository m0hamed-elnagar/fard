import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HijriDateTimeExtension', () {
    test('converts Gregorian date to Hijri string (EN)', () {
      // 2026-02-14 is approx 26 Shaban 1447
      final date = DateTime(2026, 2, 14);
      final hijri = date.toHijriDate('en');
      expect(hijri, contains('1447'));
      expect(
        hijri.toLowerCase(),
        anyOf(contains('shaban'), contains('sha\'ban'), contains('sha\'aban')),
      );
      expect(hijri, contains('26'));
      expect(hijri, contains('AH'));
    });

    test('converts Gregorian date to Hijri string (AR)', () {
      final date = DateTime(2026, 2, 14);
      final hijri = date.toHijriDate('ar');
      // 2026-02-14 is 26 Shaban 1447
      expect(hijri, contains('\u200F')); // RLM
      expect(hijri, contains('١٤٤٧')); // 1447 in Arabic-Indic
      expect(hijri, contains('شعبان'));
      expect(hijri, contains('٢٦')); // 26 in Arabic-Indic
      expect(hijri, contains('هـ'));

      // Check full string structure (Right-to-Left Mark at start)
      expect(hijri.startsWith('\u200F'), isTrue);
    });

    test('applies hijri adjustment', () {
      final date = DateTime(2026, 3, 3); // Default is 14 Ramadan 1447
      final hijriNoAdj = date.toHijriDate('en');
      final hijriMinus1 = date.toHijriDate('en', adjustment: -1);
      final hijriPlus1 = date.toHijriDate('en', adjustment: 1);

      expect(hijriNoAdj, contains('14 Ramadan'));
      expect(hijriMinus1, contains('13 Ramadan'));
      expect(hijriPlus1, contains('15 Ramadan'));
    });
  });
}
