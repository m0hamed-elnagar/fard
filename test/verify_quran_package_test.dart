import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/extensions/quran_extension.dart';

void main() {
  test('Verify QuranHizbProvider has getSurahAndVersesFromHizb', () {
    try {
      final hizbData = QuranHizbProvider.getSurahAndVersesFromHizb(1);
      print('Hizb 1 data: $hizbData');
      expect(hizbData, isNotEmpty);
    } catch (e) {
      print('Error calling getSurahAndVersesFromHizb: $e');
      fail('getSurahAndVersesFromHizb failed');
    }
  });
}
