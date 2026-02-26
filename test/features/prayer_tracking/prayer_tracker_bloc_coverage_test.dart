import 'package:adhan/adhan.dart';
import 'package:bloc_test/bloc_test.dart';
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
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final today = DateTime(2026, 2, 26);
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
    getIt.pushNewScope();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    // Default stubs
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => repo.loadAllRecords()).thenAnswer((_) async => []);
    when(() => repo.deleteRecord(any())).thenAnswer((_) async {});
    
    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
    when(() => prayerTimeService.isUpcoming(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
    when(() => prayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(dummyPrayerTimes);
  });

  tearDown(() {
    getIt.popScope();
  });

  group('PrayerTrackerBloc - Edge Cases', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Load when no previous record exists and all prayers passed',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      setUp: () {
        when(() => prayerTimeService.isPassed(any(), 
            prayerTimes: any(named: 'prayerTimes'), 
            date: any(named: 'date'))).thenReturn(true);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.load(today)),
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            expect(l.missedToday.length, Salaah.values.length);
            for (var s in Salaah.values) {
              expect(l.qadaStatus[s]?.value, 1);
            }
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Delete record should trigger cascade update',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      setUp: () {
        final r1 = DailyRecord(
          id: '2026-02-25',
          date: DateTime(2026, 2, 25),
          missedToday: {},
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(5)},
        );
        final r2 = DailyRecord(
          id: '2026-02-27',
          date: DateTime(2026, 2, 27),
          missedToday: {Salaah.fajr},
          completedToday: {},
          qada: {for (var s in Salaah.values) s: const MissedCounter(6)},
        );
        when(() => repo.loadAllRecords()).thenAnswer((_) async => [r2, r1]);
        when(() => repo.loadLastRecordBefore(r2.date)).thenAnswer((_) async => r1);
      },
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(today));
        await Future.delayed(Duration.zero);
        bloc.add(PrayerTrackerEvent.deleteRecord(DateTime(2026, 2, 26)));
      },
      verify: (bloc) {
        verify(() => repo.deleteRecord(any())).called(1);
        verify(() => repo.saveToday(any())).called(greaterThan(0));
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'History should be sorted descending by date',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      setUp: () {
        final r1 = DailyRecord(
          id: '2026-02-24',
          date: DateTime(2026, 2, 24),
          missedToday: {},
          completedToday: {},
          qada: {},
        );
        final r2 = DailyRecord(
          id: '2026-02-25',
          date: DateTime(2026, 2, 25),
          missedToday: {},
          completedToday: {},
          qada: {},
        );
        when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {
          DateTime(2026, 2, 24): r1,
          DateTime(2026, 2, 25): r2,
        });
      },
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(today));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.loadMonth(2026, 2));
      },
      skip: 1, // Skip initial load
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            expect(l.history.length, 2);
            expect(l.history[0].date, DateTime(2026, 2, 25));
            expect(l.history[1].date, DateTime(2026, 2, 24));
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Acknowledge missed days should bulk add correctly',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(
        selectedDates: [DateTime(2026, 2, 24), DateTime(2026, 2, 25)],
      )),
      verify: (bloc) {
        verify(() => repo.saveToday(any())).called(1);
        // It triggers a load at the end
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Check missed days should emit prompt if gap > 1 day',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      setUp: () {
        final lastRecord = DailyRecord(
          id: 'gap-record',
          date: DateTime.now().subtract(const Duration(days: 3)),
          missedToday: {},
          completedToday: {},
          qada: {},
        );
        when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastRecord);
      },
      act: (bloc) => bloc.add(const PrayerTrackerEvent.checkMissedDays()),
      expect: () => [
        predicate<PrayerTrackerState>((s) => s.maybeMap(
          missedDaysPrompt: (p) => p.missedDates.length == 2,
          orElse: () => false,
        )),
      ],
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Remove Qada when already at zero should not go negative',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(today));
        await Future.delayed(Duration.zero);
        bloc.add(const PrayerTrackerEvent.removeQada(Salaah.fajr));
      },
      skip: 1,
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            expect(l.qadaStatus[Salaah.fajr]?.value, 0);
          },
          orElse: () => fail('Should be loaded'),
        );
      },
    );
  });
}
