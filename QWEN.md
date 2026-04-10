# Fard (Qada Tracker) - Project Context

## Project Overview

**Fard** is a premium Flutter mobile application for tracking missed Islamic prayers (Qada). The app helps users maintain a structured record of daily prayers (Salaah) and tracks cumulative missed prayers that carry over day-to-day.

### Key Features
- **Daily Prayer Tracking**: Mark the five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) as completed or missed
- **Qada Management**: Automatic tracking of cumulative missed prayers with add-by-count or add-by-date-range options
- **Persistent Storage**: Offline-first architecture using Hive NoSQL database
- **Audio Player**: Quran recitation playback with background service support (phone devices only)
- **Azkar & Tasbih**: Islamic remembrance tracking with categorized azkar
- **Prayer Times**: Location-based prayer time calculations with azan notifications
- **Localization**: Full English (`en`) and Arabic (`ar`) support with RTL layout
- **Premium UI**: Dark theme with Islamic-inspired Emerald & Gold aesthetics (Material 3)

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter (SDK ^3.10.7) |
| **State Management** | flutter_bloc (BLoC/Cubit pattern) |
| **Dependency Injection** | get_it + injectable |
| **Database** | hive_ce (NoSQL, offline-first) |
| **Code Generation** | freezed, json_serializable, hive_ce_generator |
| **Architecture** | Clean Architecture (Domain / Data / Presentation) |
| **Notifications** | flutter_local_notifications (^20.1.0) |
| **Background Tasks** | workmanager (^0.9.0+3) |
| **Audio** | just_audio + just_audio_background |
| **UI Components** | table_calendar, google_fonts, flutter_screenutil |
| **Location** | geolocator, geocoding |
| **Islamic Utilities** | adhan, hijri, quran |

---

## Project Structure

```
fard-2/
├── lib/
│   ├── core/                    # Shared core functionality
│   │   ├── constants/           # App-wide constants
│   │   ├── di/                  # Dependency injection (get_it)
│   │   ├── errors/              # Error handling classes
│   │   ├── extensions/          # Dart extensions
│   │   ├── l10n/                # Localization (ARB files)
│   │   ├── models/              # Shared models
│   │   ├── services/            # Global services (notifications, background, migration)
│   │   ├── theme/               # App theme (Material 3)
│   │   ├── usecases/            # Shared use cases
│   │   ├── utils/               # Utility functions
│   │   └── widgets/             # Reusable widgets
│   ├── features/                # Feature modules (Clean Architecture)
│   │   ├── audio/               # Quran audio playback
│   │   ├── azkar/               # Azkar (remembrance) tracking
│   │   ├── onboarding/          # Initial user onboarding
│   │   ├── prayer_tracking/     # Core prayer/Qada tracking
│   │   ├── quran/               # Quran reading & bookmarks
│   │   ├── settings/            # App settings & preferences
│   │   ├── tasbih/              # Digital tasbih counter
│   │   └── werd/                # Daily Wird management
│   ├── main.dart                # App entry point
│   └── hive_registrar.g.dart    # Generated Hive adapter registrar
├── android/                     # Android platform configuration
├── ios/                         # iOS platform configuration
├── assets/                      # Static assets
│   ├── azkar.json               # Azkar data
│   ├── tasbih_data.json         # Tasbih configuration
│   └── pages/                   # Page images/assets
├── test/                        # Unit & widget tests
├── integration_test/            # End-to-end integration tests
└── docs/                        # Documentation files
```

### Clean Architecture Layers (per feature)

```
features/[feature_name]/
├── data/                        # Data layer
│   ├── datasources/             # Local/remote data sources
│   ├── models/                  # Data models (DTOs)
│   └── repositories/            # Repository implementations
├── domain/                      # Business logic layer
│   ├── entities/                # Business entities
│   ├── repositories/            # Repository interfaces
│   └── usecases/                # Business use cases
└── presentation/                # UI layer
    ├── blocs/                   # BLoC/Cubit state management
    ├── screens/                 # App screens
    └── widgets/                 # Feature-specific widgets
```

---

## Building and Running

### Prerequisites
- Flutter SDK ^3.10.7
- Dart SDK ^3.10.7
- Android Studio / Xcode (for platform-specific development)
- Java Development Kit (for Android builds)

### Installation

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Code** (required for Hive/Freezed/Injectable)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run App**
   ```bash
   flutter run
   ```

### Testing

```bash
# Run all unit and widget tests
flutter test

# Run integration tests
flutter test integration_test/

# Run specific test file
flutter test test/features/prayer_tracking/prayer_tracker_bloc_test.dart
```

### Code Analysis

```bash
# Static analysis
flutter analyze

# Format code
dart format .
```

---

## Development Conventions

### Architecture Patterns
- **Clean Architecture**: Strict separation between Domain, Data, and Presentation layers
- **BLoC Pattern**: State management using `flutter_bloc` with immutable states (Freezed)
- **Repository Pattern**: Data access abstracted through repository interfaces
- **Dependency Injection**: Constructor injection with `get_it` and `injectable` annotations

### Coding Style
- **Lint Rules**: Extends `package:flutter_lints/flutter.yaml`
- **Formatting**: Standard Dart format (2-space indentation)
- **Naming Conventions**:
  - BLoCs: `[Feature]Bloc` or `[Feature]Cubit`
  - Events: `[Feature]Event` (sealed classes with Freezed)
  - States: `[Feature]State` (sealed classes with Freezed)
  - Entities: `[Entity]Entity` (e.g., `DailyRecordEntity`)
  - Use Cases: `[Action][Entity]` (e.g., `GetDailyRecord`)

### State Management Pattern
```dart
// Event definition (Freezed sealed class)
@freezed
class PrayerTrackerEvent with _$PrayerTrackerEvent {
  const factory PrayerTrackerEvent.checkMissedDays() = _CheckMissedDays;
  const factory PrayerTrackerEvent.markPrayerCompleted(...) = _MarkPrayerCompleted;
}

// State definition (Freezed sealed class)
@freezed
class PrayerTrackerState with _$PrayerTrackerState {
  const factory PrayerTrackerState.initial() = _Initial;
  const factory PrayerTrackerState.loading() = _Loading;
  const factory PrayerTrackerState.success(...) = _Success;
  const factory PrayerTrackerState.failure(String error) = _Failure;
}

// BLoC usage
class PrayerTrackerBloc extends Bloc<PrayerTrackerEvent, PrayerTrackerState> {
  @override
  Stream<PrayerTrackerState> mapEventToState(PrayerTrackerEvent event) async* {
    // Event handling logic
  }
}
```

### Testing Practices
- **Unit Tests**: Test BLoCs, repositories, and use cases in isolation
- **Widget Tests**: Test individual widgets and screens
- **Integration Tests**: End-to-end flow testing using `integration_test` package
- **Mocking**: Use `mocktail` for creating mock dependencies
- **BLoC Testing**: Use `bloc_test` for BLoC state stream testing

### Localization
- **ARB Files**: Stored in `lib/core/l10n/`
- **Template**: `app_en.arb` (English)
- **Supported Locales**: English (`en`), Arabic (`ar`)
- **Generation**: `flutter gen-l10n` (configured in `l10n.yaml`)

### Version Logging Rule
**Every feature addition, bug fix, or version update MUST be logged in `VERSION_LOG.md`**:
1. **Increment version number** following semantic versioning: `MAJOR.MINOR.PATCH+BUILD`
   - MAJOR: Breaking changes
   - MINOR: New features (backward compatible)
   - PATCH: Bug fixes only
   - BUILD: Build number (increment each release)
2. **Add entry with date** under the version header
3. **Include sections** (as applicable):
   - 🎯 Features (new user-facing features)
   - ✨ Improvements (UX/performance enhancements)
   - 🐛 Bug Fixes (issues resolved)
   - 🧪 Tests (tests added/removed)
   - 🔧 Technical Details (new files, modified files, dependencies)
   - ⚠️ Known Issues (outstanding problems)
   - 📦 Dependencies Added (new packages)
   - 🔗 Related Commits (commit messages)
4. **Reference related commits and PRs** in the Related Commits section
5. **Note any breaking changes** prominently at the top of the entry
6. **Review before committing** - ensure the log accurately reflects changes

**Template**: See `VERSION_LOG.md` for the format template at the bottom of the file.

**Example**:
```markdown
## v1.4.0+6 (2026-04-10)
### 🎯 Features
- Session-based werd tracking with ReadingSegment
- Jump dialog for long-distance navigation
```

---

## Key Services

### Notification Service
- Uses `flutter_local_notifications` v20+
- Handles prayer time notifications with azan sounds
- Background scheduling via WorkManager

### Background Service
- Uses `workmanager` package for reliable background execution
- Runs every 12 hours to schedule 7-day prayer notification buffer
- Self-healing design ensures continuous notification coverage

### Widget Update Service
- Updates home screen widgets with prayer times
- Forces refresh on app start for accurate timing

### Migration Service
- Handles asset migration on first launch
- Ensures Hive boxes are properly initialized

---

## Key Architecture Decisions

### Werd Session Tracking
The Werd (daily Quran reading goal) feature uses **session-based tracking** with the following rules:

1. **"Continue" creates a new session**: Each time the user clicks "Continue" from the home screen, a new `ReadingSegment` is created immediately (not just when reading starts)
2. **Ghost session cleanup**: If the user clicks "Continue" but reads nothing and clicks "Continue" again within 5 minutes, the empty session (1 ayah, no reading) is automatically removed
3. **Previous session auto-ended**: If the previous session has real reading (more than 1 ayah or older than 5 minutes), it is properly ended with `endSession()` before the new one is created
4. **Crash-resilient**: If the app crashes or is force-closed mid-reading, the stale session (with `endTime == null`) is properly handled on the next "Continue" click
5. **"Current Position" in Werd card footer**: Calculated from the last session's `endAyah + 1`, NOT from `lastReadAbsolute` (which only updates when the user actually reads ayahs)

**Key files:**
- `lib/features/werd/domain/entities/reading_segment.dart` - Session entity with start/end timestamps
- `lib/features/werd/presentation/blocs/werd_bloc.dart` - Session creation/management logic
- `lib/features/prayer_tracking/presentation/widgets/werd_progress_card.dart` - Werd card UI with session display and footer "Current Position" logic

**Why not auto-end on navigation?** We chose explicit session creation on "Continue" instead of auto-ending sessions on page navigation because:
- It's deterministic and doesn't rely on navigation events
- Handles app crashes/force-close without stale session cleanup complexity
- Matches the user's mental model: "I clicked Continue = new session"

---

## Design System

### Material 3 (Material You)
- **Primary Color**: Emerald Green (`#2E7D32`)
- **Accent Color**: Gold/Amber (`#FFD54F`)
- **Background**: Deep Dark (`#0D1117`)
- **Corner Radius**: `24.0` to `28.0` for cards and containers
- **Typography**: `GoogleFonts.outfit`

### Reference
- [Android Material You UI Kit - Figma](https://www.figma.com/design/LglvCa6Cxj53J4HKpEqw5g/Android-Material-You-UI-Kit--Free---Community-)

---

## Important Notes

### Platform-Specific Considerations
- **Audio Playback**: Currently supported on phone devices only
- **Location Services**: Requires permissions for prayer time calculations
- **Notifications**: Platform-specific initialization (Android, iOS, Windows)
- **Home Widgets**: Uses `home_widget` package for platform-specific widget implementations

### Known Technical Details
- **Hive Adapters**: Must be registered before use (see `configure_dependencies.dart`)
- **Timezone Data**: Requires `tz.initializeTimeZones()` before scheduling notifications
- **Background Isolates**: Use minimal, background-safe service instances
- **Code Generation**: Always run `build_runner` after modifying Freezed/Injectable classes

### Common Commands
```bash
# Regenerate all generated files
dart run build_runner build --delete-conflicting-outputs

# Watch for changes during development
dart run build_runner watch --delete-conflicting-outputs

# Generate localization
flutter gen-l10n

# Clean build
flutter clean && flutter pub get
```

---

## Documentation Files

| File | Description |
|------|-------------|
| `README.md` | Project overview and quick start guide |
| `DESIGN.md` | Design system documentation |
| `APP_SUMMARY.md` | Comprehensive app functionality summary |
| `AGENTS_PLAN.md` | Recent development plan and status |
| `BACKGROUND_SERVICE_FIX_REPORT.md` | Background service implementation details |
| `future_tasks.txt` | Pending feature requests and known issues |

---

## Version Information
- **App Version**: 1.3.1+5
- **Package Name**: `com.nagar.fard`
- **Minimum SDK**: Flutter 3.10.7 / Dart 3.10.7
