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
    @Default('Amiri') String fontFamily,
    @Default(ReaderSeparator.none) ReaderSeparator separator,
    @Default(16) int selectedTafsirId,
    @Default([]) List<Bookmark> bookmarks,
  }) = _Loaded;
  const factory ReaderState.error(String message) = _Error;
}
