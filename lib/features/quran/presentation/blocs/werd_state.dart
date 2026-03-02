part of 'werd_bloc.dart';

@freezed
abstract class WerdState with _$WerdState {
  const factory WerdState({
    @Default(false) bool isLoading,
    WerdGoal? goal,
    WerdProgress? progress,
    String? error,
  }) = _WerdState;

  factory WerdState.initial() => const WerdState();
}
