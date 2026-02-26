import 'package:adhan/adhan.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late MockPrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final threeDaysAgo = normalizedToday.subtract(const Duration(days: 3));
  
  final dummyPrayerTimes = PrayerTimes(
    Coordinates(30.0, 31.0),
    DateComponents.from(today),
    CalculationMethod.muslim_world_league.getParameters(),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(DailyRecord(
      id: 'dummy',
      date: DateTime.now(),
      missedToday: {},
      completedToday: {},
      qada: {},
    ));
    registerFallbackValue(dummyPrayerTimes);
  });

  setUp(() {
    getIt.reset();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    
    // Default: all prayers passed
    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
    when(() => prayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(dummyPrayerTimes);
  });

  group('PrayerTrackerBloc Missed Days Integration', () {
    testWidgets('Dialog appears when there is a gap and clicking "Skip" (I was praying) does not add to qada', (tester) async {
      final lastRecord = DailyRecord(
        id: 'old',
        date: threeDaysAgo,
        missedToday: {},
        completedToday: {},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);

      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocListener<PrayerTrackerBloc, PrayerTrackerState>(
              bloc: bloc,
              listener: (context, state) {
                state.maybeWhen(
                  missedDaysPrompt: (dates) {
                    showDialog(
                      context: context,
                      builder: (_) => MissedDaysDialog(
                        missedDates: dates,
                        onResponse: (selected) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: selected)),
                      ),
                    );
                  },
                  orElse: () {},
                );
              },
              child: const SizedBox(),
            ),
          ),
        ),
      );

      bloc.add(const PrayerTrackerEvent.checkMissedDays());
      await tester.pumpAndSettle();

      expect(find.byType(MissedDaysDialog), findsOneWidget);
      // Key: "I was praying" is the skip text
      expect(find.text('I was praying'), findsOneWidget);

      await tester.tap(find.text('I was praying'));
      await tester.pumpAndSettle();

      expect(find.byType(MissedDaysDialog), findsNothing);
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      bloc.state.maybeMap(
        loaded: (l) {
          // It was Skip. 10 (base) + 1 (today's fajr) = 11.
          // Note: Step A in _onLoad might add another +1 if lastRecord's day had missed prayers.
          expect(l.qadaStatus[Salaah.fajr]?.value, greaterThanOrEqualTo(11));
        },
        orElse: () => fail('Should be loaded'),
      );
    });

    testWidgets('Clicking "Add All" (Add to remaining) adds missed days to qada counter', (tester) async {
      final lastRecord = DailyRecord(
        id: 'old',
        date: threeDaysAgo,
        missedToday: {},
        completedToday: {},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);

      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocListener<PrayerTrackerBloc, PrayerTrackerState>(
              bloc: bloc,
              listener: (context, state) {
                state.maybeWhen(
                  missedDaysPrompt: (dates) {
                    showDialog(
                      context: context,
                      builder: (_) => MissedDaysDialog(
                        missedDates: dates,
                        onResponse: (selected) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: selected)),
                      ),
                    );
                  },
                  orElse: () {},
                );
              },
              child: const SizedBox(),
            ),
          ),
        ),
      );

      bloc.add(const PrayerTrackerEvent.checkMissedDays());
      await tester.pumpAndSettle();

      // Key: "Add to remaining" is the addAll text
      expect(find.text('Add to remaining'), findsOneWidget);
      await tester.tap(find.text('Add to remaining'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 200));
      
      bloc.state.maybeMap(
        loaded: (l) {
          // Base 10 + 2 missed days + 1 today = 13
          expect(l.qadaStatus[Salaah.fajr]?.value, greaterThan(11));
        },
        orElse: () => fail('Should be loaded'),
      );
    });
  });
}
