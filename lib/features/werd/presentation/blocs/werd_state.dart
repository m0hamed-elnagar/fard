import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';

part 'werd_state.freezed.dart';

@freezed
abstract class WerdState with _$WerdState {
  const factory WerdState({
    @Default(false) bool isLoading,
    WerdGoal? goal,
    WerdProgress? progress,
    String? error,
  }) = _WerdState;

  const WerdState._();

  factory WerdState.initial() => const WerdState();
}
