// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasbih_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TasbihItem _$TasbihItemFromJson(Map<String, dynamic> json) => _TasbihItem(
  id: json['id'] as String,
  arabic: json['arabic'] as String,
  transliteration: json['transliteration'] as String,
  translation: json['translation'] as String,
  order: (json['order'] as num?)?.toInt() ?? 0,
  targetCount: (json['target_count'] as num?)?.toInt() ?? 33,
  source: json['source'] as String?,
  virtue: json['virtue'] as String?,
  time: json['time'] as String?,
);

Map<String, dynamic> _$TasbihItemToJson(_TasbihItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'arabic': instance.arabic,
      'transliteration': instance.transliteration,
      'translation': instance.translation,
      'order': instance.order,
      'target_count': instance.targetCount,
      'source': instance.source,
      'virtue': instance.virtue,
      'time': instance.time,
    };

_CompletionDua _$CompletionDuaFromJson(Map<String, dynamic> json) =>
    _CompletionDua(
      id: json['id'] as String,
      title: json['title'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      source: json['source'] as String?,
      optionalRecitation: json['optional_recitation'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CompletionDuaToJson(_CompletionDua instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'arabic': instance.arabic,
      'transliteration': instance.transliteration,
      'translation': instance.translation,
      'source': instance.source,
      'optional_recitation': instance.optionalRecitation,
      'note': instance.note,
    };

_TasbihCategory _$TasbihCategoryFromJson(Map<String, dynamic> json) =>
    _TasbihCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      sequenceMode: json['sequence_mode'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => TasbihItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      defaultCompletionDuaId: json['default_completion_dua_id'] as String?,
      cycles: (json['cycles'] as num?)?.toInt() ?? 1,
      countsPerCycle: (json['counts_per_cycle'] as num?)?.toInt() ?? 33,
      completionTrigger: (json['completion_trigger'] as num?)?.toInt() ?? 99,
      isEditable: json['is_editable'] as bool? ?? false,
      maxTargetCount: (json['max_target_count'] as num?)?.toInt() ?? 1000,
      allowCompletionDua: json['allow_completion_dua'] as bool? ?? false,
    );

Map<String, dynamic> _$TasbihCategoryToJson(_TasbihCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sequence_mode': instance.sequenceMode,
      'items': instance.items,
      'default_completion_dua_id': instance.defaultCompletionDuaId,
      'cycles': instance.cycles,
      'counts_per_cycle': instance.countsPerCycle,
      'completion_trigger': instance.completionTrigger,
      'is_editable': instance.isEditable,
      'max_target_count': instance.maxTargetCount,
      'allow_completion_dua': instance.allowCompletionDua,
    };

_TasbihData _$TasbihDataFromJson(Map<String, dynamic> json) => _TasbihData(
  completionDuas:
      (json['completion_duas'] as List<dynamic>?)
          ?.map((e) => CompletionDua.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories: (json['tasbih_categories'] as List<dynamic>)
      .map((e) => TasbihCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
  settings: TasbihSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TasbihDataToJson(_TasbihData instance) =>
    <String, dynamic>{
      'completion_duas': instance.completionDuas,
      'tasbih_categories': instance.categories,
      'settings': instance.settings,
    };

_TasbihSettings _$TasbihSettingsFromJson(Map<String, dynamic> json) =>
    _TasbihSettings(
      defaultCategory: json['default_category'] as String,
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      soundEffect: json['sound_effect'] as bool? ?? false,
      autoReset: json['auto_reset'] as bool? ?? true,
      showTransliteration: json['show_transliteration'] as bool? ?? true,
      showTranslation: json['show_translation'] as bool? ?? true,
      darkMode: json['dark_mode'] as bool? ?? false,
      keepScreenOn: json['keep_screen_on'] as bool? ?? true,
      statsTracking: json['stats_tracking'] as bool? ?? true,
      customTasbihTarget: (json['custom_tasbih_target'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TasbihSettingsToJson(_TasbihSettings instance) =>
    <String, dynamic>{
      'default_category': instance.defaultCategory,
      'haptic_feedback': instance.hapticFeedback,
      'sound_effect': instance.soundEffect,
      'auto_reset': instance.autoReset,
      'show_transliteration': instance.showTransliteration,
      'show_translation': instance.showTranslation,
      'dark_mode': instance.darkMode,
      'keep_screen_on': instance.keepScreenOn,
      'stats_tracking': instance.statsTracking,
      'custom_tasbih_target': instance.customTasbihTarget,
    };
