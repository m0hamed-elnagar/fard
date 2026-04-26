import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Werd New Session Bug Reproduction', () {
    late Directory tempDir;
    late WerdRepository werdRepository;
    late UpdateLastRead updateLastRead;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = Directory.systemTemp.createTempSync('werd_bug_repro_');
      await getIt.reset();
      await configureDependencies(hivePath: tempDir.path);
      werdRepository = getIt<WerdRepository>();
      updateLastRead = getIt<UpdateLastRead>();
    });

    tearDown(() async {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    test('BUG REPRO: sessions should NOT be removed or gap marked when jumping to new session', () async {
      print('🎯 Starting Bug Reproduction Test');
      
      // 1. Setup initial state: Session 1 (ayahs 1-10)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        segmentsToday: [
          ReadingSegment(
            startAyah: 1,
            endAyah: 10,
            startTime: today.add(const Duration(hours: 9)),
            endTime: today.add(const Duration(hours: 9, minutes: 30)),
          ),
        ],
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: today.add(const Duration(hours: 9, minutes: 30)),
        streak: 0,
      );
      await werdRepository.updateProgress(initialProgress);
      print('✅ Initial session 1-10 saved');

      final werdBloc = WerdBloc(werdRepository);
      werdBloc.add(const WerdEvent.load(id: 'default'));
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Simulate what happens in AyahDetailSheet when user chooses "New Session" at ayah 100
      // FIRST: ReaderBloc calls UpdateLastRead(100)
      print('🚀 Simulating UpdateLastRead(100) call...');
      await updateLastRead.call(LastReadPosition(
        ayahNumber: AyahNumber.create(surahNumber: 2, ayahNumberInSurah: 133).fold((f) => throw Exception(f.message), (v) => v), // Absolute 100
        updatedAt: DateTime.now(),
      ));

      // CHECK: After UpdateLastRead, did it mark the gap?
      var progress = (await werdRepository.getProgress(goalId: 'default')).fold((_) => null, (p) => p)!;
      print('📊 After UpdateLastRead: totalAmountReadToday = ${progress.totalAmountReadToday}');
      print('   Segments: ${progress.segmentsToday.map((s) => '${s.startAyah}-${s.endAyah}').toList()}');
      
      // If the bug exists, totalAmountReadToday will be 100 (marking the gap 11-99)
      // OR segmentsToday will be overwritten.
      
      // SECOND: WerdBloc.jumpToNewSession(100) is called
      print('🚀 Simulating jumpToNewSession(100)...');
      werdBloc.add(const WerdEvent.jumpToNewSession(100));
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. FINAL VERIFICATION
      final finalProgress = (await werdRepository.getProgress(goalId: 'default')).fold((_) => null, (p) => p)!;
      print('📊 Final State: totalAmountReadToday = ${finalProgress.totalAmountReadToday}');
      print('   Segments: ${finalProgress.segmentsToday.map((s) => '${s.startAyah}-${s.endAyah}').toList()}');

      // These should PASS now:
      expect(finalProgress.totalAmountReadToday, 10, 
          reason: 'Total should remain 10 (gap 11-99 should NOT be marked)');
      expect(finalProgress.segmentsToday.length, 1, 
          reason: 'Previous session should be preserved');

      // 4. NEXT STEP: Mark the new position (100) as read
      print('🚀 Simulating trackItemRead(100)...');
      werdBloc.add(const WerdEvent.trackItemRead(100));
      await Future.delayed(const Duration(milliseconds: 100));

      final progressAfterMark = (await werdRepository.getProgress(goalId: 'default')).fold((_) => null, (p) => p)!;
      print('📊 After marking 100: totalAmountReadToday = ${progressAfterMark.totalAmountReadToday}');
      print('   Segments: ${progressAfterMark.segmentsToday.map((s) => "${s.startAyah}-${s.endAyah}").toList()}');

      expect(progressAfterMark.segmentsToday.length, 2, 
          reason: 'Should have 2 separate segments now');
      expect(progressAfterMark.totalAmountReadToday, 11, 
          reason: 'Total should be 11 (10 from before + 1 new)');
      expect(progressAfterMark.segmentsToday.any((s) => s.startAyah == 1 && s.endAyah == 10), true);
      expect(progressAfterMark.segmentsToday.any((s) => s.startAyah == 100 && s.endAyah == 100), true);
    });
  });
}
