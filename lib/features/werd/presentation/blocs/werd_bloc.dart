import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class WerdBloc extends Bloc<WerdEvent, WerdState> {
  final WerdRepository _repository;
  StreamSubscription? _progressSubscription;

  WerdBloc(this._repository) : super(WerdState.initial()) {
    on<WerdEvent>((event, emit) async {
      await event.map(
        load: (e) async {
          emit(state.copyWith(isLoading: true));
          _progressSubscription?.cancel();
          _progressSubscription = _repository.watchProgress(goalId: e.id).listen((result) {
            result.fold(
              (_) => null,
              (progress) => add(WerdEvent.progressUpdated(progress)),
            );
          });

          final goalRes = await _repository.getGoal(id: e.id);
          final progressRes = await _repository.getProgress(goalId: e.id);
          
          emit(state.copyWith(
            isLoading: false,
            goal: goalRes.fold((_) => null, (g) => g),
            progress: progressRes.fold((_) => null, (p) => p),
          ));
        },
        setGoal: (e) async {
          emit(state.copyWith(isLoading: true));
          await _repository.setGoal(e.goal);
          
          // Reset progress for the new goal starting point
          final currentProgressRes = await _repository.getProgress(goalId: e.goal.id);
          final currentProgress = currentProgressRes.fold(
            (_) => WerdProgress(goalId: e.goal.id, totalAmountReadToday: 0, lastUpdated: DateTime.now(), streak: 0),
            (p) => p
          );

          final updatedProgress = currentProgress.copyWith(
            lastReadAbsolute: e.goal.startAbsolute != null ? e.goal.startAbsolute! - 1 : null,
            sessionStartAbsolute: e.goal.startAbsolute,
            totalAmountReadToday: 0,
            readItemsToday: const {},
          );
          await _repository.updateProgress(updatedProgress);

          if (state.goal?.id != e.goal.id) {
            add(WerdEvent.load(id: e.goal.id));
          } else {
            emit(state.copyWith(isLoading: false, goal: e.goal, progress: updatedProgress));
          }
        },
        progressUpdated: (e) {
          emit(state.copyWith(progress: e.progress));
        },
        updateBookmark: (e) async {
           // No longer used to update progress
        },
        trackItemRead: (e) async {
          // If we track a single item (e.g. from Mushaf tap), 
          // we treat it as "reached this point" for today's session
          await _handleBookmarkUpdate(e.absoluteIndex);
        },
        trackRangeRead: (e) async {
          // If range is provided, we use the end of the range
          await _handleBookmarkUpdate(e.endAbsolute);
        },
      );
    });
  }

  Future<void> _handleBookmarkUpdate(int bookmarkAbs) async {
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(goalId: goalId, totalAmountReadToday: 0, lastUpdated: DateTime.now(), streak: 0),
      (p) => p
    );

    final startAbs = currentProgress.sessionStartAbsolute ?? 1;
    
    // Progress is distance from session start to bookmark
    int newTotal = 0;
    Set<int> newItems = {};
    if (bookmarkAbs >= startAbs) {
       newTotal = bookmarkAbs - startAbs + 1;
       // Optimization: only generate if needed for UI, but here we use it for total
       newItems = Set.from(List.generate(newTotal, (i) => startAbs + i));
    } else {
       // If bookmark is BEFORE start, we don't count it as negative progress today
       newTotal = 0;
       newItems = {};
    }

    int newStreak = currentProgress.streak;
    if (state.goal != null) {
      final dailyGoal = state.goal!.valueInAyahs;
      // If was incomplete and now complete
      if (currentProgress.totalAmountReadToday < dailyGoal && newTotal >= dailyGoal) {
        newStreak++;
      } 
      // If was complete and now adjusted back to incomplete
      else if (currentProgress.totalAmountReadToday >= dailyGoal && newTotal < dailyGoal) {
        newStreak = (newStreak > 0) ? newStreak - 1 : 0;
      }
    }

    final newProgress = currentProgress.copyWith(
      totalAmountReadToday: newTotal,
      readItemsToday: newItems,
      lastReadAbsolute: bookmarkAbs,
      lastUpdated: DateTime.now(),
      streak: newStreak,
    );

    await _repository.updateProgress(newProgress);
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
