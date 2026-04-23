# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0+6] - 2026-04-23

### Added
- **Quran Symbols Guide**: New feature to explore and understand Quranic reading symbols with detailed explanations and a detection service.
- **Tasbih Navigation**: Added navigation arrows to the Tasbih page for easier switching between different remembrances.
- **Home Widget Theme Sync**: The home widget now perfectly synchronizes its colors with the app's theme presets (Emerald, Parchment, etc.), resolving the "shady green" issue.
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
