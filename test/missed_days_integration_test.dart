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

class FakePrayerRepo implements PrayerRepo {
  final Map<String, DailyRecord> _records = {};

  @override
  Future<void> saveToday(DailyRecord record) async {
    final key = '${record.date.year}-${record.date.month}-${record.date.day}';
    _records[key] = record;
  }

  @override
  Future<void> deleteRecord(DateTime date) async {
    final key = '${date.year}-${date.month}-${date.day}';
    _records.remove(key);
  }

  @override
  Future<DailyRecord?> loadRecord(DateTime date) async {
    final key = '${date.year}-${date.month}-${date.day}';
    return _records[key];
  }

  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async {
    final Map<DateTime, DailyRecord> monthRecords = {};
    for (final r in _records.values) {
      if (r.date.year == year && r.date.month == month) {
        monthRecords[r.date] = r;
      }
    }
    return monthRecords;
  }

  @override
  Future<Map<Salaah, int>> calculateRemaining(DateTime from, DateTime to) async {
    return {for (var s in Salaah.values) s: 0};
  }

  @override
  Future<DailyRecord?> loadLastSavedRecord() async {
    if (_records.isEmpty) return null;
    final sorted = _records.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return sorted.last;
  }

  @override
  Future<DailyRecord?> loadLastRecordBefore(DateTime date) async {
    final before = _records.values.where((r) => r.date.isBefore(date)).toList();
    if (before.isEmpty) return null;
    before.sort((a, b) => a.date.compareTo(b.date));
    return before.last;
  }

  @override
  Future<List<DailyRecord>> loadAllRecords() async {
    return _records.values.toList();
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late FakePrayerRepo repo;
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
    repo = FakePrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

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

    when(() => prefs.getDouble('latitude')).thenReturn(30.0);
    when(() => prefs.getDouble('longitude')).thenReturn(31.0);
  });

  group('PrayerTrackerBloc Missed Days Integration', () {
    testWidgets('Dialog appears when there is a gap and clicking "Skip" (I was praying) does not add to qada', (tester) async {
      final lastRecord = DailyRecord(
        id: 'old',
        date: threeDaysAgo,
        missedToday: {},
        completedToday: {for (var s in Salaah.values) s},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      await repo.saveToday(lastRecord);

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
      expect(find.text('I was praying'), findsOneWidget);

      await tester.tap(find.text('I was praying'));
      await tester.pumpAndSettle();

      expect(find.byType(MissedDaysDialog), findsNothing);
      
      // Wait for BLoC processing (acknowledgeMissedDays -> load)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      bloc.state.maybeMap(
        loaded: (l) {
          // It was Skip. 10 (base) + 1 (today's fajr) = 11.
          expect(l.qadaStatus[Salaah.fajr]?.value, 11);
        },
        orElse: () => fail('Should be loaded'),
      );
    });

    testWidgets('Clicking "Add All" (Add to remaining) adds missed days to qada counter', (tester) async {
      final lastRecord = DailyRecord(
        id: 'old',
        date: threeDaysAgo,
        missedToday: {},
        completedToday: {for (var s in Salaah.values) s},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      await repo.saveToday(lastRecord);

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

      expect(find.text('Add to remaining'), findsOneWidget);
      await tester.tap(find.text('Add to remaining'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      bloc.state.maybeMap(
        loaded: (l) {
          // Base 10 + 2 missed days + 1 today = 13
          expect(l.qadaStatus[Salaah.fajr]?.value, 13);
        },
        orElse: () => fail('Should be loaded'),
      );
    });

    testWidgets('Can toggle specific days and correctly update Qada', (tester) async {
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final sixDaysAgo = normalizedToday.subtract(const Duration(days: 6));

      final lastRecord = DailyRecord(
        id: 'old',
        date: sixDaysAgo,
        missedToday: {},
        completedToday: {for (var s in Salaah.values) s},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      await repo.saveToday(lastRecord);

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

      final gapDates = List.generate(5, (i) => sixDaysAgo.add(Duration(days: i + 1)));
      
      // Tap on 1st, 2nd, and 3rd gap day to unselect them
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('${gapDates[i].day}'));
        await tester.pump();
      }

      await tester.tap(find.text('Add to remaining'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      bloc.state.maybeMap(
        loaded: (l) {
          // Base 10 + 2 selected missed days + 1 today = 13.
          expect(l.qadaStatus[Salaah.fajr]?.value, 13);
        },
        orElse: () => fail('Should be loaded'),
      );
    });

    testWidgets('Can drag to toggle multiple days', (tester) async {
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final sixDaysAgo = normalizedToday.subtract(const Duration(days: 6));

      final lastRecord = DailyRecord(
        id: 'old',
        date: sixDaysAgo,
        missedToday: {},
        completedToday: {for (var s in Salaah.values) s},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      await repo.saveToday(lastRecord);

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

      final gridFinder = find.byType(GridView);
      final Offset topLeft = tester.getTopLeft(gridFinder);
      
      await tester.dragFrom(
        topLeft + const Offset(10, 30),
        const Offset(150, 0),
      );
      await tester.pump();

      await tester.tap(find.text('Add to remaining'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      bloc.state.maybeMap(
        loaded: (l) {
          // Some days toggled off. Expect less than "all 5 added" (10+5+1=16).
          expect(l.qadaStatus[Salaah.fajr]!.value, lessThan(16)); 
        },
        orElse: () => fail('Should be loaded'),
      );
    });
  });
}
