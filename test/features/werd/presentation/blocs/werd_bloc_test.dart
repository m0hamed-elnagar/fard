import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWerdRepository extends Mock implements WerdRepository {}

void main() {
  late MockWerdRepository mockRepository;
  late WerdGoal testGoal;
  late WerdProgress initialProgress;

  setUp(() {
    mockRepository = MockWerdRepository();
    testGoal = WerdGoal(
      id: 'default',
      type: WerdGoalType.fixedAmount,
      value: 10,
      unit: WerdUnit.ayah,
      startDate: DateTime.now(),
      startAbsolute: 1,
    );
    initialProgress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      sessionStartAbsolute: 1,
      lastUpdated: DateTime.now(),
      streak: 0,
    );

    registerFallbackValue(testGoal);
    registerFallbackValue(initialProgress);

    when(
      () => mockRepository.getGoal(id: any(named: 'id')),
    ).thenAnswer((_) async => Result.success(testGoal));
    when(
      () => mockRepository.getProgress(goalId: any(named: 'goalId')),
    ).thenAnswer((_) async => Result.success(initialProgress));
    when(
      () => mockRepository.watchProgress(goalId: any(named: 'goalId')),
    ).thenAnswer((_) => Stream.value(Result.success(initialProgress)));
    when(
      () => mockRepository.setGoal(any()),
    ).thenAnswer((_) async => Result.success(null));
    when(
      () => mockRepository.updateProgress(any()),
    ).thenAnswer((_) async => Result.success(null));
  });

  group('WerdBloc Counting Logic (Linear)', () {
    blocTest<WerdBloc, WerdState>(
      'tracks single item read (distance from start)',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) => bloc.add(const WerdEvent.trackItemRead(10)),
      verify: (_) {
        // Linear distance: 10 - 1 + 1 = 10
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>().having(
                (p) => p.totalAmountReadToday,
                'totalAmountReadToday',
                10,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'tracks range read (end distance from start)',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) => bloc.add(const WerdEvent.trackRangeRead(1, 5)),
      verify: (_) {
        // Linear distance: 5 - 1 + 1 = 5
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>().having(
                (p) => p.totalAmountReadToday,
                'totalAmountReadToday',
                5,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'maintains distance even with gaps',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(
        goal: testGoal,
        progress: initialProgress.copyWith(
          totalAmountReadToday: 1,
          readItemsToday: {1},
          lastReadAbsolute: 1,
        ),
      ),
      act: (bloc) => bloc.add(const WerdEvent.trackItemRead(100)),
      verify: (_) {
        // Linear distance: 100 - 1 + 1 = 100
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>().having(
                (p) => p.totalAmountReadToday,
                'totalAmountReadToday',
                100,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'does not count progress if reading before session start',
      build: () {
        final specialProgress = initialProgress.copyWith(
          sessionStartAbsolute: 100,
          totalAmountReadToday: 0,
          lastReadAbsolute: null,
        );
        when(
          () => mockRepository.getProgress(goalId: any(named: 'goalId')),
        ).thenAnswer((_) async => Result.success(specialProgress));
        return WerdBloc(mockRepository);
      },
      seed: () => WerdState(
        goal: testGoal,
        progress: initialProgress.copyWith(
          sessionStartAbsolute: 100,
          totalAmountReadToday: 0,
          lastReadAbsolute: null,
        ),
      ),
      act: (bloc) => bloc.add(const WerdEvent.trackItemRead(50)),
      verify: (_) {
        // 50 < 100, so newTotal remains 0 (no backward progress counting distance)
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>().having(
                (p) => p.totalAmountReadToday,
                'totalAmountReadToday',
                0,
              ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
