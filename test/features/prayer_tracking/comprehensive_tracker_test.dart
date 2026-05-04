import 'package:fard/core/services/notification_service.dart';
import 'package:adhan/adhan.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePrayerRepo implements PrayerRepo {
  final Map<DateTime, DailyRecord> db = {};

  @override
  Future<void> saveToday(DailyRecord record) async {
    final normalizedDate = DateTime(
      record.date.year,
      record.date.month,
      record.date.day,
    );
    db[normalizedDate] = record;
  }

  @override
  Future<DailyRecord?> loadRecord(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return db[normalizedDate];
  }

  @override
  Future<DailyRecord?> loadLastSavedRecord() async {
    if (db.isEmpty) return null;
    final keys = db.keys.toList()..sort((a, b) => b.compareTo(a));
    return db[keys.first];
  }

  @override
  Future<DailyRecord?> loadLastRecordBefore(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final before = db.keys.where((k) => k.isBefore(normalizedDate)).toList()
      ..sort((a, b) => a.compareTo(b));
    if (before.isEmpty) return null;
    return db[before.last];
  }

  @override
  Future<List<DailyRecord>> loadAllRecords() async {
    return db.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> importAllRecords(List<DailyRecord> records) async {
    db.clear();
    for (final r in records) {
      final normalizedDate = DateTime(r.date.year, r.date.month, r.date.day);
      db[normalizedDate] = r;
    }
  }

  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async {
    final Map<DateTime, DailyRecord> monthData = {};
    db.forEach((date, record) {
      if (date.year == year && date.month == month) {
        monthData[date] = record;
      }
    });
    return monthData;
  }

  @override
  Future<void> deleteRecord(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    db.remove(normalizedDate);
  }

  @override
  Future<Map<Salaah, int>> calculateRemaining(
    DateTime from,
    DateTime to,
  ) async {
    return {for (var s in Salaah.values) s: 0};
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late FakePrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;
  late MockNotificationService notificationService;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dby = today.subtract(const Duration(days: 2));

  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(today);
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

    when(() => prefs.getDouble('latitude')).thenReturn(30.0);
    when(() => prefs.getDouble('longitude')).thenReturn(31.0);

    final dummyTimes = PrayerTimes(
      Coordinates(30.0, 31.0),
      DateComponents.from(today),
      CalculationMethod.muslim_world_league.getParameters(),
    );

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
    ).thenReturn(dummyTimes);

    when(
      () => notificationService.cancelPrayerReminder(
        any(),
        forTodayOnly: any(named: 'forTodayOnly'),
      ),
    ).thenAnswer((_) async {});

  });

  group('PrayerTrackerBloc Comprehensive Tests', () {
    test('Scenario 1: Retroactive toggle ripples forward correctly', () async {
      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);

      await repo.saveToday(
        DailyRecord(
          id: 'dby',
          date: dby,
          missedToday: {},
          completedToday: Set.from(Salaah.values),
          qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
        ),
      );
      await repo.saveToday(
        DailyRecord(
          id: 'yesterday',
          date: yesterday,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {
            for (var s in Salaah.values)
              s: s == Salaah.fajr
                  ? const MissedCounter(1)
                  : const MissedCounter(0),
          },
        ),
      );
      await repo.saveToday(
        DailyRecord(
          id: 'today',
          date: today,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {
            for (var s in Salaah.values)
              s: s == Salaah.fajr
                  ? const MissedCounter(2)
                  : const MissedCounter(0),
          },
        ),
      );

      bloc.add(PrayerTrackerEvent.load(yesterday));
      await Future.delayed(const Duration(milliseconds: 500));
      print('DEBUG TEST: State after load is ${bloc.state}');

      print('DEBUG TEST: Toggling Fajr for yesterday');
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
      await Future.delayed(const Duration(seconds: 2));

      print('DEBUG TEST: State after toggle is ${bloc.state}');
      final todayRecord = await repo.loadRecord(today);
      print('DEBUG TEST: Today qada is ${todayRecord?.qada[Salaah.fajr]?.value}');
      expect(
        todayRecord?.qada[Salaah.fajr]?.value,
        1,
        reason: 'Today qada should ripple down to 1',
      );
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Scenario 2: Cascading across multi-day gaps', () async {
      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);
      final d1 = today.subtract(const Duration(days: 10));
      final d5 = today.subtract(const Duration(days: 5));

      // Seed data:
      // d1 has 1 missed Fajr. Qada = 1.
      // Mark as MISSED explicitly so cascade logic sees it correctly.
      await repo.saveToday(
        DailyRecord(
          id: 'd1',
          date: d1,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {Salaah.fajr: const MissedCounter(1)},
        ),
      );
      // Gaps d2, d3, d4 = 3 days missed. d5 total qada = 1 (d1) + 3 (gaps) = 4.
      await repo.saveToday(
        DailyRecord(
          id: 'd5',
          date: d5,
          missedToday: {},
          completedToday: Set.from(Salaah.values),
          qada: {Salaah.fajr: const MissedCounter(4)},
        ),
      );
      // Gaps d6, d7, d8, d9 = 4 days missed. today.qada = 4 + 4 + 1 (missed today) = 9.
      await repo.saveToday(
        DailyRecord(
          id: 'today',
          date: today,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {Salaah.fajr: const MissedCounter(9)},
        ),
      );

      bloc.add(PrayerTrackerEvent.load(d1));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
            'loaded',
            true,
          ),
        ),
      );

      // Toggle d1 Fajr to DONE.
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
              loaded: (l) => !l.missedToday.contains(Salaah.fajr),
              orElse: () => false,
            ),
            'toggle complete',
            true,
          ),
        ),
      );

      // Cascade is triggered.
      // d1 qada: 0.
      // gaps (3): 3.
      // d5 qada: 3.
      // gaps (4): 7.
      // today missed (1): 8.

      // Wait for all saves to finish (cascade may take time)
      await Future.delayed(const Duration(seconds: 3));

      final r5 = await repo.loadRecord(d5);
      final rToday = await repo.loadRecord(today);

      expect(r5?.qada[Salaah.fajr]?.value, 3, reason: 'd1:0 + 3 gaps = 3');
      expect(
        rToday?.qada[Salaah.fajr]?.value,
        8,
        reason: 'd5:3 + 4 gaps + today:1 = 8',
      );
    });

    test('Scenario 3: Manual Qada addition ripples forward', () async {
      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);
      await repo.saveToday(
        DailyRecord(
          id: 'yesterday',
          date: yesterday,
          missedToday: {},
          completedToday: Set.from(Salaah.values),
          qada: {Salaah.fajr: const MissedCounter(0)},
        ),
      );
      await repo.saveToday(
        DailyRecord(
          id: 'today',
          date: today,
          missedToday: {},
          completedToday: Set.from(Salaah.values),
          qada: {Salaah.fajr: const MissedCounter(1)},
        ),
      ); // 1 gap

      bloc.add(PrayerTrackerEvent.load(yesterday));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
            'loaded',
            true,
          ),
        ),
      );

      bloc.add(const PrayerTrackerEvent.addQada(Salaah.fajr));
      // Wait for state update and cascade to finish
      await Future.delayed(const Duration(seconds: 3));

      final rToday = await repo.loadRecord(today);
      expect(
        rToday?.qada[Salaah.fajr]?.value,
        2,
        reason: 'Manual addition should ripple to today',
      );
    });

    test('Scenario 4: Deleting a past record re-bases and ripples', () async {
      final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);

      await repo.saveToday(
        DailyRecord(
          id: 'd1',
          date: dby,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {Salaah.fajr: const MissedCounter(1)},
        ),
      );
      await repo.saveToday(
        DailyRecord(
          id: 'd2',
          date: yesterday,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {Salaah.fajr: const MissedCounter(2)},
        ),
      );
      await repo.saveToday(
        DailyRecord(
          id: 'dToday',
          date: today,
          missedToday: {Salaah.fajr},
          completedToday: Set.from(
            Salaah.values.where((s) => s != Salaah.fajr),
          ),
          qada: {Salaah.fajr: const MissedCounter(3)},
        ),
      );

      bloc.add(PrayerTrackerEvent.load(today));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
            'loaded',
            true,
          ),
        ),
      );

      bloc.add(PrayerTrackerEvent.deleteRecord(dby));

      // Wait for re-load state which happens after delete cascade
      await Future.delayed(const Duration(seconds: 3));

      final rYesterday = await repo.loadRecord(yesterday);
      final rToday = await repo.loadRecord(today);

      expect(
        rYesterday?.qada[Salaah.fajr]?.value,
        1,
        reason: 'Yesterday should be re-based to 1',
      );
      expect(
        rToday?.qada[Salaah.fajr]?.value,
        2,
        reason: 'Today should ripple to 2',
      );
    });
  });
}
