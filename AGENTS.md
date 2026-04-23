# AGENTS.md - Fard (Qada Tracker) Development Guide

## Project Overview
- **Type**: Flutter mobile application (Dart)
- **Purpose**: Islamic prayer tracking (Qada), Quran reader with audio, Azkar/Tasbih
- **Architecture**: Clean Architecture (Domain/Data/Presentation)
- **State Management**: flutter_bloc

## Key Commands

```bash
# Install dependencies
flutter pub get

# Generate code (required after adding Hive models or Freezed classes)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run single test
flutter test test/path/to/test.dart

# Lint / typecheck
flutter analyze

# Build Android debug APK
flutter build apk --debug
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── core/                      # Shared utilities
│   ├── di/injection.dart       # GetIt dependency injection
│   ├── services/             # NotificationService, PrayerTimeService, etc.
│   └── theme/               # ThemePresets, app_colors
└── features/
    ├── prayer_tracking/      # Main Qada tracking feature
    ├── quran/              # Quran reader
    ├── audio/              # Audio playback
    ├── azkar/              # Morning/evening reminders
    ├── settings/          # App settings
    ├── werd/               # Werd (Quran reading tracker)
    └── tasbih/              # Tasbih counter
```

## Code Generation

Generated files have `.g.dart` or `.freezed.dart` extensions. **Always regenerate after modifying:**
- Hive models (`@HiveType`, `@HiveField`)
- Freezed classes (`@freezed`, `@JsonKey`)
- Injectable registrations (`@injectable`)

Run: `dart run build_runner build --delete-conflicting-outputs`

## Testing Conventions

- Tests in `test/` mirror `lib/` structure
- Uses `bloc_test`, `mocktail` for mocking
- Many integration tests covering complex flows (history scenarios, offline audio, widget sync)

## Important Services

| Service | Location | Purpose |
|---------|----------|---------|
| NotificationService | `lib/core/services/notification_service.dart` | Prayer time + Azkar notifications |
| PrayerTimeService | `lib/core/services/prayer_time_service.dart` | Adhan calculations |
| WidgetUpdateService | `lib/core/services/widget_update_service.dart` | Home screen widget updates |
| SettingsCubit | `lib/features/settings/presentation/blocs/settings_cubit.dart` | Settings + auto-reminders |

## Key Dependencies

- `hive_ce` / `hive_ce_flutter` - Local storage (CE edition)
- `get_it` - Dependency injection
- `flutter_bloc` - State management
- `freezed` / `json_serializable` - Immutable models
- `injectable` - DI code generation
- `adhan` - Prayer time calculations
- `just_audio` - Quran audio playback

## Platform-Specific Notes

- **iOS**: Audio only on phone devices
- **Android**: Background audio with JustAudioBackground, Workmanager
- **Widgets**: Android home widget via `home_widget` package

## Lint Configuration

`analysis_options.yaml` uses Flutter recommended lints with `avoid_print: false`.