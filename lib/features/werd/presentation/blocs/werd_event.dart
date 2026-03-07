import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';

part 'werd_event.freezed.dart';

@freezed
class WerdEvent with _$WerdEvent {
  const factory WerdEvent.load({@Default('default') String id}) = _Load;
  const factory WerdEvent.setGoal(WerdGoal goal) = _SetGoal;
  
  // Specific to Quran but handled generically by absolute indices
  const factory WerdEvent.trackItemRead(int absoluteIndex) = _TrackItemRead;
  const factory WerdEvent.trackRangeRead(int startAbsolute, int endAbsolute) = _TrackRangeRead;
  
  const factory WerdEvent.updateBookmark(int absoluteIndex) = _UpdateBookmark;
  const factory WerdEvent.progressUpdated(WerdProgress progress) = _ProgressUpdated;
}
