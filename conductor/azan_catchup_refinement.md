# Plan: Refine Azan Catch-up & Time Change Handling

## Objective
Prevent multiple Azan notifications from firing at once if the device time changes or after a long sleep, ensuring only the single most relevant notification (the latest one) is shown.

## Proposed Changes

### 1. Refine Catch-up Logic (`lib/core/services/notification/prayer_scheduler.dart`)
- Modify the event gathering loop to identify missed events.
- If multiple Azans fall within the "very recent past" (1-minute window), only add the **latest** one to the `events` list.
- Keep the existing logic for future events.

### 2. Native Time Change Trigger (`android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt`)
- When a time change or timezone change is detected, enqueue a one-off `WorkManager` task for `prayer_scheduler_task`.
- This ensures that as soon as the user changes the time, the Flutter side wakes up, cancels all old alarms, and schedules the correct ones for the new time.

## Verification
- **Manual Test (Time Change):** Change phone time forward by 2 hours. Verify that only the most relevant current Azan fires (if applicable) and future ones are correct.
- **Manual Test (Catch-up):** Simulate a 45-second delay. Verify the Azan fires immediately.
- **Manual Test (Multiple Catch-up):** Simulate a time jump that puts two prayers in the last 60 seconds. Verify only the second one fires.
