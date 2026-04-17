# Implementation Plan: Reduce Default Download Quality

## Objective
Reduce the default download quality from `medium128` (128kbps) to `low64` (64kbps) to improve stability and reduce bandwidth usage during background downloads.

## Affected Files
1. `lib/features/audio/domain/repositories/audio_repository.dart`
2. `lib/features/audio/data/repositories/audio_repository_impl.dart`
3. `lib/features/audio/data/services/audio_download_service_impl.dart`

## Implementation Steps
1. Update `AudioRepository` interface methods (`getAyahAudioTrack`, `getSurahAudioTracks`) to set `low64` as the default `AudioQuality`.
2. Update the implementation in `AudioRepositoryImpl` to match the new interface defaults.
3. Review `AudioDownloadService` to ensure the manual `AudioQuality.medium128` used for Bismillah (or any other hardcoded calls) is still appropriate or should also be reduced to `low64`.

## Verification
- Run `flutter analyze` to ensure signature compatibility.
- Trigger a new download and verify in the logs or file inspector that the files are fetched with the lower bitrate.
- Verify playback quality is acceptable.
