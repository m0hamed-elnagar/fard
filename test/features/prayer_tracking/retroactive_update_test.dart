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

class MockPrayerRepo extends Mock implements PrayerRepo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late MockPrayerRepo repo;
  late PrayerTrackerBloc bloc;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(today);
    registerFallbackValue(DailyRecord(
      id: '1',
      date: today,
      missedToday: {},
      completedToday: const {},
      qada: {},
    ));
  });

  setUp(() {
    getIt.reset();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => repo.loadAllRecords()).thenAnswer((_) async => []);

    when(() => prefs.getDouble(any())).thenReturn(null);
    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
  });

  group('Retroactive Update Bug Reproduction', () {
    test('Changing yesterday prayer should impact today qada (BUG REPRO)', () async {
      // 1. Setup: Yesterday had 1 missed Fajr (Qada = 1). Today starts with Qada = 2 (1 from yesterday + 1 from today).
      final yesterdayRecord = DailyRecord(
        id: 'yesterday',
        date: yesterday,
        missedToday: {Salaah.fajr},
        completedToday: const {},
        qada: {for (var s in Salaah.values) s: s == Salaah.fajr ? const MissedCounter(1) : const MissedCounter(0)},
      );

      final todayRecord = DailyRecord(
        id: 'today',
        date: today,
        missedToday: {Salaah.fajr},
        completedToday: const {},
        qada: {for (var s in Salaah.values) s: s == Salaah.fajr ? const MissedCounter(2) : const MissedCounter(0)},
      );

      when(() => repo.loadRecord(yesterday)).thenAnswer((_) async => yesterdayRecord);
      when(() => repo.loadRecord(today)).thenAnswer((_) async => todayRecord);
      when(() => repo.loadLastRecordBefore(today)).thenAnswer((_) async => yesterdayRecord);
      when(() => repo.loadAllRecords()).thenAnswer((_) async => [todayRecord, yesterdayRecord]);

      // 2. Load yesterday
      bloc.add(PrayerTrackerEvent.load(yesterday));
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 1, orElse: () => false),
          'yesterday fajr qada is 1',
          true,
        )),
      );

      // 3. Toggle yesterday's Fajr to DONE.
      // Expectation: yesterday's Qada becomes 0, and today's Qada should eventually become 1.
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));

      // Check yesterday's state first
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 0 && l.completedToday.contains(Salaah.fajr),
            orElse: () => false,
          ),
          'yesterday fajr qada should be 0 after toggle',
          true,
        )),
      );

      // 4. Load today and check if qada rippled
      bloc.add(PrayerTrackerEvent.load(today));
      
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 1,
            orElse: () => false,
          ),
          'today fajr qada should be 1 after yesterday was fixed',
          true,
        )),
      );
    });
  });
}
