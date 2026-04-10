import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'dart:io';

/// Real integration test that verifies session tracking with actual repository
/// Tests the complete flow: Save → Load → Verify sessions are separate
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SESSION TRACKING - Real Repository Integration Tests', () {
    late Directory tempDir;
    late WerdRepository werdRepository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('fard_session_repo_test_');
      await getIt.reset();
      await configureDependencies(hivePath: tempDir.path);
      werdRepository = getIt<WerdRepository>();
    });

    tearDown(() async {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    test(
      'REAL TEST 1: Three Continue sessions saved and loaded',
      () async {
        print('');
        print('╔════════════════════════════════════════════════════╗');
        print('🎯 REAL TEST 1: Three "Continue" Sessions');
        print('╠════════════════════════════════════════════════════╣');
        print('');
        print('Simulating real user flow:');
        print('1. Click Continue → Read 1-3 → Leave');
        print('2. Click Continue → Read 4-6 → Leave');
        print('3. Click Continue → Read 7-9 → Leave');
        print('');

        // Setup goal
        final goal = WerdGoal(
          id: 'default',
          type: WerdGoalType.fixedAmount,
          value: 20,
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
          startAbsolute: 1,
        );

        await werdRepository.setGoal(goal);

        // Session 1: Read 1-3
        print('=== Saving Session 1: ayahs 1-3 ===');
        var progress = WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 3,
          segmentsToday: [
            ReadingSegment(
              startAyah: 1,
              endAyah: 3,
              startTime: DateTime(2026, 4, 7, 9, 0),
              endTime: DateTime(2026, 4, 7, 9, 15),
            ),
          ],
          lastReadAbsolute: 3,
          sessionStartAbsolute: 1,
          lastUpdated: DateTime(2026, 4, 7, 9, 15),
          streak: 0,
          completedCycles: 0,
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 1 saved');

        // Session 2: Read 4-6
        print('=== Saving Session 2: ayahs 4-6 ===');
        progress = progress.copyWith(
          totalAmountReadToday: 6,
          segmentsToday: [
            ...progress.segmentsToday,
            ReadingSegment(
              startAyah: 4,
              endAyah: 6,
              startTime: DateTime(2026, 4, 7, 14, 0),
              endTime: DateTime(2026, 4, 7, 14, 10),
            ),
          ],
          lastReadAbsolute: 6,
          lastUpdated: DateTime(2026, 4, 7, 14, 10),
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 2 saved');

        // Session 3: Read 7-9
        print('=== Saving Session 3: ayahs 7-9 ===');
        progress = progress.copyWith(
          totalAmountReadToday: 9,
          segmentsToday: [
            ...progress.segmentsToday,
            ReadingSegment(
              startAyah: 7,
              endAyah: 9,
              startTime: DateTime(2026, 4, 7, 18, 0),
              endTime: DateTime(2026, 4, 7, 18, 20),
            ),
          ],
          lastReadAbsolute: 9,
          lastUpdated: DateTime(2026, 4, 7, 18, 20),
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 3 saved');

        // READ BACK FROM REPOSITORY
        print('');
        print('╠════════════════════════════════════════════════════╣');
        print('📖 Reading back from repository...');
        print('');

        final savedProgressResult = await werdRepository.getProgress(goalId: 'default');
        
        expect(savedProgressResult.isSuccess, true, reason: 'Should load progress');
        
        final actualProgress = savedProgressResult.fold(
          (failure) => throw Exception('Failed: $failure'),
          (p) => p,
        );

        print('📊 Loaded Progress:');
        print('   Total ayahs today: ${actualProgress.totalAmountReadToday}');
        print('   Sessions count: ${actualProgress.segmentsToday.length}');
        print('');

        for (var i = 0; i < actualProgress.segmentsToday.length; i++) {
          final seg = actualProgress.segmentsToday[i];
          print('  Session ${i + 1}:');
          print('    From: Ayah ${seg.startAyah}');
          print('    To: Ayah ${seg.endAyah}');
          print('    Count: ${seg.ayahsCount} ayahs');
          print('    Time: ${seg.formattedStartTime} - ${seg.formattedEndTime}');
          print('    Duration: ${seg.durationMinutes} min');
          print('');
        }

        // VERIFICATIONS
        expect(actualProgress.segmentsToday.length, 3,
            reason: 'Should have EXACTLY 3 sessions');
        expect(actualProgress.totalAmountReadToday, 9,
            reason: 'Total should be 9 ayahs');

        // Session 1
        expect(actualProgress.segmentsToday[0].startAyah, 1);
        expect(actualProgress.segmentsToday[0].endAyah, 3);
        expect(actualProgress.segmentsToday[0].ayahsCount, 3);
        expect(actualProgress.segmentsToday[0].startTime, isNotNull);
        expect(actualProgress.segmentsToday[0].endTime, isNotNull);

        // Session 2
        expect(actualProgress.segmentsToday[1].startAyah, 4);
        expect(actualProgress.segmentsToday[1].endAyah, 6);
        expect(actualProgress.segmentsToday[1].ayahsCount, 3);
        expect(actualProgress.segmentsToday[1].startTime, isNotNull);
        expect(actualProgress.segmentsToday[1].endTime, isNotNull);

        // Session 3
        expect(actualProgress.segmentsToday[2].startAyah, 7);
        expect(actualProgress.segmentsToday[2].endAyah, 9);
        expect(actualProgress.segmentsToday[2].ayahsCount, 3);
        expect(actualProgress.segmentsToday[2].startTime, isNotNull);
        expect(actualProgress.segmentsToday[2].endTime, isNotNull);

        final allRanges = actualProgress.segmentsToday
            .map((s) => '${s.startAyah}-${s.endAyah} (${s.ayahsCount} ayahs)')
            .join(', ');

        print('✅ Session ranges: $allRanges');
        print('');
        print('✅✅✅ REAL TEST 1 PASSED ✅✅✅');
        print('Three sessions properly saved and loaded!');
        print('╚════════════════════════════════════════════════════╝');
        print('');
      },
    );

    test(
      'REAL TEST 2: Big jump with "Mark All"',
      () async {
        print('');
        print('╔════════════════════════════════════════════════════╗');
        print('🎯 REAL TEST 2: Big Jump with "Mark All"');
        print('╠════════════════════════════════════════════════════╣');
        print('');
        print('User flow:');
        print('1. Session 1: Read ayahs 1-5');
        print('2. Jump to 200 → "Mark All" → Session 2: ayahs 1-200');
        print('3. Verify: 2 separate sessions');
        print('');

        // Setup goal
        final goal = WerdGoal(
          id: 'default',
          type: WerdGoalType.fixedAmount,
          value: 200,
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
          startAbsolute: 1,
        );

        await werdRepository.setGoal(goal);

        // Session 1: Read 1-5
        print('=== Saving Session 1: ayahs 1-5 ===');
        var progress = WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 5,
          segmentsToday: [
            ReadingSegment(
              startAyah: 1,
              endAyah: 5,
              startTime: DateTime(2026, 4, 7, 9, 0),
              endTime: DateTime(2026, 4, 7, 9, 20),
            ),
          ],
          lastReadAbsolute: 5,
          sessionStartAbsolute: 1,
          lastUpdated: DateTime(2026, 4, 7, 9, 20),
          streak: 0,
          completedCycles: 0,
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 1 saved');

        // Session 2: Big jump "Mark All"
        print('=== Saving Session 2: Big jump 1-200 (Mark All) ===');
        progress = progress.copyWith(
          totalAmountReadToday: 200,
          segmentsToday: [
            ...progress.segmentsToday,
            ReadingSegment(
              startAyah: 1,
              endAyah: 200,
              startTime: DateTime(2026, 4, 7, 14, 0),
              endTime: DateTime(2026, 4, 7, 14, 30),
            ),
          ],
          lastReadAbsolute: 200,
          lastUpdated: DateTime(2026, 4, 7, 14, 30),
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 2 saved');

        // READ BACK
        print('');
        print('╠════════════════════════════════════════════════════╣');
        print('📖 Reading back from repository...');
        print('');

        final savedProgressResult = await werdRepository.getProgress(goalId: 'default');
        final actualProgress = savedProgressResult.fold(
          (failure) => throw Exception('Failed: $failure'),
          (p) => p,
        );

        print('📊 Loaded Progress:');
        print('   Total ayahs today: ${actualProgress.totalAmountReadToday}');
        print('   Sessions count: ${actualProgress.segmentsToday.length}');
        print('');

        for (var i = 0; i < actualProgress.segmentsToday.length; i++) {
          final seg = actualProgress.segmentsToday[i];
          print('  Session ${i + 1}:');
          print('    From: Ayah ${seg.startAyah}');
          print('    To: Ayah ${seg.endAyah}');
          print('    Count: ${seg.ayahsCount} ayahs');
          print('    Duration: ${seg.durationMinutes} min');
          print('');
        }

        // VERIFICATIONS
        expect(actualProgress.segmentsToday.length, 2,
            reason: 'Should have 2 sessions (NOT merged!)');
        expect(actualProgress.totalAmountReadToday, 200,
            reason: 'Total should be 200 ayahs');

        // Session 1
        expect(actualProgress.segmentsToday[0].startAyah, 1);
        expect(actualProgress.segmentsToday[0].endAyah, 5);
        expect(actualProgress.segmentsToday[0].ayahsCount, 5);

        // Session 2 (big jump)
        expect(actualProgress.segmentsToday[1].startAyah, 1);
        expect(actualProgress.segmentsToday[1].endAyah, 200);
        expect(actualProgress.segmentsToday[1].ayahsCount, 200);

        final allRanges = actualProgress.segmentsToday
            .map((s) => '${s.startAyah}-${s.endAyah} (${s.ayahsCount} ayahs)')
            .join(', ');

        print('✅ Session ranges: $allRanges');
        print('');
        print('✅✅✅ REAL TEST 2 PASSED ✅✅✅');
        print('Big jump "Mark All" creates separate session!');
        print('╚════════════════════════════════════════════════════╝');
        print('');
      },
    );

    test(
      'REAL TEST 3: Multiple jumps - sessions NOT merged',
      () async {
        print('');
        print('╔════════════════════════════════════════════════════╗');
        print('🎯 REAL TEST 3: Multiple Jumps - NOT Merged');
        print('╠════════════════════════════════════════════════════╣');
        print('');
        print('User flow:');
        print('1. Session 1: Al-Fatihah (1-7)');
        print('2. Session 2: Jump to 100 → "Mark All" (1-100)');
        print('3. Session 3: Continue reading (101-110)');
        print('4. Session 4: Jump to 200 → "New Session" (200-202)');
        print('5. Verify: 4 separate sessions!');
        print('');

        // Setup goal
        final goal = WerdGoal(
          id: 'default',
          type: WerdGoalType.fixedAmount,
          value: 200,
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
          startAbsolute: 1,
        );

        await werdRepository.setGoal(goal);

        // Session 1: Al-Fatihah
        print('=== Saving Session 1: Al-Fatihah (1-7) ===');
        var progress = WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 7,
          segmentsToday: [
            ReadingSegment(
              startAyah: 1,
              endAyah: 7,
              startTime: DateTime(2026, 4, 7, 6, 30),
              endTime: DateTime(2026, 4, 7, 6, 45),
            ),
          ],
          lastReadAbsolute: 7,
          sessionStartAbsolute: 1,
          lastUpdated: DateTime(2026, 4, 7, 6, 45),
          streak: 0,
          completedCycles: 0,
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 1 saved');

        // Session 2: Big jump "Mark All"
        print('=== Saving Session 2: Big jump (1-100) ===');
        progress = progress.copyWith(
          totalAmountReadToday: 100,
          segmentsToday: [
            ...progress.segmentsToday,
            ReadingSegment(
              startAyah: 1,
              endAyah: 100,
              startTime: DateTime(2026, 4, 7, 12, 0),
              endTime: DateTime(2026, 4, 7, 12, 15),
            ),
          ],
          lastReadAbsolute: 100,
          lastUpdated: DateTime(2026, 4, 7, 12, 15),
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 2 saved');

        // Session 3: Continuation
        print('=== Saving Session 3: Continuation (101-110) ===');
        progress = progress.copyWith(
          totalAmountReadToday: 110,
          segmentsToday: [
            ...progress.segmentsToday,
            ReadingSegment(
              startAyah: 101,
              endAyah: 110,
              startTime: DateTime(2026, 4, 7, 17, 0),
              endTime: DateTime(2026, 4, 7, 17, 30),
            ),
          ],
          lastReadAbsolute: 110,
          lastUpdated: DateTime(2026, 4, 7, 17, 30),
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 3 saved');

        // Session 4: Night jump
        print('=== Saving Session 4: Night jump (200-202) ===');
        progress = progress.copyWith(
          totalAmountReadToday: 113,
          segmentsToday: [
            ...progress.segmentsToday,
            ReadingSegment(
              startAyah: 200,
              endAyah: 202,
              startTime: DateTime(2026, 4, 7, 22, 0),
              endTime: DateTime(2026, 4, 7, 22, 10),
            ),
          ],
          lastReadAbsolute: 202,
          lastUpdated: DateTime(2026, 4, 7, 22, 10),
        );

        await werdRepository.updateProgress(progress);
        print('✅ Session 4 saved');

        // READ BACK
        print('');
        print('╠════════════════════════════════════════════════════╣');
        print('📖 Reading back from repository...');
        print('');

        final savedProgressResult = await werdRepository.getProgress(goalId: 'default');
        final actualProgress = savedProgressResult.fold(
          (failure) => throw Exception('Failed: $failure'),
          (p) => p,
        );

        print('📊 Loaded Progress:');
        print('   Total ayahs today: ${actualProgress.totalAmountReadToday}');
        print('   Sessions count: ${actualProgress.segmentsToday.length}');
        print('');

        for (var i = 0; i < actualProgress.segmentsToday.length; i++) {
          final seg = actualProgress.segmentsToday[i];
          print('  Session ${i + 1}:');
          print('    From: Ayah ${seg.startAyah}');
          print('    To: Ayah ${seg.endAyah}');
          print('    Count: ${seg.ayahsCount} ayahs');
          print('    Time: ${seg.formattedStartTime} - ${seg.formattedEndTime}');
          print('    Duration: ${seg.durationMinutes} min');
          print('');
        }

        // VERIFICATIONS
        expect(actualProgress.segmentsToday.length, 4,
            reason: 'Should have 4 separate sessions');
        expect(actualProgress.totalAmountReadToday, 113,
            reason: 'Total should be 113 ayahs');

        // Session 1
        expect(actualProgress.segmentsToday[0].startAyah, 1);
        expect(actualProgress.segmentsToday[0].endAyah, 7);
        expect(actualProgress.segmentsToday[0].ayahsCount, 7);

        // Session 2
        expect(actualProgress.segmentsToday[1].startAyah, 1);
        expect(actualProgress.segmentsToday[1].endAyah, 100);
        expect(actualProgress.segmentsToday[1].ayahsCount, 100);

        // Session 3
        expect(actualProgress.segmentsToday[2].startAyah, 101);
        expect(actualProgress.segmentsToday[2].endAyah, 110);
        expect(actualProgress.segmentsToday[2].ayahsCount, 10);

        // Session 4
        expect(actualProgress.segmentsToday[3].startAyah, 200);
        expect(actualProgress.segmentsToday[3].endAyah, 202);
        expect(actualProgress.segmentsToday[3].ayahsCount, 3);

        // All sessions should have timestamps
        for (var i = 0; i < actualProgress.segmentsToday.length; i++) {
          expect(actualProgress.segmentsToday[i].startTime, isNotNull,
              reason: 'Session $i should have startTime');
          expect(actualProgress.segmentsToday[i].endTime, isNotNull,
              reason: 'Session $i should have endTime');
        }

        final allRanges = actualProgress.segmentsToday
            .map((s) => '${s.startAyah}-${s.endAyah} (${s.ayahsCount} ayahs)')
            .join('\n    ');

        print('✅ Session summary:');
        print('    $allRanges');
        print('');
        print('✅✅✅ REAL TEST 3 PASSED ✅✅✅');
        print('Multiple jumps create separate sessions - NOT merged!');
        print('╚════════════════════════════════════════════════════╝');
        print('');
      },
    );
  });
}
