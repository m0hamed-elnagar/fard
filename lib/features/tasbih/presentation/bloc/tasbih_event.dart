part of 'tasbih_bloc.dart';

@freezed
class TasbihEvent with _$TasbihEvent {
  const factory TasbihEvent.loadData() = _LoadData;
  const factory TasbihEvent.selectCategory(String categoryId) = _SelectCategory;
  const factory TasbihEvent.increment() = _Increment;
  const factory TasbihEvent.reset() = _Reset;
  const factory TasbihEvent.toggleSound() = _ToggleSound;
  const factory TasbihEvent.toggleVibration() = _ToggleVibration;
  const factory TasbihEvent.toggleTranslation() = _ToggleTranslation;
  const factory TasbihEvent.toggleTransliteration() = _ToggleTransliteration;
  const factory TasbihEvent.selectCompletionDua(String duaId) = _SelectCompletionDua;
  const factory TasbihEvent.rememberCompletionDua() = _RememberCompletionDua;
  const factory TasbihEvent.updateCustomTarget(int? target) = _UpdateCustomTarget;
}
