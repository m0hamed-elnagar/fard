import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/quran/domain/usecases/watch_bookmark.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWerdRepository extends Mock implements WerdRepository {}
class MockWatchBookmark extends Mock implements WatchBookmark {}

void main() {
  late MockWerdRepository mockRepository;
  late MockWatchBookmark mockWatchBookmark;
  late WerdGoal testGoal;
  late WerdProgress initialProgress;

  setUp(() {
    mockRepository = MockWerdRepository();
    mockWatchBookmark = MockWatchBookmark();
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
    when(() => mockWatchBookmark())
        .thenAnswer((_) => const Stream.empty());
  });

  group('WerdBloc Bookmark Progress Adjustment', () {
    blocTest<WerdBloc, WerdState>(
      'reduces progress when bookmark is moved backwards',
      build: () => WerdBloc(mockRepository, mockWatchBookmark),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) async {
        // 1. Move bookmark forward to Ayah 5
        bloc.add(const WerdEvent.updateBookmark(5));
        // 2. Move bookmark backward to Ayah 3
        bloc.add(const WerdEvent.updateBookmark(3));
      },
      verify: (_) {
        // Verify the first update (to 5)
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 5)
        ))).called(1);

        // Verify the second update (to 3) - this proves progress was reduced
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 3)
        ))).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'maintains 0 progress if bookmark is moved before session start',
      build: () => WerdBloc(mockRepository, mockWatchBookmark),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      act: (bloc) => bloc.add(const WerdEvent.updateBookmark(0)), // Impossible but for test
      verify: (_) {
        verify(() => mockRepository.updateProgress(any(
          that: isA<WerdProgress>().having((p) => p.totalAmountReadToday, 'totalAmountReadToday', 0)
        ))).called(1);
      },
    );
  });
}
