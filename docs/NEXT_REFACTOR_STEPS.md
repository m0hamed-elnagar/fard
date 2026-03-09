# Remaining Refactor Phases

This document tracks the refactor progress of the Fard app.

## Completed
- [x] **Phase 1: Notification Service Decomposition**
  - Extracted `SoundManager`, `ChannelManager`, and `PrayerNotificationScheduler`.
  - Refactored `NotificationService` as a facade.
  - Verified with comprehensive unit tests.

---

## Next Up: Phase 2 - Quran Reader UI Modularization
**Goal:** Simplify `QuranReaderPage` by extracting logic and UI components.

### 1. Extract Scroll Logic
- **Responsibility:** Manage scrolling to specific ayahs and visibility detection.
- **Proposed Path:** `lib/features/quran/presentation/controllers/reader_scroll_controller.dart`
- **Method:** Move `_scrollController`, `_ayahKeys`, `_scrollToAyah`, `_onScroll` (throttled listener) to this controller.

### 2. Componentize UI
- **Extract `QuranReaderAppBar`**: Move the SliverAppBar logic.
- **Extract `QuranReaderBody`**: Move the list/scroll view construction.
- **Extract `QuranReaderBottomBar`**: Move the `ReaderInfoBar` and `AudioPlayerBar` stack logic.
- **Paths:** `lib/features/quran/presentation/widgets/reader/`

### 3. Simplify State Listening
- **Action:** Refactor the nested `MultiBlocListener` and `BlocBuilder`s. Create small wrapper widgets that listen to specific blocs only where needed.

---

## Phase 3: Scanned Mushaf Reader Cleanup
**Goal:** Remove inline classes and clean up file structure.

### 1. Extract Private Classes
- **Extract `MushafPageItem`**: `lib/features/quran/presentation/widgets/scanned/mushaf_page_item.dart`
- **Extract `DownloadAllDialog`**: `lib/features/quran/presentation/widgets/scanned/download_all_dialog.dart`
- **Extract `PageNavButton`**: `lib/features/quran/presentation/widgets/scanned/page_nav_button.dart`

### 2. Standardize Logic
- **Action:** Ensure `_checkAndDownload` pattern is consistent with other download services. Use `const` constructors where possible.

---

## Instructions for future sessions
To continue the refactor, tell the agent:
> "Continue the refactoring plan from `docs/NEXT_REFACTOR_STEPS.md`. Start with Phase 2."
