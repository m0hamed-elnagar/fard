# Plan: Refactor Bismillah Handling in Audio Downloads

This plan addresses the issue where Bismillah is incorrectly counted in surah ayah counts and causes progress calculation errors (stalling at 99%). It ensures Bismillah is handled as a shared, protected dependency.

## Objective
- Exclude Bismillah from the visible ayah count for all surahs (e.g., Surah 2 shows 286 ayahs).
- Ensure Bismillah is automatically downloaded when any surah is downloaded.
- Protect Bismillah from being deleted when a surah is deleted.
- Ensure audio playback works gracefully even if Bismillah is missing.
- Align with `fix_offline_download.md` for atomic writes and lifecycle management.

## Key Files & Context
- `lib/features/audio/data/repositories/audio_repository_impl.dart`: Track generation logic.
- `lib/features/audio/data/services/audio_download_service_impl.dart`: Download logic and progress reporting.
- `lib/features/audio/data/repositories/audio_player_service_impl.dart`: Playback logic.
- `lib/features/audio/presentation/blocs/audio_bloc.dart`: Playback state management.

## Implementation Steps

### STEP 1 — Update AudioRepository: Separate Bismillah from Surah Tracks
- Modify `getSurahAudioTracks` in `AudioRepositoryImpl` to stop prepending Bismillah automatically. It should return ONLY the actual ayahs of the surah.
- Ensure `shouldPrependBismillah` remains accurate for UI/Player use.

### STEP 2 — Update AudioBloc: Manually Prepend Bismillah for Playback
- Modify `_onPlaySurah` in `AudioBloc` to manually fetch and prepend the Bismillah track (Surah 1, Ayah 1) to the playlist if `shouldPrependBismillah` is true.
- Update the index calculation in `_onIndexChanged` to account for this manual prepend.

### STEP 3 — Refactor AudioDownloadService: Silent Bismillah Download
- Modify `downloadSurah` in `AudioDownloadServiceImpl`:
    - Fetch the Bismillah track separately.
    - Download Bismillah first if it's missing (using a retry loop). Do NOT emit progress for this.
    - Fetch and download surah tracks. Emit progress based on the actual surah ayah count.
- Modify `getSurahStatus` to return the actual surah count but require Bismillah for `isDownloaded` to be true.
- Modify `deleteSurah` to ALWAYS protect `001001.mp3` regardless of the surah being deleted.

### STEP 4 — AudioPlayer Safety: Graceful Bismillah Fallback
- (Optional/Refinement) Modify `AudioPlayerServiceImpl.playPlaylist` to ensure that if the first track (Bismillah) fails to load, it automatically skips to the next one instead of erroring out the whole session.

### STEP 5 — Compatibility & Atomic Writes
- Ensure all download logic uses `FileDownloadUtils.atomicWriteFile` (from `fix_offline_download.md`).
- Ensure `getReciterDownloadPercentage` uses the correct total of 6236 unique ayahs.

## Verification & Testing

### Manual Verification
- **Surah Count:** Open Surah 2 download page; it should show 286 ayahs, not 287.
- **Download Progress:** Download Surah 2; progress should go from 0 to 286 and hit 100%.
- **Bismillah Presence:** Delete Surah 1 and Surah 2; check the file system to ensure `001001.mp3` remains.
- **Playback:** Play Surah 2 offline; it should still play Bismillah at the start.
- **99% Fix:** Verify the overall reciter progress correctly hits 100% when all 114 surahs are done.

### Automated Tests
- Add a unit test to `AudioDownloadServiceImpl` to verify that `downloadSurah` for Surah 2 reports 286 total files in its progress stream.
- Update `AudioRepositoryImpl` tests to reflect that `getSurahAudioTracks` no longer includes Bismillah.
