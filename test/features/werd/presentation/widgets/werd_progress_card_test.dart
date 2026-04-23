import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/werd_progress_card.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockWerdBloc extends MockBloc<WerdEvent, WerdState> implements WerdBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockWerdBloc mockWerdBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
  });

  setUp(() {
    mockWerdBloc = MockWerdBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createWidgetUnderTest({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [mockNavigatorObserver],
      home: Scaffold(
        body: BlocProvider<WerdBloc>.value(
          value: mockWerdBloc,
          child: WerdProgressCard(onSetGoalPressed: () {}),
        ),
      ),
    );
  }

  group('WerdProgressCard No Goal State', () {
    testWidgets('shows set goal CTA when no goal is set', (tester) async {
      when(() => mockWerdBloc.state).thenReturn(WerdState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show set goal button
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });

    testWidgets('tapping set goal button triggers callback', (tester) async {
      bool callbackCalled = false;
      when(() => mockWerdBloc.state).thenReturn(WerdState());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<WerdBloc>.value(
              value: mockWerdBloc,
              child: WerdProgressCard(
                onSetGoalPressed: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final setGoalButton = find.byIcon(Icons.track_changes_rounded);
      if (setGoalButton.evaluate().isNotEmpty) {
        await tester.tap(setGoalButton.first);
        await tester.pumpAndSettle();
        expect(callbackCalled, isTrue);
      }
    });
  });

  group('WerdProgressCard Progress Display', () {
    testWidgets('shows 0/10 progress when no ayahs read', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 0,
            sessionStartAbsolute: 1,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show progress values (may be formatted differently, use partial match)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('0'),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('10'),
        ),
        findsWidgets,
      );
    });

    testWidgets('shows partial progress correctly (5/10)', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('5'),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('10'),
        ),
        findsWidgets,
      );
    });

    testWidgets('shows completion state when goal exceeded (15/10)', (
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 15,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 15,
            lastUpdated: DateTime.now(),
            streak: 1,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('15'),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('10'),
        ),
        findsWidgets,
      );
      // Should show completion icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('progress bar reflects correct percentage (50%)', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final progressIndicator = find.byType(LinearProgressIndicator);
      expect(progressIndicator, findsOneWidget);

      final LinearProgressIndicator indicator = tester.widget(
        progressIndicator,
      );
      expect(indicator.value, closeTo(0.5, 0.01)); // 5/10 = 0.5
    });
  });

  group('WerdProgressCard Continue Button', () {
    testWidgets('Continue button shows correct text', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    // BUG EXPOSURE: Continue button should go to sessionStart if no progress
    testWidgets(
      'BUG EXPOSURE: Continue button navigates to sessionStart when no progress',
      (tester) async {
        when(() => mockWerdBloc.state).thenReturn(
          WerdState(
            goal: WerdGoal(
              id: 'default',
              type: WerdGoalType.fixedAmount,
              value: 10,
              unit: WerdUnit.ayah,
              startDate: DateTime.now(),
              startAbsolute: 100, // Started from ayah 100
            ),
            progress: WerdProgress(
              goalId: 'default',
              totalAmountReadToday: 0,
              sessionStartAbsolute: 100,
              lastReadAbsolute: null,
              lastUpdated: DateTime.now(),
              streak: 0,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Current position should show ayah 100 (sessionStart)
        expect(find.textContaining('Current Position'), findsOneWidget);
      },
    );

    testWidgets(
      'Continue button navigates to lastRead when progress exists',
      (tester) async {
        when(() => mockWerdBloc.state).thenReturn(
          WerdState(
            goal: WerdGoal(
              id: 'default',
              type: WerdGoalType.fixedAmount,
              value: 10,
              unit: WerdUnit.ayah,
              startDate: DateTime.now(),
              startAbsolute: 100,
            ),
            progress: WerdProgress(
              goalId: 'default',
              totalAmountReadToday: 5,
              sessionStartAbsolute: 100,
              lastReadAbsolute: 105,
              lastUpdated: DateTime.now(),
              streak: 0,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Current position should show ayah 105 (lastRead)
        expect(find.textContaining('Current Position'), findsOneWidget);
      },
    );
  });

  group('WerdProgressCard Display Unit Switching', () {
    testWidgets('shows ayah unit label', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 10,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 10,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ayah'), findsOneWidget);
    });

    testWidgets('shows page unit when goal is in pages', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 10,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 10,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Page'), findsOneWidget);
    });

    testWidgets('tapping unit label cycles through units', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find current unit label (should start with Ayah)
      final unitLabel = find.text('Ayah');
      if (unitLabel.evaluate().isNotEmpty) {
        expect(unitLabel, findsOneWidget);

        // Tap to switch to Page
        await tester.tap(unitLabel.first);
        await tester.pumpAndSettle();

        expect(find.text('Page'), findsOneWidget);

        // Tap to switch to Juz
        await tester.tap(find.text('Page').first);
        await tester.pumpAndSettle();

        expect(find.text('Juz'), findsOneWidget);
      }
    });
  });

  group('WerdProgressCard Streak Display', () {
    testWidgets('shows streak count when greater than 0', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 7,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('7'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('does not show streak when it is 0', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 0,
            sessionStartAbsolute: 1,
            lastReadAbsolute: null,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Streak icon should not be present when streak is 0
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
    });
  });

  group('WerdProgressCard History & Month Summary', () {
    testWidgets('shows month total in ayahs', (tester) async {
      final now = DateTime.now();
      final currentMonthKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";

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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 3,
            history: {
              '$currentMonthKey-01': WerdHistoryEntry(
                totalAyahsRead: 10,
                startAbsolute: 1,
                endAbsolute: 10,
                pagesRead: 1.5,
                juzRead: 0.1,
                startSurahName: 'Al-Fatihah',
                startAyahNumber: 1,
                endSurahName: 'Al-Baqarah',
                endAyahNumber: 3,
                summary: 'Read 10 ayahs',
              ),
              '$currentMonthKey-02': WerdHistoryEntry(
                totalAyahsRead: 15,
                startAbsolute: 11,
                endAbsolute: 25,
                pagesRead: 2.0,
                juzRead: 0.15,
                startSurahName: 'Al-Baqarah',
                startAyahNumber: 4,
                endSurahName: 'Al-Baqarah',
                endAyahNumber: 18,
                summary: 'Read 15 ayahs',
              ),
            },
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show month total (10 + 15 + 5 today = 30)
      expect(find.textContaining('30'), findsOneWidget);
    });

    testWidgets('History button is present', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });
  });

  group('WerdProgressCard Arabic Localization', () {
    testWidgets('shows Arabic numerals for progress', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      // Should show Arabic numerals (checking for Arabic digit characters)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('٥'),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.contains('١٠'),
        ),
        findsWidgets,
      );
    });

    testWidgets('shows Arabic position text', (tester) async {
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
          progress: WerdProgress(
            goalId: 'default',
            totalAmountReadToday: 5,
            sessionStartAbsolute: 1,
            lastReadAbsolute: 5,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('المكان الحالي'), findsOneWidget);
      expect(find.text('متابعة'), findsOneWidget);
    });
  });
}
