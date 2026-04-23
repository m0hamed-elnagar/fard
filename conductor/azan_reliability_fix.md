# Plan: Fix Azan Notification Reliability, Spam & Time Changes

## Objective
Ensure Azan notifications work forever without opening the app, prevent multiple notifications from firing at once (spamming) when the time changes or device lags, and remove the intrusive full-screen pop-up.

## Key Problems Identified
1.  **Notification Spam on Time Change:** When the user changes the device time/date to "tomorrow", Android instantly fires all pending alarms that were skipped over, resulting in notification spam.
2.  **Catch-up Logic Conflict:** The "catch-up" feature triggers an Azan immediately if missed by < 1 minute. However, the exact `WorkManager` task scheduled alongside it wakes up the app, causing a second identical Azan to fire simultaneously.
3.  **Intrusive Pop-ups:** Azan uses `fullScreenIntent: true`, which aggressively forces the app onto the screen when the phone is locked.
4.  **Exact Alarm Quotas:** Scheduling too many exact alarms (e.g., 7 days) hits Android system limits on many devices.

## Proposed Changes

### 1. Stop Notification Spam on Time Change (`android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt`)
- When a time/timezone change is detected, immediately call the Android `NotificationManager` to cancel all active notifications to clear any spam that Android just fired.
- Enqueue a one-off `WorkManager` task for `prayer_scheduler_task` to silently wake up the Flutter engine and reschedule the correct, updated alarms for the new time.

### 2. Disable Full-Screen Intrusions (`lib/core/services/notification/prayer_scheduler.dart`)
- Set `fullScreenIntent: false` in the AndroidNotificationDetails for Azans. This allows the notification to ring normally without aggressively taking over the user's screen.

### 3. Remove Conflicting Catch-up Logic & Redundant Tasks (`lib/core/services/notification/prayer_scheduler.dart`)
- **Remove the 1-minute "Catch-up" Logic:** `flutter_local_notifications` uses exact alarms that are highly reliable. Trying to manually catch them up causes duplicate fires when `WorkManager` runs.
- **Remove Redundant `registerOneOffTask`:** The Azan loop currently creates a precise `WorkManager` task for every prayer to update the widget. This is unnecessary and causes conflicts because `PrayerAlarmManager.kt` already handles widget updates natively and precisely.
- **Reduce Window:** Limit scheduled Azans to the next **2 days** (instead of 7) to stay under Android's exact alarm limits. 

### 4. Sweep Orphaned Notifications (`lib/core/services/notification/prayer_scheduler.dart`)
- Increase the ID range in `_cancelNotificationRanges` to cancel up to **100** old IDs. This acts as a broom to sweep up any orphaned alarms left behind by previous versions of the app that scheduled 7 days out.

### 5. Strengthen the "Forever" Safety Net (`lib/core/services/background_service.dart`)
- Ensure the native 15-minute fallback worker unconditionally triggers `PrayerNotificationScheduler.schedulePrayerNotifications()` to guarantee the 2-day alarm window is always pushed forward indefinitely, even if the user never opens the app.
- Ensure `networkType` is set to `NetworkType.notRequired` so it works completely offline.

## Verification
- **Manual Test (Time Change):** Change phone time forward by 2 days. Verify no notification spam occurs and new alarms are scheduled correctly.
- **Manual Test (Spam):** Wait for an actual prayer time. Verify only 1 notification is shown, not 2.
- **Manual Test (Pop-up):** Wait for a prayer time with the screen locked. Verify it rings but does not force the app open.