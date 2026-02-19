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
  final date = DateTime(now.year, now.month, now.day);
  
  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(DailyRecord(
      id: '1',
      date: date,
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

    when(() => prefs.getDouble(any())).thenReturn(null);
    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenAnswer((invocation) {
          final d = invocation.namedArguments[#date] as DateTime?;
          final s = invocation.positionalArguments[0] as Salaah;
          if (d != null) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final normalized = DateTime(d.year, d.month, d.day);
            if (normalized.isBefore(today)) return true;
            if (normalized.isAtSameMomentAs(today)) {
              // For testing purposes, assume Fajr has passed today
              if (s == Salaah.fajr) return true;
            }
          }
          return false;
        });
  });

  group('Reproduction: Toggle affecting Qada', () {
    test('Toggle should increment/decrement Qada based on missedToday state', () async {
      // 1. Setup: Record exists where Fajr was MISSED. Qada for Fajr is 1.
      final existingRecord = DailyRecord(
        id: '2024-01-01',
        date: date,
        missedToday: {Salaah.fajr},
        completedToday: const {},
        qada: {
          Salaah.fajr: const MissedCounter(1),
          Salaah.dhuhr: const MissedCounter(0),
          Salaah.asr: const MissedCounter(0),
          Salaah.maghrib: const MissedCounter(0),
          Salaah.isha: const MissedCounter(0),
        },
      );

      when(() => repo.loadRecord(date)).thenAnswer((_) async => existingRecord);
      
      bloc.add(PrayerTrackerEvent.load(date));
      
      // Wait for load to complete
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(loaded: (l) => l.missedToday.contains(Salaah.fajr), orElse: () => false),
          'initial load has fajr missed',
          true,
        )),
      );

      // 2. Action: Toggle Fajr (it was missed, now mark as PRAYED)
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));

      // 3. Expectation: missedToday should NOT contain fajr, and Qada should be 0
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => !l.missedToday.contains(Salaah.fajr) && l.qadaStatus[Salaah.fajr]?.value == 0,
            orElse: () => false,
          ),
          'fajr prayed, qada decremented',
          true,
        )),
      );
    });

    test('Past date toggle: should only affect missedToday for that date, not today\'s qada', () async {
      final pastDate = DateTime(2023, 12, 31);
      
      // Setup: No existing record for past date
      when(() => repo.loadRecord(pastDate)).thenAnswer((_) async => null);
      // Assume Fajr was already marked as missed elsewhere
      when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => DailyRecord(
        id: 'last',
        date: pastDate.subtract(const Duration(days: 1)),
        missedToday: {},
        completedToday: const {},
        qada: {Salaah.fajr: const MissedCounter(10)},
      ));
      when(() => repo.loadLastRecordBefore(pastDate)).thenAnswer((_) async => DailyRecord(
        id: 'last',
        date: pastDate.subtract(const Duration(days: 1)),
        missedToday: {},
        completedToday: const {},
        qada: {Salaah.fajr: const MissedCounter(10)},
      ));

      bloc.add(PrayerTrackerEvent.load(pastDate));
      
      // Wait for load to complete
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.missedToday.contains(Salaah.fajr) && l.qadaStatus[Salaah.fajr]?.value == 11,
            orElse: () => false,
          ),
          'past date defaults to missed, but Qada stays at base 11 (10 carried + 1 newly missed)',
          true,
        )),
      );

      // Now toggle Fajr to PRAYED on that past date
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));

      // Check result: Fajr missedToday should be false, and Qada should REMAIN at 11
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => !l.missedToday.contains(Salaah.fajr) && l.qadaStatus[Salaah.fajr]?.value == 11,
            orElse: () => false,
          ),
          'fajr marked as prayed on past date, qada remains unchanged at 11',
          true,
        )),
      );
    });
  });
}
