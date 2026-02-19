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
  late PrayerTrackerBloc bloc;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final date = DateTime(2024, 1, 1);
  final dummyRecord = DailyRecord(
    id: '1',
    date: date,
    missedToday: {},
    completedToday: const {},
    qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
  );

  setUpAll(() {
    registerFallbackValue(dummyRecord);
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(Salaah.fajr);
  });

  setUp(() {
    getIt.reset();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();
    
    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

    // Common Stubs
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
    when(() => repo.loadAllRecords()).thenAnswer((_) async => []);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => repo.deleteRecord(any())).thenAnswer((_) async {});

    when(() => prefs.getDouble(any())).thenReturn(null);
    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
  });

  tearDown(() => bloc.close());

  group('PrayerTrackerBloc', () {
    test('initial state is loading', () {
      expect(bloc.state, const PrayerTrackerState.loading());
    });

    group('Load Event', () {
      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'emits [loading, loaded(initial), loaded(withMonth)]',
        build: () => bloc,
        setUp: () {
          // Return non-empty month to trigger a state change call
          when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
          when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.load(date)),
        expect: () => [
          const PrayerTrackerState.loading(),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'first loaded state is empty',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'second loaded state has month data',
            true,
          ),
        ],
      );
    });

    group('Management Actions', () {
      final initialState = PrayerTrackerState.loaded(
        selectedDate: date,
        missedToday: {},
        qadaStatus: {for (var s in Salaah.values) s: const MissedCounter(0)},
        monthRecords: {},
        history: [],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'TogglePrayer: optimistic update followed by sync reload',
        build: () => bloc,
        seed: () => initialState,
        setUp: () {
          // Mock month update after save
          when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr)),
        expect: () => [
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.completedToday.contains(Salaah.fajr), orElse: () => false),
            'fajr toggled to completed',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'month records synced after save',
            true,
          ),
        ],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'AddQada: optimistic update followed by sync reload',
        build: () => bloc,
        seed: () => initialState,
        setUp: () {
          when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(const PrayerTrackerEvent.addQada(Salaah.dhuhr)),
        expect: () => [
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.qadaStatus[Salaah.dhuhr]?.value == 1, orElse: () => false),
            'qada incremented',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'month records synced',
            true,
          ),
        ],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'RemoveQada: optimistic update followed by sync reload',
        build: () => bloc,
        seed: () => PrayerTrackerState.loaded(
          selectedDate: date,
          missedToday: {},
          qadaStatus: {for (var s in Salaah.values) s: const MissedCounter(1)},
          monthRecords: {},
          history: [],
        ),
        setUp: () {
          when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(const PrayerTrackerEvent.removeQada(Salaah.dhuhr)),
        expect: () => [
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.qadaStatus[Salaah.dhuhr]?.value == 0, orElse: () => false),
            'qada decremented',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'month records synced',
            true,
          ),
        ],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'UpdateQada: overwrites qada and syncs',
        build: () => bloc,
        seed: () => initialState,
        setUp: () {
          when(() => repo.loadMonth(any(), any()))
              .thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(const PrayerTrackerEvent.updateQada({
          Salaah.fajr: 100,
        })),
        expect: () => [
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
              loaded: (l) => l.qadaStatus[Salaah.fajr]?.value == 100,
              orElse: () => false,
            ),
            'qada updated to specific value',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'month records synced',
            true,
          ),
        ],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'LoadMonth: updates month records and history',
        build: () => bloc,
        seed: () => initialState,
        setUp: () {
          when(() => repo.loadMonth(2024, 2)).thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(const PrayerTrackerEvent.loadMonth(2024, 2)),
        expect: () => [
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
              loaded: (l) => l.monthRecords.isNotEmpty && l.history.isNotEmpty,
              orElse: () => false,
            ),
            'month loaded',
            true,
          ),
        ],
      );
    });

    group('Deletion', () {
      final loadedStateWithHistory = PrayerTrackerState.loaded(
        selectedDate: date,
        missedToday: {},
        qadaStatus: {for (var s in Salaah.values) s: const MissedCounter(0)},
        monthRecords: {date: dummyRecord},
        history: [dummyRecord],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'deletion triggers reload',
        build: () => bloc,
        seed: () => loadedStateWithHistory,
        setUp: () {
          // Return non-empty month to trigger a detectable state change on reload
          when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
          when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
          when(() => repo.loadAllRecords()).thenAnswer((_) async => []);
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.deleteRecord(date)),
        expect: () => [
          // 1. Load event triggered: Emits loading
          const PrayerTrackerState.loading(),
          // 2. Load event initial loaded
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'loaded initial (empty month)',
            true,
          ),
          // 3. Load event month loaded
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'loaded with month data',
            true,
          ),
        ],
      );
    });

    group('Missed Days Flow', () {
      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'emits missedDaysPrompt when needed',
        build: () => bloc,
        act: (bloc) {
          final longAgo = DateTime.now().subtract(const Duration(days: 5));
          when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => DailyRecord(
                id: 'old',
                date: longAgo,
                missedToday: {},
                completedToday: const {},
                qada: {},
              ));
          bloc.add(const PrayerTrackerEvent.checkMissedDays());
        },
        expect: () => [
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(missedDaysPrompt: (p) => p.missedDates.length == 4, orElse: () => false),
            'correct number of missed days',
            true,
          ),
        ],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'Acknowledge: carries over last qada balance and adds selected days',
        build: () => bloc,
        setUp: () {
          // Setup: last record had 10 Fajr
          when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => DailyRecord(
                id: 'old',
                date: date.subtract(const Duration(days: 2)),
                missedToday: {},
                completedToday: const {},
                qada: {
                  for (var s in Salaah.values)
                    s: s == Salaah.fajr ? const MissedCounter(10) : const MissedCounter(0)
                },
              ));
          when(() => repo.loadMonth(any(), any()))
              .thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(
          selectedDates: [date, date.add(const Duration(days: 1))],
        )),
        expect: () => [
          const PrayerTrackerState.loading(),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'after loading, initially empty records',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'final state with records',
            true,
          ),
        ],
        verify: (_) {
          // Should have saved a record with 10 + 2 = 12 Fajr
          final captured = verify(() => repo.saveToday(captureAny())).captured.last as DailyRecord;
          expect(captured.qada[Salaah.fajr]?.value, 12);
          // And other prayers should be 2 (starting from 0)
          expect(captured.qada[Salaah.dhuhr]?.value, 2);
        },
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'Acknowledge: reloads and emits expected states when dates selected',
        build: () => bloc,
        setUp: () {
          when(() => repo.loadMonth(any(), any()))
              .thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(
          selectedDates: [date],
        )),
        expect: () => [
          const PrayerTrackerState.loading(),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'after loading, initially empty records',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'final state with records',
            true,
          ),
        ],
      );

      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'Acknowledge: just reloads when no dates selected',
        build: () => bloc,
        setUp: () {
          when(() => repo.loadMonth(any(), any()))
              .thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(const PrayerTrackerEvent.acknowledgeMissedDays(
          selectedDates: [],
        )),
        expect: () => [
          const PrayerTrackerState.loading(),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'after loading, initially empty records',
            true,
          ),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'final state with records',
            true,
          ),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<PrayerTrackerBloc, PrayerTrackerState>(
        'Load: emits [loading, error] on repository failure',
        build: () => bloc,
        setUp: () {
          when(() => repo.loadRecord(any())).thenThrow(Exception('Failed to load'));
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.load(date)),
        expect: () => [
          const PrayerTrackerState.loading(),
          const PrayerTrackerState.error(message: 'Exception: Failed to load'),
        ],
      );
    });
  });
}
