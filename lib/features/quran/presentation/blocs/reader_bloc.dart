import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';

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
  
  ReaderBloc({
    required this.getSurah,
    required this.getPage,
    required this.updateLastRead,
    required this.watchLastRead,
  }) : super(const ReaderState.initial()) {
    on<ReaderEvent>((event, emit) async {
      await event.when(
        loadSurah: (surahNumber, translation) => _onLoadSurah(_LoadSurah(surahNumber: surahNumber, translation: translation), emit),
        loadPage: (pageNumber, translation) => _onLoadPage(_LoadPage(pageNumber: pageNumber, translation: translation), emit),
        selectAyah: (ayah) async => _onSelectAyah(_SelectAyah(ayah), emit),
        saveLastRead: (ayah) async => _onSaveLastRead(_SaveLastRead(ayah), emit),
        updateScale: (scale) async => _onUpdateScale(_UpdateScale(scale), emit),
      );
    });
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
      (page) => emit(ReaderState.loaded(
        surah: Surah(
          number: SurahNumber.create(0).data!,
          name: page.surahName,
          numberOfAyahs: page.ayahs.length,
          revelationType: '',
          ayahs: page.ayahs,
        ),
      )),
    );
  }

  void _onSelectAyah(
    _SelectAyah event,
    Emitter<ReaderState> emit,
  ) {
    state.mapOrNull(
      loaded: (s) {
        emit(s.copyWith(highlightedAyah: event.ayah));
      },
    );
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
}
