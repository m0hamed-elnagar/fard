part of 'reciter_manager_bloc.dart';

abstract class ReciterManagerEvent extends Equatable {
  const ReciterManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadReciters extends ReciterManagerEvent {
  const LoadReciters();
}

class SelectReciter extends ReciterManagerEvent {
  final Reciter reciter;
  const SelectReciter(this.reciter);

  @override
  List<Object?> get props => [reciter];
}

class RefreshReciterStatuses extends ReciterManagerEvent {
  const RefreshReciterStatuses();
}
