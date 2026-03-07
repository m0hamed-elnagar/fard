import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  test('WerdGoal accurate page calculation', () {
    // Page 1 has 7 ayahs
    final goalP1 = WerdGoal(
      id: '1',
      type: WerdGoalType.fixedAmount,
      value: 1,
      unit: WerdUnit.page,
      startDate: DateTime.now(),
      startAbsolute: 1, // Start at Page 1
    );
    expect(goalP1.valueInAyahs, 7);

    // Page 2 has 5 ayahs (Surah 2:1-5)
    final goalP2 = WerdGoal(
      id: '2',
      type: WerdGoalType.fixedAmount,
      value: 1,
      unit: WerdUnit.page,
      startDate: DateTime.now(),
      startAbsolute: 8, // Start at Page 2 (S2:1)
    );
    expect(goalP2.valueInAyahs, 5);
  });

  test('WerdGoal accurate Juz calculation', () {
    // Juz 1 starts at 1:1 and ends at 2:141
    // Total ayahs in Juz 1: 7 (S1) + 141 (S2) = 148
    final goalJ1 = WerdGoal(
      id: 'j1',
      type: WerdGoalType.fixedAmount,
      value: 1,
      unit: WerdUnit.juz,
      startDate: DateTime.now(),
      startAbsolute: 1,
    );
    expect(goalJ1.valueInAyahs, 148);
  });

  test('QuranHizbProvider absolute conversion', () {
    // Fatihah has 7 ayahs. 
    // Surah 2, Ayah 1 should be absolute 8.
    expect(QuranHizbProvider.getAbsoluteAyahNumber(1, 1), 1);
    expect(QuranHizbProvider.getAbsoluteAyahNumber(1, 7), 7);
    expect(QuranHizbProvider.getAbsoluteAyahNumber(2, 1), 8);
  });

  test('Quran page mapping', () {
    // Page 1 is Surah 1, Ayahs 1-7
    expect(quran.getPageNumber(1, 1), 1);
    expect(quran.getPageNumber(1, 7), 1);
    // Page 2 is Surah 2, Ayahs 1-5
    expect(quran.getPageNumber(2, 1), 2);
    expect(quran.getPageNumber(2, 5), 2);
    // Page 3 starts at Surah 2, Ayah 6
    expect(quran.getPageNumber(2, 6), 3);
  });
}
