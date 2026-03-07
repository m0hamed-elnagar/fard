part of 'reader_bloc.dart';

@freezed
class ReaderEvent with _$ReaderEvent {
  const factory ReaderEvent.loadSurah({required SurahNumber surahNumber}) = _LoadSurah;
  const factory ReaderEvent.selectAyah(Ayah ayah) = _SelectAyah;
  const factory ReaderEvent.saveLastRead(Ayah ayah) = _SaveLastRead;
  const factory ReaderEvent.updateScale(double scale) = _UpdateScale;
  const factory ReaderEvent.updateSeparator(ReaderSeparator separator) = _UpdateSeparator;
  const factory ReaderEvent.toggleBookmark(Ayah ayah) = _ToggleBookmark;
  const factory ReaderEvent.checkBookmark(Ayah ayah) = _CheckBookmark;
  const factory ReaderEvent.bookmarksUpdated(List<Bookmark> bookmarks) = _BookmarksUpdated;
  const factory ReaderEvent.updateTafsir(int tafsirId) = _UpdateTafsir;
}
