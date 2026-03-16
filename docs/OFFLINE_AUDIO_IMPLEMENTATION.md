# Offline Audio Implementation Plan

## Objective
Implement "offline first" audio features while **strictly preserving the existing Ayah-by-Ayah playback behavior**.
1.  **Cache on Playback**: Streamed Ayahs are saved to permanent storage.
2.  **Offline Manager**: Explicit download/delete management.

## Phase 1: Cache on Playback Infrastructure

### 1. Data Models
*   Create `AudioTrack` class in `lib/features/audio/domain/entities/audio_track.dart`:
    ```dart
    class AudioTrack {
      final String remoteUrl;
      final String localPath;
      final bool isDownloaded;
      
      const AudioTrack({
        required this.remoteUrl, 
        required this.localPath, 
        required this.isDownloaded
      });
    }
    ```

### 2. AudioPlayerService Refactoring
*   **Interface (`lib/features/audio/domain/repositories/audio_player_service.dart`)**:
    *   `playStreaming`: Update to accept `AudioTrack track`.
    *   `playPlaylist`: Update to accept `List<AudioTrack> tracks`.
*   **Implementation (`lib/features/audio/data/repositories/audio_player_service_impl.dart`)**:
    *   **Preserve Playlist Behavior**: Continue using `ConcatenatingAudioSource` (or equivalent list) to play Ayahs in sequence.
    *   **Smart Source Selection**:
        *   For each track in the playlist:
        *   If `track.isDownloaded`: Use `AudioSource.file(track.localPath)`.
        *   If `!track.isDownloaded`: Use `LockCachingAudioSource` with `cacheFile: File(track.localPath)`.
    *   This ensures seamless playback whether files are offline, online, or mixed.

### 3. AudioRepository Refactoring
*   **Interface (`lib/features/audio/domain/repositories/audio_repository.dart`)**:
    *   `getAyahAudioUrl` -> `getAyahAudioTrack`.
    *   `getSurahAudioUrls` -> `getSurahAudioTracks`.
*   **Implementation (`lib/features/audio/data/repositories/audio_repository_impl.dart`)**:
    *   `getAyahAudioTrack`:
        *   Calculate `localPath`.
        *   Check `File(localPath).exists()`.
        *   Return `AudioTrack` with correct status.
    *   `getSurahAudioTracks`:
        *   Generate list of `AudioTrack`s (including Bismillah logic).

### 4. AudioBloc Update
*   **`lib/features/audio/presentation/blocs/audio_bloc.dart`**:
    *   Update `_onPlayAyah` & `_onPlaySurah` to use `AudioTrack` objects.
    *   Pass `AudioTrack` objects to `playerService`.
    *   **No change to playback logic**: It still plays the sequence of Ayahs exactly as before.

## Phase 2: Offline Audio Manager

### 1. AudioDownloadService
*   Location: `lib/features/audio/domain/services/audio_download_service.dart`.
*   Responsibilities:
    *   `downloadSurah`: Loop through Ayahs, download to `localPath`.
    *   `downloadReciter`: Loop all Surahs.
    *   `deleteSurah`/`deleteReciter`: Remove files.
    *   `getDownloadStatus`: Size & completion checks.

### 2. AudioDownloadCubit
*   Manage state for the Download screens.

### 3. UI Screens
*   **OfflineAudioScreen**: List reciters.
*   **ReciterDownloadScreen**: List Surahs, Download/Delete buttons, Size info.

## Verification
1.  **Phase 1**:
    *   Stream a Surah. Verify files appear in `audio/reciter/`.
    *   Verify seamless playback (no gaps/errors).
    *   Go offline -> Play same Surah -> Verifies `AudioSource.file` path.
2.  **Phase 2**:
    *   Download a Surah. Check size estimate vs actual.
    *   Delete Surah. Verify files gone.
