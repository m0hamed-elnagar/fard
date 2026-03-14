# Report: Features Skipped vs. Ported (Session 8c36d863)

## Status Overview
We successfully restored the stable "GlobalKey" based scrolling from commit `ec38fd7` and layered the best features from later commits (`22ed581`, `9cc7d05`) on top of it.

## 1. What We Intentionally Skipped
These features were present in the later commits but were identified as the root cause of the scrolling bugs or were deemed too risky/complex to port without breaking the stable base.

### A. Modular Reader Architecture (`AyahBlockWidget` / `SliverList`)
- **Description:** The later commits replaced the single `AyahText` widget with a lazy-loading `SliverList` of `AyahBlockWidget`s.
- **Reason for Skipping:** This required a complex "Math-Based" scroll calculator (`AyahLayoutCalculator`) because `GlobalKey`s don't work reliably inside lazy lists. This calculator was the source of the "buggy scrolling".
- **Impact:** Opening very long surahs (Al-Baqarah) *might* have slightly more initial lag than the Sliver version, but scrolling will be perfectly accurate.

### B. Complex Scroll Logic (`AyahLayoutCalculator`)
- **Description:** A 400+ line system that tried to predict pixel offsets before rendering.
- **Reason for Skipping:** It failed when fonts loaded slowly or screen sizes varied. We stuck with `Scrollable.ensureVisible()`, which is native and reliable.

### C. Werd & Dashboard Refactor
- **Description:** Large changes to `WerdProgressCard.dart` (700+ lines) and `WerdBloc`.
- **Reason for Skipping:** Out of scope for this session. We focused on the Reader and Audio.
- **Future Action:** If you notice issues with the "Werd" progress circles on the home screen, this is the code to look at next.

## 2. What We Successfully Ported
We brought over all the user-facing improvements without the buggy underpinnings.

- [x] **Audio Sync:** Auto-scrolls to the active Ayah.
- [x] **Continue Playing:** "Continue Reading" card and Play buttons work instantly.
- [x] **Media Notification:** Fixed background playback, added missing permissions, and enriched metadata (Surah/Reciter names).
- [x] **Global Navigation:** Bookmarks, Hizb, and Juz jumps work perfectly.
- [x] **UI Polish:** New `AudioPlayerBar` design (slider, time labels) and "Go to Playing Ayah" button.
- [x] **Localizations:** All new Arabic/English strings.
- [x] **Location Logic:** Better GPS permission handling in Settings.

## 3. Next Steps (Optional)
If you wish to continue development, the logical next step is to **investigate the Werd/Dashboard changes** that were in the skipped commits, as that logic was distinct from the Reader scrolling issues.
