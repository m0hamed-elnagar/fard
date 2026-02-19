import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';

import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';
import 'dart:async';

part 'quran_bloc.freezed.dart';

@freezed
abstract class QuranEvent with _$QuranEvent {
  const factory QuranEvent.loadSurahs() = _LoadSurahs;
  const factory QuranEvent.loadSurahDetails(int surahNumber) = _LoadSurahDetails;
  const factory QuranEvent.search(String query) = _Search;
  const factory QuranEvent.lastReadUpdated(LastReadPosition position) = _LastReadUpdated;
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
    LastReadPosition? lastReadPosition,
  }) = _QuranState;

  factory QuranState.initial() => const QuranState();
}

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository _repository;
  final WatchLastRead _watchLastRead;
  StreamSubscription? _lastReadSubscription;

  QuranBloc(this._repository, this._watchLastRead) : super(QuranState.initial()) {
    _lastReadSubscription = _watchLastRead().listen((result) {
      result.fold(
        (_) => null,
        (pos) => add(QuranEvent.lastReadUpdated(pos)),
      );
    });

    on<_LastReadUpdated>((event, emit) {
      emit(state.copyWith(lastReadPosition: event.position));
    });

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

  @override
  Future<void> close() {
    _lastReadSubscription?.cancel();
    return super.close();
  }
}
