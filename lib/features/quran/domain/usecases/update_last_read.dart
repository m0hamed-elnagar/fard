import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateLastRead {
  final QuranRepository repository;
  final WerdRepository werdRepository;

  UpdateLastRead(this.repository, this.werdRepository);

  Future<Result<void>> call(LastReadPosition position) async {
    // 1. Update general last read in QuranRepository
    await repository.updateLastReadPosition(position);

    // 2. Update werd progress through repository
    final progressRes = await werdRepository.getProgress();

    return progressRes.fold((failure) => Result.failure(failure), (
      currentProgress,
    ) async {
      final newAbs = QuranHizbProvider.getAbsoluteAyahNumber(
        position.ayahNumber.surahNumber,
        position.ayahNumber.ayahNumberInSurah,
      );

      // If sessionStartAbsolute is null, it means this is the first read of the day.
      // Or if it was from a previous day (lastUpdated is not today), we should reset.
      final now = DateTime.now();
      final isSameDay =
          currentProgress.lastUpdated.year == now.year &&
          currentProgress.lastUpdated.month == now.month &&
          currentProgress.lastUpdated.day == now.day;

      final startAbs =
          (isSameDay && currentProgress.sessionStartAbsolute != null)
          ? currentProgress.sessionStartAbsolute!
          : newAbs;

      // Progress is direct distance from session start to current position
      int newTotal = 0;
      Set<int> newItems = {};
      List<ReadingSegment> newSegments = [];
      
      if (newAbs >= startAbs) {
        newTotal = newAbs - startAbs + 1;
        // In "reading flow", we assume user read everything from start to current
        newItems = Set.from(List.generate(newTotal, (i) => startAbs + i));
        // Create segments from the set of ayahs
        // Check if there's already an active session
        if (currentProgress.segmentsToday.isNotEmpty) {
          final lastSegment = currentProgress.segmentsToday.last;
          if (lastSegment.endTime == null) {
            // Extend the active session
            newSegments = List.from(currentProgress.segmentsToday);
            newSegments[newSegments.length - 1] = lastSegment.extend(newAbs);
          } else {
            // Previous session ended, create new one
            newSegments = ReadingSegment.fromSet(newItems);
            if (newSegments.isNotEmpty) {
              newSegments[0] = newSegments[0].copyWith(startTime: DateTime.now());
            }
          }
        } else {
          // No existing segments, create new session
          newSegments = ReadingSegment.fromSet(newItems);
          if (newSegments.isNotEmpty) {
            newSegments[0] = newSegments[0].copyWith(startTime: DateTime.now());
          }
        }
      } else {
        // If user jumps BACKWARDS from start, we don't count it towards progress for now
        // to keep the simplified "session start" logic.
        newTotal = currentProgress.totalAmountReadToday;
        newItems = currentProgress.readItemsToday;
        newSegments = currentProgress.segmentsToday;
      }

      final newProgress = currentProgress.copyWith(
        totalAmountReadToday: newTotal,
        readItemsToday: newItems,
        segmentsToday: newSegments, // FIX: Set BOTH formats!
        lastReadAbsolute: newAbs,
        sessionStartAbsolute: startAbs,
        lastUpdated: now,
      );

      return werdRepository.updateProgress(newProgress);
    });
  }
}
