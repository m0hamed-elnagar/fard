# Fard: The Ultimate Qada Tracker & Spiritual Companion

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=Dart&logoColor=white)](https://dart.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![State Management](https://img.shields.io/badge/State-BLoC-blue.svg)](https://bloclibrary.dev)
[![Database](https://img.shields.io/badge/DB-Hive_CE-orange.svg)](https://pub.dev/packages/hive_ce)
[![Testing](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)](#)

**Fard** (Arabic: فرض - Obligation) is a high-performance, premium spiritual tool designed for the modern Muslim. It combines rigorous engineering with a sophisticated Islamic aesthetic to solve the complex problem of tracking missed prayers (Qada) and maintaining spiritual consistency.

---

## ✨ Key Features (User Experience)

### 🕋 Advanced Qada Tracking
Never lose track of your spiritual debts again.
- **Cumulative Debt Management**: Intelligent counter that automatically carries over missed prayers day-to-day.
- **Bulk Entry**: Quickly add missed prayers by specific count or date ranges for historical tracking.
- **Visual History**: Detailed monthly/yearly logs provide a bird's-eye view of your progress.

### 🕒 Intelligent Automation
The app works for you, ensuring accuracy wherever you are.
- **Automatic Time Sync**: Full global support for **Daylight Saving Time (Summer Time)**.
- **Timezone Awareness**: Automatically reschedules all notifications and recalculates prayer times when you travel.
- **Precision Calculations**: Leverages the `adhan` library with custom offsets to support users globally.

### 📖 Immersive Quran Experience
A complete Quran reader built into the heart of the app.
- **Multiple Text Modes**: Switch between Uthmani (standard), IndoPak, and Simple script styles.
- **Scanned Mushaf**: Enjoy the tactile feel of traditional image-based pages.
- **Seamless Navigation**: Jump instantly to any Surah, Ayah, Juz, or Hizb.
- **Werd (Goal Tracking)**: Set daily targets (Ayat, pages, or Juz) and visualize your reading progress.
- **Smart Bookmarks**: Save your place and return with a single click.

### 🎧 Premium Audio Recitation
Listen to  Quran anywhere, anytime.
- **Offline Mode**: Download your favorite reciters for playback without an internet connection.
- **World-Class Reciters**: Access a diverse library of renowned reciters.
- **Background Play**: Full media service integration—listen while using other apps or with your screen off.
- **Smart Controls**: Precise seeking, repeat modes, and automatic progress saving.

### 📿 Azkar
Keep your tongue moist with the remembrance of Allah.
- **Azkar Library**: Comprehensive database including Morning/Evening and After-Salah remembrances.
- **Digital Tasbih**: Responsive counter with custom-tuned **haptic feedback** simulating a physical bead experience.
- **Custom zikr**: Add and track your own personal remembrances.
- **Scheduled Reminders**: Never miss your morning or evening Azkar with precise, silent-mode-respecting notifications.

### 🎨 Premium Visual Experience
A sophisticated design system that adapts to your preference.
- **Theme Presets**: Choose from professionally crafted themes like **Emerald** (Deep Green), **Parchment** (Classic Manuscript), **Rose**, and **Twilight**.
- **Dynamic Color Engine**: Manually create your own theme by picking primary and accent colors; the app intelligently auto-derives a harmonious Material 3 palette for the entire UI.
- **Islamic Aesthetics**: Custom design tokens and theme extensions ensure a consistent, premium feel across all components.

---

## 🏛️ Technical Architecture (The Engine)
Fard is built using **Clean Architecture** and **Domain-Driven Design (DDD)** principles, ensuring the codebase is modular, maintainable, and 100% testable.

### The Three Layers:
1.  **Presentation Layer (UI & Logic)**:
    *   **Bloc Pattern**: Decouples UI from business logic using `flutter_bloc` and `bloc_concurrency`.
    *   **Theme Extensions**: Custom design tokens for specialized Islamic aesthetics (Emerald & Gold).
2.  **Domain Layer (Pure Business Logic - DDD)**:
    *   **Entities**: Immutable models generated with **Freezed** for robust state handling.
    *   **Use Cases**: Explicit orchestrators of business rules (e.g., `AddMissedPrayer`, `GetSurah`).
    *   **Repository Interfaces**: Pure abstractions defining the "what" without the "how".
3.  **Data Layer (Infrastructure)**:
    *   **Dependency Injection**: Automated service registration using **Get_It** and **Injectable**.
    *   **Offline-First Persistence**: High-concurrency data access via **Hive CE** (NoSQL).
    *   **Mappers**: Seamless transformation between Data Models (DTOs) and Domain Entities.

---

## 🧪 Robust Testing Suite
Quality is guaranteed through a comprehensive testing pyramid.

| Test Type | Scope | Tools |
| :--- | :--- | :--- |
| **Unit Tests** | Core math, Mappers, and Entity logic. | `package:test` |
| **BLoC Tests** | Every state transition and event flow. | `bloc_test` |
| **Widget Tests** | Component-level UI and accessibility validation. | `flutter_test` |
| **Integration Tests** | End-to-end user flows (Onboarding, Audio navigation). | `integration_test` |

---

## 🤖 Native Android Integration
Fard integrates deeply with the Android ecosystem to provide a premium feel:
-   **Home Screen Widgets**: Native Kotlin-based widgets for "Next Prayer" countdowns and Qada stats.
-   **WorkManager**: Reliable background synchronization for notifications and widget updates.
-   **Media Session**: System-level integration for Quran playback (lock screen & Bluetooth support).
-   **Boot Receivers**: Automatically reschedules prayer alarms and background tasks after a device restart.

---

## 💎 Engineering Highlights
-   **Performance**: Optimized for smooth 60fps animations and near-instantaneous database queries.
-   **Accessibility**: Full native support for **Arabic (Right-to-Left)** layouts and typography.
-   **Reliability**: Built-in JSON export/import service for safe data portability.
-   **Precision**: Custom offsets and multi-timezone support ensure accuracy in any corner of the world.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Java 17+ (for Android builds)

### Installation
1. **Clone & Install**
   ```bash
   git clone https://github.com/yourusername/fard.git
   flutter pub get
   ```
2. **Generate Code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Run**
   ```bash
   flutter run
   ```

---

## 📄 License
Private - All rights reserved. Built with ❤️ for the Ummah.
