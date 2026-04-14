// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomTheme _$CustomThemeFromJson(Map<String, dynamic> json) => CustomTheme(
  id: json['id'] as String,
  name: json['name'] as String,
  primary: json['primary'] as String,
  accent: json['accent'] as String,
  background: json['background'] as String,
  surface: json['surface'] as String,
  text: json['text'] as String,
  textSecondary: json['textSecondary'] as String,
  cardBorder: json['cardBorder'] as String,
  surfaceLight: json['surfaceLight'] as String,
  isBuiltIn: json['isBuiltIn'] as bool? ?? false,
);

Map<String, dynamic> _$CustomThemeToJson(CustomTheme instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'primary': instance.primary,
      'accent': instance.accent,
      'background': instance.background,
      'surface': instance.surface,
      'text': instance.text,
      'textSecondary': instance.textSecondary,
      'cardBorder': instance.cardBorder,
      'surfaceLight': instance.surfaceLight,
      'isBuiltIn': instance.isBuiltIn,
    };
