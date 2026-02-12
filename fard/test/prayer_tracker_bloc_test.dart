import 'package:bloc_test/bloc_test.dart';
import 'package:fard/domain/models/daily_record.dart';
import 'package:fard/domain/models/missed_counter.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:fard/domain/repositories/prayer_repo.dart';
import 'package:fard/presentation/blocs/prayer_tracker/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}

void main() {
  late MockPrayerRepo repo;
  late PrayerTrackerBloc bloc;
  final date = DateTime(2024, 1, 1);
  final dummyRecord = DailyRecord(
    id: '1',
    date: date,
    missedToday: {},
    qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
  );

  setUpAll(() {
    registerFallbackValue(dummyRecord);
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    repo = MockPrayerRepo();
    bloc = PrayerTrackerBloc(repo);

    // Common Stubs
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => repo.deleteRecord(any())).thenAnswer((_) async {});
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
            (s) => s.maybeMap(loaded: (l) => l.missedToday.contains(Salaah.fajr), orElse: () => false),
            'fajr toggled',
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
        'optimistic deletion clears history before reloading',
        build: () => bloc,
        seed: () => loadedStateWithHistory,
        setUp: () {
          // Return non-empty month to trigger a detectable state change on reload
          when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.deleteRecord(date)),
        expect: () => [
          // 1. Optimistic removal
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.history.isEmpty, orElse: () => false),
            'optimistic removal',
            true,
          ),
          // 2. Load event triggered: Emits loading
          const PrayerTrackerState.loading(),
          // 3. Load event initial loaded
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'loaded initial (empty month)',
            true,
          ),
          // 4. Load event month loaded
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
        'Acknowledge: reloads and emits expected states',
        build: () => bloc,
        setUp: () {
           when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {date: dummyRecord});
        },
        act: (bloc) => bloc.add(PrayerTrackerEvent.acknowledgeMissedDays(
          dates: [date],
          addAsMissed: true,
        )),
        expect: () => [
          const PrayerTrackerState.loading(),
          isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isEmpty, orElse: () => false),
            'after loading, initially empty records',
            true,
          ),
           isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (l) => l.monthRecords.isNotEmpty, orElse: () => false),
            'final state with records',
            true,
          ),
        ],
      );
    });
  });
}
