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
    );
    initialProgress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      lastUpdated: DateTime.now(),
      streak: 0,
    );

    registerFallbackValue(testGoal);
    registerFallbackValue(initialProgress);
    
    when(() => mockRepository.getGoal(id: any(named: 'id')))
        .thenAnswer((_) async => Result.success(testGoal));
    when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) async => Result.success(initialProgress));
    when(() => mockRepository.watchProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) => Stream.value(Result.success(initialProgress)));
    when(() => mockRepository.setGoal(any()))
        .thenAnswer((_) async => Result.success(null));
    when(() => mockRepository.updateProgress(any()))
        .thenAnswer((_) async => Result.success(null));
  });

  group('WerdBloc Counting Logic', () {
    blocTest<WerdBloc, WerdState>(
      'tracks single item read',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) => bloc.add(const WerdEvent.trackItemRead(10)),
      verify: (_) {
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 1)
        ))).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'tracks range read',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) => bloc.add(const WerdEvent.trackRangeRead(1, 5)),
      verify: (_) {
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 5)
        ))).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'fills small gaps (<= 50)',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(
        goal: testGoal, 
        progress: initialProgress.copyWith(
          totalAmountReadToday: 1,
          readItemsToday: {1},
          lastReadAbsolute: 1,
        )
      ),
      act: (bloc) => bloc.add(const WerdEvent.trackItemRead(10)),
      verify: (_) {
        // Items 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 should be in the set
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 10)
        ))).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'does NOT fill large gaps (> 50)',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(
        goal: testGoal, 
        progress: initialProgress.copyWith(
          totalAmountReadToday: 1,
          readItemsToday: {1},
          lastReadAbsolute: 1,
        )
      ),
      act: (bloc) => bloc.add(const WerdEvent.trackItemRead(100)),
      verify: (_) {
        // Only item 1 and 100 should be in the set
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 2)
        ))).called(1);
      },
    );
  });
}
