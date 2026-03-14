# Scrolling Refactor Status & Roadmap

## Current Session Status
- **Branch:** `fix/scrolling-stable-base`
- **Base Commit:** `ec38fd77c9992665d470ecb36e921184f3ecd38b`
- **Status:** Stable base finalized with all safe features and UI enhancements ported.

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
- [x] **Settings UI:** Integrated new location status dialogs and settings shortcuts.

## Architectural Decision:
- **Stay Simple:** We explicitly chose **not** to port the `AyahBlockWidget` or the major `QuranReaderPage` refactor from later commits. We are keeping the single-column `AyahText` for maximum scrolling stability.

## Checklist for Next Session:
- [ ] **Verification:** Manually verify "Go to playing Ayah" button works across different scenarios.
- [ ] **Analyze:** Run a full `flutter analyze` on the entire project to ensure no regressions.
- [ ] **Performance Check:** Open Al-Baqarah and verify scrolling smoothness.

## Critical Files:
- `lib/features/quran/presentation/controllers/reader_scroll_controller.dart`
- `lib/features/quran/presentation/widgets/ayah_text.dart`
- `lib/features/quran/presentation/pages/quran_reader_page.dart`
- `lib/features/audio/presentation/widgets/audio_player_bar.dart`
- `lib/features/settings/presentation/blocs/settings_cubit.dart`
