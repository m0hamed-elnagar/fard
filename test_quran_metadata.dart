import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  debugPrint('Total Pages: ${quran.totalPagesCount}');
  debugPrint('Total Surahs: ${quran.totalSurahCount}');
  debugPrint('Total Verses: ${quran.totalVerseCount}');

  // To get surah/verse for a page, we can search:
  for (int s = 1; s <= 114; s++) {
    int verses = quran.getVerseCount(s);
    for (int v = 1; v <= verses; v++) {
      if (quran.getPageNumber(s, v) == 1) {
        debugPrint('Page 1 contains: Surah $s, Ayah $v');
      }
    }
  }
}
