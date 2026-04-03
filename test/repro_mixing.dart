import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/core/errors/failure.dart';
import 'dart:async';

class MockGetSurah extends Mock implements GetSurah {}

class MockGetPage extends Mock implements GetPage {}

class MockUpdateLastRead extends Mock implements UpdateLastRead {}

class MockWatchLastRead extends Mock implements WatchLastRead {}

class MockBookmarkRepository extends Mock implements BookmarkRepository {}

class MockQuranRepository extends Mock implements QuranRepository {}

class FakeGetSurahParams extends Fake implements GetSurahParams {}

class FakeAyahNumber extends Fake implements AyahNumber {}

class FakeBookmark extends Fake implements Bookmark {}

class FakeLastReadPosition extends Fake implements LastReadPosition {}

void main() {
  late ReaderBloc readerBloc;
  late MockGetSurah mockGetSurah;
  late MockGetPage mockGetPage;
  late MockUpdateLastRead mockUpdateLastRead;
  late MockWatchLastRead mockWatchLastRead;
  late MockBookmarkRepository mockBookmarkRepository;
  late MockQuranRepository mockQuranRepository;

  final tSurahNumber = SurahNumber.create(1).data!;
  final tAyah1 = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!,
    uthmaniText: 'Bismillah',
    page: 1,
    juz: 1,
  );
  final tAyah2 = Ayah(
    number: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 2).data!,
    uthmaniText: 'Alhamdulillah',
    page: 1,
    juz: 1,
  );
  final tSurah = Surah(
    number: tSurahNumber,
    name: 'Al-Fatihah',
    numberOfAyahs: 7,
    revelationType: 'Meccan',
    ayahs: [tAyah1, tAyah2],
  );

  setUpAll(() {
    registerFallbackValue(FakeGetSurahParams());
    registerFallbackValue(FakeAyahNumber());
    registerFallbackValue(FakeBookmark());
    registerFallbackValue(FakeLastReadPosition());
  });

  setUp(() {
    mockGetSurah = MockGetSurah();
    mockGetPage = MockGetPage();
    mockUpdateLastRead = MockUpdateLastRead();
    mockWatchLastRead = MockWatchLastRead();
    mockBookmarkRepository = MockBookmarkRepository();
    mockQuranRepository = MockQuranRepository();

    when(
      () => mockQuranRepository.getReaderSeparator(),
    ).thenAnswer((_) async => 0);
    when(
      () => mockGetSurah(any()),
    ).thenAnswer((_) async => Result.success(tSurah));
    when(() => mockWatchLastRead()).thenAnswer((_) => const Stream.empty());
    when(
      () => mockBookmarkRepository.getBookmarks(),
    ).thenAnswer((_) async => Result.success([]));
    when(
      () => mockBookmarkRepository.isBookmarked(any()),
    ).thenAnswer((_) async => Result.success(false));
    when(
      () => mockBookmarkRepository.addBookmark(any()),
    ).thenAnswer((_) async => Result.success(null));
    when(
      () => mockBookmarkRepository.removeBookmark(any()),
    ).thenAnswer((_) async => Result.success(null));
    when(
      () => mockBookmarkRepository.clearAllBookmarks(),
    ).thenAnswer((_) async => Result.success(null));
    when(
      () => mockUpdateLastRead(any()),
    ).thenAnswer((_) async => Result.success(null));

    readerBloc = ReaderBloc(
      getSurah: mockGetSurah,
      getPage: mockGetPage,
      updateLastRead: mockUpdateLastRead,
      watchLastRead: mockWatchLastRead,
      bookmarkRepository: mockBookmarkRepository,
      quranRepository: mockQuranRepository,
    );
  });

  test(
    'Reproduction: Toggling bookmark should NOT update lastReadAyah',
    () async {
      // 1. Load Surah
      readerBloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber));
      await expectLater(
        readerBloc.stream,
        emitsThrough(
          isA<ReaderState>().having(
            (s) => s.maybeMap(loaded: (l) => l.surah.name, orElse: () => null),
            'name',
            'Al-Fatihah',
          ),
        ),
      );

      // 2. Toggle Bookmark on Ayah 2
      readerBloc.add(ReaderEvent.toggleBookmark(tAyah2));

      // Wait for state update
      await Future.delayed(Duration.zero);

      final state = readerBloc.state.mapOrNull(loaded: (s) => s);
      expect(
        state?.bookmarks.any((b) => b.ayahNumber == tAyah2.number),
        isTrue,
      );

      // THE CRITICAL CHECK:
      expect(
        state?.lastReadAyah,
        isNull,
        reason: 'Toggling bookmark MUST NOT update lastReadAyah',
      );
    },
  );
}
