import 'dart:io';
import 'package:fard/features/tasbih/domain/tasbih_models.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibration/vibration.dart';
import 'package:injectable/injectable.dart';

part 'tasbih_bloc.freezed.dart';
part 'tasbih_event.dart';
part 'tasbih_state.dart';

@injectable
class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final TasbihRepository _repository;

  TasbihBloc(this._repository) : super(TasbihState.initial()) {
    on<_LoadData>(_onLoadData);
    on<_SelectCategory>(_onSelectCategory);
    on<_Increment>(_onIncrement);
    on<_Reset>(_onReset);
    on<_ToggleSound>(_onToggleSound);
    on<_ToggleVibration>(_onToggleVibration);
    on<_ToggleTranslation>(_onToggleTranslation);
    on<_ToggleTransliteration>(_onToggleTransliteration);
    on<_SelectCompletionDua>(_onSelectCompletionDua);
    on<_RememberCompletionDua>(_onRememberCompletionDua);
    on<_UpdateCustomTarget>(_onUpdateCustomTarget);
    on<_ChangeItem>(_onChangeItem);
  }

  Future<void> _onChangeItem(_ChangeItem event, Emitter<TasbihState> emit) async {
    final item = state.currentCategory.items.isNotEmpty
        ? state.currentCategory.items[event.newIndex.clamp(0, state.currentCategory.items.length - 1)]
        : null;

    final currentItemCount = item != null ? (state.itemProgress[item.id] ?? 0) : 0;

    if (state.currentCategory.sequenceMode == 'rotating') {
      // In rotating mode, we still want to keep totalCount somewhat synced for the completion trigger
      // but the immediate count should come from the item itself if we want to "remember"
      final newTotalCount = event.newIndex * state.currentCategory.countsPerCycle + currentItemCount;
      
      emit(state.copyWith(
        currentCycleIndex: event.newIndex,
        totalCount: newTotalCount,
        currentCycleCount: currentItemCount,
        showCompletionDua: false,
      ));
      await _repository.saveSessionProgress(state.currentCategory.id, newTotalCount);
    } else {
      emit(state.copyWith(
        currentCycleIndex: event.newIndex,
        currentCycleCount: currentItemCount,
        showCompletionDua: false,
      ));
    }
  }

  Future<void> _onLoadData(_LoadData event, Emitter<TasbihState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _repository.getTasbihData();
      final defaultCategory = data.categories.firstWhere(
        (c) => c.id == data.settings.defaultCategory,
        orElse: () => data.categories.first,
      );

      final progress = await _repository.getSessionProgress(defaultCategory.id);
      final preferredDuaId = await _repository.getPreferredCompletionDuaId(
        defaultCategory.id,
      );

      final currentDua = _resolveCompletionDua(
        data,
        defaultCategory,
        preferredDuaId,
      );

      // Load progress for all items in the category
      final Map<String, int> itemProgress = {};
      for (final item in defaultCategory.items) {
        itemProgress[item.id] = await _repository.getItemProgress(
          defaultCategory.id,
          item.id,
        );
      }

      final cycleIndex = progress == 0 ? 0 : (progress - 1) ~/ defaultCategory.countsPerCycle;
      final currentItem = defaultCategory.items.isNotEmpty 
          ? defaultCategory.items[cycleIndex.clamp(0, defaultCategory.items.length - 1)]
          : null;
      
      final currentCount = currentItem != null ? (itemProgress[currentItem.id] ?? 0) : 0;

      emit(
        state.copyWith(
          isLoading: false,
          data: data,
          currentCategory: defaultCategory,
          currentCompletionDua: currentDua,
          totalCount: progress,
          itemProgress: itemProgress,
          currentCycleCount: currentCount,
          currentCycleIndex: cycleIndex.clamp(0, defaultCategory.items.length - 1),
          customTasbihTarget: data.settings.customTasbihTarget,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  CompletionDua? _resolveCompletionDua(
    TasbihData data,
    TasbihCategory category,
    String? preferredId,
  ) {
    final duaId = preferredId ?? category.defaultCompletionDuaId;
    if (duaId == null) return null;
    return data.completionDuas.firstWhere(
      (d) => d.id == duaId,
      orElse: () => data.completionDuas.first,
    );
  }

  Future<void> _onSelectCategory(
    _SelectCategory event,
    Emitter<TasbihState> emit,
  ) async {
    final category = state.data.categories.firstWhere(
      (c) => c.id == event.categoryId,
    );
    final progress = await _repository.getSessionProgress(category.id);
    final preferredDuaId = await _repository.getPreferredCompletionDuaId(
      category.id,
    );

    final currentDua = _resolveCompletionDua(
      state.data,
      category,
      preferredDuaId,
    );

    // Load progress for all items
    final Map<String, int> itemProgress = {};
    for (final item in category.items) {
      itemProgress[item.id] = await _repository.getItemProgress(
        category.id,
        item.id,
      );
    }

    final cycleIndex = progress == 0 ? 0 : (progress - 1) ~/ category.countsPerCycle;
    final currentItem = category.items.isNotEmpty 
        ? category.items[cycleIndex.clamp(0, category.items.length - 1)]
        : null;
    
    final currentCount = currentItem != null ? (itemProgress[currentItem.id] ?? 0) : 0;

    emit(
      state.copyWith(
        currentCategory: category,
        currentCompletionDua: currentDua,
        totalCount: progress,
        itemProgress: itemProgress,
        currentCycleCount: currentCount,
        currentCycleIndex: cycleIndex.clamp(0, category.items.length - 1),
        showCompletionDua: false,
        duaRemembered: false,
        customTasbihTarget: state.data.settings.customTasbihTarget,
      ),
    );
  }

  Future<void> _onIncrement(_Increment event, Emitter<TasbihState> emit) async {
    if (state.showCompletionDua) {
      add(const TasbihEvent.reset());
      return;
    }

    final currentDhikr = state.currentCategory.items.isNotEmpty
        ? state.currentCategory.items[state.currentCycleIndex.clamp(
            0,
            state.currentCategory.items.length - 1,
          )]
        : null;

    if (currentDhikr == null) return;

    final nextItemCount = (state.itemProgress[currentDhikr.id] ?? 0) + 1;
    final nextTotalCount = state.totalCount + 1;

    final newItemProgress = Map<String, int>.from(state.itemProgress);
    newItemProgress[currentDhikr.id] = nextItemCount;

    if (state.currentCategory.sequenceMode == 'rotating') {
      final completionTrigger = state.currentCategory.completionTrigger;

      if (nextTotalCount > completionTrigger) {
        emit(state.copyWith(showCompletionDua: true));
      } else {
        emit(
          state.copyWith(
            totalCount: nextTotalCount,
            currentCycleCount: nextItemCount,
            itemProgress: newItemProgress,
          ),
        );

        if (nextTotalCount == completionTrigger) {
          emit(state.copyWith(showCompletionDua: true));
        }
      }
    } else {
      // Individual mode
      final targetCount =
          state.customTasbihTarget ?? currentDhikr.targetCount;

      if (nextItemCount >= targetCount) {
        // Current item completed
        final isLastItem =
            state.currentCycleIndex >= state.currentCategory.items.length - 1;

        if (isLastItem) {
          emit(
            state.copyWith(
              totalCount: nextTotalCount,
              currentCycleCount: nextItemCount,
              itemProgress: newItemProgress,
              showCompletionDua:
                  state.currentCategory.allowCompletionDua ||
                  state.currentCompletionDua != null,
            ),
          );
        } else {
          // Hold state on completion, let UI handle auto-advance
          emit(
            state.copyWith(
              totalCount: nextTotalCount,
              currentCycleCount: targetCount, // Cap for display
              itemProgress: newItemProgress,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            totalCount: nextTotalCount,
            currentCycleCount: nextItemCount,
            itemProgress: newItemProgress,
          ),
        );
      }
    }

    // Persist changes
    await _repository.saveItemProgress(
      state.currentCategory.id,
      currentDhikr.id,
      nextItemCount,
    );
    
    await _repository.saveSessionProgress(
      state.currentCategory.id,
      state.totalCount,
    );

    await _repository.incrementHistory(currentDhikr.id);

    if (state.data.settings.hapticFeedback && !Platform.isWindows) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _onReset(_Reset event, Emitter<TasbihState> emit) async {
    await _repository.saveSessionProgress(state.currentCategory.id, 0);
    
    final Map<String, int> newItemProgress = Map.from(state.itemProgress);
    for (final item in state.currentCategory.items) {
      newItemProgress[item.id] = 0;
      await _repository.saveItemProgress(state.currentCategory.id, item.id, 0);
    }

    emit(
      state.copyWith(
        totalCount: 0,
        currentCycleCount: 0,
        currentCycleIndex: 0,
        itemProgress: newItemProgress,
        showCompletionDua: false,
        duaRemembered: false,
      ),
    );
  }

  Future<void> _onSelectCompletionDua(
    _SelectCompletionDua event,
    Emitter<TasbihState> emit,
  ) async {
    final dua = state.data.completionDuas.firstWhere(
      (d) => d.id == event.duaId,
    );
    emit(state.copyWith(currentCompletionDua: dua, duaRemembered: false));
  }

  Future<void> _onRememberCompletionDua(
    _RememberCompletionDua event,
    Emitter<TasbihState> emit,
  ) async {
    if (state.currentCompletionDua != null) {
      await _repository.savePreferredCompletionDuaId(
        state.currentCategory.id,
        state.currentCompletionDua!.id,
      );
      emit(state.copyWith(duaRemembered: true));
    }
  }

  Future<void> _onToggleSound(
    _ToggleSound event,
    Emitter<TasbihState> emit,
  ) async {
    final newSettings = state.data.settings.copyWith(
      soundEffect: !state.data.settings.soundEffect,
    );
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onToggleVibration(
    _ToggleVibration event,
    Emitter<TasbihState> emit,
  ) async {
    final newSettings = state.data.settings.copyWith(
      hapticFeedback: !state.data.settings.hapticFeedback,
    );
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onToggleTranslation(
    _ToggleTranslation event,
    Emitter<TasbihState> emit,
  ) async {
    final newSettings = state.data.settings.copyWith(
      showTranslation: !state.data.settings.showTranslation,
    );
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onToggleTransliteration(
    _ToggleTransliteration event,
    Emitter<TasbihState> emit,
  ) async {
    final newSettings = state.data.settings.copyWith(
      showTransliteration: !state.data.settings.showTransliteration,
    );
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onUpdateCustomTarget(
    _UpdateCustomTarget event,
    Emitter<TasbihState> emit,
  ) async {
    final newSettings = state.data.settings.copyWith(
      customTasbihTarget: event.target,
    );
    await _repository.saveSettings(newSettings);
    emit(
      state.copyWith(
        data: state.data.copyWith(settings: newSettings),
        customTasbihTarget: event.target,
      ),
    );
  }
}
