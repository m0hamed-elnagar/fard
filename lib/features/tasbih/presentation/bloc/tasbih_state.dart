part of 'tasbih_bloc.dart';

@freezed
sealed class TasbihState with _$TasbihState {
  const factory TasbihState({
    required TasbihData data,
    required TasbihCategory currentCategory,
    CompletionDua? currentCompletionDua,
    @Default(0) int totalCount, 
    @Default(0) int currentCycleCount, 
    @Default(0) int currentCycleIndex, 
    @Default(false) bool showCompletionDua,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool duaRemembered,
    int? customTasbihTarget,
  }) = _TasbihState;

  factory TasbihState.initial() => TasbihState(
        data: const TasbihData(categories: [], settings: TasbihSettings(defaultCategory: '')),
        currentCategory: const TasbihCategory(id: '', name: '', description: '', sequenceMode: ''),
      );
}
