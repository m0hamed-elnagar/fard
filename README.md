# Qada Tracker (Fard)

A premium Flutter application for tracking missed Islamic prayers (Qada). Features include persistent debt tracking, auto-save functionality, an expandable calendar, and monthly history logs. Built with Clean Architecture, BLoC state management, and Hive local storage for a robust and offline-first experience.

## Features

- **Daily Tracking**: Mark prayers as missed or performed.
- **Persistent Local Storage**: Data saved securely using Hive.
- **Qada Management**: Track cumulative missed prayers that carry over day-to-day.
- **Add Qada**: Quickly add missed prayers by count or by date range (time).
- **History**: View past records and daily snapshots.
- **Premium UI**: Dark theme with Islamic-inspired aesthetics (Emerald & Gold).
- **Audio Player**: Listen to Quran recitations (currently supported on phone devices only).

## Tech Stack

- **Framework**: Flutter
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Database**: hive (NoSQL)
- **Code Generation**: freezed, json_serializable
- **Architecture**: Clean Architecture (Domain / Data / Presentation)

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Code** (required for Hive/Freezed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run App**
   ```bash
   flutter run
   ```
