# Notification & Time Change Remediation Log

## Date: 2026-04-22
**Status:** Completed & Verified

### Issues Addressed
1.  **Notification Spam on Time Change:** Changing device time/date forward caused Android to fire all "skipped" exact alarms simultaneously.
2.  **Double Azan Bug:** Conflict between 1-minute "catch-up" logic and widget update WorkManager tasks caused two identical notifications to fire.
3.  **Intrusive Pop-ups:** Azan notifications forced the app into the foreground via `fullScreenIntent`.
4.  **Orphaned Alarms:** Older app versions (7-day window) left lingering alarms that the new 2-day logic wasn't clearing.

### Technical Implementation

#### 1. Native Spam Suppression (`android/.../TimeChangedReceiver.kt`)
- Added immediate `notificationManager.cancelAll()` inside `onReceive`.
- This clears the system tray the instant a time jump is detected, before Android can spam skipped alarms.
- Enqueued a silent `WidgetUpdateWorker` to reset the schedule for the new timeline.

#### 2. Schedule Optimization (`lib/core/services/notification/prayer_scheduler.dart`)
- **Removed Catch-up Logic:** Deleted the 1-minute window check that scheduled a second immediate Azan.
- **Removed Redundant Tasks:** Deleted `Workmanager().registerOneOffTask` for widget updates inside the Azan loop. Native `PrayerAlarmManager.kt` already handles this more reliably.
- **Deep Clean:** Increased `maxPrayerNotificationIds` from 10 to **100** in the cancellation loop to ensure all old IDs (from previous 7-day windows) are purged.
- **Silenced Pop-ups:** Set `fullScreenIntent: false` in `AndroidNotificationDetails`.

#### 3. Background Persistence (`lib/core/services/background_service.dart`)
- Confirmed the 15-minute native fallback worker unconditionally triggers notification rescheduling.
- This ensures the 2-day alarm window is constantly pushed forward, maintaining "forever" reliability without app opens.

### Verification Results
- **Time Change:** Verified (Simulated) that time jumps trigger a total clear followed by a clean single reschedule.
- **Double Fire:** Removed logic race condition; only 1 Azan per prayer time remains.
- **UX:** Notifications now appear as heads-up alerts/tray items without forcing app foregrounding.
