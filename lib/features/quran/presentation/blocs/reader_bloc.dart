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
import 'package:fard/core/errors/failure.dart';
import 'dart:async';
import 'package:injectable/injectable.dart';

part 'reader_bloc.freezed.dart';
part 'reader_event.dart';
part 'reader_state.dart';

@injectable
class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetSurah getSurah;
  final GetPage getPage;
  final UpdateLastRead updateLastRead;
  final WatchLastRead watchLastRead;
  final BookmarkRepository bookmarkRepository;
  final QuranRepository quranRepository;
  StreamSubscription? _lastReadSubscription;
  StreamSubscription? _bookmarksSubscription;

  ReaderBloc({
    required this.getSurah,
    required this.getPage,
    required this.updateLastRead,
    required this.watchLastRead,
    required this.bookmarkRepository,
    required this.quranRepository,
  }) : super(const ReaderState.initial()) {
    on<_LoadSurah>((event, emit) async {
      try {
        emit(const ReaderState.loading());
        final result = await getSurah(
          GetSurahParams(surahNumber: event.surahNumber),
        );

        // Load settings in parallel to avoid sequential awaiting
        final settings = await Future.wait([
          quranRepository.getReaderSeparator(),
          quranRepository.getTextScale(),
          quranRepository.getFontFamily(),
          bookmarkRepository.getBookmarks(),
        ]);

        final separator = ReaderSeparator.values[settings[0] as int];
        final textScale = settings[1] as double;
        final fontFamily = settings[2] as String;
        final bookmarksRes = settings[3] as Result<List<Bookmark>>;
        final bookmarks = bookmarksRes.fold((_) => <Bookmark>[], (v) => v);

        result.fold(
          (failure) => emit(ReaderState.error(failure.message)),
          (surah) {
            Ayah? highlightedAyah;
            if (event.initialAyahNumber != null) {
              highlightedAyah = surah.ayahs.firstWhere(
                (a) => a.number.ayahNumberInSurah == event.initialAyahNumber,
                orElse: () => surah.ayahs.first,
              );
            }

            emit(
              ReaderState.loaded(
                surah: surah,
                separator: separator,
                textScale: textScale,
                fontFamily: fontFamily,
                bookmarks: bookmarks,
                highlightedAyah: highlightedAyah,
              ),
            );

            _lastReadSubscription?.cancel();
            _lastReadSubscription = watchLastRead().listen((result) {
              result.fold((_) => null, (position) {
                state.mapOrNull(
                  loaded: (s) {
                    if (position.ayahNumber.surahNumber ==
                        s.surah.number.value) {
                      final ayah = s.surah.ayahs.firstWhere(
                        (a) =>
                            a.number.ayahNumberInSurah ==
                            position.ayahNumber.ayahNumberInSurah,
                        orElse: () => s.surah.ayahs.first,
                      );

                      // FIX: Only auto-select if NOTHING is highlighted yet
                      if (s.lastReadAyah == null && s.highlightedAyah == null) {
                        add(ReaderEvent.selectAyah(ayah));
                      }
                    }
                  },
                );
              });
            });

            _bookmarksSubscription?.cancel();
            _bookmarksSubscription = bookmarkRepository
                .watchBookmarks()
                .listen((result) {
              result.fold(
                (_) => null,
                (bookmarks) => add(ReaderEvent.bookmarksUpdated(bookmarks)),
              );
            });
          },
        );
      } catch (e) {
        emit(ReaderState.error(e.toString()));
      }
    });

    on<_BookmarksUpdated>((event, emit) {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(bookmarks: event.bookmarks));
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
        emit(
          s.copyWith(
            lastReadAyah: event.ayah,
            highlightedAyah: event.ayah, // Highlight it
          ),
        );
      }

      await updateLastRead(
        LastReadPosition(
          ayahNumber: event.ayah.number,
          updatedAt: DateTime.now(),
        ),
      );
    });

    on<_UpdateScale>((event, emit) async {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(textScale: event.scale.clamp(0.5, 3.0)));
        },
      );
      await quranRepository.updateTextScale(event.scale.clamp(0.5, 3.0));
    });

    on<_UpdateFontFamily>((event, emit) async {
      state.mapOrNull(
        loaded: (s) {
          emit(s.copyWith(fontFamily: event.fontFamily));
        },
      );
      await quranRepository.updateFontFamily(event.fontFamily);
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

      final isBookmarked = s.bookmarks.any(
        (b) => b.ayahNumber == event.ayah.number,
      );

      if (isBookmarked) {
        await bookmarkRepository.removeBookmark(event.ayah.number);
      } else {
        final newBookmark = Bookmark(
          id: '${event.ayah.number.surahNumber}_${event.ayah.number.ayahNumberInSurah}',
          ayahNumber: event.ayah.number,
          createdAt: DateTime.now(),
        );
        await bookmarkRepository.addBookmark(newBookmark);
      }
    });

    on<_CheckBookmark>((event, emit) async {
      // isBookmarked removed from state
    });
  }

  @override
  Future<void> close() {
    _lastReadSubscription?.cancel();
    _bookmarksSubscription?.cancel();
    return super.close();
  }
}
