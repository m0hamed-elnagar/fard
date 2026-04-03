// ignore_for_file: unused_import
import 'package:quran/quran.dart' as quran;
import 'package:fard/features/werd/domain/entities/werd_goal.dart';

class QuranHizbProvider {
  static const List<List<int>> _hizbStarts = [
    [1, 1],
    [2, 75],
    [2, 142],
    [2, 203],
    [2, 253],
    [3, 15],
    [3, 93],
    [3, 171],
    [4, 24],
    [4, 88],
    [4, 148],
    [5, 27],
    [5, 82],
    [6, 36],
    [6, 111],
    [7, 1],
    [7, 88],
    [7, 171],
    [8, 41],
    [9, 34],
    [9, 111],
    [10, 71],
    [11, 41],
    [12, 1],
    [12, 101],
    [14, 1],
    [16, 1],
    [16, 90],
    [17, 50],
    [18, 32],
    [19, 22],
    [20, 55],
    [21, 29],
    [22, 19],
    [23, 36],
    [24, 35],
    [25, 53],
    [26, 160],
    [27, 82],
    [28, 76],
    [30, 1],
    [32, 11],
    [33, 51],
    [34, 46],
    [36, 60],
    [38, 21],
    [39, 53],
    [40, 66],
    [42, 13],
    [43, 57],
    [46, 21],
    [48, 18],
    [51, 31],
    [55, 1],
    [57, 16],
    [60, 1],
    [65, 1],
    [69, 1],
    [74, 1],
    [81, 1],
  ];

  static const List<List<int>> _rubStarts = [
    [1, 1],
    [2, 26],
    [2, 44],
    [2, 60],
    [2, 75],
    [2, 92],
    [2, 106],
    [2, 124],
    [2, 142],
    [2, 158],
    [2, 177],
    [2, 189],
    [2, 203],
    [2, 219],
    [2, 233],
    [2, 243],
    [2, 253],
    [2, 263],
    [2, 272],
    [2, 283],
    [3, 15],
    [3, 33],
    [3, 52],
    [3, 75],
    [3, 93],
    [3, 113],
    [3, 133],
    [3, 153],
    [3, 171],
    [3, 186],
    [4, 1],
    [4, 12],
    [4, 24],
    [4, 36],
    [4, 58],
    [4, 74],
    [4, 88],
    [4, 100],
    [4, 114],
    [4, 135],
    [4, 148],
    [4, 163],
    [5, 1],
    [5, 12],
    [5, 27],
    [5, 41],
    [5, 51],
    [5, 67],
    [5, 82],
    [5, 97],
    [5, 109],
    [6, 13],
    [6, 36],
    [6, 59],
    [6, 74],
    [6, 95],
    [6, 111],
    [6, 127],
    [6, 141],
    [6, 151],
    [7, 1],
    [7, 31],
    [7, 47],
    [7, 65],
    [7, 88],
    [7, 117],
    [7, 142],
    [7, 156],
    [7, 171],
    [7, 189],
    [8, 1],
    [8, 22],
    [8, 41],
    [8, 61],
    [9, 1],
    [9, 19],
    [9, 34],
    [9, 60],
    [9, 75],
    [9, 93],
    [9, 111],
    [10, 1],
    [10, 26],
    [10, 53],
    [10, 71],
    [10, 90],
    [11, 6],
    [11, 24],
    [11, 41],
    [11, 61],
    [11, 84],
    [11, 108],
    [12, 1],
    [12, 30],
    [12, 53],
    [12, 77],
    [12, 101],
    [13, 5],
    [13, 19],
    [13, 35],
    [14, 1],
    [14, 28],
    [14, 53],
    [15, 49],
    [16, 1],
    [16, 30],
    [16, 51],
    [16, 75],
    [16, 90],
    [16, 111],
    [17, 1],
    [17, 23],
    [17, 50],
    [17, 70],
    [17, 99],
    [18, 17],
    [18, 32],
    [18, 51],
    [18, 75],
    [18, 99],
    [19, 22],
    [19, 59],
    [20, 1],
    [20, 55],
    [20, 83],
    [20, 111],
    [21, 1],
    [21, 29],
    [21, 51],
    [21, 83],
    [22, 1],
    [22, 19],
    [22, 38],
    [22, 60],
    [23, 1],
    [23, 36],
    [23, 75],
    [24, 1],
    [24, 21],
    [24, 35],
    [24, 53],
    [25, 1],
    [25, 21],
    [25, 53],
    [26, 1],
    [26, 52],
    [26, 111],
    [26, 160],
    [27, 1],
    [27, 27],
    [27, 56],
    [27, 82],
    [28, 1],
    [28, 29],
    [28, 51],
    [28, 76],
    [29, 1],
    [29, 26],
    [29, 46],
    [30, 1],
    [30, 31],
    [30, 54],
    [31, 22],
    [32, 11],
    [33, 1],
    [33, 18],
    [33, 31],
    [33, 51],
    [33, 60],
    [34, 1],
    [34, 24],
    [34, 46],
    [35, 15],
    [36, 1],
    [36, 28],
    [36, 60],
    [37, 1],
    [37, 83],
    [37, 145],
    [38, 21],
    [38, 52],
    [39, 1],
    [39, 32],
    [39, 53],
    [39, 75],
    [40, 21],
    [40, 41],
    [40, 66],
    [41, 1],
    [41, 25],
    [41, 47],
    [42, 13],
    [42, 27],
    [42, 51],
    [43, 24],
    [43, 57],
    [44, 17],
    [45, 1],
    [46, 1],
    [46, 21],
    [47, 1],
    [47, 19],
    [48, 1],
    [48, 18],
    [49, 1],
    [49, 14],
    [50, 27],
    [51, 31],
    [52, 24],
    [53, 26],
    [54, 9],
    [55, 1],
    [56, 1],
    [56, 75],
    [57, 1],
    [57, 16],
    [58, 1],
    [58, 14],
    [59, 11],
    [60, 1],
    [61, 1],
    [62, 1],
    [64, 1],
    [65, 1],
    [66, 1],
    [67, 1],
    [68, 1],
    [69, 1],
    [70, 1],
    [71, 1],
    [73, 1],
    [74, 1],
    [76, 1],
    [77, 1],
    [79, 1],
    [81, 1],
    [85, 1],
    [88, 1],
    [94, 1],
  ];

  static final Map<int, int> _pageVerseCountMap = {};
  static final Map<int, int> _juzVerseCountMap = {};
  static bool _isDataInitialized = false;

  static void _ensureInitialized() {
    if (_isDataInitialized) return;
    for (int abs = 1; abs <= 6236; abs++) {
      final pos = getSurahAndAyahFromAbsolute(abs);
      final p = quran.getPageNumber(pos[0], pos[1]);
      final j = quran.getJuzNumber(pos[0], pos[1]);
      _pageVerseCountMap[p] = (_pageVerseCountMap[p] ?? 0) + 1;
      _juzVerseCountMap[j] = (_juzVerseCountMap[j] ?? 0) + 1;
    }
    _isDataInitialized = true;
  }

  static int getVerseCountOnPage(int page) {
    _ensureInitialized();
    return _pageVerseCountMap[page] ?? 0;
  }

  static int getVerseCountInJuz(int juz) {
    _ensureInitialized();
    return _juzVerseCountMap[juz] ?? 0;
  }

  static Map<int, List<int>> getSurahAndVersesFromHizb(int hizbNumber) {
    if (hizbNumber < 1 || hizbNumber > 60) return {};
    final start = _hizbStarts[hizbNumber - 1];
    return {
      start[0]: [start[1]],
    };
  }

  static int getHizbNumber(int surahNumber, int ayahNumber) {
    for (int i = _hizbStarts.length - 1; i >= 0; i--) {
      if (surahNumber > _hizbStarts[i][0] ||
          (surahNumber == _hizbStarts[i][0] &&
              ayahNumber >= _hizbStarts[i][1])) {
        return i + 1;
      }
    }
    return 1;
  }

  static int getAbsoluteAyahNumber(int surahNumber, int ayahNumber) {
    int absolute = 0;
    for (int i = 1; i < surahNumber; i++) {
      absolute += quran.getVerseCount(i);
    }
    return absolute + ayahNumber;
  }

  static List<int> getSurahAndAyahFromAbsolute(int absolute) {
    int remaining = absolute;
    for (int i = 1; i <= 114; i++) {
      int count = quran.getVerseCount(i);
      if (remaining <= count) {
        return [i, remaining];
      }
      remaining -= count;
    }
    return [114, quran.getVerseCount(114)];
  }

  static int getGoalRequiredAyahs(int startAbs, WerdUnit unit, int value) {
    if (unit == WerdUnit.ayah) return value;
    final endAbs = getGoalEndAbsolute(startAbs, unit, value);
    return endAbs - startAbs + 1;
  }

  static int getGoalEndAbsolute(int startAbs, WerdUnit unit, int value) {
    if (unit == WerdUnit.ayah) return (startAbs + value - 1).clamp(1, 6236);
    final startPos = getSurahAndAyahFromAbsolute(startAbs);

    if (unit == WerdUnit.page) {
      final startPage = quran.getPageNumber(startPos[0], startPos[1]);
      final targetPage = (startPage + value - 1).clamp(1, 604);
      return _getLastAyahOfPage(targetPage);
    }
    if (unit == WerdUnit.juz) {
      final startJuz = quran.getJuzNumber(startPos[0], startPos[1]);
      final targetJuz = (startJuz + value - 1).clamp(1, 30);
      return _getLastAyahOfJuz(targetJuz);
    }
    if (unit == WerdUnit.hizb) {
      final startHizb = getHizbNumber(startPos[0], startPos[1]);
      final targetHizb = (startHizb + value - 1).clamp(1, 60);
      return _getLastAyahOfHizb(targetHizb);
    }
    if (unit == WerdUnit.quarter) {
      final startRub = getRubNumber(startPos[0], startPos[1]);
      final targetRub = (startRub + value - 1).clamp(1, 240);
      return _getLastAyahOfRub(targetRub);
    }
    return (startAbs + value - 1).clamp(1, 6236);
  }

  static int getRubNumber(int surah, int ayah) {
    for (int i = _rubStarts.length - 1; i >= 0; i--) {
      if (surah > _rubStarts[i][0] ||
          (surah == _rubStarts[i][0] && ayah >= _rubStarts[i][1])) {
        return i + 1;
      }
    }
    return 1;
  }

  static int _getLastAyahOfPage(int page) {
    if (page >= 604) return 6236;
    for (int s = 1; s <= 114; s++) {
      for (int v = 1; v <= quran.getVerseCount(s); v++) {
        if (quran.getPageNumber(s, v) > page) {
          return getAbsoluteAyahNumber(s, v) - 1;
        }
      }
    }
    return 6236;
  }

  static int _getLastAyahOfJuz(int juz) {
    if (juz >= 30) return 6236;
    final nextJuzData = quran.getSurahAndVersesFromJuz(juz + 1);
    final s = nextJuzData.keys.first;
    final v = nextJuzData[s]![0];
    return getAbsoluteAyahNumber(s, v) - 1;
  }

  static int _getLastAyahOfHizb(int hizb) {
    if (hizb >= 60) return 6236;
    final start = _hizbStarts[hizb];
    return getAbsoluteAyahNumber(start[0], start[1]) - 1;
  }

  static int _getLastAyahOfRub(int rub) {
    if (rub >= 240) return 6236;
    final start = _rubStarts[rub];
    return getAbsoluteAyahNumber(start[0], start[1]) - 1;
  }

  static Map<int, List<int>> getSurahAndVersesFromRub(int rubNumber) {
    if (rubNumber < 1 || rubNumber > 240) return {};
    final index = rubNumber - 1;
    if (index >= _rubStarts.length) return {};
    final start = _rubStarts[index];
    return {
      start[0]: [start[1]],
    };
  }

  static double calculateFractionalProgress(Set<int> readItems, WerdUnit unit) {
    if (readItems.isEmpty) return 0.0;
    if (unit == WerdUnit.ayah) return readItems.length.toDouble();
    _ensureInitialized();

    double totalProgress = 0.0;

    if (unit == WerdUnit.page) {
      final Map<int, int> readOnPage = {};
      for (final abs in readItems) {
        final pos = getSurahAndAyahFromAbsolute(abs);
        final p = quran.getPageNumber(pos[0], pos[1]);
        readOnPage[p] = (readOnPage[p] ?? 0) + 1;
      }
      for (final entry in readOnPage.entries) {
        final totalInPage = getVerseCountOnPage(entry.key);
        totalProgress += entry.value / totalInPage;
      }
    } else if (unit == WerdUnit.juz) {
      final Map<int, int> readInJuz = {};
      for (final abs in readItems) {
        final pos = getSurahAndAyahFromAbsolute(abs);
        final j = quran.getJuzNumber(pos[0], pos[1]);
        readInJuz[j] = (readInJuz[j] ?? 0) + 1;
      }
      for (final entry in readInJuz.entries) {
        final totalInJuz = getVerseCountInJuz(entry.key);
        totalProgress += entry.value / totalInJuz;
      }
    } else if (unit == WerdUnit.hizb) {
      final Map<int, int> readInHizb = {};
      for (final abs in readItems) {
        final pos = getSurahAndAyahFromAbsolute(abs);
        final h = getHizbNumber(pos[0], pos[1]);
        readInHizb[h] = (readInHizb[h] ?? 0) + 1;
      }
      for (final entry in readInHizb.entries) {
        final totalInHizb = getVerseCountInHizb(entry.key);
        totalProgress += entry.value / totalInHizb;
      }
    }

    if ((totalProgress - totalProgress.round()).abs() < 0.0001) {
      totalProgress = totalProgress.roundToDouble();
    }
    return unit == WerdUnit.page
        ? totalProgress.clamp(0.0, 604.0)
        : totalProgress.clamp(0.0, 30.0);
  }

  static int getVerseCountInHizb(int hizb) {
    _ensureInitialized();
    int start = _getHizbStartAbsolute(hizb);
    int end = _getHizbStartAbsolute(hizb + 1) - 1;
    if (hizb == 60) end = 6236;
    return end - start + 1;
  }

  static int _getHizbStartAbsolute(int hizb) {
    if (hizb < 1) return 1;
    if (hizb > 60) return 6237;
    final start = _hizbStarts[hizb - 1];
    return getAbsoluteAyahNumber(start[0], start[1]);
  }
}
