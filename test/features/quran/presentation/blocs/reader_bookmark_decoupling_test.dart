import 'package:bloc_test/bloc_test.dart';
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
  late StreamController<Result<List<Bookmark>>> bookmarkStreamController;
  final List<Bookmark> currentBookmarks = [];

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
    bookmarkStreamController =
        StreamController<Result<List<Bookmark>>>.broadcast();
    currentBookmarks.clear();

    when(
      () => mockQuranRepository.getReaderSeparator(),
    ).thenAnswer((_) async => 0);

    when(
      () => mockQuranRepository.getTextScale(),
    ).thenAnswer((_) async => 1.0);

    when(
      () => mockQuranRepository.getFontFamily(),
    ).thenAnswer((_) async => 'Amiri');
    when(
      () => mockGetSurah(any()),
    ).thenAnswer((_) async => Result.success(tSurah));
    when(() => mockWatchLastRead()).thenAnswer((_) => const Stream.empty());

    when(
      () => mockBookmarkRepository.watchBookmarks(),
    ).thenAnswer((_) => bookmarkStreamController.stream);
    when(
      () => mockBookmarkRepository.getBookmarks(),
    ).thenAnswer((_) async => Result.success(List.from(currentBookmarks)));
    when(() => mockBookmarkRepository.isBookmarked(any())).thenAnswer((
      event,
    ) async {
      final ayahNum = event.positionalArguments[0] as AyahNumber;
      return Result.success(
        currentBookmarks.any((b) => b.ayahNumber == ayahNum),
      );
    });

    when(() => mockBookmarkRepository.addBookmark(any())).thenAnswer((
      event,
    ) async {
      final bookmark = event.positionalArguments[0] as Bookmark;
      currentBookmarks.add(bookmark);
      bookmarkStreamController.add(Result.success(List.from(currentBookmarks)));
      return Result.success(null);
    });

    when(() => mockBookmarkRepository.removeBookmark(any())).thenAnswer((
      event,
    ) async {
      final ayahNum = event.positionalArguments[0] as AyahNumber;
      currentBookmarks.removeWhere((b) => b.ayahNumber == ayahNum);
      bookmarkStreamController.add(Result.success(List.from(currentBookmarks)));
      return Result.success(null);
    });

    when(() => mockBookmarkRepository.clearAllBookmarks()).thenAnswer((
      _,
    ) async {
      currentBookmarks.clear();
      bookmarkStreamController.add(Result.success([]));
      return Result.success(null);
    });

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

  tearDown(() {
    bookmarkStreamController.close();
    readerBloc.close();
  });

  group('Decoupling Bookmark and Last Read', () {
    blocTest<ReaderBloc, ReaderState>(
      'Toggling bookmark on Ayah 2 should NOT update lastReadAyah if it was null',
      build: () => readerBloc,
      act: (bloc) async {
        bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber));
        await Future.delayed(Duration.zero);
        bloc.add(ReaderEvent.toggleBookmark(tAyah2));
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (bloc) {
        final state = bloc.state.mapOrNull(loaded: (s) => s);
        expect(
          state?.bookmarks.any((b) => b.ayahNumber == tAyah2.number),
          isTrue,
        );
        expect(
          state?.lastReadAyah,
          isNull,
          reason: 'Bookmark should not set lastReadAyah',
        );
      },
    );

    blocTest<ReaderBloc, ReaderState>(
      'Toggling bookmark on Ayah 2 should NOT change an existing lastReadAyah on Ayah 1',
      build: () => readerBloc,
      act: (bloc) async {
        bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber));
        await Future.delayed(Duration.zero);

        // Now that it's loaded and subscribed, set a last read
        bloc.add(ReaderEvent.saveLastRead(tAyah1));
        await Future.delayed(Duration.zero);

        // We need to trigger the subscription in ReaderBloc by "loading" or manually setting it up
        // In this simplified test, we'll just emit to the stream
        bookmarkStreamController.add(
          Result.success([
            Bookmark(
              id: '1_2',
              ayahNumber: tAyah2.number,
              createdAt: DateTime.now(),
            ),
          ]),
        );
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (bloc) {
        final state = bloc.state.mapOrNull(loaded: (s) => s);
        expect(
          state?.bookmarks.any((b) => b.ayahNumber == tAyah2.number),
          isTrue,
        );
        expect(
          state?.lastReadAyah,
          tAyah1,
          reason: 'Bookmark should not change existing lastReadAyah',
        );
      },
    );

    blocTest<ReaderBloc, ReaderState>(
      'Saving last read on Ayah 1 should NOT update bookmark',
      build: () => readerBloc,
      seed: () => ReaderState.loaded(surah: tSurah, lastReadAyah: null),
      act: (bloc) => bloc.add(ReaderEvent.saveLastRead(tAyah1)),
      verify: (bloc) {
        final state = bloc.state.mapOrNull(loaded: (s) => s);
        expect(state?.lastReadAyah, tAyah1);
        expect(
          state?.bookmarks,
          isEmpty,
          reason: 'Saving last read should not set bookmark',
        );
      },
    );

    blocTest<ReaderBloc, ReaderState>(
      'Should be able to save multiple bookmarks',
      build: () => readerBloc,
      act: (bloc) async {
        bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber));
        await Future.delayed(Duration.zero);
        bloc.add(ReaderEvent.toggleBookmark(tAyah1));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(ReaderEvent.toggleBookmark(tAyah2));
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (bloc) {
        final state = bloc.state.mapOrNull(loaded: (s) => s);
        expect(state?.bookmarks.length, 2);
        expect(
          state?.bookmarks.any((b) => b.ayahNumber == tAyah1.number),
          isTrue,
        );
        expect(
          state?.bookmarks.any((b) => b.ayahNumber == tAyah2.number),
          isTrue,
        );
      },
    );
    group('Reactive Updates', () {
      blocTest<ReaderBloc, ReaderState>(
        'Should update bookmarks when repository emits new values (external change)',
        build: () => readerBloc,
        seed: () => ReaderState.loaded(surah: tSurah, bookmarks: []),
        act: (bloc) async {
          // Manual setup for subscription in the test seed case
          // In real use, LoadSurah sets up the subscription.
          // Since we seeded ReaderState.loaded, we need to ensure the subscription is active.
          // For the sake of this test, we can just trigger a LoadSurah or manually mock the behavior.

          // Re-load to trigger subscription
          bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber));
          await Future.delayed(Duration.zero);

          final externalBookmark = Bookmark(
            id: '1_1',
            ayahNumber: tAyah1.number,
            createdAt: DateTime.now(),
          );
          bookmarkStreamController.add(Result.success([externalBookmark]));
          await Future.delayed(const Duration(milliseconds: 50));
        },
        verify: (bloc) {
          final state = bloc.state.mapOrNull(loaded: (s) => s);
          expect(state?.bookmarks.length, 1);
          expect(state?.bookmarks.first.ayahNumber, tAyah1.number);
        },
      );
    });
  });
}
