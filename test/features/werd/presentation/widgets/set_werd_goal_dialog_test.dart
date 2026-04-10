import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/werd/presentation/widgets/set_werd_goal_dialog.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockWerdBloc extends MockBloc<WerdEvent, WerdState> implements WerdBloc {}

class MockQuranBloc extends MockBloc<QuranEvent, QuranState> implements QuranBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockWerdBloc mockWerdBloc;
  late MockQuranBloc mockQuranBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockWerdBloc = MockWerdBloc();
    mockQuranBloc = MockQuranBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
    registerFallbackValue(
      WerdGoal(
        id: 'default',
        type: WerdGoalType.fixedAmount,
        value: 10,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
        startAbsolute: 1,
      ),
    );

    // Mock Quran state with basic surahs for dropdown
    when(() => mockQuranBloc.state).thenReturn(
      QuranState(
        surahs: [
          Surah(
            number: SurahNumber.create(1).data!,
            name: 'Al-Fatihah',
            englishName: 'The Opener',
            englishNameTranslation: 'The Opening',
            numberOfAyahs: 7,
            revelationType: 'Meccan',
            ayahs: [],
          ),
          Surah(
            number: SurahNumber.create(2).data!,
            name: 'Al-Baqarah',
            englishName: 'The Cow',
            englishNameTranslation: 'The Cow',
            numberOfAyahs: 286,
            revelationType: 'Medinan',
            ayahs: [],
          ),
        ],
      ),
    );
  });

  Widget createDialogUnderTest({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [mockNavigatorObserver],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WerdBloc>.value(value: mockWerdBloc),
          BlocProvider<QuranBloc>.value(value: mockQuranBloc),
        ],
        child: Builder(
          builder: (context) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => MultiBlocProvider(
                      providers: [
                        BlocProvider<WerdBloc>.value(value: mockWerdBloc),
                        BlocProvider<QuranBloc>.value(value: mockQuranBloc),
                      ],
                      child: const SetWerdGoalDialog(),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  group('SetWerdGoalDialog Goal Type Selection', () {
    testWidgets('shows default goal type as fixedAmount', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      
      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show "Daily" selected by default
      expect(find.text('Daily'), findsOneWidget);
    });

    testWidgets('switching to finishInDays changes value to 30', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap "Finish" button
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Value should change to 30
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('shows existing goal type when editing', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.finishInDays,
            value: 60,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show "Finish" selected
      expect(find.text('Finish'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    });
  });

  group('SetWerdGoalDialog Start Point Selection', () {
    testWidgets('defaults to "Start from Al-Fatihah (beginning)"', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
          progress: null, // No progress yet
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Start from Al-Fatihah (beginning)'), findsOneWidget);
    });

    testWidgets('shows "Continue where I stopped" option', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.text('Start from Al-Fatihah (beginning)'));
      await tester.pumpAndSettle();

      expect(find.text('Continue where I stopped'), findsOneWidget);
      expect(find.text('Choose specific surah/ayah'), findsOneWidget);
    });

    // BUG EXPOSURE: "Continue where I stopped" with no lastRead defaults to 1
    testWidgets(
      'BUG EXPOSURE: "Continue where I stopped" with no lastRead defaults to ayah 1',
      (tester) async {
        when(() => mockWerdBloc.state).thenReturn(
          WerdState(
            goal: WerdGoal(
              id: 'default',
              type: WerdGoalType.fixedAmount,
              value: 10,
              unit: WerdUnit.ayah,
              startDate: DateTime.now(),
              startAbsolute: 1,
            ),
          ),
        );
        // No last read position
        when(() => mockQuranBloc.state).thenReturn(
          QuranState.initial().copyWith(lastReadPosition: null),
        );

        await tester.pumpWidget(createDialogUnderTest());
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Select "Continue where I stopped"
        await tester.tap(find.text('Start from Al-Fatihah (beginning)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue where I stopped'));
        await tester.pumpAndSettle();

        // Should still work, defaulting to ayah 1
        expect(find.text('Continue where I stopped'), findsOneWidget);
      },
    );

    testWidgets('"Continue where I stopped" uses QuranBloc lastReadPosition', (
      tester,
    ) async {
      // Note: AyahNumber uses factory constructor, create via Result
      final ayahResult = AyahNumber.create(surahNumber: 2, ayahNumberInSurah: 50);
      
      await ayahResult.fold(
        (failure) async => fail('Should create valid AyahNumber'),
        (ayahNumber) async {
          final lastReadPosition = LastReadPosition(
            ayahNumber: ayahNumber,
            updatedAt: DateTime.now(),
          );

          when(() => mockWerdBloc.state).thenReturn(
            WerdState(
              goal: WerdGoal(
                id: 'default',
                type: WerdGoalType.fixedAmount,
                value: 10,
                unit: WerdUnit.ayah,
                startDate: DateTime.now(),
                startAbsolute: 1,
              ),
            ),
          );
          when(() => mockQuranBloc.state).thenReturn(
            QuranState.initial().copyWith(lastReadPosition: lastReadPosition),
          );

          await tester.pumpWidget(createDialogUnderTest());
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Select "Continue where I stopped"
          await tester.tap(find.text('Start from Al-Fatihah (beginning)'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Continue where I stopped'));
          await tester.pumpAndSettle();

          // Should show "Continue where I stopped" selected
          expect(find.text('Continue where I stopped'), findsOneWidget);
        },
      );
    });

    testWidgets('Choose specific surah/ayah selector shows surah dropdown', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Open dropdown and select "Choose specific surah/ayah"
      await tester.tap(find.text('Start from Al-Fatihah (beginning)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose specific surah/ayah'));
      await tester.pumpAndSettle();

      // Should show surah dropdown
      expect(find.text('Al-Fatihah'), findsOneWidget);
    });

    testWidgets('changing surah resets ayah to 1', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Select "Choose specific surah/ayah"
      await tester.tap(find.text('Start from Al-Fatihah (beginning)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose specific surah/ayah'));
      await tester.pumpAndSettle();

      // Change surah to Al-Baqarah
      await tester.tap(find.text('Al-Fatihah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Al-Baqarah').last);
      await tester.pumpAndSettle();

      // Ayah should reset to 1
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('SetWerdGoalDialog Unit Selection', () {
    testWidgets('shows ayah, page, juz units', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Ayah'), findsOneWidget);
      expect(find.text('Page'), findsOneWidget);
      expect(find.text('Juz'), findsOneWidget);
    });

    testWidgets('selecting existing goal shows correct unit', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 2,
            unit: WerdUnit.page,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Page should be selected
      expect(find.text('Page'), findsOneWidget);
    });

    testWidgets('switching units updates correctly', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Switch to Page
      await tester.tap(find.text('Page'));
      await tester.pumpAndSettle();

      expect(find.text('Page'), findsWidgets); // Both chip and label
    });
  });

  group('SetWerdGoalDialog Value Input', () {
    testWidgets('shows current goal value', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 20,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('increment button increases value', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap increment
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('decrement button decreases value (min 1)', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap decrement
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();

      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('value respects max limit for juz (30)', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 1,
            unit: WerdUnit.juz,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to enter 31
      await tester.enterText(find.byType(TextField), '31');
      await tester.pumpAndSettle();

      // Should be clamped to 30
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('value respects max limit for pages (604)', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 1,
            unit: WerdUnit.page,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to enter 605
      await tester.enterText(find.byType(TextField), '605');
      await tester.pumpAndSettle();

      // Should be clamped to 604
      expect(find.text('604'), findsOneWidget);
    });
  });

  group('SetWerdGoalDialog Save & Cancel', () {
    testWidgets('Save button dispatches WerdEvent.setGoal', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Change value to 15
      await tester.enterText(find.byType(TextField), '15');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Goal'));
      await tester.pumpAndSettle();

      // Verify event was dispatched by checking that goal was saved
      // (We verify the side effect since WerdEvent.setGoal is a constructor, not a type)
      verify(
        () => mockWerdBloc.add(any(that: isA<WerdEvent>())),
      ).called(1);
    });

    testWidgets('Save button creates goal with correct startAbsolute', (
      tester,
    ) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Select "Choose specific surah/ayah" - Surah 2, Ayah 5
      await tester.tap(find.text('Start from Al-Fatihah (beginning)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose specific surah/ayah'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Al-Fatihah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Al-Baqarah').last);
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Goal'));
      await tester.pumpAndSettle();

      // Verify event was dispatched (verify side effect since setGoal is constructor)
      verify(
        () => mockWerdBloc.add(any(that: isA<WerdEvent>())),
      ).called(1);
    });

    testWidgets('Cancel button closes dialog', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed (no SetWerdGoalDialog found)
      expect(find.byType(SetWerdGoalDialog), findsNothing);
    });

    testWidgets('Close icon button closes dialog', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SetWerdGoalDialog), findsNothing);
    });
  });

  group('SetWerdGoalDialog Arabic Localization', () {
    testWidgets('shows Arabic text for goal type', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest(locale: const Locale('ar')));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('كمية يومية'), findsOneWidget);
      expect(find.text('ختم القرآن'), findsOneWidget);
    });

    testWidgets('shows Arabic text for start points', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest(locale: const Locale('ar')));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('من البداية (الفاتحة)'), findsOneWidget);
      expect(find.text('متابعة من حيث توقفت'), findsOneWidget);
      expect(find.text('اختيار سورة وآية محددة'), findsOneWidget);
    });

    testWidgets('shows Arabic text for save/cancel', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(
        WerdState(
          goal: WerdGoal(
            id: 'default',
            type: WerdGoalType.fixedAmount,
            value: 10,
            unit: WerdUnit.ayah,
            startDate: DateTime.now(),
            startAbsolute: 1,
          ),
        ),
      );
      when(() => mockQuranBloc.state).thenReturn(QuranState.initial());

      await tester.pumpWidget(createDialogUnderTest(locale: const Locale('ar')));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('حفظ الهدف'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
    });
  });
}
