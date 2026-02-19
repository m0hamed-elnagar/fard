part of 'reader_bloc.dart';

@freezed
class ReaderEvent with _$ReaderEvent {
  const factory ReaderEvent.loadSurah({
    required SurahNumber surahNumber,
    String? translation,
  }) = _LoadSurah;
  
  const factory ReaderEvent.loadPage({
    required int pageNumber,
    String? translation,
  }) = _LoadPage;

  const factory ReaderEvent.selectAyah(Ayah ayah) = _SelectAyah;
  
  const factory ReaderEvent.saveLastRead(Ayah ayah) = _SaveLastRead;
  
  const factory ReaderEvent.updateScale(double scale) = _UpdateScale;
}
