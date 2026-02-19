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

    when(() => prefs.getDouble(any())).thenReturn(null);
    
    // Default: all prayers passed
    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
  });

  group('Qada Scenarios', () {
    final now = DateTime.now();
    final todayInBloc = DateTime(now.year, now.month, now.day);
    final yesterdayInBloc = todayInBloc.subtract(const Duration(days: 1));
    final dbYesterdayInBloc = todayInBloc.subtract(const Duration(days: 2));

    test('Scenario 1: Normal carry over from yesterday to today (No double counting)', () async {
      // Yesterday: Fajr was missed. Total Qada was 10.
      final lastRecord = DailyRecord(
        id: 'yesterday',
        date: yesterdayInBloc,
        missedToday: {Salaah.fajr},
        completedToday: const {},
        qada: {
          for (var s in Salaah.values) 
            s: s == Salaah.fajr ? const MissedCounter(10) : const MissedCounter(0)
        },
      );

      when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);
      when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => lastRecord);
      
      bloc.add(PrayerTrackerEvent.load(todayInBloc));

      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 11,
            orElse: () => false,
          ),
          'should be 11, not 12 (double counting) or 10 (no carry over)',
          true,
        )),
      );
    });

    test('Scenario 2: Skipping a day entirely', () async {
      // DayBeforeYesterday: 0 missed.
      // Yesterday: Missed entirely (no record).
      // Today: Fajr passed.
      final lastRecord = DailyRecord(
        id: 'db-yesterday',
        date: dbYesterdayInBloc,
        missedToday: {},
        completedToday: const {},
        qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
      );

      when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);
      when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => lastRecord);
      
      bloc.add(PrayerTrackerEvent.load(todayInBloc));

      // Qada should be: 
      // 0 (db-yesterday) 
      // + 1 (yesterday missed entirely) 
      // + 1 (today's Fajr/all passed in mock) 
      // = 2.
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 2 && l.qadaStatus[Salaah.dhuhr]?.value == 2,
            orElse: () => false,
          ),
          'should account for skipped day',
          true,
        )),
      );
    });

    test('Scenario 3: Toggling today prayer affects qada immediately', () async {
       final lastRecord = DailyRecord(
        id: 'yesterday',
        date: yesterdayInBloc,
        missedToday: {},
        completedToday: const {},
        qada: {for (var s in Salaah.values) s: const MissedCounter(5)},
      );
       when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);
       when(() => repo.loadLastRecordBefore(todayInBloc)).thenAnswer((_) async => lastRecord);

      bloc.add(PrayerTrackerEvent.load(todayInBloc));
      
      // Initial: 5 (yesterday) + 1 (today's Fajr) = 6.
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 6,
            orElse: () => false,
          ),
          'initial load 6',
          true,
        )),
      );

      // Toggle Fajr to DONE
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));

      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 5 && !l.missedToday.contains(Salaah.fajr),
            orElse: () => false,
          ),
          'toggled to done, balance is 5',
          true,
        )),
      );
      
      // Toggle Fajr back to MISSED
      bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));

      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 6 && l.missedToday.contains(Salaah.fajr),
            orElse: () => false,
          ),
          'toggled back to missed, balance is 6',
          true,
        )),
      );
    });
    
    test('Scenario 4: Loading a future date (No qada added yet)', () async {
      final tomorrow = todayInBloc.add(const Duration(days: 1));
      when(() => prayerTimeService.isPassed(any(), 
          prayerTimes: any(named: 'prayerTimes'), 
          date: tomorrow)).thenReturn(false);

      final lastRecord = DailyRecord(
        id: 'today',
        date: todayInBloc,
        missedToday: {Salaah.fajr},
        completedToday: const {},
        qada: {for (var s in Salaah.values) s: s == Salaah.fajr ? const MissedCounter(1) : const MissedCounter(0)},
      );
      when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);
      when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => lastRecord);

      bloc.add(PrayerTrackerEvent.load(tomorrow));

      await expectLater(
        bloc.stream,
        emitsThrough(isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 1 && l.missedToday.isEmpty,
            orElse: () => false,
          ),
          'tomorrow should not have missed prayers yet',
          true,
        )),
      );
    });
  });
}
