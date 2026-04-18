# Fard Test Suite Remediation Plan

**Goal:** Resolve all 50 failing tests in the Fard (Qada Tracker) project by addressing missing mock stubs, DI registration issues, and null-safety regressions.

**Architecture:**
- Focus on fixing the infrastructure (DI) first to resolve environment-wide failures.
- Then, proceed to unit tests (stubs and logic).
- Finally, address UI and Integration test regressions (localization, null-safety).

**Tech Stack:**
- Dart/Flutter (Test, Bloc, Mocktail, GetIt)

---

### Task 1: Infrastructure & DI Fixes
**Files:**
- Modify: `test/features/onboarding/splash_screen_test.dart`
- Modify: `test/integration/werd_session_tracking_real_test.dart`

- [ ] **Step 1: Register `AudioDownloadService` in `splash_screen_test.dart`**
  Add mock registration for `AudioDownloadService` in the test setup.
- [ ] **Step 2: Mock `SharedPreferences` in `werd_session_tracking_real_test.dart`**
  Inject a mock `SharedPreferences` instance to avoid `MissingPluginException`.

### Task 2: Mock Stub & Bloc Fixes (Unit Level)
**Files:**
- Modify: `test/features/werd/presentation/widgets/set_werd_goal_dialog_test.dart`
- Modify: `test/features/settings/widget_preview_widget_test.dart`
- Modify: `test/features/quran/presentation/widgets/quran_dialogs_test.dart`

- [ ] **Step 1: Add missing stubs for `MockSettingsRepository`, `MockQuranRepository`, and `MockSettingsCubit`**
  Implement required return values for `audioQuality`, `getTextScale`, and `getAvailablePresets` in the test files.
- [ ] **Step 2: Stub `Stream<WerdState>` for `MockQuranBloc` in `SetWerdGoalDialog` tests.**

### Task 3: UI & Logic Regression Fixes
**Files:**
- Modify: `test/features/settings/widget_preview_widget_test.dart`
- Modify: `test/features/quran/presentation/widgets/ayah_text_test.dart`
- Modify: `test/features/werd/data/repositories/werd_repository_comprehensive_test.dart`

- [ ] **Step 1: Fix `WidgetPreview` crash**
  Add null-safety check or mock data in the test to prevent the null-check operator error at line 22 of `widget_preview.dart`.
- [ ] **Step 2: Update `AyahText` callback stubs**
  Stub `onAyahTap` to accept or return the expected value in `ayah_text_test.dart`.
- [ ] **Step 3: Correct `WerdRepository` import/rollover logic**
  Update the test logic to clear mock data and verify the repository returns `0.0` or proper values.

### Task 4: Localization & Final Validation
**Files:**
- Modify: `test/features/quran/presentation/widgets/quran_dialogs_test.dart`

- [ ] **Step 1: Update Arabic Matchers**
  Verify the text/icon matchers in `JumpDialog` and `SetWerdGoalDialog` against the current UI strings.
- [ ] **Step 2: Run all tests**
  Execute `flutter test` and ensure all 50 failures are cleared.
