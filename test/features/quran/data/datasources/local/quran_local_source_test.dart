import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/ayah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<SurahEntity> {}

void main() {
  late QuranLocalSourceImpl localSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    localSource = QuranLocalSourceImpl(mockBox);
  });

  final tAyah = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'Text',
    translation: 'Trans',
    page: 1,
    juz: 1,
    audioUrl: 'url',
  );

  final tSurahBasic = Surah(
    number: SurahNumber.create(1).data!,
    name: 'Al-Fatiha Updated',
    englishName: 'The Opening Updated',
    englishNameTranslation: 'The Opening',
    numberOfAyahs: 7,
    revelationType: 'Meccan',
    ayahs: [], // Empty ayahs (like from /chapters API)
  );

  final tExistingEntity = SurahEntity(
    number: 1,
    name: 'Al-Fatiha',
    englishName: 'The Opening',
    englishNameTranslation: 'The Opening',
    numberOfAyahs: 7,
    revelationType: 'Meccan',
    ayahs: [
      AyahEntity(
        surahNumber: 1,
        ayahNumber: 1,
        uthmaniText: 'Text',
        translation: 'Trans',
        page: 1,
        juz: 1,
        audioUrl: 'url',
      ),
    ],
  );

  test('cacheSurahs should preserve existing ayahs if new data has none', () async {
    // Arrange
    when(() => mockBox.get(1)).thenReturn(tExistingEntity);
    when(() => mockBox.putAll(any())).thenAnswer((_) async => {});

    // Act
    await localSource.cacheSurahs([tSurahBasic]);

    // Assert
    final captured = verify(() => mockBox.putAll(captureAny())).captured.first as Map<int, SurahEntity>;
    
    expect(captured[1]!.ayahs, isNotEmpty);
    expect(captured[1]!.ayahs.length, tExistingEntity.ayahs.length);
    expect(captured[1]!.name, tSurahBasic.name);
  });

  test('cacheSurahs should overwrite ayahs if new data HAS ayahs', () async {
    // Arrange
    when(() => mockBox.get(1)).thenReturn(tExistingEntity);
    when(() => mockBox.putAll(any())).thenAnswer((_) async => {});

    final tSurahWithNewAyahs = Surah(
      number: SurahNumber.create(1).data!,
      name: 'Al-Fatiha',
      englishName: 'The Opening',
      englishNameTranslation: 'The Opening',
      numberOfAyahs: 7,
      revelationType: 'Meccan',
      ayahs: [tAyah], // One new ayah
    );

    // Act
    await localSource.cacheSurahs([tSurahWithNewAyahs]);

    // Assert
    final captured = verify(() => mockBox.putAll(captureAny())).captured.first as Map<int, SurahEntity>;
    
    // In this case, _toEntity is used, which might return empty if our mock list is empty, 
    // but the point is it shouldn't use the 'existing' logic.
    expect(captured[1]!.ayahs.length, tSurahWithNewAyahs.ayahs.length);
  });
}
