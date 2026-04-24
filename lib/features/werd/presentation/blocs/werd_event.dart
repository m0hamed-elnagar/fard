import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';

part 'werd_event.freezed.dart';

@freezed
class WerdEvent with _$WerdEvent {
  const factory WerdEvent.load({@Default('default') String id}) = _Load;
  const factory WerdEvent.setGoal(WerdGoal goal) = _SetGoal;

  // Session tracking (screen-based)
  const factory WerdEvent.startSession(int startAyah) = _StartSession;
  const factory WerdEvent.endSession() = _EndSession;

  // Specific to Quran but handled generically by absolute indices
  const factory WerdEvent.trackItemRead(int absoluteIndex) = _TrackItemRead;
  const factory WerdEvent.trackRangeRead(int startAbsolute, int endAbsolute) =
      _TrackRangeRead;

  // Jump dialog choice
  const factory WerdEvent.trackItemReadMarkAll({
    required int startAbsolute,
    required int endAbsolute,
  }) = _TrackItemReadMarkAll;

  const factory WerdEvent.jumpToNewSession(int targetAbsoluteIndex) =
      _JumpToNewSession;

  // NEW: Cycle completion
  const factory WerdEvent.completeCycle() = _CompleteCycle;
  const factory WerdEvent.completeCycleAndRestart() = _CompleteCycleAndRestart;
  const factory WerdEvent.completeCycleStayHere() = _CompleteCycleStayHere;

  // NEW: Undo last action
  const factory WerdEvent.undoLastAction() = _UndoLastAction;
  
  // NEW: Toggle ayah mark (unmark if already marked)
  const factory WerdEvent.toggleAyahMark(int absoluteIndex) = _ToggleAyahMark;
  
  // NEW: Remove specific segment from edit dialog
  const factory WerdEvent.removeSegment(int segmentIndex) = _RemoveSegment;

  const factory WerdEvent.updateBookmark(int absoluteIndex) = _UpdateBookmark;
  const factory WerdEvent.progressUpdated(WerdProgress progress) =
      _ProgressUpdated;
}
