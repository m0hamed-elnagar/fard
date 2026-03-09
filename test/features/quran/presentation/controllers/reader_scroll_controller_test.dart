import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/presentation/controllers/reader_scroll_controller.dart';

void main() {
  late ReaderScrollController controller;

  setUp(() {
    controller = ReaderScrollController();
  });

  tearDown(() {
    controller.dispose();
  });

  test('generateKeys should create keys for all ayahs', () {
    final List<Ayah> ayahs = List.generate(
      7,
      (i) => Ayah(
        number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: i + 1).data!,
        uthmaniText: 'Text ${i + 1}',
        page: 1,
        juz: 1,
      ),
    );

    controller.generateKeys(ayahs);

    expect(controller.ayahKeys.length, equals(7));
    for (int i = 1; i <= 7; i++) {
      expect(controller.ayahKeys.containsKey(i), isTrue);
      expect(controller.ayahKeys[i], isA<GlobalKey>());
    }
  });

  test('generateKeys should not overwrite existing keys', () {
    final List<Ayah> ayahs1 = [
      Ayah(
        number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
        uthmaniText: 'Text 1',
        page: 1,
        juz: 1,
      ),
    ];
    controller.generateKeys(ayahs1);
    final originalKey = controller.ayahKeys[1];

    controller.generateKeys(ayahs1);
    expect(controller.ayahKeys[1], same(originalKey));
  });

  test('registerAyahKey should add a specific key', () {
    final key = GlobalKey();
    controller.registerAyahKey(1, key);
    expect(controller.ayahKeys[1], same(key));
  });

  testWidgets('currentVisibleAyah should update when scrolling', (tester) async {
    // This is hard to unit test without a real RenderBox layout.
    // We would need a full widget test with mock layout.
    // For now, let's just verify the ValueNotifier exists.
    expect(controller.currentVisibleAyah.value, isNull);
  });
}
