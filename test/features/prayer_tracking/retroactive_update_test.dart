import 'package:bloc_test/bloc_test.dart';
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

class FakePrayerRepo extends Fake implements PrayerRepo {
  final Map<DateTime, DailyRecord> _records = {};

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<DailyRecord?> loadRecord(DateTime date) async {
    return _records[_normalize(date)];
  }

  @override
  Future<void> saveToday(DailyRecord record) async {
    _records[_normalize(record.date)] = record;
  }

  @override
  Future<DailyRecord?> loadLastRecordBefore(DateTime date) async {
    final normalized = _normalize(date);
    final before = _records.keys.where((d) => d.isBefore(normalized)).toList()
      ..sort((a, b) => b.compareTo(a));
    if (before.isEmpty) return null;
    return _records[before.first];
  }

  @override
  Future<List<DailyRecord>> loadAllRecords() async {
    return _records.values.toList();
  }

  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async {
    final result = <DateTime, DailyRecord>{};
    for (final entry in _records.entries) {
      if (entry.key.year == year && entry.key.month == month) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<DailyRecord?> loadLastSavedRecord() async {
    if (_records.isEmpty) return null;
    final sorted = _records.keys.toList()..sort((a, b) => b.compareTo(a));
    return _records[sorted.first];
  }

  @override
  Future<void> deleteRecord(DateTime date) async {
    _records.remove(_normalize(date));
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockPrayerTimes extends Mock implements PrayerTimes {}

void main() {
  late FakePrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;
  late MockPrayerTimes mockPrayerTimes;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final yesterdayRecord = DailyRecord(
    id: 'yesterday',
    date: yesterday,
    missedToday: {Salaah.fajr},
    completedToday: const {},
    qada: {
      for (var s in Salaah.values)
        s: s == Salaah.fajr ? const MissedCounter(1) : const MissedCounter(0),
    },
  );

  final todayRecord = DailyRecord(
    id: 'today',
    date: today,
    missedToday: {Salaah.fajr},
    completedToday: const {},
    qada: {
      for (var s in Salaah.values)
        s: s == Salaah.fajr ? const MissedCounter(2) : const MissedCounter(0),
    },
  );

  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(today);
    registerFallbackValue(
      DailyRecord(
        id: '1',
        date: today,
        missedToday: {},
        completedToday: const {},
        qada: {},
      ),
    );
  });

  setUp(() {
    getIt.reset();
    repo = FakePrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();
    mockPrayerTimes = MockPrayerTimes();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    when(() => prefs.getDouble('latitude')).thenReturn(25.0);
    when(() => prefs.getDouble('longitude')).thenReturn(55.0);
    when(() => prefs.getString(any())).thenReturn(null);
    when(
      () => prayerTimeService.getPrayerTimes(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        method: any(named: 'method'),
        madhab: any(named: 'madhab'),
        date: any(named: 'date'),
      ),
    ).thenReturn(mockPrayerTimes);

    when(
      () => prayerTimeService.isPassed(
        any(),
        prayerTimes: any(named: 'prayerTimes'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((invocation) {
      final salaah = invocation.positionalArguments[0] as Salaah;
      return salaah == Salaah.fajr;
    });

    // Seed initial records
    repo.saveToday(yesterdayRecord);
    repo.saveToday(todayRecord);
  });

  group('Retroactive Update Bug Reproduction', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Changing yesterday prayer should impact today qada (BUG REPRO)',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(yesterday));
        // Wait for first load to finish before toggle
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
        // Wait for toggle to finish before final load
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(PrayerTrackerEvent.load(today));
      },
      expect: () => [
        const PrayerTrackerState.loading(),
        // Load(yesterday)
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) =>
                l.qadaStatus[Salaah.fajr]?.value == 1 &&
                l.selectedDate == yesterday,
            orElse: () => false,
          ),
          'yesterday loaded with qada 1 (stage 1)',
          true,
        ),
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) =>
                l.qadaStatus[Salaah.fajr]?.value == 1 &&
                l.selectedDate == yesterday &&
                l.history.isNotEmpty,
            orElse: () => false,
          ),
          'yesterday loaded with qada 1 (stage 2 - history)',
          true,
        ),
        // Toggle(Salaah.fajr)
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) =>
                l.qadaStatus[Salaah.fajr]?.value == 0 &&
                l.selectedDate == yesterday &&
                l.completedToday.contains(Salaah.fajr),
            orElse: () => false,
          ),
          'yesterday toggled, qada becomes 0 (stage 1)',
          true,
        ),
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) =>
                l.qadaStatus[Salaah.fajr]?.value == 0 &&
                l.selectedDate == yesterday &&
                l.monthRecords.values.any(
                  (r) => r.qada[Salaah.fajr]?.value == 0,
                ),
            orElse: () => false,
          ),
          'yesterday toggled, qada becomes 0 (stage 2 - monthRecords updated)',
          true,
        ),
        // Load(today)
        const PrayerTrackerState.loading(),
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) =>
                l.qadaStatus[Salaah.fajr]?.value == 1 &&
                l.selectedDate == today,
            orElse: () => false,
          ),
          'today loaded, qada should be 1 (rippled from yesterday)',
          true,
        ),
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) =>
                l.qadaStatus[Salaah.fajr]?.value == 1 &&
                l.selectedDate == today &&
                l.history.isNotEmpty,
            orElse: () => false,
          ),
          'today loaded with qada 1 (stage 2 - history)',
          true,
        ),
      ],
    );
    group('Date Change Interaction', () {
      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'switching dates should preserve toggled state in repo',
        build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
        act: (bloc) async {
          bloc.add(PrayerTrackerEvent.load(yesterday));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(PrayerTrackerEvent.load(today));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(PrayerTrackerEvent.load(yesterday));
          await Future.delayed(const Duration(milliseconds: 200));
        },
        verify: (_) async {
          final rec = await repo.loadRecord(yesterday);
          expect(
            rec?.completedToday.contains(Salaah.fajr),
            true,
            reason: 'Yesterday should be marked as completed in repo',
          );
          expect(
            rec?.qada[Salaah.fajr]?.value,
            0,
            reason: 'Yesterday Qada should be 0 in repo',
          );
        },
      );
    });
  });
}
