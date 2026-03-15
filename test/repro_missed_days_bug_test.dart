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

void main() {
  late FakePrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final threeDaysAgo = today.subtract(const Duration(days: 3));
  
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

    // Mock prefs
    when(() => prefs.getDouble('latitude')).thenReturn(30.0);
    when(() => prefs.getDouble('longitude')).thenReturn(31.0);
    when(() => prefs.getString('calculation_method')).thenReturn('muslim_league');
    when(() => prefs.getString('madhab')).thenReturn('shafi');
  });

  test('Reproduction: Clicking "I was praying" (skip) SHOULD NOT add to qada', () async {
    // 1. Setup: last record was 3 days ago with qada = 10
    final lastRecord = DailyRecord(
      id: 'last',
      date: threeDaysAgo,
      missedToday: {},
      completedToday: {for (var s in Salaah.values) s}, // All done 3 days ago
      qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
    );
    
    await repo.saveToday(lastRecord);

    final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

    // 2. Trigger acknowledgeMissedDays with empty list (Skip)
    bloc.add(const PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: []));
    
    // We need to wait for the bloc to process and eventually call load()
    await Future.delayed(const Duration(milliseconds: 1000));

    // 3. Verify the final state
    bloc.state.maybeMap(
      loaded: (s) {
        // If "I was praying" was clicked, qada for the 2 days in between should NOT be added.
        // Base = 10.
        // Today is 'today'. All prayers passed = +1 for today.
        // Expected = 11.
        
        final fajrQada = s.qadaStatus[Salaah.fajr]?.value ?? 0;

        expect(fajrQada, 11, reason: 'Should only have today\'s missed prayers added, not the skipped ones');      },
      orElse: () => fail('Should be in loaded state, but was ${bloc.state}'),
    );
  });

  test('Reproduction: Clicking "Add All" SHOULD add to qada', () async {
    // 1. Setup: last record was 3 days ago with qada = 10
    final lastRecord = DailyRecord(
      id: 'last',
      date: threeDaysAgo,
      missedToday: {},
      completedToday: {for (var s in Salaah.values) s},
      qada: {for (var s in Salaah.values) s: const MissedCounter(10)},
    );
    
    await repo.saveToday(lastRecord);

    final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

    // 2. Trigger acknowledgeMissedDays with ALL dates (Add All)
    final gapDates = <DateTime>[];
    for (int i = 1; i < 3; i++) {
      gapDates.add(threeDaysAgo.add(Duration(days: i)));
    }
    
    bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: gapDates));
    
    await Future.delayed(const Duration(milliseconds: 1000));

    // 3. Verify the final state
    bloc.state.maybeMap(
      loaded: (s) {
        // Base 10 + 2 gap days + 1 today = 13.
        final fajrQada = s.qadaStatus[Salaah.fajr]?.value ?? 0;
        
        expect(fajrQada, 13, reason: 'Should have today\'s AND gap days added to qada');
      },
      orElse: () => fail('Should be in loaded state'),
    );
  });
}
