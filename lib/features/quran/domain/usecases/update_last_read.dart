import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
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
    
    return progressRes.fold(
      (failure) => Result.failure(failure),
      (currentProgress) async {
        final newAbs = QuranHizbProvider.getAbsoluteAyahNumber(
          position.ayahNumber.surahNumber,
          position.ayahNumber.ayahNumberInSurah,
        );

        // If sessionStartAbsolute is null, it means this is the first read of the day.
        // Or if it was from a previous day (lastUpdated is not today), we should reset.
        final now = DateTime.now();
        final isSameDay = currentProgress.lastUpdated.year == now.year &&
            currentProgress.lastUpdated.month == now.month &&
            currentProgress.lastUpdated.day == now.day;

        final startAbs = (isSameDay && currentProgress.sessionStartAbsolute != null)
            ? currentProgress.sessionStartAbsolute!
            : newAbs;

        // Progress is direct distance from session start to current position
        int newTotal = 0;
        Set<int> newItems = {};
        if (newAbs >= startAbs) {
           newTotal = newAbs - startAbs + 1;
           // In "reading flow", we assume user read everything from start to current
           newItems = Set.from(List.generate(newTotal, (i) => startAbs + i));
        } else {
           // If user jumps BACKWARDS from start, we don't count it towards progress for now
           // to keep the simplified "session start" logic.
           newTotal = currentProgress.totalAmountReadToday;
           newItems = currentProgress.readItemsToday;
        }

        final newProgress = currentProgress.copyWith(
          totalAmountReadToday: newTotal,
          readItemsToday: newItems,
          lastReadAbsolute: newAbs,
          sessionStartAbsolute: startAbs,
          lastUpdated: now,
        );
        
        return werdRepository.updateProgress(newProgress);
      }
    );
  }
}
