# Plan - Fix Home Widget Synchronization

Fix the home screen widget not updating when settings change and the manual refresh button not working.

## User Review Required

> [!IMPORTANT]
> This fix changes the MethodChannel payload for `settingsChanged` to include the full `prayer_data` JSON. This ensures the native side has the latest data immediately without waiting for disk I/O from the Flutter side.

- **Approach**: Atomic sync via MethodChannel payload.
- **Risk**: Low (backward compatible for native code that already reads from disk, but improved with direct payload).

## Proposed Changes

### Core Services

#### [lib/core/services/widget_update_service.dart](lib/core/services/widget_update_service.dart)
- Wrap `HomeWidget.saveWidgetData` in a try-catch to prevent failure from blocking native sync.
- Pass `jsonData` in the `_syncNative` payload as `prayer_data`.
- Log the sync attempt for easier debugging.

### Native (Android)

#### [android/app/src/main/kotlin/com/qada/fard/prayer/SettingsRepository.kt](android/app/src/main/kotlin/com/qada/fard/prayer/SettingsRepository.kt)
- Update `saveSettings` to accept an optional `prayerData` string.
- Save `prayerData` using `CalculationContract.PREF_PREFIX + "prayer_data"`.

#### [android/app/src/main/kotlin/com/qada/fard/MainActivity.kt](android/app/src/main/kotlin/com/qada/fard/MainActivity.kt)
- Extract `prayer_data` from the MethodChannel arguments in `handleInstantSettingsUpdate`.
- Pass it to `repository.saveSettings`.

### Testing

#### [test/features/settings/widget_sync_integration_test.dart](test/features/settings/widget_sync_integration_test.dart)
- Mock the `home_widget` MethodChannel to avoid `MissingPluginException`.
- Complete the test cases for Madhab, Calculation Method, and Hijri Adjustment.
- Add assertions to verify `prayer_data` is present in the payload.

## Verification Plan

### Automated Tests
- Run the fixed integration test:
  ```bash
  flutter test test/features/settings/widget_sync_integration_test.dart
  ```

### Manual Verification
1. Open the app on an Android Emulator/Device.
2. Add the "Fard" widget to the home screen.
3. Go to Settings in the app.
4. Change the Calculation Method.
5. Verify the widget updates its prayer times immediately.
6. Scroll down to "Debug: Widget" and click "Refresh".
7. Verify the widget refreshes (check the "last updated" time if visible, or just observe any flickering/re-render).
