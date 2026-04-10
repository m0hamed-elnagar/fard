# Fard: Qada Tracker - App Summary

## Overview
**Fard** is a Flutter-based mobile application designed to help users track their missed Islamic prayers (Salaah), commonly referred to as Qada. The app provides a structured way to log daily prayers and maintain a cumulative count of prayers that need to be made up.

## Core Functionality

### 1. Prayer Tracking (Core Module)
- **Daily Logging:** Users can mark the status of the five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha).
- **Qada Counter:** Automatically tracks and manages the count of missed prayers.
- **Daily Records:** Maintains a history of prayer completion for each day.
- **Calendar Integration:** Provides a visual representation of prayer history and status over time.

### 2. Onboarding
- **Initial Setup:** Guides new users through the application's purpose and initial configuration to ensure a smooth start.

### 3. Settings & Personalization
- **Localization:** Full support for both English (`en`) and Arabic (`ar`) languages.
- **Theming:** Customizable app theme (Light/Dark mode support).
- **User Preferences:** Management of global app settings via a dedicated Cubit.

### 4. Werd (Daily Quran Reading Goals)
- **Session-Based Tracking:** Each reading session is tracked separately with start/end times
  - Multiple separate sessions per day (e.g., morning reading, evening reading)
  - `ReadingSegment` entity stores: start/end ayah, timestamps, duration
  - New sessions created on each "Continue" click from home
  - Ghost sessions auto-cleaned (empty sessions < 5 min removed)
- **Goal Types:** Fixed amount (ayahs/pages/juz) or finish-in-days
- **Progress Display:** Fractional support (pages, juz) with unit selector
- **History:** Per-day reading history with session count and details
- **Cycle Completion:** Tracks completed Quran cycles with celebration dialog

### 5. Quran Reader
- **Audio Playback:** Quran recitation with background service (phone devices only)
- **Bookmarks:** Ayah-level bookmark tracking
- **Werd Integration:** Automatic progress sync with daily reading goals
- **Jump Navigation:** Smart dialog for long-distance ayah jumps

### 6. Azkar & Tasbih
- **Az Categories:** Morning, evening, prayer, and other categorized remembrances
- **Tasbih Counter:** Digital counter with preset categories and custom mode
- **Persistent Counts:** Daily tracking with reset logic

---

## Key Design Decisions

### Session Tracking Logic (Werd)
- **"Continue" creates a new session**: Each time the user clicks "Continue" from home, a new `ReadingSegment` is created
- **Ghost session cleanup**: If the user clicks "Continue" but reads nothing and clicks again within 5 minutes, the empty session is removed
- **Previous session auto-ended**: If the previous session has real reading, it's properly ended before creating the new one
- **Crash-resilient**: Stale sessions from crashes are handled on the next "Continue" click
- **Footer "Current Position"**: Calculated from the last session's `endAyah + 1`, not from `lastReadAbsolute` (which only updates on actual reading)

---

## Technical Stack

### Frontend & Framework
- **Flutter:** Cross-platform UI framework.
- **Material Design:** Follows Material Design principles for a modern and intuitive UI.
- **Google Fonts:** Custom typography for enhanced readability.

### State Management & Architecture
- **flutter_bloc:** Utilizes BLoC (Business Logic Component) and Cubit for predictable state management.
- **Clean Architecture:** Divided into `data`, `domain`, and `presentation` layers to ensure maintainability and scalability.
- **GetIt:** Used for Dependency Injection (DI) to manage service instances.

### Data & Persistence
- **Hive:** A lightweight and blazing fast key-value database for local storage (used for daily records and counters).
- **Shared Preferences:** Used for storing simple user settings and preferences.

### Code Generation & Utilities
- **Freezed:** For creating robust, immutable data classes and unions.
- **Hive Generator:** Automates the creation of Hive adapters.
- **Equatable:** Simplifies object comparison.
- **Intl:** Handles internationalization and date formatting.

### Testing
- **Unit & Widget Testing:** Extensive tests using `flutter_test` and `bloc_test`.
- **Mocking:** `mocktail` for creating mock objects in tests.
- **Integration Testing:** `integration_test` for end-to-end verification.
