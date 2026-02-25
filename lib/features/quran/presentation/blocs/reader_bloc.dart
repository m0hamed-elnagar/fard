import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:uuid/uuid.dart';

import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';

part 'reader_bloc.freezed.dart';
part 'reader_event.dart';
part 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetSurah getSurah;
  final GetPage getPage;
  final UpdateLastRead updateLastRead;
  final WatchLastRead watchLastRead;
  final BookmarkRepository bookmarkRepository;
  
  ReaderBloc({
    required this.getSurah,
    required this.getPage,
    required this.updateLastRead,
    required this.watchLastRead,
    required this.bookmarkRepository,
  }) : super(const ReaderState.initial()) {
    on<ReaderEvent>((event, emit) async {
      await event.when(
        loadSurah: (surahNumber, translation) => _onLoadSurah(_LoadSurah(surahNumber: surahNumber, translation: translation), emit),
        loadPage: (pageNumber, translation) => _onLoadPage(_LoadPage(pageNumber: pageNumber, translation: translation), emit),
        selectAyah: (ayah) async => _onSelectAyah(_SelectAyah(ayah), emit),
        saveLastRead: (ayah) async => _onSaveLastRead(_SaveLastRead(ayah), emit),
        updateScale: (scale) async => _onUpdateScale(_UpdateScale(scale), emit),
        toggleBookmark: (ayah) async => _onToggleBookmark(_ToggleBookmark(ayah), emit),
        checkBookmarkStatus: (ayahNumber) async => _onCheckBookmarkStatus(_CheckBookmarkStatus(ayahNumber), emit),
        updateTafsir: (tafsirId) async => _onUpdateTafsir(tafsirId, emit),
      );
    });
  }

  void _onUpdateTafsir(int tafsirId, Emitter<ReaderState> emit) {
    state.mapOrNull(
      loaded: (s) {
        emit(s.copyWith(selectedTafsirId: tafsirId));
      },
    );
  }
  
  Future<void> _onLoadSurah(
    _LoadSurah event,
    Emitter<ReaderState> emit,
  ) async {
    emit(const ReaderState.loading());
    
    final result = await getSurah(GetSurahParams(
      surahNumber: event.surahNumber,
      translation: event.translation,
    ));
    
    await result.fold(
      (failure) async => emit(ReaderState.error(failure.message)),
      (surah) async {
        // Get initial last read
        final lastReadRes = await watchLastRead().first;
        final lastReadAyahPos = lastReadRes.data;

        Ayah? lastReadInThisSurah;
        if (lastReadAyahPos != null && lastReadAyahPos.ayahNumber.surahNumber == surah.number.value) {
          try {
            lastReadInThisSurah = surah.ayahs.firstWhere(
              (a) => a.number.ayahNumberInSurah == lastReadAyahPos.ayahNumber.ayahNumberInSurah
            );
          } catch (_) {}
        }

        emit(ReaderState.loaded(
          surah: surah,
          lastReadAyah: lastReadInThisSurah,
        ));

        if (lastReadInThisSurah != null) {
          add(ReaderEvent.checkBookmarkStatus(lastReadInThisSurah.number));
        } else if (surah.ayahs.isNotEmpty) {
           add(ReaderEvent.checkBookmarkStatus(surah.ayahs.first.number));
        }
      },
    );
  }

  Future<void> _onSaveLastRead(
    _SaveLastRead event,
    Emitter<ReaderState> emit,
  ) async {
    await updateLastRead(LastReadPosition(
      ayahNumber: event.ayah.number,
      updatedAt: DateTime.now(),
    ));
    
    state.mapOrNull(
      loaded: (s) {
        emit(s.copyWith(lastReadAyah: event.ayah));
      },
    );
  }
  
  Future<void> _onLoadPage(
    _LoadPage event,
    Emitter<ReaderState> emit,
  ) async {
    emit(const ReaderState.loading());
    
    final result = await getPage(GetPageParams(
      pageNumber: event.pageNumber,
      translation: event.translation,
    ));
    
    result.fold(
      (failure) => emit(ReaderState.error(failure.message)),
      (page) {
        final sortedAyahs = List<Ayah>.from(page.ayahs)
          ..sort((a, b) => a.number.ayahNumberInSurah.compareTo(b.number.ayahNumberInSurah));
          
        emit(ReaderState.loaded(
          surah: Surah(
            number: SurahNumber.create(0).data!,
            name: page.surahName,
            numberOfAyahs: sortedAyahs.length,
            revelationType: '',
            ayahs: sortedAyahs,
          ),
        ));
        if (page.ayahs.isNotEmpty) {
          add(ReaderEvent.checkBookmarkStatus(page.ayahs.first.number));
        }
      },
    );
  }

  Future<void> _onSelectAyah(
    _SelectAyah event,
    Emitter<ReaderState> emit,
  ) async {
    state.mapOrNull(
      loaded: (s) {
        emit(s.copyWith(highlightedAyah: event.ayah));
      },
    );
    add(ReaderEvent.checkBookmarkStatus(event.ayah.number));
  }

  void _onUpdateScale(
    _UpdateScale event,
    Emitter<ReaderState> emit,
  ) {
    state.mapOrNull(
      loaded: (s) {
        emit(s.copyWith(textScale: event.scale.clamp(0.8, 3.0)));
      },
    );
  }

  Future<void> _onToggleBookmark(
    _ToggleBookmark event,
    Emitter<ReaderState> emit,
  ) async {
    final isBookmarkedResult = await bookmarkRepository.isBookmarked(event.ayah.number);
    final isCurrentlyBookmarked = isBookmarkedResult.fold((_) => false, (val) => val);

    if (isCurrentlyBookmarked) {
      final bookmarksRes = await bookmarkRepository.getBookmarks();
      bookmarksRes.fold((_) => null, (bookmarks) async {
        final bookmark = bookmarks.firstWhere(
          (b) => b.ayahNumber == event.ayah.number
        );
        await bookmarkRepository.removeBookmark(bookmark.id);
      });
    } else {
      final bookmark = Bookmark(
        id: const Uuid().v4(),
        ayahNumber: event.ayah.number,
        createdAt: DateTime.now(),
      );
      await bookmarkRepository.addBookmark(bookmark);
    }

    add(ReaderEvent.checkBookmarkStatus(event.ayah.number));
  }

  Future<void> _onCheckBookmarkStatus(
    _CheckBookmarkStatus event,
    Emitter<ReaderState> emit,
  ) async {
    final result = await bookmarkRepository.isBookmarked(event.ayahNumber);
    result.fold(
      (_) => null,
      (isBookmarked) {
        state.mapOrNull(
          loaded: (s) {
            emit(s.copyWith(isBookmarked: isBookmarked));
          },
        );
      },
    );
  }
}
