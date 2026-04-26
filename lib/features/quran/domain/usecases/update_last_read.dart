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
    // 1. Update general last read in QuranRepository (UI state)
    await repository.updateLastReadPosition(position);

    // 2. Update werd progress markers through repository
    // Note: We only update markers here. Actual progress tracking (segments/total)
    // is handled by WerdBloc via trackItemRead/trackRangeRead/etc.
    final progressRes = await werdRepository.getProgress();

    return progressRes.fold((failure) => Result.failure(failure), (
      currentProgress,
    ) async {
      final newAbs = QuranHizbProvider.getAbsoluteAyahNumber(
        position.ayahNumber.surahNumber,
        position.ayahNumber.ayahNumberInSurah,
      );

      final now = DateTime.now();
      final isSameDay =
          currentProgress.lastUpdated.year == now.year &&
          currentProgress.lastUpdated.month == now.month &&
          currentProgress.lastUpdated.day == now.day;

      // Only update markers, don't touch segments or totalAmountReadToday
      final updatedProgress = currentProgress.copyWith(
        lastReadAbsolute: newAbs,
        // If it's a new day, we also set sessionStartAbsolute
        sessionStartAbsolute: isSameDay 
            ? currentProgress.sessionStartAbsolute 
            : newAbs,
        lastUpdated: now,
      );

      return werdRepository.updateProgress(updatedProgress);
    });
  }
}
