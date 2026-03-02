part of 'werd_bloc.dart';

@freezed
abstract class WerdEvent with _$WerdEvent {
  const factory WerdEvent.load() = _Load;
  const factory WerdEvent.setGoal(WerdGoal goal) = _SetGoal;
  const factory WerdEvent.trackAyahRead(AyahNumber ayah) = _TrackAyahRead;
  const factory WerdEvent.progressUpdated(WerdProgress progress) = _ProgressUpdated;
}
