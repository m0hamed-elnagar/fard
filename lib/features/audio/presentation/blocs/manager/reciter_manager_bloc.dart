import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:injectable/injectable.dart';

part 'reciter_manager_event.dart';
part 'reciter_manager_state.dart';

@injectable
class ReciterManagerBloc extends Bloc<ReciterManagerEvent, ReciterManagerState> {
  final AudioRepository audioRepository;
  final AudioDownloadService downloadService;

  ReciterManagerBloc({
    required this.audioRepository,
    required this.downloadService,
  }) : super(const ReciterManagerState()) {
    on<LoadReciters>(_onLoadReciters);
    on<SelectReciter>(_onSelectReciter);
    on<RefreshReciterStatuses>(_onLoadReciters);

    add(const LoadReciters());
  }

  Future<void> _onLoadReciters(
    ReciterManagerEvent event,
    Emitter<ReciterManagerState> emit,
  ) async {
    // 1. Helper to sort and emit
    void emitSorted(
      List<Reciter> reciters,
      Map<String, double> progress,
      Map<String, int> sizes,
    ) {
      final sortedReciters = List<Reciter>.from(reciters);
      sortedReciters.sort((a, b) {
        final pA = progress[a.identifier] ?? 0.0;
        final pB = progress[b.identifier] ?? 0.0;
        if (pB != pA) return pB.compareTo(pA);
        return a.englishName.compareTo(b.englishName);
      });

      emit(
        state.copyWith(
          availableReciters: sortedReciters,
          reciterDownloadProgress: progress,
          reciterDownloadSizes: sizes,
          currentReciter: state.currentReciter ?? sortedReciters.firstOrNull,
          error: null,
        ),
      );
    }

    // 2. Load cached reciters AND data immediately
    final cachedRecitersResult = await audioRepository.getCachedReciters();
    final cachedData = await audioRepository.getCachedReciterData();

    List<Reciter> currentReciters = [];

    if (cachedRecitersResult.isSuccess &&
        cachedRecitersResult.data!.isNotEmpty) {
      currentReciters = cachedRecitersResult.data!;
      emitSorted(currentReciters, cachedData.progress, cachedData.sizes);
    }

    // 3. Fetch fresh reciters list
    final freshRecitersResult = await audioRepository.getAvailableReciters();
    freshRecitersResult.fold(
      (failure) {
        if (state.availableReciters.isEmpty) {
          emit(state.copyWith(error: failure.message));
        }
      },
      (reciters) {
        currentReciters = reciters;
      },
    );

    if (currentReciters.isEmpty) return;

    // 4. Calculate fresh data in background
    final freshProgress = <String, double>{};
    final freshSizes = <String, int>{};

    await Future.wait(
      currentReciters.map((r) async {
        freshProgress[r.identifier] = await downloadService
            .getReciterDownloadPercentage(r.identifier);
        freshSizes[r.identifier] = await downloadService
            .getReciterDownloadedSize(r.identifier);
      }),
    );

    // 5. Check if data changed
    bool hasChanged = false;

    // Check lengths
    if (freshProgress.length != cachedData.progress.length ||
        freshSizes.length != cachedData.sizes.length) {
      hasChanged = true;
    } else {
      // Check values
      for (final id in freshProgress.keys) {
        if ((freshProgress[id] ?? 0) != (cachedData.progress[id] ?? 0) ||
            (freshSizes[id] ?? 0) != (cachedData.sizes[id] ?? 0)) {
          hasChanged = true;
          break;
        }
      }
    }

    // 6. Only re-emit if data changed
    if (hasChanged) {
      await audioRepository.cacheReciterData(freshProgress, freshSizes);
      emitSorted(currentReciters, freshProgress, freshSizes);
    } else if (state.availableReciters.length != currentReciters.length) {
      emitSorted(currentReciters, freshProgress, freshSizes);
    }
  }

  Future<void> _onSelectReciter(
    SelectReciter event,
    Emitter<ReciterManagerState> emit,
  ) async {
    emit(state.copyWith(currentReciter: event.reciter));
    await audioRepository.cacheReciters(state.availableReciters);
  }
}
