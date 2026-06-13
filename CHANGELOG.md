# Changelog

All notable changes to this project will be documented in this file.

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
