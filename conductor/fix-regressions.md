# Plan: Fix Regressions (Infinite Loading, Multiple Instances, Main Tab Error)

## Objective
Restore widget functionality (fix infinite loading), ensure a single app instance on widget click, and fix the "Something happened" error in the main tab.

## Key Files
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt`: Simplify and fix session conflict.
- `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidgetReceiver.kt`: Simplify and fix session conflict.
- `android/app/src/main/AndroidManifest.xml`: Change `launchMode` to `singleInstance`.
- `lib/core/services/prayer_time_service.dart`: Re-verify parameters and imports.

## Proposed Changes

### 1. Fix Infinite Loading (Glance Session Conflict)
- **Problem:** Overriding `onReceive` and calling `updateAll` inside a manual `goAsync` coroutine while also calling `super.onReceive` causes a race condition for the Glance session.
- **Fix:** Remove the complex `onReceive` override. Let `GlanceAppWidgetReceiver` handle the broadcast normally. If we need to reschedule alarms on update, we can do it inside the `GlanceAppWidget.provideGlance` (or better, keep it separate from the UI update to avoid infinite loops).
- **Alternative:** Use `WorkManager` for the alarm rescheduling triggered by the receiver, or just simplify `onReceive` to not interfere with Glance.

### 2. Fix Multiple Instances
- **Problem:** `singleTask` might not be enough if the widget intent is perceived as a different task or if the system is being aggressive.
- **Fix:** Change `MainActivity` `launchMode` to `singleInstance`. This is the most restrictive and should force only one instance.
- **Action:** Add `android:alwaysRetainTaskState="true"` and `android:clearTaskOnLaunch="false"` to be safe.

### 3. Fix Main Tab Error
- **Problem:** "Something happened" in Flutter main tab.
- **Hypothesis:** The `PrayerTimeService` changes might have introduced a runtime error (e.g., if a enum value was used incorrectly or if an import is missing).
- **Action:** Check `lib/core/services/prayer_time_service.dart` for syntax or logic errors. Ensure `HighLatitudeRule.middle_of_the_night` is the correct enum value in the version of `adhan` being used.

## Implementation Steps

### Step 1: Simplify PrayerWidgetReceiver.kt
- Remove the manual `goAsync` and `launch` block from `onReceive`.
- If alarm rescheduling is needed on every update, trigger a one-off `Worker`.

### Step 2: Simplify NextPrayerCountdownWidgetReceiver.kt
- Remove `onReceive` override entirely if not strictly needed (the base class handles `APPWIDGET_UPDATE`).

### Step 3: Update AndroidManifest.xml
- Set `launchMode="singleInstance"`.

### Step 4: Fix PrayerTimeService.dart
- Ensure correct `adhan` package usage.

## Verification
- `./gradlew :app:assembleDebug`
- Manual test: Add widget, check for loading.
- Manual test: Tap widget, check for multiple instances.
- Manual test: Open app, check main tab.
