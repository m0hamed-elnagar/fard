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
