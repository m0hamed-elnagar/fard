# Implementation Plan: Native Prayer Widget System with Synchronized Settings

## Objective
Migrate to a hybrid-native architecture for prayer time calculations to ensure accurate, synchronized widget updates. Flutter remains the primary settings controller, while Native Kotlin calculates prayer times independently using the same algorithm (`adhan`).

## Key Files & Context
- **Flutter (Settings):** `lib/features/settings/presentation/blocs/settings_cubit.dart`, `lib/core/services/settings_loader.dart`
- **Flutter (Widget Service):** `lib/core/services/widget_update_service.dart`
- **Native Kotlin:** `android/app/src/main/kotlin/com/qada/fard/`
- **Native UI (Glance):** `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`
- **Android Configuration:** `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`

## Implementation Steps

### Phase 1: Native Layer Preparation (Kotlin)

1.  **Add Dependencies:**
    - Add `com.batoulapps.adhan:adhan:1.2.0` to `android/app/build.gradle.kts`.

2.  **Create Prayer Calculation Logic:**
    - `android/app/src/main/kotlin/com/qada/fard/prayer/PrayerTimesCalculator.kt`: A singleton wrapper around the Adhan library.
    - `android/app/src/main/kotlin/com/qada/fard/prayer/CalculationSettings.kt`: Data class holding calculation parameters (lat, lon, method, madhab, locale).
    - `android/app/src/main/kotlin/com/qada/fard/prayer/SettingsRepository.kt`: Helper to read settings from `HomeWidgetPreferences` and map them to `CalculationSettings`.

3.  **Create Shared UI Components:**
    - `android/app/src/main/kotlin/com/qada/fard/widget/GlanceTheme.kt`: Define shared colors and styles for both widgets.

### Phase 2: Widget Development (Kotlin)

1.  **Refactor Existing `PrayerWidget.kt`:**
    - Update to use `PrayerTimesCalculator` instead of reading pre-calculated JSON from Dart if possible, or use a hybrid approach where it recalculates if needed.
    - Ensure it matches the visual design from the existing implementation.

2.  **Create `NextPrayerCountdownWidget.kt`:**
    - New Glance widget showing:
        - Next prayer name.
        - Countdown timer (HH:MM:SS).
        - Progress bar for the current prayer interval.
    - Updates every minute via `ACTION_TIME_TICK`.

3.  **Update Receivers:**
    - `PrayerWidgetReceiver.kt`: Ensure it handles both widgets.
    - `TimeChangedReceiver.kt`: Explicitly trigger recalculation and update for both widgets.
    - `BootReceiver.kt`: Ensure both widgets are refreshed on boot.

### Phase 3: Flutter Integration (Dart)

1.  **Settings Synchronization:**
    - Modify `SettingsCubit` in `lib/features/settings/presentation/blocs/settings_cubit.dart` to sync settings to `HomeWidget` whenever they change (latitude, longitude, calculation method, madhab, locale).
    - Add `_syncToHomeWidget()` method and call it in all relevant setters.

2.  **Widget Update Service Update:**
    - Update `WidgetUpdateService` in `lib/core/services/widget_update_service.dart` to ensure it still provides the necessary data for the widgets but primarily focuses on syncing settings.

### Phase 4: Android Configuration

1.  **Register New Widget:**
    - Add `NextPrayerCountdownWidget` to `AndroidManifest.xml`.
    - Create `res/xml/next_prayer_countdown_widget_info.xml`.

2.  **Resource Updates:**
    - Update `res/values/strings.xml` and `res/values-ar/strings.xml` with prayer names and labels for native use.

## Verification & Testing

1.  **Parity Test:**
    - Verify that prayer times calculated in Flutter (Dart) and Native (Kotlin) match exactly for various locations and calculation methods.
2.  **Settings Sync Test:**
    - Change calculation method/location in Flutter and verify that the widget updates immediately with the correct native calculation.
3.  **Countdown Test:**
    - Verify that the countdown widget updates every minute and correctly transitions to the next prayer.
4.  **Timezone/Time Change Test:**
    - Manually change the phone's time or timezone and verify that widgets update immediately.
5.  **Reboot Test:**
    - Reboot the device and verify that widgets refresh automatically.
