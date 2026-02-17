import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';

part 'reader_bloc.freezed.dart';
part 'reader_event.dart';
part 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetSurah getSurah;
  final GetPage getPage;
  
  ReaderBloc({
    required this.getSurah,
    required this.getPage,
  }) : super(const ReaderState.initial()) {
    on<ReaderEvent>((event, emit) async {
      await event.when(
        loadSurah: (surahNumber, translation) => _onLoadSurah(_LoadSurah(surahNumber: surahNumber, translation: translation), emit),
        loadPage: (pageNumber, translation) => _onLoadPage(_LoadPage(pageNumber: pageNumber, translation: translation), emit),
        selectAyah: (ayah) async => _onSelectAyah(_SelectAyah(ayah), emit),
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
    
    result.fold(
      (failure) => emit(ReaderState.error(failure.message)),
      (surah) => emit(ReaderState.loaded(
        surah: surah,
      )),
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
