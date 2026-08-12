# Changelog

All notable changes to this project will be documented in this file.

## [1.6.5+22] - 2026-08-12

### Added
- **Battery Optimization & OEM Autostart Onboarding Page**: Added Page 4 to initial onboarding flow with dedicated cards for setting battery usage to "Unrestricted" and configuring OEM autostart toggles on supported brands (Xiaomi, Huawei, OPPO, Vivo, OnePlus, Samsung, Realme, Honor, POCO, Redmi).
- **Dismissible Home Screen Warning Banner**: Added a top warning card on the Home Screen for existing Android installs when battery optimization is restricted, with a 1-tap permanent dismiss option (`battery_prompt_dismissed_v1`).
- **Centralized Instruction Dialog**: Added `BatteryInstructionDialog` widget to centralize battery and OEM autostart guidance dialogs across Onboarding, Settings, and Home Screen.

### Fixed
- **Doze Mode Minute-Tick Self-Healing**: Updated `NextPrayerCountdownWidgetReceiver.kt` to evaluate `isTargetInvalid` (`now >= nextPrayerTime`) on minute-ticks and force persistent countdown notification updates when prayer target times have passed.
- **Centralized OEM Manufacturer Logic**: Centralized OEM manufacturer detection in `NotificationService.isOemDeviceForAutostart()` to eliminate duplicate OEM checking logic between Settings, Onboarding, and HomeScreen.

## [1.6.4+21] - 2026-08-08

### Added
- **Location Display in Notifications**: Integrated localized location indicator (`📍 Cairo` / `📍 القاهرة`) into the Next Salah Countdown Notification header.
- **Arabic City Name Translation**: Built bidirectional city name translator (`getLocalizedCityName`) mapping regional and international city names to Arabic when the app locale is Arabic.
- **Onboarding Countdown Control**: Added a dedicated switch card for enabling/disabling the Next Salah Countdown Notification directly in the Onboarding Azan setup step.
- **Background Actions**: Added background action buttons ("Mark as Prayed") to the Azan notification and the Salah countdown notification.
- **Port Communication Bridge**: Added `IsolateNameServer` port bridge (`notification_tap_port`) to send real-time notification action taps to the main isolate when the app is in the foreground.

### Changed
- **Instant Switch Responsiveness**: Updated `AdhanCubit` with optimistic UI state updates (0ms latency, instant 60fps switch animation) and asynchronous background MethodChannel calls.
- **High-Contrast Text Visibility**: Upgraded dark theme notification text to pure crisp white (`#FFFFFF`) for primary titles and bright off-white (`#E2E8F0`) for secondary labels.
- **Single Target Time Display**: Positioned target prayer time strictly once under the progress bar on the timeline, eliminating duplicate target time displays in the header.
- **Minimal Collapsed Notification**: Streamlined collapsed notification to a clean 2-line layout without location clutter, increasing progress bar height to 5dp for clear tracking.
- **Explicit RTL Layout Direction**: Applied `LAYOUT_DIRECTION_RTL` to native Android RemoteViews, aligning prayer titles to the right and location/times to the left in Arabic mode.

### Fixed
- **Past Prayer Time Synchronization**: Fixed native Kotlin background rollover to persist `flutter.prev_prayer_time` in `SharedPreferences` when prayer targets roll over in the background.
- **Safe SharedPreferences Reading**: Resolved `ClassCastException` in Kotlin when reading `prev_prayer_time` across `Long` and `Int` types.
- **Test Suite Stability**: Resolved mock SharedPreferences and mock NotificationService issues in unit and integration tests.

## [1.6.3+20] - 2026-07-18

### Added
- **Onboarding / Sound Status Checks**: Added native checks on Android (silent, vibration, do not disturb) with warning banners and localizations during onboarding to warn the user if notifications could be silenced.

### Changed
- **Settings Screen**: Redesigned the developer signature and settings footer with a new "About" dialog.
- **Settings Screen**: Cleaned up the settings display to show only the version name without the build number.

### Removed
- **Adhan Voices**: Removed 6 Adhan/Azan voices containing unwanted advertisement or website attribution outros (Hamad Deghreri, Ibrahim Al-Arkani, Majed Al-Hamathani, Mishary Rashid Alafasy, Mansoor Az-Zahrani, and Nasser Al-Qatami).

### Fixed
- **Adhan Cubit Test Mocking**: Fixed settings repository mock setup for `AdhanCubit` in tests to resolve Null casting errors.
- **Silent & Do Not Disturb Muting**: Integrated ringer mode and Do Not Disturb (DND) status checks in Android's native foreground playback service. Real alarms will now skip playing the Adhan audio when silent or DND is active, replacing the ongoing service notification with a clean, clearable alert.

## [1.6.2+19] - 2026-07-05

### Added
- **Battery Optimization Settings**: Added warning cards and settings tiles to guide Android users to set battery usage to "Unrestricted". Includes step-by-step guidance dialogs optimized for senior citizens.
- **Autostart Settings**: Added warning banners and settings entries targeting custom OEMs (Xiaomi, Huawei, OPPO, Vivo, OnePlus) to keep the app active in the background.
- **Dismissible warning cards**: Warning banners can be closed/dismissed permanently (persisting the state in SharedPreferences).
- **Developer OEM Spoof Toggle**: Added a debug-only option to spoof manufacturer settings, enabling easy testing of OEM warning cards on standard emulators or other brands.

### Fixed
- **Google Play Policy Compliance**: Removed `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` from the manifest. Querying and launching battery optimization bypass is now handled natively via MethodChannel and App Info redirects, completely avoiding policy review risks.

## [1.6.1+18] - 2026-07-04

### Fixed
- **Werd (Quran reading tracker)**: Fixed the issue where changing/editing the goal of the day would reset today's reading progress back to 0. It now correctly preserves today's progress counters, segments, and read items.
- **Werd Card position sync**: Updated the Werd progress card's next ayah calculation to prioritize `lastReadAbsolute` as the primary source of truth, ensuring that manual jumps or goal position shifts are properly respected by the "Continue" button.
- **Premature History Writes**: Removed premature writing of today's progress to the history map when editing goals, which previously caused data loss by overwriting earlier progress when the daily rollover happened.

## [1.5.9+17] - 2026-07-04

### Fixed
- **Local Notifications**: Corrected Android scheduled notification receiver NullPointerException by properly referencing the launcher icon resource as `@mipmap/ic_launcher` instead of `ic_launcher`.

## [1.5.8+16] - 2026-06-27

### Added
- **Local Fallback Fonts**: Added a local fallback directory (`assets/fonts/`) to the Flutter configuration.

### Fixed
- **Glance Widget**: Resolved crash on Android when clicking/opening the widget by providing an explicit intent flag instead of generic class action start activity.
- **Local Notifications**: Fixed local notification initialization crash on Android by using `ic_launcher` directly.
- **Reciters List**: Filtered out duplicate/alternate entries for reciters (identifiers ending with `-2`) from Al Quran Cloud to prevent duplicates in selection, and added comprehensive repository tests.
- **Google Fonts Loading**: Suppressed non-fatal Google Fonts network loading errors from polluting Crashlytics.

## [1.5.7+15] - 2026-06-21

### Added
- **After-Salah Azkar Card**: Redesigned the "After Salah" options to present Azkar directly as a top-level settings card with an integrated offset minutes slider.
- **Unified Prayer Selection**: Added smart master sync that dynamically registers toggles under a unified checklist.

### Changed
- **Pre-Prayer Reminders**: Removed hardcoded minute counts (`باقي X دقيقة`) from pre-prayer reminder notifications to avoid accuracy deviations, changing the notification body to `'اقتربت صلاة...'`.
- **Werd Reminder Default**: Updated the default time for Werd (Quran reading tracker) notifications from 8:00 PM to 8:00 AM (`08:00`).

### Removed
- **"Did you pray?" Logging Notification**: Completely deprecated/removed the legacy logging reminder to simplify user notifications and prevent overlapping alerts.

---

## [1.5.0+7] - 2026-06-13

### Added
- **Firebase Analytics** with typed in-app event tracking:
  - `prayer_marked` — fired when a Fard prayer is toggled to completed
  - `qada_completed` — fired when a Qada prayer is decremented
  - `quran_opened` — fired when the Quran reader successfully loads
  - `theme_changed` — fired when the user selects a new theme preset
- **Firebase Crashlytics** for automatic crash reporting:
  - Flutter framework errors reported as non-fatal
  - Unhandled async/platform errors reported as fatal
  - Crashlytics + Analytics collection **disabled in debug builds** to keep the Firebase Console clean
  - ProGuard/R8 mapping file upload enabled for human-readable release stack traces
- **`AnalyticsService`** — injectable service wrapping `FirebaseAnalytics`; all methods are silent no-ops if Firebase fails to initialize, fully decoupling feature code from Firebase

### Changed
- `FlutterError.onError` handler upgraded to `recordFlutterError` (non-fatal) — prevents minor Flutter framework warnings from appearing as fatal crashes in the Crashlytics dashboard

### Removed
- `USE_FULL_SCREEN_INTENT` Android permission — was declared but never used; all notifications explicitly set `fullScreenIntent: false`
- `requestLegacyExternalStorage="true"` from the Android manifest — no-op on Android 11+ and flagged by Play Store policy review tools

### Security
- `android/app/google-services.json` is now gitignored; it must be manually placed on fresh clones (see README — Firebase Setup)

---

## [1.4.0+6] - 2026-04-23

### Added
- **Quran Symbols Guide**: New feature to explore and understand Quranic reading symbols with detailed explanations and a detection service.
- **Tasbih Navigation**: Added navigation arrows to the Tasbih page for easier switching between different remembrances.
- **Home Widget Theme Sync**: The home widget now perfectly synchronizes its colors with the app's theme presets (Emerald, Antique, etc.), resolving the "shady green" issue.
- **SymbolDetectorService**: Added a service to identify specific Quran symbols from text.

### Changed
- **Home Widget Robustness**: Improved countdown heartbeat reliability and consistent 12h time formatting.
- **Smooth Transitions**: Refined prayer time transitions in the widget, narrowing the window to 1 minute and handling negative countdowns gracefully.
- **Dependency Injection**: Migrated ConnectivityService and ConnectivityBloc to `injectable` for better infrastructure management.
- **Audio Downloads**: Scoped download cancellation to individual surahs for better user control.
- **Offline Experience**: Enhanced offline mode banner and surah filtering logic.

### Fixed
- Fixed "shady green" background in Emerald theme home widget by using direct preset color mapping.
- Resolved various test stabilization issues across WidgetPreview, SetWerdGoalDialog, and integration flows.
- Improved notification permission and connectivity check flows.

## [1.3.1+5] - 2026-04-18

### Added
- Connectivity monitoring integration.
- Initial offline mode support for Quran audio.

### Changed
- Migrated various services to `injectable`.
- UI refinements for audio player controls.

### Fixed
- Fixed several bugs in prayer time calculations.
- Resolved issues with background task scheduling.
