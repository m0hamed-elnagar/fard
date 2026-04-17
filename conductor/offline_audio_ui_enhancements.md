# Offline Audio Enhancements & Surah List Play Button Fix

## Objective
Make the surah list play button "offline friendly" and consistent with the surah reader screen. This includes adding UI feedback (play/pause/loading states), handling offline playback with alternative reciters, and adding a direct download option from the list.

## Key Files
- `lib/features/audio/presentation/utils/offline_audio_helper.dart`: Centralized offline playback logic.
- `lib/features/quran/presentation/pages/quran_page.dart`: Surah list implementation.
- `lib/features/quran/presentation/widgets/surah_header.dart`: Surah reader header implementation.
- `lib/features/audio/presentation/blocs/audio_bloc.dart`: Audio state management.

## Implementation Steps

### 1. Enhance `OfflineAudioHelper`
- Update `handlePlayRequest` to handle pause/resume if the requested surah is already the active one.
- This centralizes the "smart" play button logic.

### 2. Update `SurahHeader` (Reader Screen)
- Replace direct `AudioBloc` calls with `OfflineAudioHelper.handlePlayRequest` in the `onPressed` handler.
- This ensures the reader screen also benefits from the "Alternative Reciter" dialog when offline.

### 3. Refactor Surah List in `QuranPage`
- **Track Downloading State**: Use a map in `_QuranPageState` to track currently downloading surahs via the `progressStream`.
- **UI State Enhancement**:
    - Wrap the play button in a `BlocBuilder<AudioBloc, AudioState>`.
    - Change icon to `pause_rounded` if playing the current surah.
    - Show a small `CircularProgressIndicator` if loading.
- **Add Download Button**:
    - If a surah is not downloaded, show a `download_for_offline` icon.
    - If downloading, show progress (e.g., a circular progress indicator with percentage).
    - If downloaded, show the existing checkmark.
- **Handle Playback**:
    - Use the enhanced `OfflineAudioHelper.handlePlayRequest`.

### 4. Verification
- Test play/pause toggle from the surah list.
- Test offline playback: verify the alternative reciter dialog appears if the primary reciter's surah is not downloaded.
- Test downloading a surah directly from the list.
- Ensure the reader screen's play button still works and now handles offline cases correctly.

## Verification & Testing
- **Manual Test**: Go to Quran Page, play a surah, verify it changes to pause.
- **Manual Test**: Go offline, play a non-downloaded surah, verify alternative dialog.
- **Manual Test**: Download a surah from the list, verify progress UI and then the checkmark.
- **Manual Test**: In reader screen, verify play/pause works and offline handling is active.
