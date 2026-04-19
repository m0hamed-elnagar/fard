# Plan: Fix Azan Notification Reliability & "Forever" Background Sync

## Objective
Ensure Azan notifications show up reliably on all Android devices (fixing the "reminder shows but Azan doesn't" bug) and maintain the schedule indefinitely without requiring the user to open the app.

## Key Problems Identified
1.  **Exact Alarm Quota:** Scheduling 105 exact alarms at once (7 days of sync) hits Android system limits on many devices.
2.  **Network Constraint:** The background refresh task currently requires internet, even though prayer calculations are offline.
3.  **One-Way Safety Net:** The native `WidgetUpdateWorker` (which runs every 15 mins) only updates widgets, not Azan notifications.
4.  **Redundant/Broken Sound Logic:** Azan sounds use complex URI logic that can fail silently if the FileProvider path is inconsistent.

## Proposed Changes

### 1. Optimize Notification Scheduling (`lib/core/services/notification/prayer_scheduler.dart`)
- **Reduce Window:** Change `maxScheduledDays` from 7 to **2 days**. This reduces the alarm count from 105 to ~30, staying safely under system limits.
- **Prioritize Azans:** Use `exactAllowWhileIdle` ONLY for Azans. Switch "Prayer Reminders" and "After Salah Azkar" to standard `allowWhileIdle` (non-exact). This makes the OS more likely to prioritize the Azan.
- **Catch-up Logic:** If an Azan time was missed by less than 1 minute (due to system lag), show it immediately.

### 2. Remove Background Constraints (`lib/core/services/background_service.dart`)
- Remove `networkType: NetworkType.connected` constraint from the periodic background task. Rescheduling should work 100% offline.

### 3. Strengthen the "Forever" Safety Net (`lib/core/services/widget_update_service.dart`)
- Update `WidgetUpdateService` (which is called by the native 15-minute worker) to also trigger `NotificationService.schedulePrayerNotifications()`. This ensures that even if the 12-hour Flutter task fails, the 15-minute native safety net will keep Azans scheduled.

### 4. Fix Sound URI Fallbacks (`lib/core/services/notification/sound_manager.dart`)
- Ensure `getSoundUriForChannel` returns `null` if file copying fails, instead of falling back to a broken resource path.
- In `channel_manager.dart`, if sound resolution fails, use the default system sound so the user at least gets a notification.

### 5. Add Battery Optimization Request (`lib/features/settings/presentation/screens/settings_screen.dart`)
- Add a clear action/button in the Settings UI to guide users to disable battery optimizations for the app, which is required for "Forever" reliability on brands like Xiaomi/Samsung.

## Verification
- **Diagnostic Tool:** Use the existing `runDiagnostics()` in `NotificationService` to verify channel and alarm states.
- **Manual Test:** Use the "Test Azan" button to verify sound URI resolution.
- **Logs:** Check background service logs to ensure rescheduling happens without internet.
