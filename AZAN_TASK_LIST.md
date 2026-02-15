# Azan and Reminders Task List

## 1. Analysis and Fixes of Current Uncommitted Changes
- [x] Review `NotificationService` implementation.
- [x] Review `SettingsCubit` and `SettingsState`.
- [x] Review `SettingsScreen` UI and dialog.
- [ ] Fix missing `raw` directory in Android resources.
- [ ] Add placeholder Azan sound files (or instructions for the user).
- [ ] Verify `SCHEDULE_EXACT_ALARM` permission handling for Android 14+.
- [ ] Ensure `fullScreenIntent` works correctly for "pop up when closed".

## 2. New Features Implementation
- [ ] Add voice selection logic (dynamically list available sounds if possible).
- [ ] Implement reminder time customization (15 mins default).
- [ ] Ensure settings for each Salah are correctly persisted and applied.
- [ ] Add "Test Azan" button in settings to verify sound and notification.

## 3. Testing
- [ ] Add unit tests for `SettingsCubit` regarding `SalaahSettings`.
- [ ] Add unit tests for `NotificationService` scheduling logic (using mocks).
- [ ] Add widget tests for `SettingsScreen` Azan dialog.

## 4. Final Verification
- [ ] Verify notifications show when app is in background/closed.
- [ ] Verify permissions are requested at the right time.
- [ ] Verify localization for all new strings.
