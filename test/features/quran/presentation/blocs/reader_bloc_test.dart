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
import 'package:fard/core/errors/failure.dart';

class MockGetSurah extends Mock implements GetSurah {}
class MockGetPage extends Mock implements GetPage {}
class MockUpdateLastRead extends Mock implements UpdateLastRead {}
class MockWatchLastRead extends Mock implements WatchLastRead {}
class MockBookmarkRepository extends Mock implements BookmarkRepository {}

// Helper to create valid SurahNumber
class FakeGetSurahParams extends Fake implements GetSurahParams {}
class FakeAyahNumber extends Fake implements AyahNumber {}

void main() {
  late ReaderBloc readerBloc;
  late MockGetSurah mockGetSurah;
  late MockGetPage mockGetPage;
  late MockUpdateLastRead mockUpdateLastRead;
  late MockWatchLastRead mockWatchLastRead;
  late MockBookmarkRepository mockBookmarkRepository;

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
    
    // Default mock for checkBookmarkStatus
    when(() => mockBookmarkRepository.isBookmarked(any()))
        .thenAnswer((_) async => Result.success(false));

    readerBloc = ReaderBloc(
      getSurah: mockGetSurah,
      getPage: mockGetPage,
      updateLastRead: mockUpdateLastRead,
      watchLastRead: mockWatchLastRead,
      bookmarkRepository: mockBookmarkRepository,
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

    test('initial state is ReaderState.initial', () {
      expect(readerBloc.state, const ReaderState.initial());
    });

    blocTest<ReaderBloc, ReaderState>(
      'emits [loading, loaded] when loadSurah is added and watchLastRead fails (empty cache)',
      build: () {
        // Setup GetSurah success
        when(() => mockGetSurah(any())).thenAnswer((_) async => Result.success(tSurah));
        
        // Setup WatchLastRead to emit failure (simulating no cache)
        when(() => mockWatchLastRead()).thenAnswer(
          (_) => Stream.value(Result.failure(const CacheFailure('No last read position found')))
        );
        
        return readerBloc;
      },
      act: (bloc) => bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber)),
      expect: () => [
        const ReaderState.loading(),
        ReaderState.loaded(surah: tSurah, lastReadAyah: null, isBookmarked: false),
      ],
    );

    blocTest<ReaderBloc, ReaderState>(
      'emits [loading, error] when loadSurah fails',
      build: () {
        when(() => mockGetSurah(any())).thenAnswer((_) async => Result.failure(const ServerFailure()));
        return readerBloc;
      },
      act: (bloc) => bloc.add(ReaderEvent.loadSurah(surahNumber: tSurahNumber)),
      expect: () => [
        const ReaderState.loading(),
        const ReaderState.error('Server Failure'),
      ],
    );
  });
}
