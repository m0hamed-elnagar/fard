import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/repositories/quran_repository.dart';
import '../../domain/models/surah.dart';
import '../../domain/models/ayah.dart';

part 'quran_bloc.freezed.dart';

@freezed
sealed class QuranEvent with _$QuranEvent {
  const factory QuranEvent.loadSurahs() = _LoadSurahs;
  const factory QuranEvent.loadSurahDetails(int surahNumber) = _LoadSurahDetails;
  const factory QuranEvent.search(String query) = _Search;
}

@freezed
sealed class QuranState with _$QuranState {
  const factory QuranState({
    @Default(false) bool isLoading,
    @Default([]) List<Surah> surahs,
    @Default([]) List<Ayah> ayahs,
    Surah? selectedSurah,
    SurahDetail? selectedSurahDetail,
    String? error,
    @Default([]) List<Ayah> searchResults,
  }) = _QuranState;

  factory QuranState.initial() => const QuranState();
}

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository _repository;

  QuranBloc(this._repository) : super(QuranState.initial()) {
    on<_LoadSurahs>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final surahs = await _repository.getSurahs();
        emit(state.copyWith(isLoading: false, surahs: surahs));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<_LoadSurahDetails>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final surahDetail = await _repository.getSurahDetail(event.surahNumber);
        emit(state.copyWith(
          isLoading: false, 
          selectedSurahDetail: surahDetail,
          selectedSurah: state.surahs.isEmpty ? null : state.surahs.firstWhere((s) => s.number == event.surahNumber, orElse: () => state.surahs.first)
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<_Search>((event, emit) async {
      if (event.query.isEmpty) {
        emit(state.copyWith(searchResults: []));
        return;
      }
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final results = await _repository.searchAyahs(event.query);
        emit(state.copyWith(isLoading: false, searchResults: results));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}
