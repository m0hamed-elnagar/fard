import 'package:fard/features/tasbih/domain/tasbih_models.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibration/vibration.dart';

part 'tasbih_bloc.freezed.dart';
part 'tasbih_event.dart';
part 'tasbih_state.dart';

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
      final preferredDuaId = await _repository.getPreferredCompletionDuaId(defaultCategory.id);
      
      final currentDua = _resolveCompletionDua(data, defaultCategory, preferredDuaId);
      
      emit(state.copyWith(
        isLoading: false,
        data: data,
        currentCategory: defaultCategory,
        currentCompletionDua: currentDua,
        totalCount: progress,
        currentCycleCount: progress == 0 ? 0 : (progress - 1) % defaultCategory.countsPerCycle + 1,
        currentCycleIndex: progress == 0 ? 0 : (progress - 1) ~/ defaultCategory.countsPerCycle,
        customTasbihTarget: data.settings.customTasbihTarget,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  CompletionDua? _resolveCompletionDua(TasbihData data, TasbihCategory category, String? preferredId) {
    final duaId = preferredId ?? category.defaultCompletionDuaId;
    if (duaId == null) return null;
    return data.completionDuas.firstWhere((d) => d.id == duaId, orElse: () => data.completionDuas.first);
  }

  Future<void> _onSelectCategory(_SelectCategory event, Emitter<TasbihState> emit) async {
    final category = state.data.categories.firstWhere((c) => c.id == event.categoryId);
    final progress = await _repository.getSessionProgress(category.id);
    final preferredDuaId = await _repository.getPreferredCompletionDuaId(category.id);
    
    final currentDua = _resolveCompletionDua(state.data, category, preferredDuaId);
    
    emit(state.copyWith(
      currentCategory: category,
      currentCompletionDua: currentDua,
      totalCount: progress,
      currentCycleCount: progress == 0 ? 0 : (progress - 1) % category.countsPerCycle + 1,
      currentCycleIndex: progress == 0 ? 0 : (progress - 1) ~/ category.countsPerCycle,
      showCompletionDua: false,
      duaRemembered: false,
      customTasbihTarget: state.data.settings.customTasbihTarget, // Keep the custom target across categories
    ));
  }

  Future<void> _onIncrement(_Increment event, Emitter<TasbihState> emit) async {
    if (state.showCompletionDua) {
      add(const TasbihEvent.reset());
      return;
    }

    final nextTotalCount = state.totalCount + 1;
    
    if (state.currentCategory.sequenceMode == 'rotating') {
      final countsPerCycle = state.currentCategory.countsPerCycle;
      final completionTrigger = state.currentCategory.completionTrigger;
      
      if (nextTotalCount > completionTrigger) {
        emit(state.copyWith(showCompletionDua: true));
      } else {
        final nextCycleCount = (nextTotalCount - 1) % countsPerCycle + 1;
        final nextCycleIndex = (nextTotalCount - 1) ~/ countsPerCycle;
        
        emit(state.copyWith(
          totalCount: nextTotalCount,
          currentCycleCount: nextCycleCount,
          currentCycleIndex: nextCycleIndex,
        ));
        
        if (nextTotalCount == completionTrigger) {
          emit(state.copyWith(showCompletionDua: true));
        }
      }
    } else {
      final targetCount = state.customTasbihTarget ?? 
                           (state.currentCategory.items.isNotEmpty 
                           ? state.currentCategory.items.first.targetCount 
                           : 33);
          
      if (nextTotalCount >= targetCount) {
        emit(state.copyWith(
          totalCount: nextTotalCount,
          currentCycleCount: nextTotalCount,
          showCompletionDua: state.currentCategory.allowCompletionDua || state.currentCompletionDua != null,
        ));
      } else {
        emit(state.copyWith(
          totalCount: nextTotalCount,
          currentCycleCount: nextTotalCount,
        ));
      }
    }

    await _repository.saveSessionProgress(state.currentCategory.id, state.totalCount);
    
    if (state.currentCategory.items.isNotEmpty) {
      final itemIndex = state.currentCategory.sequenceMode == 'rotating' 
          ? state.currentCycleIndex.clamp(0, state.currentCategory.items.length - 1)
          : 0;
      await _repository.incrementHistory(state.currentCategory.items[itemIndex].id);
    }

    if (state.data.settings.hapticFeedback) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _onReset(_Reset event, Emitter<TasbihState> emit) async {
    await _repository.saveSessionProgress(state.currentCategory.id, 0);
    emit(state.copyWith(
      totalCount: 0,
      currentCycleCount: 0,
      currentCycleIndex: 0,
      showCompletionDua: false,
      duaRemembered: false,
    ));
  }

  Future<void> _onSelectCompletionDua(_SelectCompletionDua event, Emitter<TasbihState> emit) async {
    final dua = state.data.completionDuas.firstWhere((d) => d.id == event.duaId);
    emit(state.copyWith(currentCompletionDua: dua, duaRemembered: false));
  }

  Future<void> _onRememberCompletionDua(_RememberCompletionDua event, Emitter<TasbihState> emit) async {
    if (state.currentCompletionDua != null) {
      await _repository.savePreferredCompletionDuaId(state.currentCategory.id, state.currentCompletionDua!.id);
      emit(state.copyWith(duaRemembered: true));
    }
  }

  Future<void> _onToggleSound(_ToggleSound event, Emitter<TasbihState> emit) async {
    final newSettings = state.data.settings.copyWith(soundEffect: !state.data.settings.soundEffect);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onToggleVibration(_ToggleVibration event, Emitter<TasbihState> emit) async {
    final newSettings = state.data.settings.copyWith(hapticFeedback: !state.data.settings.hapticFeedback);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onToggleTranslation(_ToggleTranslation event, Emitter<TasbihState> emit) async {
    final newSettings = state.data.settings.copyWith(showTranslation: !state.data.settings.showTranslation);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onToggleTransliteration(_ToggleTransliteration event, Emitter<TasbihState> emit) async {
    final newSettings = state.data.settings.copyWith(showTransliteration: !state.data.settings.showTransliteration);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(data: state.data.copyWith(settings: newSettings)));
  }

  Future<void> _onUpdateCustomTarget(_UpdateCustomTarget event, Emitter<TasbihState> emit) async {
    final newSettings = state.data.settings.copyWith(customTasbihTarget: event.target);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(
      data: state.data.copyWith(settings: newSettings),
      customTasbihTarget: event.target,
    ));
  }
}
