# Implementation Plan: Fix Settings Refactoring Regressions and Optimize Repository

This plan addresses regressions found during the review of the uncommitted changes in the Settings feature refactoring. It also includes optimizations for the repository implementation and adds missing regression tests.

## Objective
- Fix the broken bulk update logic in `SettingsCubit` (due to immutability).
- Optimize `SettingsRepositoryImpl` to avoid redundant storage reads.
- Ensure all bulk update methods in `SettingsCubit` use the repository's dedicated methods.
- Add regression tests for bulk update features.

## Key Files & Context
- **SettingsCubit:** `lib/features/settings/presentation/blocs/settings_cubit.dart` (Contains broken `_bulk` logic).
- **SettingsRepositoryImpl:** `lib/features/settings/data/repositories/settings_repository_impl.dart` (Contains redundant reads in getters).
- **SettingsRepository:** `lib/features/settings/domain/repositories/settings_repository.dart` (Defines the interface).
- **Tests:** `test/features/settings/settings_cubit_test.dart` (Needs new tests for bulk updates).

## Implementation Steps

### 1. Optimize SettingsRepositoryImpl
- [ ] Refactor `salaahSettings` and `reminders` getters in `lib/features/settings/data/repositories/settings_repository_impl.dart` to store the result of `_storage.readJsonList` in a variable and check it for emptiness before returning, avoiding a second read call.

### 2. Fix SettingsCubit Bulk Updates
- [ ] In `lib/features/settings/presentation/blocs/settings_cubit.dart`:
    - [ ] Remove the private `_bulk` helper method (it is broken for immutable types and redundant).
    - [ ] Refactor `updateAllAzanEnabled`, `updateAllReminderEnabled`, `updateAllAzanSound`, `updateAllReminderMinutes`, and `updateAllAfterSalahMinutes` to call their corresponding methods in `_repo` directly.
    - [ ] Ensure each of these methods calls `emit(state.copyWith(salaahSettings: _repo.salaahSettings))` and `_sync()` after the repository update.

### 3. Add Regression Tests
- [ ] Update `test/features/settings/settings_cubit_test.dart`:
    - [ ] Add a new test group "Bulk Updates".
    - [ ] Add tests for `updateAllAzanEnabled`, `updateAllReminderEnabled`, `updateAllAzanSound`, `updateAllReminderMinutes`, and `updateAllAfterSalahMinutes`.
    - [ ] Verify that these methods correctly update the Cubit state and call the appropriate repository methods.

## Verification & Testing
- [ ] Run `flutter analyze` to ensure no static analysis errors.
- [ ] Run all settings-related tests:
    - `test/features/settings/settings_cubit_test.dart`
    - `test/features/settings/after_salah_azkar_test.dart`
    - `test/features/settings/widget_sync_integration_test.dart`
- [ ] Verify that the "Select All" functionality in the app's settings screen works correctly (once deployed).
