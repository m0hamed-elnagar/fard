# Agents Plan

## Objective
Fix compilation errors, improve code quality, and update documentation for the `fard-2` project.

## Status: Completed

## Phase 1: Fix Compilation Errors (High Priority)
- [x] **Analyze `notification_service.dart`**: Identified breaking changes in `flutter_local_notifications` version 20+.
- [x] **Fix `notification_service.dart`**:
    - [x] Updated `initialize` call to use `settings` parameter.
    - [x] Removed `uiLocalNotificationDateInterpretation` from `zonedSchedule` call.
    - [x] Added `WindowsInitializationSettings` with required parameters (`appName`, `appUserModelId`, `guid`) to fix Windows runtime error.
    - [x] Added `WindowsNotificationDetails` to `NotificationDetails`.

## Phase 2: Code Quality & Lints
- [x] **Fix Linter Warnings**:
    - [x] Addressed `use_build_context_synchronously` in `lib/features/azkar/presentation/screens/azkar_list_screen.dart` and `integration_test/azkar_test.dart`.
    - [x] Removed unused imports in `integration_test/azkar_test.dart`.

## Phase 3: Testing
- [x] **Run Tests**:
    - [x] Executed `flutter test`.
    - [x] Fixed failing test in `test/features/settings/settings_cubit_test.dart` by registering fallback values for `SettingsState` and `List<AzkarItem>`.
    - [x] Verified all tests pass.

## Phase 4: Documentation
- [x] **Update README**: Reviewed `README.md`, content is up to date.

## Execution Summary
The project is now compiling, all tests pass, and critical lints are resolved.
