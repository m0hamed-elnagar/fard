import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/reader_settings.dart';
import 'dart:async';

part 'reader_bloc.freezed.dart';
part 'reader_event.dart';
part 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetSurah getSurah;
  final GetPage getPage;
  final UpdateLastRead updateLastRead;
  final WatchLastRead watchLastRead;
  final BookmarkRepository bookmarkRepository;
  final QuranRepository quranRepository;
  StreamSubscription? _lastReadSubscription;

  ReaderBloc({
    required this.getSurah,
    required this.getPage,
    required this.updateLastRead,
    required this.watchLastRead,
    required this.bookmarkRepository,
    required this.quranRepository,
  }) : super(const ReaderState.initial()) {
    on<_LoadSurah>((event, emit) async {
      emit(const ReaderState.loading());
      final result = await getSurah(GetSurahParams(surahNumber: event.surahNumber));
      final separatorIndex = await quranRepository.getReaderSeparator();
      final separator = ReaderSeparator.values[separatorIndex];
      
      await result.fold(
        (failure) async => emit(ReaderState.error(failure.message)),
        (surah) async {
          final bookmarkRes = await bookmarkRepository.getBookmark();
          final bookmark = bookmarkRes.fold((_) => null, (v) => v);
          
          emit(ReaderState.loaded(
            surah: surah, 
            separator: separator,
            bookmark: bookmark,
          ));
          
          _lastReadSubscription?.cancel();
          _lastReadSubscription = watchLastRead().listen((result) {
            result.fold(
              (_) => null,
              (position) {
                state.mapOrNull(
                  loaded: (s) {
                    if (position.ayahNumber.surahNumber == s.surah.number.value) {
                      final ayah = s.surah.ayahs.firstWhere(
                        (a) => a.number.ayahNumberInSurah == position.ayahNumber.ayahNumberInSurah,
                        orElse: () => s.surah.ayahs.first,
                      );
                      
                      // Avoid infinite loop by checking if it's actually a new position
                      if (s.lastReadAyah?.number != ayah.number) {
                        add(ReaderEvent.saveLastRead(ayah));
                      }
                    }
                  },
                );
              },
            );
          });
        },
      );
    });

    on<_SelectAyah>((event, emit) {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(highlightedAyah: event.ayah));
        },
      );
    });

    on<_SaveLastRead>((event, emit) async {
      final s = state.mapOrNull(loaded: (s) => s);
      if (s != null) {
        final newBookmark = Bookmark(
          id: 'active_bookmark',
          ayahNumber: event.ayah.number,
          createdAt: DateTime.now(),
        );
        await bookmarkRepository.setBookmark(newBookmark);
        emit(s.copyWith(
          lastReadAyah: event.ayah,
          bookmark: newBookmark,
          isBookmarked: true,
          highlightedAyah: event.ayah, // Highlight it
        ));
      }
      
      await updateLastRead(LastReadPosition(
        ayahNumber: event.ayah.number,
        updatedAt: DateTime.now(),
      ));
    });

    on<_UpdateScale>((event, emit) {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(textScale: event.scale.clamp(0.5, 3.0)));
        },
      );
    });

    on<_UpdateSeparator>((event, emit) async {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(separator: event.separator));
        },
      );
      await quranRepository.updateReaderSeparator(event.separator.index);
    });

    on<_UpdateTafsir>((event, emit) {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(selectedTafsirId: event.tafsirId));
        },
      );
    });

    on<_ToggleBookmark>((event, emit) async {
      final s = state.mapOrNull(loaded: (s) => s);
      if (s == null) return;

      final isBookmarkedRes = await bookmarkRepository.isBookmarked(event.ayah.number);
      final isBookmarked = isBookmarkedRes.fold((_) => false, (v) => v);

      if (isBookmarked) {
        // If clicking the ALREADY bookmarked ayah, remove it
        await bookmarkRepository.clearBookmark();
        emit(s.copyWith(isBookmarked: false, bookmark: null));
      } else {
        // If clicking ANY OTHER ayah, it becomes the new single bookmark (replacing the old one)
        final newBookmark = Bookmark(
          id: 'active_bookmark',
          ayahNumber: event.ayah.number,
          createdAt: DateTime.now(),
        );
        await bookmarkRepository.setBookmark(newBookmark);
        emit(s.copyWith(
          isBookmarked: true, 
          bookmark: newBookmark, 
          lastReadAyah: event.ayah,
          highlightedAyah: event.ayah, // Highlight it
        ));
      }
    });

    on<_CheckBookmark>((event, emit) async {
      final s = state.mapOrNull(loaded: (s) => s);
      if (s == null) return;

      final result = await bookmarkRepository.isBookmarked(event.ayah.number);

      result.fold(
        (_) => null,
        (isBookmarked) => emit(s.copyWith(isBookmarked: isBookmarked)),
      );
    });
  }

  @override
  Future<void> close() {
    _lastReadSubscription?.cancel();
    return super.close();
  }
}
