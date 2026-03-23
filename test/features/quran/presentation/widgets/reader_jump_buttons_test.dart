import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/reader_info_bar.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockWerdBloc extends MockBloc<WerdEvent, WerdState> implements WerdBloc {}

void main() {
  late MockWerdBloc mockWerdBloc;

  setUp(() {
    mockWerdBloc = MockWerdBloc();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<WerdBloc>.value(
          value: mockWerdBloc,
          child: child,
        ),
      ),
    );
  }

  group('ReaderInfoBar Jump Buttons', () {
    testWidgets('should show all jump buttons when data is present', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 10,
            lastReadAbsolute: 15,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(buildTestableWidget(
        ReaderInfoBar(
          surahNumber: 1,
          ayahNumber: 1,
          onJumpToStart: () {},
          onJumpToLastRead: () {},
          onJumpToBookmark: () {},
          bookmarkAbsolutes: const [20],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      
      // Verify Arabic numbers
      // Absolute 10 -> Surah 2, Ayah 3 -> ٣
      // Absolute 15 -> Surah 2, Ayah 8 -> ٨
      // Absolute 20 -> Surah 2, Ayah 13 -> ١٣
      expect(find.text('٣'), findsOneWidget);
      expect(find.text('٨'), findsOneWidget);
      expect(find.text('١٣'), findsOneWidget);
    });
  });

  group('AyahText Icons', () {
    testWidgets('should render flag and bookmark icons at different positions in same ayah', (tester) async {
      final ayah = Ayah(
        number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
        uthmaniText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        translation: 'Bismillah',
        page: 1,
        juz: 1,
        hizb: 1,
        rub: 1,
        isSajdah: false,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AyahText(
            ayahs: [ayah],
            dayStartAyah: ayah,
            bookmarks: [
              Bookmark(id: '1', ayahNumber: ayah.number, createdAt: DateTime.now()),
            ],
            onAyahTap: (_) {},
            textScale: 1.0,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // AyahText uses Unicode characters, not Icon widgets
      expect(find.textContaining('\u2691'), findsOneWidget); // Flag
      expect(find.textContaining('\u{1F516}'), findsOneWidget); // Bookmark
    });
  });
}
