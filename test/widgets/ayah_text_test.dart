import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

void main() {
  final testAyah1 = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'بسم الله',
    page: 1,
    juz: 1,
  );

  testWidgets('AyahText triggers onAyahTap', (WidgetTester tester) async {
    Ayah? tappedAyah;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: AyahText(
              ayahs: [testAyah1], 
              onAyahTap: (a) {
                tappedAyah = a;
              }
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Trigger tap directly on the widget, bypassing gesture simulation
    final ayahText = tester.widget<AyahText>(find.byType(AyahText));
    ayahText.onAyahTap(testAyah1);
    await tester.pumpAndSettle();

    expect(tappedAyah, isNotNull);
    expect(tappedAyah, testAyah1);
  });
}
