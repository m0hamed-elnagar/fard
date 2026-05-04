import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockWerdRepository extends Mock implements WerdRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockWerdRepository mockRepository;
  late MockNotificationService mockNotificationService;
  late WerdGoal testGoal;

  setUp(() {
    mockRepository = MockWerdRepository();
    mockNotificationService = MockNotificationService();
    testGoal = WerdGoal(
      id: 'default',
      type: WerdGoalType.fixedAmount,
      value: 10,
      unit: WerdUnit.ayah,
      startDate: DateTime.now(),
      startAbsolute: 1,
    );

    registerFallbackValue(testGoal);
    registerFallbackValue(
      WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
    );

    when(() => mockRepository.getGoal(id: any(named: 'id')))
        .thenAnswer((_) async => Result.success(testGoal));
    when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) async => Result.success(
              WerdProgress(
                goalId: 'default',
                totalAmountReadToday: 0,
                lastReadAbsolute: null,
                lastUpdated: DateTime.now(),
                streak: 0,
              ),
            ));
    when(() => mockRepository.watchProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) => Stream.value(Result.success(
              WerdProgress(
                goalId: 'default',
                totalAmountReadToday: 0,
                lastReadAbsolute: null,
                lastUpdated: DateTime.now(),
                streak: 0,
              ),
            )));
    when(() => mockRepository.setGoal(any()))
        .thenAnswer((_) async => Result.success(null));
    when(() => mockRepository.updateProgress(any()))
        .thenAnswer((_) async => Result.success(null));
  });

  group('Jump Dialog - Mark All Range Tracking', () {
    blocTest<WerdBloc, WerdState>(
      'jump from 100 to 6236: mark all creates segment 101-6236, total = 6136',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 5,
                    lastReadAbsolute: 100,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 96, endAyah: 100),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 2,
                  ),
                ));
      },
      act: (bloc) => bloc.add(
        const WerdEvent.trackItemReadMarkAll(
          startAbsolute: 101,
          endAbsolute: 6236,
        ),
      ),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.totalAmountReadToday, 'total', 6141)
                  .having(
                    (p) => p.segmentsToday,
                    'segments',
                    const [ReadingSegment(startAyah: 96, endAyah: 6236)],
                  )
                  .having((p) => p.lastReadAbsolute, 'lastRead', 6236),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'jump from 6100 to 6236: mark all creates segment 6101-6236, total = 186',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 50,
                    lastReadAbsolute: 6100,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 6051, endAyah: 6100),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 5,
                  ),
                ));
      },
      act: (bloc) => bloc.add(
        const WerdEvent.trackItemReadMarkAll(
          startAbsolute: 6101,
          endAbsolute: 6236,
        ),
      ),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.totalAmountReadToday, 'total', 186)
                  .having(
                    (p) => p.segmentsToday,
                    'segments',
                    const [ReadingSegment(startAyah: 6051, endAyah: 6236)],
                  ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'jump from 1 to 6236: mark all creates segment 1-6236 (entire Quran)',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 0,
                    lastReadAbsolute: 1,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 1, endAyah: 1),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 0,
                  ),
                ));
      },
      act: (bloc) => bloc.add(
        const WerdEvent.trackItemReadMarkAll(
          startAbsolute: 1,
          endAbsolute: 6236,
        ),
      ),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.totalAmountReadToday, 'total', 6236)
                  .having(
                    (p) => p.segmentsToday,
                    'segments',
                    const [ReadingSegment(startAyah: 1, endAyah: 6236)],
                  ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'jump from 6000 to 6236: mark all adds 236 ayahs',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 50,
                    lastReadAbsolute: 6000,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 5951, endAyah: 6000),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 3,
                  ),
                ));
      },
      act: (bloc) => bloc.add(
        const WerdEvent.trackItemReadMarkAll(
          startAbsolute: 6001,
          endAbsolute: 6236,
        ),
      ),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.totalAmountReadToday, 'total', 286)
                  .having(
                    (p) => p.segmentsToday,
                    'segments',
                    const [ReadingSegment(startAyah: 5951, endAyah: 6236)],
                  ),
            ),
          ),
        ).called(1);
      },
    );
  });

  // NOTE: "New Session" option was removed from Jump Dialog UI
  // Only "Mark All" and "Dismiss" remain
  // The following test is kept as documentation but is disabled

  /*
  group('Jump Dialog - New Session Tracking (DISABLED)', () {
    blocTest<WerdBloc, WerdState>(
      'new session at 6236: tracks only ayah 6236, total = 1 [DISABLED]',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      // Test disabled - trackItemReadWithNewSession event no longer exists
    );
  });
  */

  group('Cycle Completion - State Updates', () {
    blocTest<WerdBloc, WerdState>(
      'after restart: lastReadAbsolute = 1, totalAmountReadToday = 0',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 100,
                    lastReadAbsolute: 6236,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 6137, endAyah: 6236),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 10,
                    completedCycles: 0,
                  ),
                ));
      },
      act: (bloc) => bloc.add(const WerdEvent.completeCycleAndRestart()),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.lastReadAbsolute, 'lastRead', 1)
                  .having((p) => p.totalAmountReadToday, 'total', 0)
                  .having((p) => p.segmentsToday, 'segments', isEmpty)
                  .having((p) => p.completedCycles, 'cycles', 1),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'after stay: lastReadAbsolute = 6236, totalAmountReadToday = 0',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 100,
                    lastReadAbsolute: 6236,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 6137, endAyah: 6236),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 10,
                    completedCycles: 0,
                  ),
                ));
      },
      act: (bloc) => bloc.add(const WerdEvent.completeCycleStayHere()),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.lastReadAbsolute, 'lastRead', 6236)
                  .having((p) => p.totalAmountReadToday, 'total', 0)
                  .having((p) => p.segmentsToday, 'segments', isEmpty)
                  .having((p) => p.completedCycles, 'cycles', 1),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WerdBloc, WerdState>(
      'second cycle completion: completedCycles = 2',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 100,
                    lastReadAbsolute: 6236,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 6137, endAyah: 6236),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 10,
                    completedCycles: 1,
                  ),
                ));
      },
      act: (bloc) => bloc.add(const WerdEvent.completeCycleAndRestart()),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.completedCycles, 'cycles', 2)
                  .having((p) => p.lastReadAbsolute, 'lastRead', 1),
            ),
          ),
        ).called(1);
      },
    );
  });

  group('Edge Cases - Boundary Conditions', () {
    blocTest<WerdBloc, WerdState>(
      'jump from 6185 to 6236 (51 ayah gap): mark all tracks 51 ayahs',
      build: () => WerdBloc(mockRepository, mockNotificationService),
      setUp: () {
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
            .thenAnswer((_) async => Result.success(
                  WerdProgress(
                    goalId: 'default',
                    totalAmountReadToday: 50,
                    lastReadAbsolute: 6185,
                    segmentsToday: const [
                      ReadingSegment(startAyah: 6136, endAyah: 6185),
                    ],
                    lastUpdated: DateTime.now(),
                    streak: 5,
                  ),
                ));
      },
      act: (bloc) => bloc.add(
        const WerdEvent.trackItemReadMarkAll(
          startAbsolute: 6186,
          endAbsolute: 6236,
        ),
      ),
      verify: (_) {
        verify(
          () => mockRepository.updateProgress(
            any(
              that: isA<WerdProgress>()
                  .having((p) => p.totalAmountReadToday, 'total', 101)
                  .having(
                    (p) => p.segmentsToday,
                    'segments',
                    const [ReadingSegment(startAyah: 6136, endAyah: 6236)],
                  ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
