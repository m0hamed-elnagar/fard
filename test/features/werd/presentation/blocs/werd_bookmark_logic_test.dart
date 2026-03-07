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
    
    when(() => mockRepository.getGoal(id: any(named: 'id')))
        .thenAnswer((_) async => Result.success(testGoal));
    when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) async => Result.success(initialProgress));
    when(() => mockRepository.watchProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) => Stream.value(Result.success(initialProgress)));
    when(() => mockRepository.updateProgress(any()))
        .thenAnswer((_) async => Result.success(null));
  });

  group('WerdBloc Bookmark Decoupling', () {
    blocTest<WerdBloc, WerdState>(
      'updateBookmark should NOT update progress (it is now decoupled)',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) async {
        bloc.add(const WerdEvent.updateBookmark(5));
      },
      verify: (_) {
        // Should NOT call updateProgress
        verifyNever(() => mockRepository.updateProgress(any()));
      },
    );
  });
}
