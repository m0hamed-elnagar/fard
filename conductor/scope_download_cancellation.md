# Implementation Plan: Scope Audio Download Cancellation to Individual Surahs

## Problem
Currently, the `AudioDownloadService` manages cancellation at the **Reciter** level using a `Map<String, bool> _cancellationFlags` where the key is the `reciterId`. When a user cancels a download for a specific surah, it sets the cancellation flag for the entire `reciterId` to `true`, causing all other surah downloads for that reciter to stop as well.

## Objective
Scope the cancellation logic to individual surahs so that cancelling one surah only stops its specific download task.

## Key Files & Context
- `lib/features/audio/data/services/audio_download_service_impl.dart`: The core logic using `_cancellationFlags`.
- `lib/features/audio/presentation/blocs/audio_download/audio_download_cubit.dart`: The BLoC managing the UI state and calling the service.
- `lib/features/audio/domain/services/audio_download_service.dart`: The service interface.

## Implementation Steps

### 1. Update `AudioDownloadService` Interface
Modify the `cancelDownload` method signature in `lib/features/audio/domain/services/audio_download_service.dart`:
```dart
Future<void> cancelDownload(String reciterId, int? surahNumber);
```

### 2. Update `AudioDownloadServiceImpl`
- Change `_cancellationFlags` to `Map<String, Set<int>>` or `Map<String, bool>` keyed by `reciterId_surahNumber`.
- Update `downloadSurah` to check for specific `reciterId_surahNumber` cancellation flag.
- Update `downloadReciter` to check for `reciterId` cancellation (for global reciter cancellation) and individual surah flags.
- Implement the new `cancelDownload` logic to selectively set the cancellation flag.

### 3. Update `AudioDownloadCubit`
- Update `cancelDownload(Reciter reciter, int surahNumber)` to pass the surah number to the service.

### 4. Update UI
- Update `reciter_download_screen.dart` to pass the `surahNumber` when `cancelDownload` is called.

## Verification & Testing
- Start multiple surah downloads for a single reciter.
- Cancel one specific surah download.
- Verify other downloads for the same reciter continue normally.
- Cancel all downloads for a reciter and verify they all stop.
