import 'package:adhan/adhan.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc_test/bloc_test.dart';

class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockPrayerTimeService mockPrayerTimeService;
  late MockSettingsCubit mockSettingsCubit;

  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
  });

  setUp(() async {
    mockPrayerTimeService = MockPrayerTimeService();
    mockSettingsCubit = MockSettingsCubit();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);

    when(() => mockSettingsCubit.state).thenReturn(const SettingsState(
      locale: Locale('en'),
      isQadaEnabled: true,
      latitude: 0,
      longitude: 0,
    ));
    when(() => mockSettingsCubit.stream).thenAnswer((_) => const Stream.empty());

    // Mock all prayers as passed
    when(() => mockPrayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
    
    final prayerTimes = PrayerTimes(
      Coordinates(0, 0),
      DateComponents.from(DateTime.now()),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    when(() => mockPrayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(prayerTimes);
  });

  testWidgets('HistoryList shows missed today count and total qada (which includes missed today)', (WidgetTester tester) async {
    // Scenario: User has 10 qada from before, and missed Fajr today.
    // So total qada in record should be 11.
    final record = DailyRecord(
      id: 'test',
      date: DateTime(2024, 2, 17),
      missedToday: {Salaah.fajr},
      completedToday: {Salaah.dhuhr, Salaah.asr, Salaah.maghrib, Salaah.isha}, // Completed 4, Missed 1
      qada: {
        Salaah.fajr: const MissedCounter(11), // 10 + 1 missed today
        Salaah.dhuhr: const MissedCounter(0),
        Salaah.asr: const MissedCounter(0),
        Salaah.maghrib: const MissedCounter(0),
        Salaah.isha: const MissedCounter(0),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: mockSettingsCubit,
            child: HistoryList(
              records: [record],
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Missed 1" is shown (actualMissedCount)
    expect(find.text('Missed 1'), findsOneWidget);
    
    // Verify "Remaining: 10" is shown (totalQada 11 - actualMissed 1)
    expect(find.text('Remaining: 10'), findsOneWidget);

    // Verify both are present at the same time
    expect(find.text('Missed 1'), findsOneWidget);
    expect(find.text('Remaining: 10'), findsOneWidget);
  });

  testWidgets('HistoryList shows qada completion count when qada is prayed', (WidgetTester tester) async {
    // Scenario: User has 10 qada, and completed 2 qada today.
    // record.qada should reflect the remaining qada (8).
    // record.completedQada should show 2.
    final record = DailyRecord(
      id: 'test-qada-comp',
      date: DateTime(2024, 2, 17),
      missedToday: const {},
      completedToday: Set.from(Salaah.values), // All daily prayers done
      qada: {
        Salaah.fajr: const MissedCounter(8), // 10 - 2 completed
        Salaah.dhuhr: const MissedCounter(0),
        Salaah.asr: const MissedCounter(0),
        Salaah.maghrib: const MissedCounter(0),
        Salaah.isha: const MissedCounter(0),
      },
      completedQada: {
        Salaah.fajr: 2,
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: mockSettingsCubit,
            child: HistoryList(
              records: [record],
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Qada 2" is shown (qadaCompletedToday)
    expect(find.text('Qada 2'), findsOneWidget);
    
    // Verify "Done 5" is shown (daily prayers)
    expect(find.text('Done 5'), findsOneWidget);
    
    // Verify "Remaining: 8" is shown (8 - 0 missed today)
    expect(find.text('Remaining: 8'), findsOneWidget);
  });

  testWidgets('HistoryList shows both missed today and qada completed', (WidgetTester tester) async {
    // Scenario: 10 qada from before.
    // Today: Missed Fajr (+1), Completed 2 Qada Dhuhr (-2).
    // Net qada change: -1. Total remaining: 9.
    final record = DailyRecord(
      id: 'test-mixed',
      date: DateTime(2024, 2, 17),
      missedToday: {Salaah.fajr},
      completedToday: {Salaah.dhuhr, Salaah.asr, Salaah.maghrib, Salaah.isha},
      qada: {
        Salaah.fajr: const MissedCounter(1), // The one missed today
        Salaah.dhuhr: const MissedCounter(8), // 10 - 2
        Salaah.asr: const MissedCounter(0),
        Salaah.maghrib: const MissedCounter(0),
        Salaah.isha: const MissedCounter(0),
      },
      completedQada: {
        Salaah.dhuhr: 2,
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: mockSettingsCubit,
            child: HistoryList(
              records: [record],
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Missed 1 (Fajr)
    expect(find.text('Missed 1'), findsOneWidget);
    
    // Qada 2 (Dhuhr)
    expect(find.text('Qada 2'), findsOneWidget);
    
    // Remaining 8 (9 total - 1 missed today)
    expect(find.text('Remaining: 8'), findsOneWidget);
  });

  testWidgets('HistoryList shows 0 missed if all prayers are completed', (WidgetTester tester) async {
    final record = DailyRecord(
      id: 'test',
      date: DateTime(2024, 2, 17),
      missedToday: const {},
      completedToday: Set.from(Salaah.values), // All completed
      qada: {for (var s in Salaah.values) s: const MissedCounter(10)}, // Total 50 qada from before
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: mockSettingsCubit,
            child: HistoryList(
              records: [record],
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Missed" count is NOT shown (it is 0)
    expect(find.textContaining('Missed'), findsNothing);
    
    // Verify "Remaining: 50" is shown
    expect(find.text('Remaining: 50'), findsOneWidget);
  });
}
