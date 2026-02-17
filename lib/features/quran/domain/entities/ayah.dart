import 'package:equatable/equatable.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'word.dart';

enum SajdahType { obligatory, recommended }

class Ayah extends Equatable {
  final AyahNumber number;
  final String uthmaniText;
  final String? indoPakText;
  final String? translation;
  final String? transliteration;
  final int page;
  final int juz;
  final int? hizb;
  final int? rub;
  final bool isSajdah;
  final SajdahType? sajdahType;
  final int? revelationOrder;
  final List<Word> words;
  final String? audioUrl;

  const Ayah({
    required this.number,
    required this.uthmaniText,
    this.indoPakText,
    this.translation,
    this.transliteration,
    required this.page,
    required this.juz,
    this.hizb,
    this.rub,
    this.isSajdah = false,
    this.sajdahType,
    this.revelationOrder,
    this.words = const [],
    this.audioUrl,
  });

  Ayah copyWith({
    AyahNumber? number,
    String? uthmaniText,
    String? indoPakText,
    String? translation,
    String? transliteration,
    int? page,
    int? juz,
    int? hizb,
    int? rub,
    bool? isSajdah,
    SajdahType? sajdahType,
    int? revelationOrder,
    List<Word>? words,
    String? audioUrl,
  }) {
    return Ayah(
      number: number ?? this.number,
      uthmaniText: uthmaniText ?? this.uthmaniText,
      indoPakText: indoPakText ?? this.indoPakText,
      translation: translation ?? this.translation,
      transliteration: transliteration ?? this.transliteration,
      page: page ?? this.page,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      rub: rub ?? this.rub,
      isSajdah: isSajdah ?? this.isSajdah,
      sajdahType: sajdahType ?? this.sajdahType,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      words: words ?? this.words,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  @override
  List<Object?> get props => [
        number,
        uthmaniText,
        indoPakText,
        translation,
        transliteration,
        page,
        juz,
        hizb,
        rub,
        isSajdah,
        sajdahType,
        revelationOrder,
        words,
        audioUrl,
      ];
}
