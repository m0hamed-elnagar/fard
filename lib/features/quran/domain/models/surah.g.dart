// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Surah _$SurahFromJson(Map<String, dynamic> json) => _Surah(
  number: (json['number'] as num).toInt(),
  name: json['name'] as String,
  englishName: json['englishName'] as String,
  englishNameTranslation: json['englishNameTranslation'] as String,
  numberOfAyahs: (json['numberOfAyahs'] as num).toInt(),
  revelationType: json['revelationType'] as String,
);

Map<String, dynamic> _$SurahToJson(_Surah instance) => <String, dynamic>{
  'number': instance.number,
  'name': instance.name,
  'englishName': instance.englishName,
  'englishNameTranslation': instance.englishNameTranslation,
  'numberOfAyahs': instance.numberOfAyahs,
  'revelationType': instance.revelationType,
};

_SurahDetail _$SurahDetailFromJson(Map<String, dynamic> json) => _SurahDetail(
  number: (json['number'] as num).toInt(),
  name: json['name'] as String,
  englishName: json['englishName'] as String,
  englishNameTranslation: json['englishNameTranslation'] as String,
  revelationType: json['revelationType'] as String,
  numberOfAyahs: (json['numberOfAyahs'] as num).toInt(),
  ayahs: (json['ayahs'] as List<dynamic>)
      .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SurahDetailToJson(_SurahDetail instance) =>
    <String, dynamic>{
      'number': instance.number,
      'name': instance.name,
      'englishName': instance.englishName,
      'englishNameTranslation': instance.englishNameTranslation,
      'revelationType': instance.revelationType,
      'numberOfAyahs': instance.numberOfAyahs,
      'ayahs': instance.ayahs,
    };
