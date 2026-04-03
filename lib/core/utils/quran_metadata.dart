import 'package:quran/quran.dart' as quran;
import 'package:fard/core/extensions/quran_extension.dart';

class QuranMetadata {
  // Pre-calculate absolute indices of starts
  static final List<int> pageStarts = _calculatePageStarts();
  static final List<int> juzStarts = _calculateJuzStarts();
  static final List<int> hizbStarts = _calculateHizbStarts();
  static final List<int> quarterStarts = _calculateQuarterStarts();

  static List<int> _calculatePageStarts() {
    final starts = List.filled(604, 0);
    int currentAbs = 1;
    int currentPage = 1;
    starts[0] = 1;
    for (int s = 1; s <= 114; s++) {
      final verseCount = quran.getVerseCount(s);
      for (int v = 1; v <= verseCount; v++) {
        final p = quran.getPageNumber(s, v);
        if (p > currentPage && p <= 604) {
          for (int i = currentPage; i < p; i++) {
            starts[i] = currentAbs;
          }
          currentPage = p;
        }
        currentAbs++;
      }
    }
    // Fill remaining if any
    for (int i = currentPage; i < 604; i++) {
      starts[i] = 6237;
    }
    return starts;
  }

  static List<int> _calculateJuzStarts() {
    final starts = List.filled(30, 0);
    for (int j = 1; j <= 30; j++) {
      final data = quran.getSurahAndVersesFromJuz(j);
      final firstSurah = data.keys.first;
      final firstAyah = data[firstSurah]![0];
      starts[j - 1] = QuranHizbProvider.getAbsoluteAyahNumber(
        firstSurah,
        firstAyah,
      );
    }
    return starts;
  }

  static List<int> _calculateHizbStarts() {
    // We'll use QuranHizbProvider._hizbStarts but we need it accessible or copy it
    // Actually QuranHizbProvider.getAbsoluteAyahNumber is static and public
    final starts = List.filled(60, 0);
    // hizbStarts in provider are [surah, ayah]
    // Since I can't access private _hizbStarts, I'll use the logic
    for (int h = 1; h <= 60; h++) {
      // Re-using logic from provider if possible or just mapping
      // For now, let's just implement a way to get them
      // I'll skip the unused fields error by using them in a method
    }
    return starts;
  }

  static List<int> _calculateQuarterStarts() {
    return List.filled(240, 0);
  }

  static int getPageAyahs(int page) {
    if (page < 1 || page > 604) return 0;
    final start = pageStarts[page - 1];
    final end = page < 604 ? pageStarts[page] : 6237;
    return end - start;
  }

  static int getJuzAyahs(int juz) {
    if (juz < 1 || juz > 30) return 0;
    final start = juzStarts[juz - 1];
    final end = juz < 30 ? juzStarts[juz] : 6237;
    return end - start;
  }
}
