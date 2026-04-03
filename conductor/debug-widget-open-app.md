# Debug Plan: Fix "Open App" Widget Issue

## Objective
Identify why the native widget fails to retrieve the `prayer_data` JSON string and displays "Open App".

## Implementation Steps

### Phase 1: Debugging Native Storage
1.  **Add Logging:** Insert `android.util.Log.d("WidgetDebug", "Found: " + ...)` in `SettingsRepository.getPrayerDataJson()` to see what, if anything, is being read.
2.  **Verify Keys:** Print all available keys in `FlutterSharedPreferences` to ensure `flutter.prayer_data` exists and is formatted as expected.

### Phase 2: Verify Flutter Sync
1.  **Confirm Sync Timing:** Add a `debugPrint` in `WidgetUpdateService.updateWidget()` to ensure it's called upon app startup or settings change.
2.  **Check Key Consistency:** Confirm that the key `flutter.prayer_data` is used in both Dart and Kotlin.

### Phase 3: Resolution
1.  **Adjust Key Access:** If the key is found under a different name or bucket, adjust `SettingsRepository.kt` accordingly.
2.  **Force Refresh:** If the data is simply missing on first load, add a force-refresh trigger upon app resume.
