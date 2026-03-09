# Remaining Refactor Phases

This document tracks the refactor progress of the Fard app.

## Completed
- [x] **Phase 1: Notification Service Decomposition**
  - Extracted `SoundManager`, `ChannelManager`, and `PrayerNotificationScheduler`.
  - Refactored `NotificationService` as a facade.
  - Verified with comprehensive unit tests.

---

- [x] **Phase 2: Quran Reader UI Modularization**
  - Extracted `ReaderScrollController` for scroll/visibility logic.
  - Componentized UI into `QuranReaderAppBar`, `QuranReaderHeader`, `QuranReaderBody`, and `QuranReaderBottomBar`.
  - Simplified `QuranReaderPage` and improved state listening.
  - Verified with integration test adjustments for RTL/Arabic names.

---

- [x] **Phase 3: Scanned Mushaf Reader Cleanup**
**Goal:** Remove inline classes and clean up file structure.

### 1. Extract Private Classes
- [x] **Extract `MushafPageItem`**: `lib/features/quran/presentation/widgets/scanned/mushaf_page_item.dart`
- [x] **Extract `DownloadAllDialog`**: `lib/features/quran/presentation/widgets/scanned/download_all_dialog.dart`
- [x] **Extract `PageNavButton`**: `lib/features/quran/presentation/widgets/scanned/page_nav_button.dart`

### 2. Standardize Logic
- [x] **Action:** Ensure `_checkAndDownload` pattern is consistent with other download services. Use `const` constructors where possible.

---

## Instructions for future sessions
To continue the refactor, tell the agent:
> "Continue the refactoring plan from `docs/NEXT_REFACTOR_STEPS.md`. Start with Phase 2."
