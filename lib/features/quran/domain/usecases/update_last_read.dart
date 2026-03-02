import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/repositories/werd_repository.dart';
import 'package:fard/features/quran/domain/entities/werd_progress.dart';

class UpdateLastRead {
  final QuranRepository repository;
  final WerdRepository werdRepository;

  UpdateLastRead(this.repository, this.werdRepository);

  Future<Result<void>> call(LastReadPosition position) async {
    // 1. Update general last read
    await repository.updateLastReadPosition(position);
    
    // 2. Update werd progress
    final progressRes = await werdRepository.getProgress();
    return progressRes.fold(
      (failure) => Result.failure(failure),
      (currentProgress) async {
        if (currentProgress.lastReadAyah == position.ayahNumber) {
          return Result.success(null);
        }
        
        final newTotal = currentProgress.totalAyahsReadToday + 1;
        
        // We don't have goal context here, but we can update the progress.
        // The goal-based streak increment can happen in WerdBloc when it detects goal completion.
        // Or we can just store the total here.
        
        final newProgress = WerdProgress(
          totalAyahsReadToday: newTotal,
          lastReadAyah: position.ayahNumber,
          lastUpdated: DateTime.now(),
          streak: currentProgress.streak, 
        );
        
        return werdRepository.updateProgress(newProgress);
      }
    );
  }
}
