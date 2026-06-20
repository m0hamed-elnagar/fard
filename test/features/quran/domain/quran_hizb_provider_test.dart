import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;

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

    test('all 60 hizbs and 240 rubs should be non-empty and align correctly', () {
      expect(QuranHizbProvider.rubStartsLength, 240, reason: '_rubStarts should have exactly 240 elements');
      
      for (int hizbNum = 1; hizbNum <= 60; hizbNum++) {
        final hizbData = QuranHizbProvider.getSurahAndVersesFromHizb(hizbNum);
        expect(hizbData.isNotEmpty, true, reason: 'Hizb $hizbNum data is empty');
        final hSurah = hizbData.keys.first;
        final hAyah = hizbData[hSurah]![0];

        // The first Rub (quarter) of Hizb h is rubNum = (h - 1) * 4 + 1
        final firstRubNum = (hizbNum - 1) * 4 + 1;
        
        for (int qIndex = 0; qIndex < 4; qIndex++) {
          final rubNum = firstRubNum + qIndex;
          final rubData = QuranHizbProvider.getSurahAndVersesFromRub(rubNum);
          expect(rubData.isNotEmpty, true, reason: 'Hizb $hizbNum, Rub $rubNum data is empty');
          final rSurah = rubData.keys.first;
          final rAyah = rubData[rSurah]![0];

          // Call getPageNumber to check for invalid verse number exceptions
          try {
            final page = quran.getPageNumber(rSurah, rAyah);
            expect(page, isNotNull);
          } catch (e) {
            fail('Hizb $hizbNum, Rub $rubNum: quran.getPageNumber($rSurah, $rAyah) threw $e');
          }

          if (qIndex == 0) {
            // First Rub must align with Hizb start
            expect(rSurah, hSurah, reason: 'Hizb $hizbNum starts at Surah $hSurah but its first Rub $rubNum starts at Surah $rSurah');
            expect(rAyah, hAyah, reason: 'Hizb $hizbNum starts at Ayah $hAyah but its first Rub $rubNum starts at Ayah $rAyah');
          }
        }
      }
    });
  });
}
