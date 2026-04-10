import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuranRepository extends Mock implements QuranRepository {}
class MockWerdRepository extends Mock implements WerdRepository {}

/// This test EXACTLY matches what the user does:
/// 1. Open Quran reader
/// 2. Click "Mark Last Read" on ayah 1
/// 3. Click "Mark Last Read" on ayah 2
/// 4. Click "Mark Last Read" on ayah 3
/// 5. Leave reader → Check Today's Reading
///
/// This uses UpdateLastRead use case, NOT WerdEvent.trackItemRead!
void main() {
  late MockQuranRepository mockQuranRepo;
  late MockWerdRepository mockWerdRepo;
  late UpdateLastRead updateLastRead;

  setUpAll(() {
    registerFallbackValue(LastReadPosition(
      ayahNumber: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      segmentsToday: const [],
      lastUpdated: DateTime.now(),
      streak: 0,
      completedCycles: 0,
    ));
  });

  setUp(() {
    mockQuranRepo = MockQuranRepository();
    mockWerdRepo = MockWerdRepository();
    updateLastRead = UpdateLastRead(mockQuranRepo, mockWerdRepo);

    // Initial progress with session start set (user clicked Continue)
    WerdProgress currentProgress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      readItemsToday: const {},
      segmentsToday: const [],
      sessionStartAbsolute: 1,
      lastReadAbsolute: null,
      lastUpdated: DateTime.now(),
      streak: 0,
      completedCycles: 0,
    );

    when(() => mockQuranRepo.updateLastReadPosition(any()))
        .thenAnswer((_) async => Result<void>.success(null));
    when(() => mockWerdRepo.getProgress())
        .thenAnswer((_) async => Result.success(currentProgress));
    when(() => mockWerdRepo.updateProgress(any())).thenAnswer((invocation) async {
      currentProgress = invocation.positionalArguments[0] as WerdProgress;
      return Result.success(null);
    });
  });

  test(
    'REAL USER FLOW: Click "Mark Last Read" 3 times on sequential ayahs',
    () async {
      print('╔════════════════════════════════════════════════════╗');
      print('🎯 REAL USER FLOW TEST (UpdateLastRead use case)');
      print('╠════════════════════════════════════════════════════╣');
      print('');
      print('User flow:');
      print('1. Click "Continue" (sessionStartAbsolute = 1)');
      print('2. Click "Mark Last Read" on ayah 1');
      print('3. Click "Mark Last Read" on ayah 2');
      print('4. Click "Mark Last Read" on ayah 3');
      print('5. Leave reader (endSession)');
      print('');

      // User clicks "Mark Last Read" on ayah 1
      print('=== Mark Last Read: Ayah 1 ===');
      final result1 = await updateLastRead.call(LastReadPosition(
        ayahNumber: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
        updatedAt: DateTime.now(),
      ));
      expect(result1.isFailure, false, reason: 'First mark should not fail');

      // User clicks "Mark Last Read" on ayah 2
      print('=== Mark Last Read: Ayah 2 ===');
      final result2 = await updateLastRead.call(LastReadPosition(
        ayahNumber: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 2).data!,
        updatedAt: DateTime.now(),
      ));
      expect(result2.isFailure, false, reason: 'Second mark should not fail');

      // User clicks "Mark Last Read" on ayah 3
      print('=== Mark Last Read: Ayah 3 ===');
      final result3 = await updateLastRead.call(LastReadPosition(
        ayahNumber: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 3).data!,
        updatedAt: DateTime.now(),
      ));
      expect(result3.isFailure, false, reason: 'Third mark should not fail');

      // Verify updateProgress was called (3 times)
      // Just check it was called, we'll verify the data from the captured calls
      final captured = verify(
        () => mockWerdRepo.updateProgress(captureAny()),
      ).captured;

      final finalProgress = captured.last as WerdProgress;

      print('');
      print('╠════════════════════════════════════════════════════╣');
      print('📊 RESULTS:');
      print('   Total ayahs today: ${finalProgress.totalAmountReadToday}');
      print('   Sessions count: ${finalProgress.segmentsToday.length}');
      print('');

      for (var i = 0; i < finalProgress.segmentsToday.length; i++) {
        final seg = finalProgress.segmentsToday[i];
        print('  Session ${i + 1}:');
        print('    Ayahs: ${seg.startAyah}-${seg.endAyah} (${seg.ayahsCount} ayahs)');
        print('    Start: ${seg.formattedStartTime}');
        print('    End: ${seg.formattedEndTime}');
        if (seg.durationMinutes != null) {
          print('    Duration: ${seg.durationMinutes} min');
        }
        print('');
      }

      if (finalProgress.segmentsToday.length == 1 &&
          finalProgress.segmentsToday[0].ayahsCount == 3) {
        print('✅✅✅ SUCCESS! ✅✅✅');
        print('');
        print('One session with 3 ayahs (range 1-3)');
        print('This is what the user should see!');
      } else if (finalProgress.segmentsToday.length == 3) {
        print('❌ FAILURE: Created 3 separate single-ayah segments!');
        print('');
        print('This is the bug - each "Mark Last Read" created its own segment');
        print('instead of extending the same session!');
      } else {
        print('❌ UNEXPECTED RESULT');
      }
      print('╚════════════════════════════════════════════════════╝');

      // SHOULD HAVE ONE SESSION WITH 3 AYAHS
      expect(finalProgress.segmentsToday.length, 1,
          reason: 'Should have ONE session after marking 3 sequential ayahs');
      expect(finalProgress.segmentsToday[0].ayahsCount, 3,
          reason: 'Session should have 3 ayahs (1-3)');
      expect(finalProgress.segmentsToday[0].startAyah, 1,
          reason: 'Session should start at ayah 1');
      expect(finalProgress.segmentsToday[0].endAyah, 3,
          reason: 'Session should end at ayah 3');
      expect(finalProgress.totalAmountReadToday, 3,
          reason: 'Total should be 3 ayahs');
    },
  );
}
