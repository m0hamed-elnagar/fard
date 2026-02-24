part of 'reader_bloc.dart';

@freezed
class ReaderState with _$ReaderState {
  const factory ReaderState.initial() = _Initial;
  const factory ReaderState.loading() = _Loading;
  const factory ReaderState.loaded({
    required Surah surah,
    Ayah? highlightedAyah,
    Ayah? lastReadAyah,
    @Default(1.0) double textScale,
    @Default(false) bool isBookmarked,
    @Default(16) int selectedTafsirId,
  }) = _Loaded;
  const factory ReaderState.error(String message) = _Error;
}
