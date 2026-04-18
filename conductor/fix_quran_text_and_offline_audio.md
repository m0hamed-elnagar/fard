# Fix: Quran Text Disappearing and Offline Playback Improvements

## Objective
1. Fix the issue where downloaded Quran text disappears after some time.
2. Resolve `ClientException` during offline playback by improving connectivity detection and robustness.
3. Ensure the app correctly identifies and uses downloaded audio tracks (reciter/quality).

## Analysis & Root Causes

### 1. Text Disappearing
- **Cause:** `QuranRepositoryImpl._refreshSurahs` is called whenever `getSurahs()` is invoked (if there's a cache). It fetches basic surah info from the remote API (`baseUrl/chapters`), which does NOT include ayahs.
- **Problem:** `localSource.cacheSurahs(surahs)` overwrites existing `SurahEntity` entries in Hive with these "basic" surahs, effectively clearing the `ayahs` list (setting it to `[]`).
- **Fix:** Update `QuranLocalSourceImpl.cacheSurahs` to preserve existing ayahs if the incoming surah data has none.

### 2. ClientException Offline
- **Cause:** `OfflineAudioHelper` uses `ConnectivityBloc` to check `isConnected`. `connectivity_plus` (used by the bloc) reports `true` if connected to Wi-Fi/Mobile data, even if there is NO internet access.
- **Problem:** When "falsely" connected, `OfflineAudioHelper` proceeds to play the surah. If it's not actually downloaded, `AudioPlayerService` attempts to stream it and fails with `ClientException`.
- **Fix:** Improve `ConnectivityService` to verify actual internet access (e.g., via a simple lookup) and update `OfflineAudioHelper` to be more defensive.

### 3. Reciter/Quality Consistency
- **Verification:** `AudioRepositoryImpl` uses a fixed local path for audio files regardless of quality setting. Whatever quality was downloaded is what's played locally.
- **Robustness:** Ensure `AudioDownloadService` status checks accurately reflect disk state.

## Implementation Steps

### Phase 1: Fix Data Integrity (Text)
1. **Update `SurahEntity`**: Add a `copyWith` method to `lib/features/quran/data/datasources/local/entities/surah_entity.dart`.
2. **Update `QuranLocalSource`**: Modify `cacheSurahs` in `lib/features/quran/data/datasources/local/quran_local_source.dart` to merge incoming data with existing ayahs if necessary.

### Phase 2: Improve Offline Robustness
1. **Update `ConnectivityService`**: Add a robust check for internet access in `lib/core/services/connectivity_service.dart`.
2. **Update `OfflineAudioHelper`**: Enhance the play request logic to handle cases where connectivity is reported but the network is unreachable.
3. **Verify `AudioDownloadService`**: Ensure `getSurahStatus` correctly identifies completed downloads by checking both manifest and disk.

### Phase 3: UI & UX Polishing
1. **Fix `OfflineAudioScreen`**: Resolve the analysis errors by using the correct getters from `AudioState` and updating localization keys.
2. **Download Center**: Ensure the "Quran Text" download accurately reflects progress and doesn't get "overwritten" by refreshes.

## Verification Plan

### Automated Tests
- **Unit Test**: `QuranLocalSource` should not overwrite existing ayahs with an empty list during `cacheSurahs`.
- **Unit Test**: `AudioRepository` should return `isDownloaded: true` only if the file exists on disk.

### Manual Verification
1. **Text Persistence**: Download Quran text -> Restart app -> Navigate around -> Verify text is still there.
2. **Offline Playback**: Go to a place with Wi-Fi but NO internet (or use airplane mode with Wi-Fi on) -> Try to play a non-downloaded surah -> Verify it correctly shows "Offline" or suggests an alternative instead of throwing `ClientException`.
3. **Reciter Switch**: Download Reciter A -> Select Reciter B -> Go Offline -> Play Surah -> Verify dialog suggests Reciter A.
