part of 'reciter_manager_bloc.dart';

class ReciterManagerState extends Equatable {
  final List<Reciter> availableReciters;
  final Reciter? currentReciter;
  final Map<String, double> reciterDownloadProgress; // reciterId -> percentage (0.0 to 1.0)
  final Map<String, int> reciterDownloadSizes; // reciterId -> size in bytes
  final String? error;

  const ReciterManagerState({
    this.availableReciters = const [],
    this.currentReciter,
    this.reciterDownloadProgress = const {},
    this.reciterDownloadSizes = const {},
    this.error,
  });

  ReciterManagerState copyWith({
    List<Reciter>? availableReciters,
    Object? currentReciter = _sentinel,
    Map<String, double>? reciterDownloadProgress,
    Map<String, int>? reciterDownloadSizes,
    Object? error = _sentinel,
  }) {
    return ReciterManagerState(
      availableReciters: availableReciters ?? this.availableReciters,
      currentReciter: currentReciter == _sentinel
          ? this.currentReciter
          : currentReciter as Reciter?,
      reciterDownloadProgress:
          reciterDownloadProgress ?? this.reciterDownloadProgress,
      reciterDownloadSizes: reciterDownloadSizes ?? this.reciterDownloadSizes,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
        availableReciters,
        currentReciter,
        reciterDownloadProgress,
        reciterDownloadSizes,
        error,
      ];
}
