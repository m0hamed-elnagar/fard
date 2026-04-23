# Fard (Qada Tracker) - Project Improvement Plan

## Current Status

### Test Results
- **Total tests**: 495+ passing
- **Failed tests**: 30 (approximately 6% failure rate)
- **Analysis warnings**: 6 (unused imports, invalid annotations)

### Architecture
- Clean Architecture with Domain/Data/Presentation layers
- flutter_bloc for state management
- hive_ce for local storage
- get_it for dependency injection

---

## Priority 1: Fix Warnings & Code Quality

### 1.1 Remove Unused Imports (HIGH)
Files with unused imports:
- `lib/core/utils/symbol_detector.dart:1` - `quran_symbol.dart` imported but not used
- `lib/features/quran/presentation/pages/symbol_list_screen.dart:6` - `google_fonts` unused
- `lib/features/quran/presentation/widgets/quran_reader_help_overlay.dart:4` - `quran_symbol` unused

**Fix**: Remove unused imports or use them if needed.

### 1.2 Fix Invalid JsonSerializable Annotations (HIGH)
File: `lib/features/quran/domain/models/quran_symbol.dart`
- Line 10, 30, 44: `@JsonSerializable()` on non-class members

**Fix**: Move annotations to class level or remove.

---

## Priority 2: Fix Failing Tests

### 2.1 Integration Tests (CRITICAL)
These tests require native plugin implementations:
- `werd_session_tracking_real_test.dart` - MissingPluginException for SharedPreferences

**Fix**: Set up proper test mocks or use integration_test framework.

### 2.2 Widget Interaction Tests (MEDIUM)
Tests failing due to UI interaction issues:
- `set_werd_goal_dialog_test.dart` - tap() warnings, element not found
- `increment/decrement button` - values not updating as expected

**Fix**: Update test finders or widget logic.

---

## Priority 3: Feature Improvements

### 3.1 Qada Tracking Enhancements
- [ ] Add batch qada entry (multiple days at once)
- [ ] Qada forgiveness options (Ramadan, travel, illness)
- [ ] Export qada history as PDF/CSV

### 3.2 Quran Reader Enhancements
- [ ] Tafsir integration ( Ibn Kathir, etc.)
- [ ] Word-by-word translation mode
- [ ] Night mode with red-tinted display
- [ ] Bookmark folders/categories

### 3.3 Audio Improvements
- [ ] Reciter comparison feature
- [ ] Playback speed control (0.5x - 2x)
- [ ] Sleep timer
- [ ] Queue management

### 3.4 Settings & Customization
- [ ] Theme presets (more than current 5)
- [ ] Widget customization
- [ ] Backup/restore to cloud

---

## Priority 4: Performance & Stability

### 4.1 Performance Improvements
- [ ] Lazy load Quran pages (only load visible)
- [ ] Cache管理体系优化
- [ ] Reduce app startup time

### 4.2 Stability
- [ ] Fix Hive type adapter conflicts
- [ ] Better error handling in downloads
- [ ] Offline mode improvements

---

## Priority 5: New Features (Roadmap)

### 5.1 Community Features
- [ ] Qada leaderboard (optional, anonymous)
- [ ] Reading streaks

### 5.2 Advanced Features
- [ ] Multiple qibla directions display
- [ ] Compass with magnetic declination
- [ ] Prayer time widget complications

---

## Implementation Timeline Suggestion

| Priority | Items | Est. Time |
|----------|-------|----------|
| P1 | Fix warnings | 1-2 hours |
| P2 | Fix tests | 4-8 hours |
| P3 | Feature enhancements | 2-3 weeks |
| P4 | Performance | 1-2 weeks |
| P5 | New features | Ongoing |

---

## Technical Debt

1. **Remove print statements** used for debugging (symbol_detector.dart)
2. **Document complex components** (Qada calculation logic, Werd tracking)
3. **Improve error messages** across the app
4. **Add analytics** for usage patterns

---

## Summary

The app is functional with good architecture. Main areas for improvement:
1. Code cleanup (6 warnings)
2. Test remediation (30 failing tests)
3. Feature enhancements
4. Performance optimization