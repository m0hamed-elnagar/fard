# Debug Plan: Fix Widget "Open App" & Parity Failure

## Objective
The widget shows "Open App" because the native side is either failing to read the `flutter.prayer_data` key or it is discarding it due to a parity failure. We must force the native widget to use the Flutter-provided JSON and remove the parity enforcement.

## Implementation Steps

### Phase 1: Force Trust in Flutter Data
1.  **Modify `PrayerWidget.kt`**: Remove the `PrayerParity` check entirely. The widget should only be responsible for parsing and rendering the JSON provided by `SettingsRepository.getPrayerDataJson()`.
2.  **Update `PrayerWidget.kt` Parsing**: Ensure the widget doesn't fall back to "Open App" unless the JSON is truly null.

### Phase 2: Key Consistency Audit
1.  **Sync Constants**: Ensure `CalculationContract.PREF_PREFIX` matches exactly in Kotlin (`flutter.`) and Dart (`flutter.`).
2.  **Log Validation**: Use `adb logcat` to confirm the exact key the native `SharedPreferences` is looking for.

### Phase 3: Verification
1.  **Deployment**: Push the changes.
2.  **Validation**: Open the app, wait for the background worker to trigger, and verify that the widget updates with the correct prayer times without the parity failure error.
