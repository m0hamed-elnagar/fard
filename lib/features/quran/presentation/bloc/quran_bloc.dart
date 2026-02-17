import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';

part 'quran_bloc.freezed.dart';

@freezed
abstract class QuranEvent with _$QuranEvent {
  const factory QuranEvent.loadSurahs() = _LoadSurahs;
  const factory QuranEvent.loadSurahDetails(int surahNumber) = _LoadSurahDetails;
  const factory QuranEvent.search(String query) = _Search;
}

@freezed
abstract class QuranState with _$QuranState {
  const factory QuranState({
    @Default(false) bool isLoading,
    @Default([]) List<Surah> surahs,
    @Default([]) List<Ayah> ayahs,
    Surah? selectedSurah,
    String? error,
    @Default([]) List<SearchResult> searchResults,
  }) = _QuranState;

  factory QuranState.initial() => const QuranState();
}

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository _repository;

  QuranBloc(this._repository) : super(QuranState.initial()) {
    on<_LoadSurahs>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      final result = await _repository.getSurahs();
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (surahs) => emit(state.copyWith(isLoading: false, surahs: surahs)),
      );
    });

    on<_LoadSurahDetails>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
    });

    on<_Search>((event, emit) async {
      if (event.query.isEmpty) {
        emit(state.copyWith(searchResults: []));
        return;
      }
      emit(state.copyWith(isLoading: true, error: null));
      final result = await _repository.search(event.query);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (results) => emit(state.copyWith(isLoading: false, searchResults: results)),
      );
    });
  }
}
