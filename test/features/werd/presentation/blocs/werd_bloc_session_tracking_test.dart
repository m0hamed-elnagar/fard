import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWerdRepository extends Mock implements WerdRepository {}

/// This test verifies the exact user flow:
/// 1. User clicks "Continue" → Session 1 starts
/// 2. User clicks "Continue" again → Session 2 starts
/// 3. User clicks "Continue" third time → Session 3 starts
///
/// Result: Should have 3 separate sessions in Today's Reading
void main() {
  late MockWerdRepository mockRepository;
  late WerdGoal testGoal;
  late WerdProgress emptyProgress;

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
    emptyProgress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      segmentsToday: const [],
      lastReadAbsolute: null,
      sessionStartAbsolute: 1,
      lastUpdated: DateTime.now(),
      streak: 0,
      completedCycles: 0,
    );

    when(() => mockRepository.getGoal(id: any(named: 'id')))
        .thenAnswer((_) async => Result.success(testGoal));
    when(() => mockRepository.getProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) async => Result.success(emptyProgress));
    when(() => mockRepository.watchProgress(goalId: any(named: 'goalId')))
        .thenAnswer((_) => Stream.value(Result.success(emptyProgress)));
    when(() => mockRepository.updateProgress(any()))
        .thenAnswer((_) async => Result.success(null));
  });

  group('SESSION TRACKING: Continue Button Flow', () {
    
    blocTest<WerdBloc, WerdState>(
      'REAL USER FLOW: Clicking "Continue" 3 times creates 3 separate sessions',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: emptyProgress),
      setUp: () {
        var currentProgress = emptyProgress;
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId'))).thenAnswer(
          (_) async => Result.success(currentProgress),
        );
        when(() => mockRepository.updateProgress(any())).thenAnswer((invocation) async {
          currentProgress = invocation.positionalArguments[0] as WerdProgress;
          return Result.success(null);
        });
      },
      act: (bloc) {
        // Simulate user clicking "Continue" 3 times
        
        // First Continue: Starts at Al-Fatihah 1
        bloc.add(const WerdEvent.startSession(1));
        
        // Simulate reading ayahs 1-3
        for (int i = 1; i <= 3; i++) {
          bloc.add(WerdEvent.trackItemRead(i));
        }
        
        // User leaves Quran reader (session ends)
        bloc.add(const WerdEvent.endSession());
        
        // Second Continue: Starts at Al-Fatihah 4
        bloc.add(const WerdEvent.startSession(4));
        
        // Simulate reading ayahs 4-6
        for (int i = 4; i <= 6; i++) {
          bloc.add(WerdEvent.trackItemRead(i));
        }
        
        // User leaves Quran reader (session ends)
        bloc.add(const WerdEvent.endSession());
        
        // Third Continue: Starts at Al-Fatihah 7
        bloc.add(const WerdEvent.startSession(7));
        
        // Simulate reading ayahs 7-10
        for (int i = 7; i <= 10; i++) {
          bloc.add(WerdEvent.trackItemRead(i));
        }
        
        // User leaves Quran reader (session ends)
        bloc.add(const WerdEvent.endSession());
      },
      verify: (_) {
        final captured = verify(
          () => mockRepository.updateProgress(captureAny()),
        ).captured;

        print('╔════════════════════════════════════════════════════╗');
        print('🎯 SESSION TRACKING TEST RESULTS');
        print('╠════════════════════════════════════════════════════╣');
        print('updateProgress called: ${captured.length} times');
        
        if (captured.isNotEmpty) {
          final finalProgress = captured.last as WerdProgress;
          
          print('');
          print('📊 Final State:');
          print('   Total ayahs today: ${finalProgress.totalAmountReadToday}');
          print('   Sessions count: ${finalProgress.segmentsToday.length}');
          print('');
          
          if (finalProgress.segmentsToday.length == 3) {
            print('✅✅✅ SUCCESS! 3 SESSIONS CREATED ✅✅✅');
            print('');
            print('Session Details:');
            
            for (var i = 0; i < finalProgress.segmentsToday.length; i++) {
              final seg = finalProgress.segmentsToday[i];
              print('');
              print('  Session ${i + 1}:');
              print('    Ayahs: ${seg.startAyah}-${seg.endAyah} (${seg.ayahsCount} ayahs)');
              print('    Start: ${seg.formattedStartTime}');
              print('    End: ${seg.formattedEndTime}');
              if (seg.durationMinutes != null) {
                print('    Duration: ${seg.durationMinutes} min');
              }
            }
            
            print('');
            print('This is what the user will see in Today\'s Reading dialog!');
          } else {
            print('❌ FAILURE: Expected 3 sessions, got ${finalProgress.segmentsToday.length}');
            print('');
            print('Actual sessions:');
            for (var i = 0; i < finalProgress.segmentsToday.length; i++) {
              final seg = finalProgress.segmentsToday[i];
              print('  Session $i: ${seg.startAyah}-${seg.endAyah} (${seg.ayahsCount} ayahs)');
            }
          }
        }
        print('╚════════════════════════════════════════════════════╝');

        // Verify we have exactly 3 sessions
        final finalProgress = captured.last as WerdProgress;
        expect(finalProgress.segmentsToday.length, 3,
            reason: 'Should have 3 separate sessions after 3 Continue clicks');
        
        // Verify each session has correct ayah count
        expect(finalProgress.segmentsToday[0].ayahsCount, 3,
            reason: 'Session 1 should have 3 ayahs (1-3)');
        expect(finalProgress.segmentsToday[1].ayahsCount, 3,
            reason: 'Session 2 should have 3 ayahs (4-6)');
        expect(finalProgress.segmentsToday[2].ayahsCount, 4,
            reason: 'Session 3 should have 4 ayahs (7-10)');
        
        // Verify total ayah count
        expect(finalProgress.totalAmountReadToday, 10,
            reason: 'Total should be 10 ayahs (3+3+4)');
        
        // Verify each session has timestamps
        for (var i = 0; i < finalProgress.segmentsToday.length; i++) {
          final seg = finalProgress.segmentsToday[i];
          expect(seg.startTime, isNotNull,
              reason: 'Session $i should have startTime');
          expect(seg.endTime, isNotNull,
              reason: 'Session $i should have endTime (session ended)');
        }
      },
    );

    blocTest<WerdBloc, WerdState>(
      'EDGE CASE: Session without endSession should still work',
      build: () => WerdBloc(mockRepository),
      seed: () => WerdState(goal: testGoal, progress: emptyProgress),
      setUp: () {
        var currentProgress = emptyProgress;
        when(() => mockRepository.getProgress(goalId: any(named: 'goalId'))).thenAnswer(
          (_) async => Result.success(currentProgress),
        );
        when(() => mockRepository.updateProgress(any())).thenAnswer((invocation) async {
          currentProgress = invocation.positionalArguments[0] as WerdProgress;
          return Result.success(null);
        });
      },
      act: (bloc) {
        // User clicks Continue but never leaves (active session)
        bloc.add(const WerdEvent.startSession(1));
        bloc.add(const WerdEvent.trackItemRead(1));
        bloc.add(const WerdEvent.trackItemRead(2));
        // No endSession called - user is still reading
      },
      verify: (_) {
        final captured = verify(
          () => mockRepository.updateProgress(captureAny()),
        ).captured;

        print('╔════════════════════════════════════════════════════╗');
        print('🎯 ACTIVE SESSION TEST (no endSession)');
        print('╠════════════════════════════════════════════════════╣');
        
        if (captured.isNotEmpty) {
          final finalProgress = captured.last as WerdProgress;
          
          print('Sessions count: ${finalProgress.segmentsToday.length}');
          
          if (finalProgress.segmentsToday.isNotEmpty) {
            final seg = finalProgress.segmentsToday[0];
            print('Session 0:');
            print('  Ayahs: ${seg.startAyah}-${seg.endAyah} (${seg.ayahsCount} ayahs)');
            print('  Start: ${seg.formattedStartTime}');
            print('  End: ${seg.formattedEndTime}');
            
            if (seg.endTime == null) {
              print('  Status: ACTIVE (still reading)');
              print('');
              print('✅ Session is active - endTime is null as expected');
            } else {
              print('');
              print('⚠️ Session has endTime - might be auto-ended');
            }
          }
        }
        print('╚════════════════════════════════════════════════════╝');

        final finalProgress = captured.last as WerdProgress;
        expect(finalProgress.segmentsToday.length, 1);
        expect(finalProgress.segmentsToday[0].ayahsCount, 2);
        // endTime can be null if session is still active
      },
    );
  });
}
