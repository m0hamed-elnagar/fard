// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurahModel _$SurahModelFromJson(Map<String, dynamic> json) => SurahModel(
  id: (json['id'] as num).toInt(),
  name: json['name_arabic'] as String,
  englishName: json['name_simple'] as String?,
  translatedName: json['translated_name'] as Map<String, dynamic>?,
  numberOfAyahs: (json['verses_count'] as num).toInt(),
  revelationType: json['revelation_place'] as String,
  revelationOrder: (json['revelation_order'] as num?)?.toInt(),
  verses: (json['verses'] as List<dynamic>?)
      ?.map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SurahModelToJson(SurahModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_arabic': instance.name,
      'name_simple': instance.englishName,
      'translated_name': instance.translatedName,
      'verses_count': instance.numberOfAyahs,
      'revelation_place': instance.revelationType,
      'revelation_order': instance.revelationOrder,
      'verses': instance.verses,
    };
