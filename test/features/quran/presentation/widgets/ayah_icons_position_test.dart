import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  final testAyah = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'بسم الله',
    page: 1,
    juz: 1,
  );

  testWidgets('Check visual order of Ayah Text, Marker and Green Bookmark Symbol 🔖', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AyahText(
            ayahs: [testAyah],
            lastReadAyah: testAyah,
            onAyahTap: (_) {},
          ),
        ),
      ),
    );

    final richTextFinder = find.byType(RichText);
    final RenderParagraph renderParagraph = tester.renderObject(richTextFinder.first);
    
    // 1. Ayah Text position
    final ayahTextBox = renderParagraph.getBoxesForSelection(
      const TextSelection(baseOffset: 1, extentOffset: 4), 
    ).first;
    final ayahDx = renderParagraph.localToGlobal(ayahTextBox.toRect().center).dx;

    // 2. Marker position
    final markerText = quran.getVerseEndSymbol(1, arabicNumeral: true);
    final plainText = renderParagraph.text.toPlainText();
    final markerIndex = plainText.indexOf(markerText);
    final markerBox = renderParagraph.getBoxesForSelection(
      TextSelection(baseOffset: markerIndex, extentOffset: markerIndex + markerText.length),
    ).first;
    final markerDx = renderParagraph.localToGlobal(markerBox.toRect().center).dx;

    // 3. Bookmark Symbol position 🔖
    // Instead of TextSelection (which might fail if it's across spans or special chars),
    // we find it as a text piece.
    final bookmarkFinder = find.textContaining('\u{1F516}');
    expect(bookmarkFinder, findsOneWidget);
    final bookmarkDx = tester.getCenter(bookmarkFinder).dx;

    debugPrint('Ayah Dx: $ayahDx');
    debugPrint('Marker Dx: $markerDx');
    debugPrint('Bookmark Dx: $bookmarkDx');

    // Expected Visual Order (Right to Left):
    // Right: Ayah Text (largest Dx)
    // Middle: Marker
    // Left: Bookmark Symbol (smallest Dx)
    
    expect(ayahDx, greaterThan(markerDx), reason: 'Ayah text should be to the right of Marker');
    expect(markerDx, greaterThan(bookmarkDx), reason: 'Marker should be to the right of Bookmark symbol');
  });
}
