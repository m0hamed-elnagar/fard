# Fard - Qada Tracker App Documentation

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Automatic Time Synchronization](#automatic-time-synchronization)
4. [Technical Architecture](#technical-architecture)
5. [User Guide](#user-guide)
6. [Development Guide](#development-guide)
7. [Changelog](#changelog)

---

## Overview

**Fard** (Arabic: فرض -Obligation) is a comprehensive Islamic prayer tracking application for Muslims to track their missed prayers (Qada) and maintain daily spiritual practices.

### App Purpose
- Track missed (Qada) prayers that accumulate
- Read the Quran with progress tracking
- Listen to Quran recitation
- Daily Azkar reminders
- Tasbih counter for dhikr

### Version Information
- **Current Version**: 1.3.1+5
- **Min Android**: API 21 (Android 5.0)
- **Min iOS**: 12.0

---

## Features

### 1. Qada Prayer Tracking
| Feature | Description |
|---------|------------|
| Daily tracking | Mark Fajr, Dhuhr, Asr, Maghrib, Isha as performed/missed |
| Qada counter | Cumulative missed prayer count |
| Calendar view | Visual calendar showing prayer history |
| Add Qada | Add missed prayers by count or date range |
| History | Monthly/yearly view of all prayer records |
| Undo | Limited undo for recent changes |

### 2. Quran Reader
| Feature | Description |
|---------|------------|
| Text modes | Uthmani, IndoPak, Simple |
| Scanned mushaf | Image-based pages |
| Scroll navigation | Jump to surah/ayah/juz/hizb |
| Bookmarks | Save positions |
| Search | Search text in Quran |
| Audio | Play recitation (offline support) |

### 3. Werd (Quran Progress)
| Feature | Description |
|---------|------------|
| Set goals | Daily/weekly/monthly targets |
| Track progress | Visual progress bar |
| History | Session history |
| Units | Track by ayah/page/juz |

### 4. Audio Player
| Feature | Description |
|---------|------------|
| Reciters | Multiple reciters available |
| Offline | Download audio for offline use |
| Background | Play in background |
| Controls | Play/pause, seek, repeat |

### 5. Azkar (Remembrances)
| Feature | Description |
|---------|------------|
| Categories | Morning/Evening, After Salah, etc. |
| Reminders | Scheduled notifications |
| Progress | Track completion |

### 6. Tasbih
| Feature | Description |
|---------|------------|
| Counter | Digital tasbih |
| Presets | Common tasbihat |
| Custom | Add custom dhikr |

### 7. Settings
| Feature | Description |
|---------|------------|
| Location | GPS or manual location |
| Calculation | Prayer time calculation method |

| DST Support | Automatic Summer Time (Daylight Saving Time) adjustment |
| Theme | Dark/Light with custom colors |
| Notifications | Enable/disable reminders |
| Backup | Export/Import data |

### 8. Home Widget
- Display next prayer countdown
- Shows Qada count
- Customizable theme

### 9. Automatic Time Synchronization
| Feature | Description |
|---------|------------|
| DST Awareness | Fully respects and automatically adjusts for Summer Time (Daylight Saving Time) globally |
| Timezone Sync | Automatically synchronizes prayer times when the device's timezone or system clock changes |
| Real-time Updates | Background service reschedules notifications immediately upon system time changes |

---

## Technical Architecture

### Clean Architecture Layers

```
lib/
├── main.dart                    # Entry point
├── core/                        # Shared
│   ├── di/                      # Dependency Injection
│   ├── services/                # Services
│   ├── theme/                   # Themes
│   ├── utils/                  # Utilities
│   └── ...
└── features/
    ├── prayer_tracking/          # Qada tracking
    │   ├── data/                # Data layer
    │   ├── domain/               # Domain layer
    │   └── presentation/         # UI layer
    ├── quran/                   # Quran
    ├── audio/                   # Audio playback
    ├── azkar/                   # Azkar
    ├── settings/                 # Settings
    ├── werd/                    # Progress tracking
    └── tasbih/                  # Tasbih
```

### State Management
- **flutter_bloc** for state management
- Cubits for simpler state (Settings, Theme)
- BLoCs for complex flows

### Data Storage
- **hive_ce** for local NoSQL storage
- **SharedPreferences** for settings
- Filesystem for audio/images

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | 9.1.1 | State management |
| hive_ce | 2.19.1 | Local database |
| get_it | 9.2.0 | Dependency injection |
| freezed | 3.2.5 | Immutable models |
| adhan | 2.0.0+1 | Prayer times |
| just_audio | 0.10.5 | Audio playback |

---

## User Guide

### Getting Started

1. **First Launch**
   - Complete onboarding
   - Set location for prayer times
   - Configure notification times

2. **Daily Usage**
   - Open app each prayer time
   - Mark prayers as performed or missed
   - Track Qada count

### Qada Tracking

**How to mark prayers:**
1. Open home screen
2. Tap prayer tiles (Fajr, Dhuhr, etc.)
3. Toggle between performed/missed

**Adding missed prayers:**
- Tap "+" button
- Enter count or select dates
- Confirm

### Quran Reader

1. Open Quran from home
2. Navigate via surah list or search
3. Tap ayah for audio/verse info
4. Use scroll progress indicators

### Werd (Progress)

1. Set a goal (daily ayah target)
2. Read Quran
3. Progress auto-tracks
4. View history

### Azkar

1. Morning/evening notifications
2. Tap to view azkar
3. Mark complete

---

## Development Guide

### Building the Project

```bash
# Install dependencies
flutter pub get

# Generate code (after changes)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Analyze
flutter analyze

# Build APK
flutter build apk --debug
```

### Testing

- Unit tests in `test/unit/`
- Widget tests in `test/widgets/`
- Integration tests in `test/integration/`

### Code Generation

Required after modifying:
- Hive models (`@HiveType`, `@HiveField`)
- Freezed classes (`@freezed`)
- Injectable services (`@injectable`)

---

## Changelog

### v1.3.1 (Current)
- Enhanced Qada tracking
- Quran reader improvements
- Offline audio support
- Home widget enhancements
- Bug fixes

### v1.3.0
- Custom themes
- Werd tracking
- Tasbih counter

### v1.2.x
- Basic Qada tracking
- Quran text
- Azkar reminders

---

## FAQ

### Q: How is Qada calculated?
A: Each missed prayer adds to your Qada total. You can mark them as performed to reduce the count.

### Q: Can I export my data?
A: Yes, go to Settings > Backup > Export

### Q: Does the app work offline?
A: Yes, all core features work offline. Quran text is bundled; audio requires download.

### Q: Can I change prayer calculation method?
A: Yes, Settings > Location > Calculation Method

### Q: Does the app support Summer Time (Daylight Saving Time)?
A: Yes. The app automatically detects your region's summer timing rules and adjusts all Salah times and notifications accordingly. No manual adjustment is required.

### Q: What happens if I travel to a different timezone?
A: The app detects system timezone changes and will automatically synchronize prayer times for your new location (ensure GPS is enabled or update location manually in Settings).

---

## Credits

- Prayer times: Adhan package
- Quran text: Tanzil project
- Audio: Various reciters
- App icon: Islamic design

---

## License

Private - All rights reserved