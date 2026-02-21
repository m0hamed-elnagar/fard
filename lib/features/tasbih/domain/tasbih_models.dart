import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasbih_models.freezed.dart';
part 'tasbih_models.g.dart';

@freezed
sealed class TasbihItem with _$TasbihItem {
  const factory TasbihItem({
    required String id,
    required String arabic,
    required String transliteration,
    required String translation,
    @Default(0) int order,
    @JsonKey(name: 'target_count') @Default(33) int targetCount,
    String? source,
    String? virtue,
    String? time,
  }) = _TasbihItem;

  factory TasbihItem.fromJson(Map<String, dynamic> json) => _$TasbihItemFromJson(json);
}

@freezed
sealed class CompletionDua with _$CompletionDua {
  const factory CompletionDua({
    required String id,
    required String title,
    required String arabic,
    required String transliteration,
    required String translation,
    String? source,
    @JsonKey(name: 'optional_recitation') String? optionalRecitation,
    String? note,
  }) = _CompletionDua;

  factory CompletionDua.fromJson(Map<String, dynamic> json) => _$CompletionDuaFromJson(json);
}

@freezed
sealed class TasbihCategory with _$TasbihCategory {
  const factory TasbihCategory({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'sequence_mode') required String sequenceMode,
    @Default([]) List<TasbihItem> items,
    @JsonKey(name: 'default_completion_dua_id') String? defaultCompletionDuaId,
    @Default(1) int cycles,
    @JsonKey(name: 'counts_per_cycle') @Default(33) int countsPerCycle,
    @JsonKey(name: 'completion_trigger') @Default(99) int completionTrigger,
    @JsonKey(name: 'is_editable') @Default(false) bool isEditable,
    @JsonKey(name: 'max_target_count') @Default(1000) int maxTargetCount,
    @JsonKey(name: 'allow_completion_dua') @Default(false) bool allowCompletionDua,
  }) = _TasbihCategory;

  factory TasbihCategory.fromJson(Map<String, dynamic> json) => _$TasbihCategoryFromJson(json);
}

@freezed
sealed class TasbihData with _$TasbihData {
  const factory TasbihData({
    @JsonKey(name: 'completion_duas') @Default([]) List<CompletionDua> completionDuas,
    @JsonKey(name: 'tasbih_categories') required List<TasbihCategory> categories,
    required TasbihSettings settings,
  }) = _TasbihData;

  factory TasbihData.fromJson(Map<String, dynamic> json) => _$TasbihDataFromJson(json);
}

@freezed
sealed class TasbihSettings with _$TasbihSettings {
  const factory TasbihSettings({
    @JsonKey(name: 'default_category') required String defaultCategory,
    @JsonKey(name: 'haptic_feedback') @Default(true) bool hapticFeedback,
    @JsonKey(name: 'sound_effect') @Default(false) bool soundEffect,
    @JsonKey(name: 'auto_reset') @Default(true) bool autoReset,
    @JsonKey(name: 'show_transliteration') @Default(true) bool showTransliteration,
    @JsonKey(name: 'show_translation') @Default(true) bool showTranslation,
    @JsonKey(name: 'dark_mode') @Default(false) bool darkMode,
    @JsonKey(name: 'keep_screen_on') @Default(true) bool keepScreenOn,
    @JsonKey(name: 'stats_tracking') @Default(true) bool statsTracking,
  }) = _TasbihSettings;

  factory TasbihSettings.fromJson(Map<String, dynamic> json) => _$TasbihSettingsFromJson(json);
}
