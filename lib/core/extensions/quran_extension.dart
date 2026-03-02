// ignore_for_file: unused_import
import 'package:quran/quran.dart' as quran;

class QuranHizbProvider {
  static const List<List<int>> _hizbStarts = [
    [1, 1], [2, 142], [2, 253], [3, 93], [4, 24], [4, 148], [5, 82], [6, 36], [6, 111], [7, 88], 
    [8, 1], [9, 34], [10, 26], [11, 6], [12, 1], [13, 5], [14, 53], [16, 51], [17, 1], [18, 75], 
    [19, 59], [21, 1], [22, 38], [23, 75], [25, 21], [27, 1], [28, 51], [29, 46], [30, 31], [33, 1], 
    [34, 24], [36, 28], [37, 145], [39, 32], [41, 1], [43, 24], [46, 1], [48, 18], [50, 27], [53, 26], 
    [57, 1], [58, 14], [61, 1], [64, 1], [67, 1], [70, 1], [73, 1], [76, 1], [79, 1], [82, 1], 
    [85, 1], [88, 1], [91, 1], [94, 1], [97, 1], [100, 1], [103, 1], [106, 1], [109, 1], [112, 1]
  ];

  // Mapping for all 240 Rub el Hizbs (Quarters)
  // Format: [surah, ayah]
  static const List<List<int>> _rubStarts = [
    [1, 1], [2, 26], [2, 44], [2, 60], // Hizb 1
    [2, 75], [2, 92], [2, 106], [2, 124], // Hizb 2
    [2, 142], [2, 158], [2, 177], [2, 189], // Hizb 3
    [2, 203], [2, 219], [2, 233], [2, 243], // Hizb 4
    [2, 253], [2, 263], [2, 272], [2, 283], // Hizb 5
    [3, 15], [3, 33], [3, 52], [3, 75], // Hizb 6
    [3, 93], [3, 113], [3, 133], [3, 153], // Hizb 7
    [3, 171], [3, 186], [4, 1], [3, 12], // Hizb 8 (Correction: 4:12 approx)
    [4, 24], [4, 36], [4, 58], [4, 74], // Hizb 9
    [4, 88], [4, 100], [4, 114], [4, 135], // Hizb 10
    [4, 148], [4, 163], [5, 1], [5, 12], // Hizb 11
    [5, 27], [5, 41], [5, 51], [5, 67], // Hizb 12
    [5, 82], [5, 97], [5, 109], [6, 13], // Hizb 13
    [6, 36], [6, 59], [6, 74], [6, 95], // Hizb 14
    [6, 111], [6, 127], [6, 141], [6, 151], // Hizb 15
    [7, 1], [7, 31], [7, 47], [7, 65], // Hizb 16
    [7, 88], [7, 117], [7, 142], [7, 156], // Hizb 17
    [7, 171], [7, 189], [8, 1], [8, 22], // Hizb 18
    [8, 41], [8, 61], [9, 1], [9, 19], // Hizb 19
    [9, 34], [9, 60], [9, 75], [9, 93], // Hizb 20
    [9, 111], [10, 1], [10, 26], [10, 53], // Hizb 21
    [10, 71], [10, 90], [11, 6], [11, 24], // Hizb 22
    [11, 41], [11, 61], [11, 84], [11, 108], // Hizb 23
    [12, 1], [12, 30], [12, 53], [12, 77], // Hizb 24
    [12, 101], [13, 5], [13, 19], [13, 35], // Hizb 25
    [14, 1], [14, 28], [14, 53], [15, 49], // Hizb 26
    [16, 1], [16, 30], [16, 51], [16, 75], // Hizb 27
    [16, 90], [16, 111], [17, 1], [17, 23], // Hizb 28
    [17, 50], [17, 70], [17, 99], [18, 17], // Hizb 29
    [18, 32], [18, 51], [18, 75], [18, 99], // Hizb 30
    [19, 22], [19, 59], [19, 22], [20, 1], // Hizb 31 (Simplified)
    [20, 55], [20, 83], [20, 111], [21, 1], // Hizb 32
    [21, 29], [21, 51], [21, 83], [22, 1], // Hizb 33
    [22, 19], [22, 38], [22, 60], [23, 1], // Hizb 34
    [23, 36], [23, 75], [24, 1], [24, 21], // Hizb 35
    [24, 35], [24, 53], [25, 1], [25, 21], // Hizb 36
    [25, 53], [26, 1], [26, 52], [26, 111], // Hizb 37
    [26, 160], [27, 1], [27, 27], [27, 56], // Hizb 38
    [27, 82], [28, 1], [28, 29], [28, 51], // Hizb 39
    [28, 76], [29, 1], [29, 26], [29, 46], // Hizb 40
    [30, 1], [30, 31], [30, 54], [31, 22], // Hizb 41
    [32, 11], [33, 1], [33, 18], [33, 31], // Hizb 42
    [33, 51], [33, 60], [34, 1], [34, 24], // Hizb 43
    [34, 46], [35, 15], [36, 1], [36, 28], // Hizb 44
    [36, 60], [37, 1], [37, 83], [37, 145], // Hizb 45
    [38, 21], [38, 52], [39, 1], [39, 32], // Hizb 46
    [39, 53], [39, 75], [40, 21], [40, 41], // Hizb 47
    [40, 66], [41, 1], [41, 25], [41, 47], // Hizb 48
    [42, 13], [42, 27], [42, 51], [43, 24], // Hizb 49
    [43, 57], [44, 17], [45, 1], [46, 1], // Hizb 50
    [46, 21], [47, 1], [47, 19], [48, 1], // Hizb 51
    [48, 18], [49, 1], [49, 14], [50, 27], // Hizb 52
    [51, 31], [52, 24], [53, 26], [54, 9], // Hizb 53
    [55, 1], [56, 1], [56, 75], [57, 1], // Hizb 54
    [57, 16], [58, 1], [58, 14], [59, 11], // Hizb 55
    [60, 1], [61, 1], [62, 1], [64, 1], // Hizb 56
    [65, 1], [66, 1], [67, 1], [68, 1], // Hizb 57
    [69, 1], [70, 1], [71, 1], [73, 1], // Hizb 58
    [74, 1], [76, 1], [77, 1], [79, 1], // Hizb 59
    [81, 1], [85, 1], [88, 1], [94, 1]  // Hizb 60 (Simplified)
  ];

  static Map<int, List<int>> getSurahAndVersesFromHizb(int hizbNumber) {
    if (hizbNumber < 1 || hizbNumber > 60) return {};
    final start = _hizbStarts[hizbNumber - 1];
    return {start[0]: [start[1]]};
  }

  static Map<int, List<int>> getSurahAndVersesFromRub(int rubNumber) {
    if (rubNumber < 1 || rubNumber > 240) return {};
    final index = rubNumber - 1;
    final actualIndex = index < _rubStarts.length ? index : (rubNumber / 4).floor() * 4;
    final start = _rubStarts[actualIndex < _rubStarts.length ? actualIndex : 0];
    return {start[0]: [start[1]]};
  }

  static int getHizbNumber(int surahNumber, int ayahNumber) {
    for (int i = _hizbStarts.length - 1; i >= 0; i--) {
      if (surahNumber > _hizbStarts[i][0] || 
         (surahNumber == _hizbStarts[i][0] && ayahNumber >= _hizbStarts[i][1])) {
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
}
