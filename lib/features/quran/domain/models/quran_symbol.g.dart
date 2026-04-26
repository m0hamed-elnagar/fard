// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_symbol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuranSymbol _$QuranSymbolFromJson(Map<String, dynamic> json) => _QuranSymbol(
  id: json['id'] as String,
  char: json['char'] as String,
  arabicName: json['arabic_name'] as String,
  brief: json['brief'] as String,
  ruleSummary: json['rule_summary'] as String,
  difficulty: (json['difficulty'] as num).toInt(),
  color: json['color'] as String,
  sources: (json['sources'] as List<dynamic>)
      .map((e) => SymbolSource.fromJson(e as Map<String, dynamic>))
      .toList(),
  examples:
      (json['examples'] as List<dynamic>?)
          ?.map((e) => SymbolExample.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$QuranSymbolToJson(_QuranSymbol instance) =>
    <String, dynamic>{
      'id': instance.id,
      'char': instance.char,
      'arabic_name': instance.arabicName,
      'brief': instance.brief,
      'rule_summary': instance.ruleSummary,
      'difficulty': instance.difficulty,
      'color': instance.color,
      'sources': instance.sources,
      'examples': instance.examples,
    };

_SymbolSource _$SymbolSourceFromJson(Map<String, dynamic> json) =>
    _SymbolSource(
      name: json['name'] as String,
      sourceType: json['type'] as String,
      content: json['text'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$SymbolSourceToJson(_SymbolSource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.sourceType,
      'text': instance.content,
      'url': instance.url,
    };

_SymbolExample _$SymbolExampleFromJson(Map<String, dynamic> json) =>
    _SymbolExample(
      surah: (json['surah'] as num).toInt(),
      ayah: (json['ayah'] as num).toInt(),
      context: json['context'] as String?,
    );

Map<String, dynamic> _$SymbolExampleToJson(_SymbolExample instance) =>
    <String, dynamic>{
      'surah': instance.surah,
      'ayah': instance.ayah,
      'context': instance.context,
    };
