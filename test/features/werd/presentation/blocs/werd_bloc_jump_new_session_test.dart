import 'package:fard/features/werd/domain/entities/reading_segment.dart';
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

  setUpAll(() {
    registerFallbackValue(WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      segmentsToday: const [],
      lastUpdated: DateTime.now(),
      streak: 0,
    ));
    registerFallbackValue(WerdGoal(
      id: 'default',
      type: WerdGoalType.fixedAmount,
      value: 20,
      unit: WerdUnit.ayah,
      startDate: DateTime.now(),
      startAbsolute: 1,
    ));
  });

  setUp(() {
    mockRepository = MockWerdRepository();
    testGoal = WerdGoal(
      id: 'default',
      type: WerdGoalType.fixedAmount,
      value: 20,
      unit: WerdUnit.ayah,
      startDate: DateTime.now(),
      startAbsolute: 1,
    );
    // Initial progress with 10 ayahs read (1-10)
    initialProgress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 10,
      segmentsToday: [
        ReadingSegment(
          startAyah: 1,
          endAyah: 10,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        )
      ],
      lastReadAbsolute: 10,
      sessionStartAbsolute: 1,
      lastUpdated: DateTime.now(),
      streak: 1,
      completedCycles: 0,
    );

    when(() => mockRepository.getGoal(id: any(named: 'id')))
        .thenAnswer((_) async => Result.success(testGoal));
    when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) async => Result.success(initialProgress));
    when(() => mockRepository.watchProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) => Stream.value(Result.success(initialProgress)));
    when(() => mockRepository.updateProgress(any()))
        .thenAnswer((_) async => Result.success(null));
  });

  group('WerdBloc: Jump to New Session', () {
    blocTest<WerdBloc, WerdState>(
      'should update lastReadAbsolute and sessionStartAbsolute without counting the jump ayah immediately',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      setUp: () {
        var currentProgress = initialProgress;
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId'))).thenAnswer(
          (_) async => Result.success(currentProgress),
        );
        when(() => mockRepository.updateProgress(any())).thenAnswer((invocation) async {
          currentProgress = invocation.positionalArguments[0] as WerdProgress;
          return Result.success(null);
        });
      },
      act: (bloc) => bloc.add(const WerdEvent.jumpToNewSession(100)),
      expect: () => [
        isA<WerdState>().having(
          (s) => s.progress?.lastReadAbsolute,
          'lastReadAbsolute',
          100,
        ).having(
          (s) => s.progress?.sessionStartAbsolute,
          'sessionStartAbsolute',
          100,
        ).having(
          (s) => s.progress?.totalAmountReadToday,
          'totalAmountReadToday',
          10, // Unchanged! Correct.
        ),
      ],
    );

    blocTest<WerdBloc, WerdState>(
      'subsequent trackItemRead after jump should count 1 ayah (the new mark)',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: initialProgress),
      setUp: () {
        var currentProgress = initialProgress;
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId'))).thenAnswer(
          (_) async => Result.success(currentProgress),
        );
        when(() => mockRepository.updateProgress(any())).thenAnswer((invocation) async {
          currentProgress = invocation.positionalArguments[0] as WerdProgress;
          return Result.success(null);
        });
      },
      act: (bloc) async {
        bloc.add(const WerdEvent.jumpToNewSession(100));
        await Future.delayed(Duration.zero);
        bloc.add(const WerdEvent.trackItemRead(101));
      },
      skip: 1, // Skip state from jumpToNewSession
      expect: () => [
        isA<WerdState>().having(
          (s) => s.progress?.totalAmountReadToday,
          'totalAmountReadToday',
          11, // 10 initial + 1 (new ayah at 101)
        ),
      ],
    );

    blocTest<WerdBloc, WerdState>(
      'jumpToNewSession should end previous active session and NOT add a new one yet',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(
        goal: testGoal,
        progress: initialProgress.copyWith(
          segmentsToday: [
            ReadingSegment(
              startAyah: 1,
              endAyah: 10,
              startTime: DateTime.now(),
              // No endTime = active
            )
          ],
        ),
      ),
      setUp: () {
        var currentProgress = initialProgress.copyWith(
          segmentsToday: [
            ReadingSegment(
              startAyah: 1,
              endAyah: 10,
              startTime: DateTime.now(),
            )
          ],
        );
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(currentProgress));
        when(() => mockRepository.updateProgress(any())).thenAnswer((invocation) async {
          currentProgress = invocation.positionalArguments[0] as WerdProgress;
          return Result.success(null);
        });
      },
      act: (bloc) => bloc.add(const WerdEvent.jumpToNewSession(500)),
      expect: () => [
        isA<WerdState>().having(
          (s) => s.progress?.lastReadAbsolute,
          'lastReadAbsolute',
          500,
        ),
      ],
      verify: (bloc) {
        final progress = bloc.state.progress!;
        // Should have ONE ended segment: [1, 10]
        expect(progress.segmentsToday.length, 1);
        expect(progress.segmentsToday[0].endTime, isNotNull);
      },
    );
  });
}

