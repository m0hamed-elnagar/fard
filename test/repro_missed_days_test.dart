// ignore_for_file: avoid_print
import 'package:adhan/adhan.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePrayerRepo implements PrayerRepo {
  final Map<DateTime, DailyRecord> _records = {};

  @override
  Future<void> saveToday(DailyRecord record) async {
    _records[record.date] = record;
  }

  @override
  Future<void> deleteRecord(DateTime date) async {
    _records.remove(date);
  }

  @override
  Future<DailyRecord?> loadRecord(DateTime date) async {
    return _records[date];
  }

  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async {
    return {};
  }

  @override
  Future<Map<Salaah, int>> calculateRemaining(DateTime from, DateTime to) async {
    return {};
  }

  @override
  Future<DailyRecord?> loadLastSavedRecord() async {
    if (_records.isEmpty) return null;
    final sorted = _records.keys.toList()..sort();
    return _records[sorted.last];
  }

  @override
  Future<DailyRecord?> loadLastRecordBefore(DateTime date) async {
    final keys = _records.keys.where((k) => k.isBefore(date)).toList()..sort();
    if (keys.isEmpty) return null;
    return _records[keys.last];
  }

  @override
  Future<List<DailyRecord>> loadAllRecords() async {
    return _records.values.toList();
  }

  @override
  Future<void> importAllRecords(List<DailyRecord> records) async {
    _records.clear();
    for (final r in records) {
      _records[r.date] = r;
    }
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late FakePrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final lastOpenedDate = DateTime(2026, 3, 18);
  final gapDate1 = DateTime(2026, 3, 19);
  final gapDate2 = DateTime(2026, 3, 20);
  final today = DateTime(2026, 3, 21);

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
    repo = FakePrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    when(() => prefs.getDouble('latitude')).thenReturn(30.0);
    when(() => prefs.getDouble('longitude')).thenReturn(31.0);
    when(() => prefs.getString(any())).thenReturn(null);

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

  group('PrayerTrackerBloc - Missed Days Regression Tests', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Choosing "I was praying (All)" should mark gap days AND today\'s passed prayers as done',
      build: () {
        final lastRecord = DailyRecord(
          id: '2026-03-18',
          date: lastOpenedDate,
          missedToday: Set.from(Salaah.values),
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
        );
        repo.saveToday(lastRecord);
        return PrayerTrackerBloc(repo, prefs, prayerTimeService);
      },
      act: (bloc) => bloc.add(const PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: [])),
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            // Qada should be exactly 10 (no increments from gap or today)
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 10, reason: 'Qada for $s should remain 10');
              expect(l.completedToday.contains(s), isTrue, reason: 'Today\'s passed prayer $s should be marked as done');
            }
          },
          orElse: () => fail('Should be loaded, but was ${bloc.state}'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Choosing "Add All" should increment qada for all gap days',
      build: () {
        final lastRecord = DailyRecord(
          id: '2026-03-18',
          date: lastOpenedDate,
          missedToday: Set.from(Salaah.values),
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
        );
        repo.saveToday(lastRecord);
        return PrayerTrackerBloc(repo, prefs, prayerTimeService);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: [gapDate1, gapDate2])),
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            // Gap (2 days) + Today (passed prayers)
            // 10 + 2 (gap) + 1 (today) = 13
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 13, reason: 'Qada for $s should be 13 (10 + 2 gap + 1 today)');
            }
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Choosing selective missed days should increment Qada correctly',
      build: () {
        final lastRecord = DailyRecord(
          id: '2026-03-18',
          date: lastOpenedDate,
          missedToday: {},
          completedToday: Set.from(Salaah.values),
          qada: {for (var s in Salaah.values) s: const MissedCounter(50)},
        );
        repo.saveToday(lastRecord);
        return PrayerTrackerBloc(repo, prefs, prayerTimeService);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: [gapDate1])),
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            // gapDate1 (missed) + gapDate2 (prayed) + today (missed because selectedDates is not empty)
            // 50 + 1 (gap1) + 1 (today) = 52
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 52, reason: 'Qada for $s should be 52 (50 + 1 gap1 + 1 today)');
            }
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Handling long gaps (10 days) with Add All',
      build: () {
        final longAgo = today.subtract(const Duration(days: 11));
        final lastRecord = DailyRecord(
          id: 'long-ago',
          date: longAgo,
          missedToday: {},
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(100)},
        );
        repo.saveToday(lastRecord);
        return PrayerTrackerBloc(repo, prefs, prayerTimeService);
      },
      act: (bloc) {
        final gapDates = List.generate(10, (i) => today.subtract(Duration(days: 10 - i)));
        bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: gapDates));
      },
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            // 100 + 10 gaps + 1 today = 111
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 111);
            }
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Handling large Qada numbers (1000+) correctly',
      build: () {
        final lastRecord = DailyRecord(
          id: 'yesterday',
          date: today.subtract(const Duration(days: 2)), // Gap is 1 day (yesterday)
          missedToday: {},
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(1000)},
        );
        repo.saveToday(lastRecord);
        return PrayerTrackerBloc(repo, prefs, prayerTimeService);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: [today.subtract(const Duration(days: 1))])),
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            // 1000 + 1 gap + 1 today = 1002
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 1002);
            }
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Fallback when no location is configured',
      build: () {
        when(() => prefs.getDouble('latitude')).thenReturn(null);
        when(() => prefs.getDouble('longitude')).thenReturn(null);
        final lastRecord = DailyRecord(
          id: '2026-03-18',
          date: lastOpenedDate,
          missedToday: {},
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
        );
        repo.saveToday(lastRecord);
        return PrayerTrackerBloc(repo, prefs, prayerTimeService);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: [gapDate1, gapDate2])),
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            // 0 + 2 gaps + 1 today (all missed because not praying) = 3
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 3);
            }
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );
  });
}
