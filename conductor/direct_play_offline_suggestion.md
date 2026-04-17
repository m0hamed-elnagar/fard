# Plan: Direct Play and Offline Reciter Suggestions

## Objective
Enhance the Quran surahs list to support direct audio playback without navigating to the reader screen, provide visual indicators for downloaded surahs, and suggest alternative reciters when the current one is unavailable offline.

## Key Files & Context
- `lib/features/quran/presentation/pages/quran_page.dart`: The main surahs list UI.
- `lib/features/audio/presentation/blocs/audio_bloc.dart`: Audio state management.
- `lib/features/audio/domain/services/audio_download_service.dart`: Interface for download status.
- `lib/features/audio/data/services/audio_download_service_impl.dart`: Implementation for download status.
- `lib/features/audio/presentation/widgets/audio_player_bar.dart`: Player UI.

## Implementation Steps

### 1. Enhance Audio Download Service
- Add `Future<List<Reciter>> getRecitersWithDownloadedSurah(int surahNumber)` to `AudioDownloadService` and implement it in `AudioDownloadServiceImpl`.
- Add `Future<Set<int>> getDownloadedSurahIdsForReciter(String reciterId)` to efficiently check all surahs for the current reciter.

### 2. Update QuranPage UI & Logic
- **Download Status Tracking:**
  - Add a state variable or use a `ValueNotifier` in `_QuranPageState` to store the set of downloaded surah IDs for the current reciter.
  - Refresh this list when `currentReciter` changes or when the page is opened.
- **Surah List Item:**
  - Display a small download icon (e.g., `Icons.check_circle_outline`) near the surah name if it is downloaded for the current reciter.
- **Direct Play Logic (Play Button):**
  - Modify the `onPressed` of the play icon in `ListTile`.
  - Check connectivity and download status.
  - If downloaded OR online: 
    - Dispatch `AudioEvent.playSurah` and `AudioEvent.showBanner`.
    - Do NOT navigate to `QuranReaderPage`.
  - If offline and NOT downloaded:
    - Call `getRecitersWithDownloadedSurah`.
    - If alternatives exist: Show a confirmation dialog suggesting the first available alternative reciter.
    - If no alternatives: Show a SnackBar indicating the content is not available offline.

### 3. Implement Suggestion Dialog
- Create a reusable dialog `AlternativeReciterDialog` that shows:
  - Message: "[Surah] is not downloaded for [Current Reciter]. It is available for [Alternative Reciter]. Would you like to play it with [Alternative Reciter] instead?"
  - Actions: "Cancel" and "Play with [Alternative Reciter]".

### 4. AudioBloc Enhancement (Optional/Refinement)
- Ensure `AudioBloc` handles the `PlaySurah` event gracefully even when not in the reader context (it already does, but verification is needed).

## Verification & Testing
- **Verification:**
  - Open `QuranPage`, press play icon on a surah. Verify audio starts and the player bar appears at the bottom, but the screen stays on `QuranPage`.
  - Turn off internet. 
  - Verify downloaded surahs have a visual indicator.
  - Press play on a downloaded surah. Verify it plays.
  - Press play on a non-downloaded surah. Verify the suggestion dialog appears if another reciter has it downloaded.
  - Confirm the suggestion and verify it switches reciter and plays.
- **Automated Tests:**
  - Add a widget test for `QuranPage` to verify the new play button behavior.
  - Add a unit test for the new `AudioDownloadService` methods.
