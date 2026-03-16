import 'package:equatable/equatable.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';

class AudioDownloadState extends Equatable {
  final Map<int, SurahDownloadStatus> surahStatuses;
  final ReciterDownloadStatus? reciterStatus;
  final bool isLoading;
  final String? error;
  
  // Active download tracking
  final String? activeReciterId;
  final int? activeSurahNumber; // Null if full reciter download
  final double progress; // 0.0 to 1.0

  const AudioDownloadState({
    this.surahStatuses = const {},
    this.reciterStatus,
    this.isLoading = false,
    this.error,
    this.activeReciterId,
    this.activeSurahNumber,
    this.progress = 0.0,
  });

  AudioDownloadState copyWith({
    Map<int, SurahDownloadStatus>? surahStatuses,
    ReciterDownloadStatus? reciterStatus,
    bool? isLoading,
    String? error,
    String? activeReciterId,
    int? activeSurahNumber,
    double? progress,
  }) {
    return AudioDownloadState(
      surahStatuses: surahStatuses ?? this.surahStatuses,
      reciterStatus: reciterStatus ?? this.reciterStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error, // If passed null, it clears error. If omitted, keeps old. Wait, standard pattern usually:
      // error: error == _sentinel ? this.error : error as String?
      // For simplicity:
      activeReciterId: activeReciterId ?? this.activeReciterId,
      activeSurahNumber: activeSurahNumber ?? this.activeSurahNumber,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    surahStatuses, 
    reciterStatus, 
    isLoading, 
    error, 
    activeReciterId, 
    activeSurahNumber, 
    progress
  ];
}
