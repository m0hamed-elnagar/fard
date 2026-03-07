import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/presentation/widgets/reader_info_bar.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
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
    testWidgets('should show both start and bookmark buttons when data is present', (tester) async {
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
          onJumpToBookmark: () {},
        ),
      ));

      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      
      // Verify Arabic numbers (using toArabicIndic extensions)
      // 10 -> ١٠, 15 -> ١٥
      expect(find.text('١٠'), findsOneWidget);
      expect(find.text('١٥'), findsOneWidget);
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
            lastReadAyah: ayah,
            onAyahTap: (_) {},
            textScale: 1.0,
          ),
        ),
      ));

      // Both icons should be present
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      // Verify they are rendered (no overlap error)
      // In a real widget test, we could check offsets if needed, 
      // but the fact they both find widgets in a RichText is a good start.
    });
  });
}
