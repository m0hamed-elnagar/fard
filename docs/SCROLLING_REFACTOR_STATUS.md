# Scrolling Refactor Status & Roadmap

## Current Session Status
- **Branch:** `fix/scrolling-stable-base`
- **Base Commit:** `ec38fd77c9992665d470ecb36e921184f3ecd38b`
- **Status:** Stable base finalized with all safe features, UI enhancements, Media Player fixes, and "Continue Playing" logic ported.

## Features Implemented:
- [x] **Foundation:** Restored reliable `GlobalKey` based scrolling (from commit `ec38fd7`).
- [x] **Audio-Sync Scrolling:** Added listener in `QuranReaderPage` and `ScannedMushafReaderPage` to auto-scroll with audio.
- [x] **Surah-Specific Bookmarks:** Reverted bookmark jumping to be surah-specific and loop correctly.
- [x] **Safe Localization Port:** Added all new location and reader strings (Arabic & English) from commit `b00c47f`.
- [x] **Enhanced Location Logic:** Ported `LocationStatus` enum and improved error handling for GPS permissions.
- [x] **Enhanced Audio UI:** Ported the full `AudioPlayerBar` update from `9cc7d05`:
    - [x] Enhanced progress slider with time labels and better thumb.
    - [x] "Go to playing Ayah" button integrated into controls.
    - [x] Support for direct scrolling via `onScrollRequest` in reader pages.
- [x] **Media Player Notification Fix:**
    - [x] Added `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permission.
    - [x] Added `MediaButtonReceiver` to `AndroidManifest.xml`.
    - [x] Enriched metadata (Surah Name, Reciter, Ayah Number) passed to `just_audio_background`.
    - [x] Switched `AudioServiceActivity` back to `.MainActivity` for correct notification behavior.
- [x] **Continue Playing Logic:** 
    - [x] Added `playOnLoad` parameter to `QuranReaderPage`.
    - [x] Updated "Continue Reading" card and surah play buttons in `QuranPage` to trigger auto-playback.
    - [x] Fixed `saveLastRead` logic by properly capturing `ReaderBloc` context in `QuranReaderPage`.
- [x] **Settings UI:** Integrated new location status dialogs and settings shortcuts.

## Architectural Decision:
- **Stay Simple:** We explicitly chose **not** to port the `AyahBlockWidget` or the major `QuranReaderPage` refactor from later commits. We are keeping the single-column `AyahText` for maximum scrolling stability.

## Checklist for Next Session:
- [ ] **Verification:** Manually verify "Go to playing Ayah" button works across different scenarios.
- [ ] **Notification Test:** Play audio and verify media controls + metadata in the Android notification drawer.
- [ ] **Continue Playing Test:** Verify that tapping "Play" on a surah starts audio immediately in the reader.
- [ ] **Analyze:** Run a full `flutter analyze` on the entire project to ensure no regressions.

## Critical Files:
- `lib/features/quran/presentation/controllers/reader_scroll_controller.dart`
- `lib/features/quran/presentation/widgets/ayah_text.dart`
- `lib/features/quran/presentation/pages/quran_reader_page.dart`
- `lib/features/audio/presentation/widgets/audio_player_bar.dart`
- `lib/features/audio/data/repositories/audio_player_service_impl.dart`
- `android/app/src/main/AndroidManifest.xml`
