import 'package:adhan/adhan.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
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
import 'package:fard/core/services/notification_service.dart';

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
  Future<Map<Salaah, int>> calculateRemaining(
    DateTime from,
    DateTime to,
  ) async {
    return {for (var s in Salaah.values) s: 0};
  }

  @override
  Future<DailyRecord?> loadLastSavedRecord() async {
    if (_records.isEmpty) return null;
    final sorted = _records.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
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

  @override
  Future<void> importAllRecords(List<DailyRecord> records) async {
    _records.clear();
    for (final r in records) {
      final key = '${r.date.year}-${r.date.month}-${r.date.day}';
      _records[key] = r;
    }
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late FakePrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;
  late MockNotificationService notificationService;

  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final sixDaysAgo = normalizedToday.subtract(const Duration(days: 6));

  final dummyPrayerTimes = PrayerTimes(
    Coordinates(30.0, 31.0),
    DateComponents.from(today),
    CalculationMethod.muslim_world_league.getParameters(),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(
      DailyRecord(
        id: 'dummy',
        date: DateTime.now(),
        missedToday: {},
        completedToday: {},
        qada: {},
      ),
    );
    registerFallbackValue(dummyPrayerTimes);
  });

  setUp(() {
    getIt.reset();
    repo = FakePrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();
    notificationService = MockNotificationService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);
    getIt.registerSingleton<NotificationService>(notificationService);
    getIt.registerSingleton<WidgetUpdateService>(MockWidgetUpdateService());

    // Default: all prayers passed
    when(
      () => prayerTimeService.isPassed(
        any(),
        prayerTimes: any(named: 'prayerTimes'),
        date: any(named: 'date'),
      ),
    ).thenReturn(true);
    when(
      () => prayerTimeService.getPrayerTimes(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        method: any(named: 'method'),
        madhab: any(named: 'madhab'),
        date: any(named: 'date'),
      ),
    ).thenReturn(dummyPrayerTimes);

    when(() => prefs.getDouble('latitude')).thenReturn(30.0);
    when(() => prefs.getDouble('longitude')).thenReturn(31.0);
    when(
      () => prefs.getString('calculation_method'),
    ).thenReturn('muslim_league');
    when(() => prefs.getString('madhab')).thenReturn('shafi');
  });

  group('Missed Days Selection Integration', () {
    testWidgets('Can toggle specific days and correctly update Qada', (
      tester,
    ) async {
      // Gap: 6 days ago (last record) -> Today.
      // Gap days: 5, 4, 3, 2, 1 days ago (5 days in total).
      final lastRecord = DailyRecord(
        id: 'old',
        date: sixDaysAgo,
        missedToday: {},
        completedToday: {for (var s in Salaah.values) s},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      await repo.saveToday(lastRecord);

      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);

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
                        onResponse: (selected) => bloc.add(
                          PrayerTrackerEvent.acknowledgeMissedDays(
                            selectedDates: selected,
                          ),
                        ),
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

      // All days are selected by default. 5 gap days.
      // Let's unselect 3 of them.
      // Days in gap: sixDaysAgo + 1, + 2, + 3, + 4, + 5.

      final gapDates = List.generate(
        5,
        (i) => sixDaysAgo.add(Duration(days: i + 1)),
      );

      // Tap on 1st, 2nd, and 3rd gap day to unselect them
      for (int i = 0; i < 3; i++) {
        final date = gapDates[i];
        // We find the day text. Note: there might be multiple same days if it spans months,
        // but here it's 5 days, so day numbers are likely unique unless it's month end.
        // To be safe, we can use find.byType(_CalendarDayItem) and check the date.
        // But for simplicity in this test, we'll try to find by text.
        await tester.tap(find.text('${date.day}'));
        await tester.pump();
      }

      // Now only 2 days should be selected.
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Wait for BLoC processing
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      bloc.state.maybeMap(
        loaded: (l) {
          // Base 10 + 2 selected missed days + 1 today = 13.
          expect(l.qadaStatus[Salaah.fajr]?.value, 13);
        },
        orElse: () => fail('Should be loaded'),
      );

      // Verify records in repo
      for (int i = 0; i < 5; i++) {
        final date = gapDates[i];
        final record = await repo.loadRecord(date);
        expect(record, isNotNull, reason: 'Record for $date should exist');
        if (i < 3) {
          expect(
            record!.missedToday,
            isEmpty,
            reason: 'Day $i should be marked as prayed',
          );
        } else {
          expect(
            record!.missedToday,
            isNotEmpty,
            reason: 'Day $i should be marked as missed',
          );
        }
      }
    });

    testWidgets('Can drag to toggle multiple days', (tester) async {
      final lastRecord = DailyRecord(
        id: 'old',
        date: sixDaysAgo,
        missedToday: {},
        completedToday: {for (var s in Salaah.values) s},
        qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
      );
      await repo.saveToday(lastRecord);

      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);

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
                        onResponse: (selected) => bloc.add(
                          PrayerTrackerEvent.acknowledgeMissedDays(
                            selectedDates: selected,
                          ),
                        ),
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

      // Drag from the first day to the third day.
      // They are all selected by default, so dragging over them will TOGGLE them to unselected.

      final gridFinder = find.byType(GridView);
      final Offset topLeft = tester.getTopLeft(gridFinder);

      // We want to drag across the first 3 items in the first row.
      // Item size is roughly itemWidth x 60.0.
      // constraints.maxWidth / 7 is itemWidth.
      // Let's just drag horizontally from topLeft + small offset.

      await tester.dragFrom(
        topLeft + const Offset(10, 30), // Start in first item
        const Offset(150, 0), // Drag right through next items
      );
      await tester.pump();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      bloc.state.maybeMap(
        loaded: (l) {
          // Some days should have been unselected.
          // Since they are toggled, and they were all selected, some are now 0.
          // 10 (base) + (5 - unselected_count) + 1 (today)
          // We expect at least 1 or 2 to be unselected.
          expect(l.qadaStatus[Salaah.fajr]!.value, lessThan(16));
        },
        orElse: () => fail('Should be loaded'),
      );
    });
  });
}
