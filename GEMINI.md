XXR# Fard (Qada Tracker) Project Context

This document provides foundational context and instructions for the Fard (Qada Tracker) project. Use this as a guide for development, maintenance, and interaction within this codebase.

## Project Overview

**Fard** is a premium Flutter application designed for tracking missed Islamic prayers (Qada). It emphasizes a robust, offline-first experience with a focus on persistent debt tracking and high-quality aesthetics.

### Key Features
- **Prayer Tracking:** Daily logs for missed (Qada) or performed prayers.
- **Cumulative Debt Management:** Persistent tracking of cumulative missed prayers that carry over daily.
- **Adhan & Prayer Times:** Precise prayer time calculation using the `adhan` package, with notification support (Azan sounds).
- **Quran Audio:** Integration for listening to Quran recitations with background playback support.
- **Azkar & Tasbih:** Islamic remembrances and a digital tasbih counter.
- **Android Widgets:** Native home screen widgets for prayer times and countdowns.
- **Hijri Calendar:** Support for the Islamic calendar.

## Tech Stack & Architecture

- **Framework:** Flutter (Dart)
- **State Management:** `flutter_bloc` (BLoC pattern)
- **Dependency Injection:** `get_it` with `injectable` for code-generated configuration.
- **Local Storage:** `hive_ce` (NoSQL) for high-performance offline storage.
- **Architecture:** Clean Architecture (Domain / Data / Presentation) organized by **Feature**.
- **Android Integration:** Kotlin-based native widgets and receivers.

### Core Modules (`lib/core/`)
- **DI:** Dependency injection setup (`injection.dart`, `configure_dependencies.dart`).
- **Services:** High-level services for notifications, background tasks, migrations, and widget updates.
- **Theme:** Islamic-inspired dark theme (Emerald & Gold).
- **L10n:** Localization support (Primary: Arabic, Secondary: English).

### Features (`lib/features/`)
- `prayer_tracking`: Core logic for managing prayer records and Qada counts.
- `quran`: Quran reader and metadata management.
- `audio`: Playback and download logic for Quran recitations.
- `azkar`: Database and UI for Islamic remembrances.
- `settings`: User preferences, location, and calculation methods.
- `werd`: Structured Quran reading portions.

## Engineering Standards

### Coding Conventions
- **Naming:** Follow standard Dart/Flutter conventions (`PascalCase` for classes, `camelCase` for variables/methods, `snake_case` for files).
- **Immutability:** Favor immutable data structures and `equatable` for BLoC states and events.
- **Code Generation:** Use `build_runner` for Hive adapters, Freezed classes, and Injectable DI.
- **UI Logic:** Keep `build` methods clean; move complex logic to BLoCs or dedicated helper classes.

### Project Mandates (GEMINI.md Precedence)
- **GitFlow:** Use feature branches for development, `develop` for integration, and `main` for releases.
- **Testing:** Always add tests when implementing features or fixing bugs. Never remove existing tests unless they are obsolete.
- **Android Linting:** Use `./gradlew :app:lintDebug` from the `android` directory for Kotlin/Android linting.
- **Validation:** Always run `flutter analyze` and relevant tests before completing a task.

## Building and Running

### Prerequisites
- Flutter SDK (see `pubspec.yaml` for version requirements).
- Android Studio / VS Code with Flutter/Dart plugins.

### Key Commands
- **Install Dependencies:** `flutter pub get`
- **Code Generation:** `dart run build_runner build --delete-conflicting-outputs`
- **Run Application:** `flutter run` (Target Windows/Android as needed)
- **Run Unit Tests:** `flutter test`
- **Run Integration Tests:** `flutter test integration_test/`
- **Analyze Code:** `flutter analyze`

## Current Project State (Restoration Phase)

The project is currently undergoing a **Restoration Phase** to resolve technical debt and analysis errors. Key focus areas include:
1. **Reader Test Alignment:** Aligning Quran reader tests with the `AyahText` widget implementation.
2. **Audio Service Stabilization:** Synchronizing repositories and download services.
3. **DI Refactoring:** Resolving "unregistered type" warnings and ambiguous extensions.

Refer to `docs/MASTER_REMEDIATION_PLAN.md` for the detailed session-by-session roadmap.
