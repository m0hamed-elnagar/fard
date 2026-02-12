import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
final class MissedCounter extends Equatable {
  final int value;
  const MissedCounter(int value) : value = value < 0 ? 0 : value;
  MissedCounter addMissed() => MissedCounter(value + 1);
  MissedCounter removeMissed() => MissedCounter(value > 0 ? value - 1 : 0);
  @override
  List<Object> get props => [value];
}
