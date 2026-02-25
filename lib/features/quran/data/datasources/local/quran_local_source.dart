import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/ayah_entity.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:hive_ce/hive_ce.dart';

abstract interface class QuranLocalSource {
  Future<void> cacheSurahs(List<Surah> surahs);
  Future<List<Surah>> getCachedSurahs();
  Future<void> cacheSurahDetail(Surah surah);
  Future<Surah?> getCachedSurahDetail(int surahNumber);
}

class QuranLocalSourceImpl implements QuranLocalSource {
  final Box<SurahEntity> _surahBox;
  static const String boxName = 'quran_surahs';

  QuranLocalSourceImpl(this._surahBox);

  @override
  Future<void> cacheSurahs(List<Surah> surahs) async {
    // We only cache the basic info if ayahs are empty
    final entities = {
      for (var s in surahs) s.number.value: _toEntity(s)
    };
    await _surahBox.putAll(entities);
  }

  @override
  Future<List<Surah>> getCachedSurahs() async {
    return _surahBox.values.map(_toDomain).toList();
  }

  @override
  Future<void> cacheSurahDetail(Surah surah) async {
    await _surahBox.put(surah.number.value, _toEntity(surah));
  }

  @override
  Future<Surah?> getCachedSurahDetail(int surahNumber) async {
    final entity = _surahBox.get(surahNumber);
    if (entity == null) return null;
    return _toDomain(entity);
  }

  SurahEntity _toEntity(Surah s) {
    return SurahEntity(
      number: s.number.value,
      name: s.name,
      englishName: s.englishName,
      englishNameTranslation: s.englishNameTranslation,
      numberOfAyahs: s.numberOfAyahs,
      revelationType: s.revelationType,
      ayahs: s.ayahs.map((a) => AyahEntity(
        surahNumber: a.number.surahNumber,
        ayahNumber: a.number.ayahNumberInSurah,
        uthmaniText: a.uthmaniText,
        translation: a.translation,
        page: a.page,
        juz: a.juz,
        audioUrl: a.audioUrl,
      )).toList(),
    );
  }

  Surah _toDomain(SurahEntity e) {
    return Surah(
      number: SurahNumber.create(e.number).data!,
      name: e.name,
      englishName: e.englishName,
      englishNameTranslation: e.englishNameTranslation,
      numberOfAyahs: e.numberOfAyahs,
      revelationType: e.revelationType,
      ayahs: e.ayahs.map((ae) => Ayah(
        number: AyahNumber.create(
          surahNumber: ae.surahNumber,
          ayahNumberInSurah: ae.ayahNumber,
        ).data!,
        uthmaniText: ae.uthmaniText,
        translation: ae.translation,
        page: ae.page,
        juz: ae.juz,
        audioUrl: ae.audioUrl,
      )).toList(),
    );
  }
}
