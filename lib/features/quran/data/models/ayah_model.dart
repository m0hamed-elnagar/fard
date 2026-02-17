import 'package:json_annotation/json_annotation.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/word.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

part 'ayah_model.g.dart';

@JsonSerializable()
class WordModel {
  final int id;
  final String text;
  final int position;
  final Map<String, dynamic>? transliteration;
  final Map<String, dynamic>? translation;

  const WordModel({
    required this.id,
    required this.text,
    required this.position,
    this.transliteration,
    this.translation,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) => _$WordModelFromJson(json);
  Map<String, dynamic> toJson() => _$WordModelToJson(this);

  Word toDomain() {
    return Word(
      id: id,
      text: text,
      transliteration: transliteration?['text'] as String? ?? '',
      translation: translation?['text'] as String? ?? '',
      position: position,
    );
  }
}

@JsonSerializable()
class AudioModel {
  final String? url;

  const AudioModel({this.url});

  factory AudioModel.fromJson(Map<String, dynamic> json) => _$AudioModelFromJson(json);
  Map<String, dynamic> toJson() => _$AudioModelToJson(this);
}

@JsonSerializable()
class AyahModel {
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'verse_number')
  final int number;
  @JsonKey(name: 'text_uthmani')
  final String? textUthmani;
  @JsonKey(name: 'text_indopak')
  final String? textIndoPak;
  @JsonKey(name: 'juz_number')
  final int? juz;
  @JsonKey(name: 'page_number')
  final int? page;
  @JsonKey(name: 'hizb_number')
  final int? hizb;
  @JsonKey(name: 'rub_el_hizb_number')
  final int? rub;
  @JsonKey(name: 'sajdah_number')
  final int? sajdahNumber;
  @JsonKey(name: 'sajdah_type')
  final String? sajdahType;
  final List<WordModel>? words;
  final AudioModel? audio;

  const AyahModel({
    this.id,
    required this.number,
    this.textUthmani,
    this.textIndoPak,
    this.juz,
    this.page,
    this.hizb,
    this.rub,
    this.sajdahNumber,
    this.sajdahType,
    this.words,
    this.audio,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) => _$AyahModelFromJson(json);
  Map<String, dynamic> toJson() => _$AyahModelToJson(this);

  Ayah toDomain(int surahNumber, {String? translation}) {
    final ayahNumberResult = AyahNumber.create(
      surahNumber: surahNumber,
      ayahNumberInSurah: number,
    );

    SajdahType? type;
    if (sajdahType == 'recommended') {
      type = SajdahType.recommended;
    } else if (sajdahType == 'obligatory') {
      type = SajdahType.obligatory;
    }

    String? fullAudioUrl;
    if (audio?.url != null) {
      if (audio!.url!.startsWith('http')) {
        fullAudioUrl = audio!.url;
      } else {
        fullAudioUrl = 'https://verses.quran.com/${audio!.url}';
      }
    }

    return Ayah(
      number: ayahNumberResult.data!,
      uthmaniText: textUthmani ?? '',
      indoPakText: textIndoPak,
      translation: translation,
      page: page ?? 0,
      juz: juz ?? 0,
      hizb: hizb,
      rub: rub,
      isSajdah: sajdahNumber != null,
      sajdahType: type,
      words: words?.map((w) => w.toDomain()).toList() ?? [],
      audioUrl: fullAudioUrl,
    );
  }
}
