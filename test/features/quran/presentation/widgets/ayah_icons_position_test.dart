import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  final testAyah = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'بسم الله',
    page: 1,
    juz: 1,
  );

  testWidgets('Check visual order of Ayah Text, Marker and Green Symbols', (WidgetTester tester) async {
    final testBookmark = Bookmark(
      id: 'test',
      ayahNumber: testAyah.number,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AyahText(
            ayahs: [testAyah],
            lastReadAyah: testAyah,
            bookmarks: [testBookmark],
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

    // 3. Last Read Symbol position ➤
    final lastReadIndex = plainText.indexOf('\u27A4');
    expect(lastReadIndex, isNot(-1));
    final lastReadBox = renderParagraph.getBoxesForSelection(
      TextSelection(baseOffset: lastReadIndex, extentOffset: lastReadIndex + 1),
    ).first;
    final lastReadDx = renderParagraph.localToGlobal(lastReadBox.toRect().center).dx;

    // 4. Bookmark Symbol position 🔖
    final bookmarkIndex = plainText.indexOf('\u{1F516}');
    expect(bookmarkIndex, isNot(-1));
    // Bookmark is a surrogate pair, so extent is +2? 
    // Actually plainText length for surrogate pair is 2.
    final bookmarkBox = renderParagraph.getBoxesForSelection(
      TextSelection(baseOffset: bookmarkIndex, extentOffset: bookmarkIndex + 2),
    ).first;
    final bookmarkDx = renderParagraph.localToGlobal(bookmarkBox.toRect().center).dx;

    debugPrint('Ayah Dx: $ayahDx');
    debugPrint('Marker Dx: $markerDx');
    debugPrint('LastRead Dx: $lastReadDx');
    debugPrint('Bookmark Dx: $bookmarkDx');

    // Expected Visual Order (Right to Left):
    // Right: Ayah Text (largest Dx)
    // Middle: Marker
    // Left-ish: Last Read
    // Left-most: Bookmark Symbol (smallest Dx)
    
    expect(ayahDx, greaterThan(markerDx), reason: 'Ayah text should be to the right of Marker');
    expect(markerDx, greaterThan(lastReadDx), reason: 'Marker should be to the right of LastRead symbol');
    expect(lastReadDx, greaterThan(bookmarkDx), reason: 'LastRead should be to the right of Bookmark symbol');
  });
}
