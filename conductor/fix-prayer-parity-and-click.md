# Plan: Fix Prayer Parity and Widget Click Action

## Objective
Fix 2-minute prayer time discrepancy between Dart and Kotlin, and ensure widget clicks bring the existing app instance to the front.

## Key Files
- `lib/core/services/prayer_time_service.dart`: Update Dart calculation parameters.
- `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidget.kt`: Update click handler.
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`: Verify click handler (already `actionStartActivity`).

## Proposed Changes

### 1. Fix Prayer Parity (Dart side)
- Update `PrayerTimeService.dart` to explicitly use `HighLatitudeRule.middle_of_the_night` and `CalculationMethod.muslim_world_league.getParameters()..rounding = Rounding.nearest_minute`.
- This will align with the Kotlin implementation which uses `HighLatitudeRule.MIDDLE_OF_THE_NIGHT` and `adhan-java`'s default nearest-minute rounding.

### 2. Fix Widget Click Action
- Update `NextPrayerCountdownWidget.kt` to use `actionStartActivity<MainActivity>()` instead of `actionRunCallback<WidgetClickCallback>()`.
- This ensures consistency with `PrayerWidget.kt` and works with the `singleTask` launch mode in `AndroidManifest.xml` to prevent multiple instances.

## Implementation Steps

### Step 1: Update PrayerTimeService.dart
- Modify `_getParams` to set `highLatitudeRule` and `rounding`.

### Step 2: Update NextPrayerCountdownWidget.kt
- Replace `actionRunCallback` with `actionStartActivity`.
- Remove `import androidx.glance.appwidget.action.actionRunCallback` and add `import androidx.glance.action.actionStartActivity`.

## Verification
- Run `./gradlew :app:assembleDebug` to verify compilation.
- (Manual) Verify prayer times match between App (Dart) and Widget (Kotlin).
- (Manual) Verify clicking countdown widget opens/brings app to front.
