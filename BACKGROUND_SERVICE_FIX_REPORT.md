# Background Service and Notification Fix Report

## Overview
The background service has been finalized using the `workmanager` package to ensure that prayer notifications are scheduled reliably and indefinitely. The implementation follows architectural best practices for Flutter background isolates and optimizes the user experience by keeping notification displays clean.

## Key Improvements

### 1. Indefinite Scheduling (WorkManager)
- **Periodic Task**: A periodic background task is registered to run every **12 hours**.
- **Buffer Management**: Each execution of the background task schedules a **7-day buffer** of prayer notifications.
- **Self-Healing**: Since the task runs twice a day, it continuously pushes the 7-day window forward, ensuring that the user never runs out of scheduled notifications as long as the background service is active.
- **Existing Work Policy**: Uses `ExistingPeriodicWorkPolicy.update` to ensure that any changes to location or calculation methods are reflected in the background task immediately.

### 2. Clean Notification UI (timeoutAfter)
- **Dynamic Timeouts**: The `PrayerNotificationScheduler` now calculates the duration until the *next* scheduled prayer event.
- **Automatic Dismissal**: Each notification is scheduled with a `timeoutAfter` value. This ensures that a displayed notification (e.g., Fajr) automatically disappears from the notification tray when the next prayer (e.g., Dhuhr) is due.
- **Clutter Reduction**: This fulfills the requirement of "only being interested in the last one of each," preventing a buildup of old prayer notifications.

### 3. Robust Background Initialization
- **Bindings & Timezones**: The `callbackDispatcher` correctly initializes `WidgetsFlutterBinding` and `timezone` data within the background isolate.
- **Dependency Injection**: Minimal, background-safe versions of services (e.g., `BackgroundAzkarSource`) are used to avoid unnecessary overhead or dependency on the main UI's `getIt` container if it's not fully initialized in the background.
- **Error Handling**: Comprehensive try-catch blocks and logging ensure that background failures are captured and don't crash the service.

### 4. Code Quality & Lints
- **Named Parameters**: Fixed `FlutterLocalNotificationsPlugin.initialize` to use named parameters as required by version 20.x, removing the need for lint suppressions.
- **Style Consistency**: All flow control structures in the settings screen now use curly braces, adhering to the project's styling guidelines.
- **Type Safety**: Removed unnecessary casts in the notification scheduling logic where `TZDateTime` was already correctly inferred.

## Verification
- **Static Analysis**: `dart analyze` passes with no critical errors or major lints.
- **Manual Test**: "Test Azan" and "Test Reminder" buttons in the app settings verify the notification engine and sound playback.
