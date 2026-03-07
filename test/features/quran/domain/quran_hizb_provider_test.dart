import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/extensions/quran_extension.dart';

void main() {
  group('QuranHizbProvider', () {
    test('should return correct Hizb number', () {
      // Baqarah 142 is the start of Juz 2, which is Hizb 3
      expect(QuranHizbProvider.getHizbNumber(2, 142), 3);
      
      // Al-Fatiha 1 is Hizb 1
      expect(QuranHizbProvider.getHizbNumber(1, 1), 1);
      
      // Baqarah 75 is roughly the start of Hizb 2
      expect(QuranHizbProvider.getHizbNumber(2, 75), 2);
    });
  });
}
