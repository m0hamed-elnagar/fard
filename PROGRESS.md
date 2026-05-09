# Azkar and Tasbih Navigation Refactoring

## Objectives
- [x] Implement auto-scroll to next item upon completion in Azkar.
- [x] Move Azkar navigation arrows outside the PageView for static positioning.
- [x] Refactor Tasbih to use PageView for horizontal manual scrolling.
- [x] Implement auto-scroll in Tasbih (both Rotating and Individual modes).
- [x] Add static navigation arrows to Tasbih.
- [x] Fix Tasbih manual navigation sync and auto-scroll direction weirdness.
- [x] Verify both features with integration tests.

## Phase 1: Pre-Refactoring Testing & Scoping
- [x] Audit existing test coverage for `SettingsCubit`.
- [x] Write baseline integration tests in `settings_refactor_baseline_test.dart` (5/5 passing).
- [x] Scope Phase 1 execution based on audit results.

## Phase 2: Create New Cubits & State Classes
- [x] Scaffold `ThemeCubit` and its `freezed` state class.
- [x] Scaffold `LocationPrayerCubit` and its `freezed` state class.
- [x] Scaffold `AdhanCubit` and its `freezed` state class.
- [x] Scaffold `DailyRemindersCubit` and its `freezed` state class.
- [x] Migrate `ThemeCubit` logic from `SettingsCubit`.
- [x] Migrate `LocationPrayerCubit` logic from `SettingsCubit`.
- [x] Migrate `AdhanCubit` logic from `SettingsCubit`.
- [x] Migrate `DailyRemindersCubit` logic from `SettingsCubit`.

## Phase 3: Implement WidgetSyncCoordinator
- [x] Create `WidgetSyncCoordinator` class.
- [x] Implement stream subscriptions to new Cubits with proper disposal.
- [x] Map relevant state changes to `WidgetUpdateService` calls.
- [x] Set up initialization in `main.dart`.

## Phase 4: UI & Dependency Injection Migration
- [x] Update GetIt/Injectable configurations for new Cubits and Coordinator.
- [x] Migrate UI: `SettingsScreen` (Using modular sections).
- [x] Migrate UI: `RemindersSettingsScreen`.
- [x] Migrate UI: `HomeScreen` & `HomeContent`.
- [x] Migrate UI: `AzkarCategoriesScreen` & `MainNavigationScreen`.
- [x] Migrate UI: `OnboardingScreen`.
- [x] Resolve `injectable` dependency warnings for `NotificationService`.

## Phase 5: Deprecation & Cleanup
- [x] Verify all integration and unit tests pass.
- [x] Verify home screen widgets update reactively.
- [x] Remove legacy `SettingsCubit`.
- [x] Remove legacy `SettingsState`.
- [x] Final code audit for cross-domain data leaking.
