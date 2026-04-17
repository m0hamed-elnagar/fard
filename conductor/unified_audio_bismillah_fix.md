# Plan: Unified Audio Download & Bismillah Refactor

This plan fixes the "99% stall" issue and the incorrect ayah counts in the UI. It establishes Bismillah as a shared, protected dependency that is excluded from surah-specific counts while remaining critical for playback.

## Objective
- **Fix UI Counts:** Surah 2 should show 286 ayahs, not 287.
- **Fix 99% Stall:** Ensure surah and reciter downloads reach 100% by aligning counts.
- **Silent Bismillah:** Download Bismillah automatically but silently (no progress impact).
- **Protection:** Prevent Bismillah from being deleted during individual surah cleanup.
- **Resilience:** Playback must skip missing Bismillah files gracefully.
- **Compatibility:** Integrate with atomic writes and lifecycle fixes from `fix_offline_download.md`.

## Key Files & Context
- `lib/features/audio/data/repositories/audio_repository_impl.dart`
- `lib/features/audio/data/services/audio_download_service_impl.dart`
- `lib/features/audio/presentation/blocs/audio_bloc.dart`
- `lib/features/audio/data/repositories/audio_player_service_impl.dart`

## Implementation Steps

### STEP 1 — Repository: Extract Bismillah from Surah Tracks
- Modify `getSurahAudioTracks` in `AudioRepositoryImpl` to return ONLY actual verses.
- Add `getBismillahTrack` helper method to the repository.
- Ensure `getAyahCount` returns the correct verse counts (already verified as 6236 total).

### STEP 2 — Download Service: Silent Dependency Logic
- Refactor `downloadSurah` in `AudioDownloadServiceImpl`:
    - Fetch the Bismillah track separately.
    - Download Bismillah first (using `FileDownloadUtils.atomicWriteFile`) if it doesn't pass integrity checks.
    - Do NOT include Bismillah in `totalFiles` or `currentlyOnDisk` reported to the progress stream.
    - Progress reporting will be `X / 286` for Surah 2.
- Update `getSurahStatus` to base `isDownloaded` on (Verses Present && Bismillah Present).
- Modify `deleteSurah` to hard-code a protection for `001001.mp3`.

### STEP 3 — AudioBloc: Manual Prepend & Index Management
- Update `_onPlaySurah` to manually prepend the Bismillah track to the playlist if the surah needs it.
- Adjust `_onIndexChanged` to handle the offset (Index 0 is Bismillah, Index 1 is Ayah 1).
- Add error handling: If the first track (index 0) is Bismillah and it fails, skip to index 1.

### STEP 4 — Player Service: Graceful Skipping
- Modify `AudioPlayerServiceImpl` to catch loading errors on individual sources.
- If a source fails, log it and attempt to skip to the next track if the user is in "Surah" mode.

### STEP 5 — Overall Progress Verification
- Ensure `getReciterDownloadPercentage` uses the 6236 total.
- Ensure the circular progress in `OfflineAudioScreen` correctly triggers 100% when all 6236 files are present.

## Verification & Testing
- **Manual Check:** Surah 2 must show 286 ayahs. Download must reach 100%.
- **File Check:** Verify `001001.mp3` exists after downloading Surah 2 and remains after deleting it.
- **Playback Check:** Play Surah 2 offline. It should play Bismillah then Ayah 1.
- **Corruption Check:** Manually delete Bismillah and play Surah 2; it should start from Ayah 1 without hanging.
