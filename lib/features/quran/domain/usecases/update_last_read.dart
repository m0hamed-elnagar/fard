import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/core/extensions/quran_extension.dart';

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

        final startAbs = currentProgress.sessionStartAbsolute ?? 1;
        
        // Progress is direct distance from session start to current position
        int newTotal = 0;
        Set<int> newItems = {};
        if (newAbs >= startAbs) {
           newTotal = newAbs - startAbs + 1;
           newItems = Set.from(List.generate(newTotal, (i) => startAbs + i));
        } else {
           newTotal = 0;
           newItems = {};
        }

        final newProgress = currentProgress.copyWith(
          totalAmountReadToday: newTotal,
          readItemsToday: newItems,
          lastReadAbsolute: newAbs,
          lastUpdated: DateTime.now(),
        );
        
        return werdRepository.updateProgress(newProgress);
      }
    );
  }
}
