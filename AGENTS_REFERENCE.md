# Agent Collaboration Reference

## Project Overview
**Fard** is a Flutter-based application for tracking missed prayers (Qada) and daily Azkar. It uses Clean Architecture principles with Bloc/Cubit for state management.

## Current Architecture

### 1. Dependency Injection
*   **Loc:** `lib/core/di/injection.dart`
*   **Tool:** `get_it`
*   **Key Registrations:**
    *   `NotificationService` (Singleton) - Handles local notifications.
    *   `PrayerTimeService` (Singleton) - Calculates prayer times using `adhan` dart package.
    *   `SettingsCubit` (Factory) - Manages app settings, location, and reminders.
    *   `AzkarBloc` (Factory) - Manages Azkar categories, lists, and progress.

### 2. State Management
*   **Settings:** Managed by `SettingsCubit`. Persists data to `SharedPreferences`.
    *   *Trigger:* Updates to settings (locale, location, times) automatically trigger `_updateReminders()` to reschedule notifications.
*   **Azkar:** Managed by `AzkarBloc`. Loads data from `assets/azkar.json` and persists progress to `Hive`.
*   **Prayer Tracking:** Managed by `PrayerTrackerBloc`. Handles daily prayer logs and missed prayer counts (Hive).

### 3. Key Features Implementation

#### A. Azkar Reminders (Notifications)
*   **Service:** `lib/core/services/notification_service.dart`
*   **Library:** `flutter_local_notifications`
*   **Logic:**
    *   Schedules two daily notifications: Morning (ID 100) and Evening (ID 101).
    *   Times are determined by `SettingsState` (either manual time or calculated Fajr/Asr if "Auto" is enabled).
    *   **Content:** Picks a random Zekr from the corresponding category to display in the notification body.
    *   **Trigger:** Called via `SettingsCubit._updateReminders()` whenever relevant settings change.

#### B. Azkar Dialog (Foreground)
*   **Loc:** `lib/features/prayer_tracking/presentation/screens/home_screen.dart` (`_HomeBodyState`)
*   **Logic:**
    *   A `Timer` checks every minute if the current time matches the scheduled Morning or Evening Azkar time.
    *   If matched and not yet shown today, an `AlertDialog` appears asking the user if they want to read the Azkar.
    *   **Action:** Navigates to `AzkarListScreen` upon confirmation.

#### C. Settings & Auto-Configuration
*   **Loc:** `lib/features/settings/presentation/screens/settings_screen.dart`
*   **Auto Mode:**
    *   Toggle `autoAzkarTimes` in settings.
    *   When ON: UI displays calculated Fajr/Asr times (read-only).
    *   When OFF: UI displays time pickers for manual selection.
*   **Contrast:** Time pickers use a Dark Theme configuration for better visibility.

### 4. Known Issues & Watch-outs
*   **Platform Specifics:** iOS permissions are requested in `NotificationService.init()`. Android 13+ permissions might need explicit handling if not covered by the plugin's default behavior (currently assumes granted or basic setup).
*   **Timezone:** `timezone` package is initialized. Ensure `tz.local` is correctly set if the user changes timezones (currently relies on device default).
*   **Deprecations:** `withOpacity` is used instead of `withValues` for compatibility with older Flutter SDKs if needed, though `withValues` is the modern standard.

### 5. Files of Interest
*   `lib/main.dart`: App entry point, initializes DI, Notifications, and Schedules initial reminders.
*   `lib/core/services/notification_service.dart`: The core logic for scheduling background notifications.
*   `lib/features/settings/presentation/blocs/settings_cubit.dart`: The "brain" connecting settings changes to notification updates.
