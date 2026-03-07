import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/entities/reader_settings.dart';

import 'package:fard/core/errors/failure.dart';

void main() {
  final testAyah = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'بسم الله الرحمن الرحيم',
    translation: 'In the name of Allah',
    page: 1,
    juz: 1,
    isSajdah: false,
  );

  Widget createWidget({
    List<Ayah>? ayahs,
    Ayah? dayStartAyah,
    Ayah? lastReadAyah,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AyahText(
          ayahs: ayahs ?? [testAyah],
          dayStartAyah: dayStartAyah,
          lastReadAyah: lastReadAyah,
          onAyahTap: (_) {},
        ),
      ),
    );
  }

  testWidgets('AyahText renders spans in correct order', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget(
      dayStartAyah: testAyah,
      lastReadAyah: testAyah,
    ));

    final richTextFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.textAlign == TextAlign.justify,
    );
    expect(richTextFinder, findsOneWidget);

    final RichText richText = tester.widget(richTextFinder);
    final List<InlineSpan> allSpans = [];
    
    void collectSpans(InlineSpan? span) {
      if (span == null) return;
      if (span is TextSpan) {
        if (span.text != null) {
          allSpans.add(span);
        }
        if (span.children != null) {
          for (final child in span.children!) {
            collectSpans(child);
          }
        }
      } else if (span is WidgetSpan) {
        allSpans.add(span);
      }
    }

    collectSpans(richText.text);

    // Filter out the root spans that don't have text or widget directly
    final leafSpans = allSpans.where((s) => (s is TextSpan && s.text != null) || s is WidgetSpan).toList();
    
    // leafSpans should be:
    // 0: Anchor (WidgetSpan)
    // 1: Flag (WidgetSpan)
    // 2: Ayah Text (TextSpan)
    // 3: Bookmark (WidgetSpan)
    // 4: Marker (TextSpan)
    // 5: Trailing space (TextSpan)
    
    expect(leafSpans.length, 6);
    expect(leafSpans[0], isA<WidgetSpan>()); // Anchor
    expect(leafSpans[1], isA<WidgetSpan>()); // Flag
    expect(leafSpans[2], isA<TextSpan>());
    expect((leafSpans[2] as TextSpan).text, testAyah.uthmaniText);
    expect(leafSpans[3], isA<WidgetSpan>()); // Bookmark
    expect(leafSpans[4], isA<TextSpan>());
    expect((leafSpans[4] as TextSpan).text, contains('۝'));
    expect(leafSpans[5], isA<TextSpan>());
    expect((leafSpans[5] as TextSpan).text, ' ');
    
    // Verify RTL
    expect(richText.textDirection, TextDirection.rtl);
    expect(richText.textAlign, TextAlign.justify);
  });
}
