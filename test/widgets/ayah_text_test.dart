import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/presentation/widgets/sajdah_indicator.dart';

void main() {
  final testAyah1 = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'بسم الله',
    page: 1,
    juz: 1,
  );

  final testAyah2 = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 2).data!,
    uthmaniText: 'الحمد لله',
    page: 1,
    juz: 1,
  );

  final testAyahSajdah = Ayah(
    number: AyahNumber.create(surahNumber: 7, ayahNumberInSurah: 206).data!,
    uthmaniText: 'ان الذين عند ربك',
    page: 176,
    juz: 9,
    isSajdah: true,
    sajdahType: SajdahType.obligatory,
  );

  testWidgets('AyahText renders multiple ayahs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AyahText(ayahs: [testAyah1, testAyah2], onAyahTap: (_) {}),
        ),
      ),
    );

    expect(find.byType(RichText), findsWidgets);
    expect(find.textContaining('بسم الله'), findsOneWidget);
    expect(find.textContaining('الحمد لله'), findsOneWidget);
  });

  testWidgets('AyahText triggers onAyahTap', (WidgetTester tester) async {
    Ayah? tappedAyah;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AyahText(ayahs: [testAyah1], onAyahTap: (a) => tappedAyah = a),
        ),
      ),
    );

    // Find the RichText and tap its right side (since it is RTL)
    final richTextFinder = find.byType(RichText).first;
    final Offset topRight = tester.getTopRight(richTextFinder);

    // Tap 50 pixels from the right edge, middle vertically
    final Offset tapPoint = Offset(topRight.dx - 50, topRight.dy + 30);
    await tester.tapAt(tapPoint);
    await tester.pumpAndSettle(); // Wait for all animations and timers

    expect(tappedAyah, testAyah1);
  });

  testWidgets('AyahText renders sajdah indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AyahText(ayahs: [testAyahSajdah], onAyahTap: (_) {}),
        ),
      ),
    );

    expect(find.byType(SajdahIndicator), findsOneWidget);
  });
}
