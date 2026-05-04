# SettingsCubit Refactoring Progress

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
- [ ] Migrate UI: `HomeScreen` & `HomeContent`.
- [ ] Migrate UI: `AzkarCategoriesScreen` & `MainNavigationScreen`.
- [ ] Migrate UI: `OnboardingScreen`.
- [ ] Resolve `injectable` dependency warnings for `NotificationService`.

## Phase 5: Deprecation & Cleanup
- [ ] Verify all integration and unit tests pass.
- [ ] Verify home screen widgets update reactively.
- [ ] Remove legacy `SettingsCubit`.
- [ ] Remove legacy `SettingsState`.
- [ ] Final code audit for cross-domain data leaking.
