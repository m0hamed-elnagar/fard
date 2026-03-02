import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/domain/entities/werd_progress.dart';
import 'package:fard/features/quran/domain/repositories/werd_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/core/extensions/quran_extension.dart';

part 'werd_bloc.freezed.dart';
part 'werd_event.dart';
part 'werd_state.dart';

class WerdBloc extends Bloc<WerdEvent, WerdState> {
  final WerdRepository _repository;
  StreamSubscription? _progressSubscription;

  WerdBloc(this._repository) : super(WerdState.initial()) {
    _progressSubscription = _repository.watchProgress().listen((result) {
      result.fold(
        (_) => null,
        (progress) => add(WerdEvent.progressUpdated(progress)),
      );
    });

    on<_Load>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      
      final goalRes = await _repository.getGoal();
      final progressRes = await _repository.getProgress();
      
      emit(state.copyWith(
        isLoading: false,
        goal: goalRes.fold((_) => null, (g) => g),
        progress: progressRes.fold((_) => null, (p) => p),
      ));
    });

    on<_SetGoal>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      await _repository.setGoal(event.goal);
      emit(state.copyWith(isLoading: false, goal: event.goal));
    });

    on<_ProgressUpdated>((event, emit) {
      emit(state.copyWith(progress: event.progress));
    });

    on<_TrackAyahRead>((event, emit) async {
      final progressRes = await _repository.getProgress();
      final currentProgress = progressRes.fold(
        (_) => WerdProgress(totalAyahsReadToday: 0, lastUpdated: DateTime.now(), streak: 0),
        (p) => p
      );
      
      final newAbs = QuranHizbProvider.getAbsoluteAyahNumber(
        event.ayah.surahNumber, 
        event.ayah.ayahNumberInSurah
      );

      if (currentProgress.lastReadAyah == event.ayah) return;
      
      int delta = 1;
      if (currentProgress.lastReadAbsolute != null) {
        // If the new ayah is after the last one in the same session/day
        if (newAbs > currentProgress.lastReadAbsolute!) {
          delta = newAbs - currentProgress.lastReadAbsolute!;
          // Cap delta if it seems like a huge jump (e.g. > 100 ayahs might be a navigation, not reading)
          // Actually, let's trust the user or cap it at something reasonable
          if (delta > 200) delta = 1; 
        }
      }
      
      final newTotal = currentProgress.totalAyahsReadToday + delta;
      
      int newStreak = currentProgress.streak;
      if (state.goal != null) {
        final dailyGoalInAyahs = state.goal!.valueInAyahs;
        // If we just reached or crossed the goal
        if (currentProgress.totalAyahsReadToday < dailyGoalInAyahs && newTotal >= dailyGoalInAyahs) {
          newStreak++;
        }
      }

      final newProgress = WerdProgress(
        totalAyahsReadToday: newTotal,
        lastReadAyah: event.ayah,
        lastReadAbsolute: newAbs,
        lastUpdated: DateTime.now(),
        streak: newStreak,
      );
      
      await _repository.updateProgress(newProgress);
    });
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
