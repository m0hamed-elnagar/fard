// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WordModel _$WordModelFromJson(Map<String, dynamic> json) => WordModel(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  position: (json['position'] as num).toInt(),
  transliteration: json['transliteration'] as Map<String, dynamic>?,
  translation: json['translation'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$WordModelToJson(WordModel instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'position': instance.position,
  'transliteration': instance.transliteration,
  'translation': instance.translation,
};

AudioModel _$AudioModelFromJson(Map<String, dynamic> json) =>
    AudioModel(url: json['url'] as String?);

Map<String, dynamic> _$AudioModelToJson(AudioModel instance) =>
    <String, dynamic>{'url': instance.url};

AyahModel _$AyahModelFromJson(Map<String, dynamic> json) => AyahModel(
  id: (json['id'] as num?)?.toInt(),
  number: (json['verse_number'] as num).toInt(),
  textUthmani: json['text_uthmani'] as String?,
  textIndoPak: json['text_indopak'] as String?,
  juz: (json['juz_number'] as num?)?.toInt(),
  page: (json['page_number'] as num?)?.toInt(),
  hizb: (json['hizb_number'] as num?)?.toInt(),
  rub: (json['rub_el_hizb_number'] as num?)?.toInt(),
  sajdahNumber: (json['sajdah_number'] as num?)?.toInt(),
  sajdahType: json['sajdah_type'] as String?,
  words: (json['words'] as List<dynamic>?)
      ?.map((e) => WordModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  audio: json['audio'] == null
      ? null
      : AudioModel.fromJson(json['audio'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AyahModelToJson(AyahModel instance) => <String, dynamic>{
  'id': instance.id,
  'verse_number': instance.number,
  'text_uthmani': instance.textUthmani,
  'text_indopak': instance.textIndoPak,
  'juz_number': instance.juz,
  'page_number': instance.page,
  'hizb_number': instance.hizb,
  'rub_el_hizb_number': instance.rub,
  'sajdah_number': instance.sajdahNumber,
  'sajdah_type': instance.sajdahType,
  'words': instance.words,
  'audio': instance.audio,
};
