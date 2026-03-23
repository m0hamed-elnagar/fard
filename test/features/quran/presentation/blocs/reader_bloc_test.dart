import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/core/errors/failure.dart';

class MockGetSurah extends Mock implements GetSurah {}
class MockGetPage extends Mock implements GetPage {}
class MockUpdateLastRead extends Mock implements UpdateLastRead {}
class MockWatchLastRead extends Mock implements WatchLastRead {}
class MockBookmarkRepository extends Mock implements BookmarkRepository {}
class MockQuranRepository extends Mock implements QuranRepository {}

class FakeGetSurahParams extends Fake implements GetSurahParams {}
class FakeAyahNumber extends Fake implements AyahNumber {}

void main() {
  late ReaderBloc readerBloc;
  late MockGetSurah mockGetSurah;
  late MockGetPage mockGetPage;
  late MockUpdateLastRead mockUpdateLastRead;
  late MockWatchLastRead mockWatchLastRead;
  late MockBookmarkRepository mockBookmarkRepository;
  late MockQuranRepository mockQuranRepository;

  setUpAll(() {
    registerFallbackValue(FakeGetSurahParams());
    registerFallbackValue(FakeAyahNumber());
  });

  setUp(() {
    mockGetSurah = MockGetSurah();
    mockGetPage = MockGetPage();
    mockUpdateLastRead = MockUpdateLastRead();
    mockWatchLastRead = MockWatchLastRead();
    mockBookmarkRepository = MockBookmarkRepository();
    mockQuranRepository = MockQuranRepository();
    
    when(() => mockBookmarkRepository.isBookmarked(any()))
        .thenAnswer((_) async => Result.success(false));
    
    when(() => mockBookmarkRepository.getBookmarks())
        .thenAnswer((_) async => Result.success([]));
    
    when(() => mockBookmarkRepository.watchBookmarks())
        .thenAnswer((_) => Stream.value(Result.success([])));
    
    when(() => mockQuranRepository.getReaderSeparator())
        .thenAnswer((_) async => 0);

    readerBloc = ReaderBloc(
      getSurah: mockGetSurah,
      getPage: mockGetPage,
      updateLastRead: mockUpdateLastRead,
      watchLastRead: mockWatchLastRead,
      bookmarkRepository: mockBookmarkRepository,
      quranRepository: mockQuranRepository,
    );
  });

  tearDown(() {
    readerBloc.close();
  });

  group('ReaderBloc', () {
    final tSurahNumber = SurahNumber.create(1).data!;
    final tSurah = Surah(
      number: tSurahNumber,
      name: 'Al-Fatihah',
      numberOfAyahs: 7,
      revelationType: 'Meccan',
      ayahs: [],
    );

    blocTest<ReaderBloc, ReaderState>(
      'emits [loading, loaded] when loadSurah is added',
      build: () {
        when(() => mockGetSurah(any())).thenAnswer((_) async => Result.success(tSurah));
        when(() => mockWatchLastRead()).thenAnswer(
          (_) => Stream.value(Result.failure(const CacheFailure('No last read position found')))
        );
        return readerBloc;
      },
      act: (bloc) => bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber)),
      expect: () => [
        const ReaderState.loading(),
        ReaderState.loaded(surah: tSurah, lastReadAyah: null, bookmarks: []),
      ],
    );
  });
}
