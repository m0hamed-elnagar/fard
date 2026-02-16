import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/domain/models/surah.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/quran/presentation/pages/quran_page.dart';

class MockQuranBloc extends MockBloc<QuranEvent, QuranState> implements QuranBloc {}

void main() {
  late MockQuranBloc mockQuranBloc;

  setUp(() {
    final getIt = GetIt.instance;
    getIt.allowReassignment = true;
    mockQuranBloc = MockQuranBloc();
    getIt.registerFactory<QuranBloc>(() => mockQuranBloc);

    when(() => mockQuranBloc.state).thenReturn(const QuranState(
      surahs: [
        Surah(
          number: 1,
          name: 'سُورَةُ الْفَاتِحَةِ',
          englishName: 'Al-Faatiha',
          englishNameTranslation: 'The Opening',
          numberOfAyahs: 7,
          revelationType: 'Meccan',
        ),
        Surah(
          number: 2,
          name: 'سُورَةُ البَقَرَةِ',
          englishName: 'Al-Baqara',
          englishNameTranslation: 'The Cow',
          numberOfAyahs: 286,
          revelationType: 'Medinan',
        ),
      ],
      isLoading: false,
    ));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const QuranPage(),
    );
  }

  group('QuranPage', () {
    testWidgets('renders list of surahs', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Al-Faatiha'), findsOneWidget);
      expect(find.text('Al-Baqara'), findsOneWidget);
      expect(find.text('سُورَةُ الْفَاتِحَةِ'), findsOneWidget);
    });

    testWidgets('search filters surahs', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'baqara');
      await tester.pumpAndSettle();

      expect(find.text('Al-Baqara'), findsOneWidget);
      expect(find.text('Al-Faatiha'), findsNothing);
    });

    testWidgets('shows loading indicator when state is loading', (tester) async {
      when(() => mockQuranBloc.state).thenReturn(const QuranState(isLoading: true));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state has error', (tester) async {
      when(() => mockQuranBloc.state).thenReturn(const QuranState(error: 'Failed to load'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load'), findsOneWidget);
    });
   group('SurahDetailPage integration', () {
      testWidgets('tapping a surah navigates to detail page', (tester) async {
         // We need to return the state with ayahs when requested
         when(() => mockQuranBloc.state).thenReturn(QuranState(
           surahs: [
             const Surah(
               number: 1,
               name: 'سُورَةُ الْفَاتِحَةِ',
               englishName: 'Al-Faatiha',
               englishNameTranslation: 'The Opening',
               numberOfAyahs: 7,
               revelationType: 'Meccan',
             )
           ],
           selectedSurahDetail: SurahDetail(
              number: 1,
              name: 'سُورَةُ الْفَاتِحَةِ',
              englishName: 'Al-Faatiha',
              englishNameTranslation: 'The Opening',
              revelationType: 'Meccan',
              numberOfAyahs: 7,
              ayahs: [],
           ),
           isLoading: false,
         ));

         await tester.pumpWidget(createWidgetUnderTest());
         await tester.pumpAndSettle();

         await tester.tap(find.text('Al-Faatiha'));
         await tester.pumpAndSettle();

         // Should now be on Detail Page
         expect(find.text('The Opening'), findsAtLeast(1));
         expect(find.text('سُورَةُ الْفَاتِحَةِ'), findsAtLeast(1));
      });
    });
  });
}
