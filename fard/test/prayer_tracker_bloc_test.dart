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

  setUpAll(() {
    registerFallbackValue(DailyRecord(
      id: 'dummy',
      date: DateTime.now(),
      missedToday: {},
      qada: {},
    ));
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    repo = MockPrayerRepo();
    bloc = PrayerTrackerBloc(repo);

    // Default stubs
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    // Mock non-empty month to ensure state change
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {
          DateTime(2024, 1, 1): DailyRecord(
            id: 'dummy',
            date: DateTime(2024, 1, 1),
            missedToday: {},
            qada: {},
          )
        });
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => repo.deleteRecord(any())).thenAnswer((_) async {});
    when(() => repo.loadAllRecords()).thenAnswer((_) async => []);
  });

  tearDown(() => bloc.close());

  group('PrayerTrackerBloc', () {
    final date = DateTime(2024, 1, 1);

    test('initial state is loading', () {
      expect(bloc.state, const PrayerTrackerState.loading());
    });

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'emits [loading, loaded, loaded(month)] when Load is added',
      build: () => bloc,
      act: (bloc) => bloc.add(PrayerTrackerEvent.load(date)),
      expect: () => [
        const PrayerTrackerState.loading(),
        isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
            'first loaded state',
            true),
        isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
            'second loaded state (month updated)',
            true),
      ],
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'calls deleteRecord on repo and reloads month on DeleteRecord event',
      build: () => bloc,
      seed: () => PrayerTrackerState.loaded(
        selectedDate: date,
        missedToday: {},
        qadaStatus: {for (var s in Salaah.values) s: const MissedCounter(0)},
        monthRecords: {
          date: DailyRecord(
            id: 'dummy',
            date: date,
            missedToday: {},
            qada: {},
          )
        },
        history: [
          DailyRecord(
            id: 'dummy',
            date: date,
            missedToday: {},
            qada: {},
          )
        ],
      ),
      act: (bloc) => bloc.add(PrayerTrackerEvent.deleteRecord(date)),
      verify: (_) {
        verify(() => repo.deleteRecord(date)).called(1);
        verify(() => repo.loadMonth(date.year, date.month)).called(1);
      },
      expect: () => [
        isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(
                loaded: (l) => l.history.isEmpty, orElse: () => false),
            'optimistic delete',
            true),
        const PrayerTrackerState.loading(),
        isA<PrayerTrackerState>().having(
            (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
            'loaded after refresh',
            true),
        isA<PrayerTrackerState>(), // loaded with month
      ],
    );
  });
}
