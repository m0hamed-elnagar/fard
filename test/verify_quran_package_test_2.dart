import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/extensions/quran_extension.dart';

void main() {
  test('Verify QuranHizbProvider has getHizbNumber', () {
    try {
      final hizbNum = QuranHizbProvider.getHizbNumber(1, 1);
      debugPrint('Surah 1, Ayah 1 is in Hizb: $hizbNum');
      expect(hizbNum, 1);

      final hizb2 = QuranHizbProvider.getHizbNumber(2, 142);
      debugPrint('Surah 2, Ayah 142 is in Hizb: $hizb2');
      expect(hizb2, 2);
    } catch (e) {
      debugPrint('Error calling getHizbNumber: $e');
      fail('getHizbNumber failed');
    }
  });
}
