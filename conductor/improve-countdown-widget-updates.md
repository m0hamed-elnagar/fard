# Plan: Improve Next Prayer Countdown Widget Update Frequency

The objective is to make the "Next Prayer Countdown" home widget update immediately when a minute passes, even when the app is in the background or killed.

## Background
Currently, the app uses a dynamic `InstantTimeReceiver` for `ACTION_TIME_TICK` updates. This receiver only works while the app process is alive. When the process is killed by Android (common for background apps), the widget stops updating every minute and falls back to a 15-minute `WorkManager` safety net.

## Proposed Changes

### 1. Android (Kotlin)
- **Modify `NextPrayerCountdownWidgetReceiver.kt`**:
    - Implement a robust `AlarmManager` based update loop.
    - Add `ACTION_MINUTE_UPDATE` constant.
    - Implement `scheduleNextMinuteUpdate(context)` to schedule an alarm at the start of the next minute.
    - Handle `ACTION_MINUTE_UPDATE` in `onReceive` by updating the widget and scheduling the next alarm.
    - Start the loop in `onEnabled` and stop it in `onDisabled`.
    - Ensure it also handles system events like `BOOT_COMPLETED`, `TIME_SET`, and `TIMEZONE_CHANGED` to keep the loop running.

- **Update `AndroidManifest.xml`**:
    - Add necessary intent-filters to `NextPrayerCountdownWidgetReceiver` to handle reboots and time changes.

- **Cleanup `FardApplication.kt` and `InstantTimeReceiver.kt`**:
    - Remove the dynamic `InstantTimeReceiver` as it's redundant with the new `AlarmManager` approach.

### 2. Flutter
- No changes needed in the Flutter layer as it already correctly updates the data in `SharedPreferences`.

## Verification Plan

### Automated Tests
- Since this is a native Android widget behavior change, automated testing is difficult without a full Android integration test suite that supports widgets.
- We will rely on manual verification and log analysis.

### Manual Verification
1. Add the "Next Prayer Countdown" widget to the home screen.
2. Observe the countdown. It should update exactly when the system clock changes minute.
3. Kill the app from the task manager.
4. Observe the widget again. It should CONTINUE to update every minute.
5. Restart the device and verify the widget resumes updating after boot.
6. Change the system time/timezone and verify the widget adjusts immediately.

## Log Analysis
- Check `adb logcat` for "CountdownWidgetRec" tags to see if `ACTION_MINUTE_UPDATE` is firing every minute.
