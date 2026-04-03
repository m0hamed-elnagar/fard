# Plan: Fix Android Widget Crashes and App Instance Issues

## Objective
Fix fatal crashes (NPE, ClassNotFoundException, SessionWorker) and ensure only one instance of the app opens when clicking the widget.

## Key Files
- `android/app/src/main/AndroidManifest.xml`: Fix activity launch behavior and class resolution.
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt`: Fix `goAsync()` and NPE.
- `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidgetReceiver.kt`: Fix `goAsync()` and NPE.
- `android/app/build.gradle.kts`: Verify package configuration.

## Proposed Changes

### 1. Fix "Multiple Instances" Issue
- In `AndroidManifest.xml`, remove `android:taskAffinity=""` from `MainActivity`. This attribute was likely preventing the system from recognizing the existing task and bringing it to the front.
- Ensure `android:launchMode="singleTask"` is maintained.

### 2. Fix `ClassNotFoundException`
- In `AndroidManifest.xml`, change receiver names from relative (`.PrayerWidgetReceiver`) to fully qualified (`com.qada.fard.PrayerWidgetReceiver`). This ensures that even when the `applicationId` changes (e.g., in debug with `.debug1` suffix), the system can still find the class in the base package.

### 3. Fix `NullPointerException` in Receivers
- Refactor `PrayerWidgetReceiver` and `NextPrayerCountdownWidgetReceiver` to handle `goAsync()` more safely.
- Use a `try-finally` block to ensure `finish()` is only called if `pendingResult` is non-null.
- Ensure `super.onReceive` is called correctly.

### 4. Fix Glance Session Errors
- Ensure `updateAll` calls are managed properly.

## Implementation Steps

### Step 1: Update AndroidManifest.xml
- Remove `taskAffinity`.
- Fully qualify receiver class names.

### Step 2: Update PrayerWidgetReceiver.kt
- Implement safer `goAsync()` handling.
- Use `SupervisorJob` and `Dispatchers.Main` for UI-related calls if needed, but keep background work on `Dispatchers.IO`.

### Step 3: Update NextPrayerCountdownWidgetReceiver.kt
- Apply similar fixes as `PrayerWidgetReceiver`.

## Verification
- Run `./gradlew :app:assembleDebug` to verify compilation.
- Run `./gradlew :app:lintDebug` to check for manifest or code issues.
- (Manual) Verify that clicking the widget opens/brings to front the existing app instance.
