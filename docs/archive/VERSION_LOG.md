# Version History

> **Version Logging Rule**: Every feature addition, bug fix, or version update MUST be logged in this file following the format below. Use semantic versioning: `MAJOR.MINOR.PATCH+BUILD`.

---

## v1.4.0+6 (2026-04-10)

**Version Type**: Minor release (new features)  
**Previous Version**: v1.3.1+5

### 🎯 Features

- **Session-Based Werd Tracking**: Each reading session is now tracked separately with start/end times
  - New `ReadingSegment` entity with session timestamps
  - Session-aware merge logic that respects user reading patterns
  - History page shows session count badge
  - Edit dialog displays individual sessions with timing
  
- **Jump Dialog**: Smart navigation for long-distance ayah jumps
  - Detects when user jumps far from last read position
  - Offers "Mark All" (count intermediate ayahs) or "Dismiss" options
  - Shows gap information (ayah count, approximate pages)
  - Displays source and target surah/ayah with localization
  
- **Cycle Completion Dialog**: Celebrates completing the entire Quran
  - Triggers when user reaches ayah 6236 (end of Quran)
  - Offers 3 choices: Read Doaa, Start New Cycle, Stay Here
  - Beautiful celebration UI with Material 3 design
  
- **SVG Icon Support**: Added `flutter_svg` package for scalable icons
  - New `AppSvgIcon` widget with theme support
  - `AppIcons` constants class for icon paths
  - Icon asset directory structure

### ✨ Improvements

- **Startup Performance Optimization**
  - Parallelized background service initialization using `Future.wait()`
  - Delayed BLoC events to after first frame (reduces startup jank)
  - Added startup timing logs with millisecond precision
  - Non-critical services now load in background without blocking UI
  
- **Enhanced Werd Goal Dialog**
  - Better priority logic for start point selection
  - Pre-populates current reading position if user has progress
  - Improved Arabic/English labels:
    - "Start from Al-Fatihah (beginning)"
    - "Continue where I stopped"
    - "Choose specific surah/ayah"
    
- **Quran Reader UX Enhancements**
  - Improved reader body with scroll progress indicator
  - Enhanced reader header with better UI
  - Updated ayah detail sheet styling
  - Better surah header design
  - Scroll-to-top FAB for quick navigation
  
- **Android Baseline Profile Support**
  - Added baseline profile generation for improved startup performance
  - New `benchmark` build type for performance testing
  - Automatic generation disabled for normal builds
  - Manual trigger: `./gradlew :app:generateBaselineProfile`
  
- **Splash Screen Theme Integration**
  - Updated to use app's dark background color (`@color/dark_background`)
  - Shows app icon centered with proper theming
  - Removed placeholder launch image references

### 🧪 Tests

**Kept (18 essential test files)**:
- `werd_bloc_session_tracking_test.dart` - Session tracking logic
- `werd_bloc_track_range_test.dart` - Range tracking
- `werd_bloc_track_range_edge_cases_test.dart` - Edge cases
- `werd_jump_dialog_behavior_test.dart` - Jump dialog UX
- `werd_cycle_completion_test.dart` - Cycle completion
- `werd_history_with_segments_test.dart` - Segment history
- `werd_repository_comprehensive_test.dart` - Repository coverage
- `werd_progress_with_segments_test.dart` - Segment progress
- `werd_real_device_flow_test.dart` - Device scenarios
- `continue_button_logic_test.dart` - Continue button
- `set_werd_goal_dialog_test.dart` - Goal dialog
- `werd_progress_card_test.dart` - Progress card UI
- `user_correction_test.dart` - User correction
- `reading_segment_test.dart` - Segment entity
- `reading_segment_range_test.dart` - Segment ranges
- `quran_dialog_flow_test.dart` - Quran dialogs
- `update_last_read_real_user_flow_test.dart` - User flows
- `werd_dialog_dismissal_test.dart` - Dialog dismissal

**Removed (38 redundant test files)**:
- 22 investigation/debug unit tests
- 8 redundant integration tests
- 8 duplicate coverage tests

### 🔧 Technical Details

**New Files Added**:
- `lib/features/werd/domain/entities/reading_segment.dart` - Session entity
- `lib/features/quran/presentation/widgets/jump_dialog.dart` - Jump dialog
- `lib/features/quran/presentation/widgets/cycle_completion_dialog.dart` - Cycle dialog
- `lib/core/widgets/app_svg_icon.dart` - SVG icon widget
- `lib/core/widgets/fast_scroll_scrollbar.dart` - Custom scrollbar
- `lib/core/constants/app_icons.dart` - Icon path constants
- `android/baselineprofile/` - Baseline profile module
- `android/app/src/main/res/values/colors.xml` - Theme colors
- `android/app/src/main/res/values-night/colors.xml` - Dark theme colors
- `assets/icons/praying_hands.svg` - SVG asset

**Modified Core Files**:
- `lib/main.dart` - Startup optimization
- `lib/features/werd/presentation/blocs/werd_bloc.dart` - Session tracking
- `lib/features/werd/presentation/blocs/werd_event.dart` - New events
- `lib/features/werd/presentation/blocs/werd_state.dart` - Segment state
- `lib/features/werd/presentation/pages/werd_history_page.dart` - Session badges
- `lib/features/werd/presentation/widgets/set_werd_goal_dialog.dart` - UX improvements
- `lib/features/quran/presentation/widgets/reader/reader_body.dart` - Scroll progress
- `lib/features/quran/presentation/widgets/reader/reader_header.dart` - Header update
- `lib/features/quran/presentation/widgets/ayah_detail_sheet.dart` - Styling
- `lib/features/quran/presentation/widgets/surah_header.dart` - Design update
- `lib/features/quran/domain/usecases/update_last_read.dart` - Enhancement
- `lib/core/services/notification_service.dart` - Background init
- `lib/core/services/migration_service.dart` - Asset migration
- `lib/core/di/configure_dependencies.dart` - DI updates
- `lib/features/azkar/data/azkar_repository.dart` - Azkar updates
- `lib/features/azkar/presentation/screens/azkar_list_screen.dart` - UI
- `assets/azkar.json` - Formatted data
- `android/app/build.gradle.kts` - Baseline profile
- `android/build.gradle.kts` - Baseline profile plugin
- `android/settings.gradle.kts` - Baseline profile include
- `pubspec.yaml` - Added `flutter_svg: ^2.0.17`

**Localization Updates**:
- `lib/core/l10n/app_en.arb` - New strings for dialogs
- `lib/core/l10n/app_ar.arb` - Arabic translations
- Generated localization files updated

### 🐛 Bug Fixes

- Fixed werd goal dialog showing wrong start point for users with progress
- Fixed startup jank caused by blocking service initialization
- Fixed splash screen showing wrong background color
- Fixed session merging logic causing confusing UX
- **Fixed session tracking**: Each "Continue" click now creates an explicit new session (sessions were merging into one)
  - Ghost sessions (empty + < 5 min) auto-cleaned on double-Continue
  - Previous sessions properly ended before new ones created
  - Crash-resilient: stale sessions handled on next Continue click
- **Fixed Werd card "Current Position"**: Now shows correct next ayah based on last session's `endAyah + 1` (was showing stale `lastReadAbsolute` when user clicked Continue without reading)

### ⚠️ Known Issues

- Audio playback still limited to phone devices only (tablet/desktop not supported)
- Baseline profile requires connected device to generate (not auto-generated)
- Some integration tests may be flaky on CI (recommend running locally)

### 📦 Dependencies Added

- `flutter_svg: ^2.0.17` - SVG rendering support
- Transitive: `vector_graphics`, `vector_graphics_codec`, `vector_graphics_compiler`, `path_parsing`

### 🔗 Related Commits

- `feat(werd): Add session-based reading tracking with segments`
- `perf(quran): Enhance reader UX and optimize startup`
- `chore: Remove redundant tests and consolidate documentation`

---

## v1.3.1+5 (Previous Version)

**Note**: Baseline version before session tracking feature

### Features
- Daily prayer tracking with Qada management
- Quran reading with bookmarks
- Azkar & Tasbih tracking
- Prayer time calculations with azan notifications
- Basic werd progress tracking (linear, no sessions)
- Settings with import/export
- Home widgets
- Multi-language support (EN/AR)

---

## Version Logging Template

Use this template for future entries:

```markdown
## v[MAJOR].[MINOR].[PATCH]+[BUILD] (YYYY-MM-DD)

**Version Type**: [Major/Minor/Patch] release ([reason])  
**Previous Version**: v[X.Y.Z+B]

### 🎯 Features
- [New feature 1]
- [New feature 2]

### ✨ Improvements
- [Improvement 1]
- [Improvement 2]

### 🐛 Bug Fixes
- [Bug fix 1]
- [Bug fix 2]

### 🧪 Tests
**Added**: [New test files]  
**Removed**: [Deleted test files with reason]

### 🔧 Technical Details
**New Files**: [List new significant files]  
**Modified**: [List modified core files]  
**Dependencies**: [New or updated packages]

### ⚠️ Known Issues
- [Issue 1]
- [Issue 2]

### 🔗 Related Commits
- `[commit message 1]`
- `[commit message 2]`
```

---

**Last Updated**: 2026-04-10  
**Maintained By**: Development Team  
**Review Frequency**: Every release commit
