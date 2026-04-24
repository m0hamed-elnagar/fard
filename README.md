# Fard: The Ultimate Qada Tracker & Spiritual Companion

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![Offline First](https://img.shields.io/badge/Offline-First-blue.svg)](#)

**Fard** (Arabic: فرض - Obligation) is a premium, feature-rich spiritual tool designed to help Muslims meticulously track missed prayers (Qada), maintain a daily Quran habit, and stay connected with their dhikr. Built with a focus on high-performance, offline-first reliability, and a sophisticated aesthetic.

---

## ✨ Key Features

### 🕋 Advanced Qada tracking
Never lose track of your spiritual debts again.
- **Precision Logging**: Mark each of the five daily prayers as performed or missed with a single tap.
- **Cumulative Debt Management**: Intelligent counter that automatically carries over missed prayers day-to-day.
- **Bulk Entry**: Quickly add missed prayers by specific count or date ranges for historical tracking.
- **Visual History**: An expandable calendar and detailed monthly/yearly logs provide a bird's-eye view of your progress.
- **Undo Support**: Safety first—easily revert accidental changes to your counts.

### 📖 Immersive Quran Experience
A complete Quran reader built into the heart of the app.
- **Multiple Text Modes**: Switch between Uthmani (standard), IndoPak, and Simple script styles.
- **Scanned Mushaf**: Enjoy the tactile feel of traditional image-based pages.
- **Seamless Navigation**: Jump instantly to any Surah, Ayah, Juz, or Hizb.
- **Werd (Goal Tracking)**: Set daily targets (Ayat, pages, or Juz) and visualize your reading progress.
- **Smart Bookmarks**: Save your place and return with a single click.

### 🎧 Premium Audio Recitation
Listen to the words of Allah anywhere, anytime.
- **World-Class Reciters**: Access a diverse library of renowned reciters.
- **Offline Mode**: Download your favorite Surahs for playback without an internet connection.
- **Background Play**: Full media service integration—listen while using other apps or with your screen off.
- **Smart Controls**: Precise seeking, repeat modes, and automatic progress saving.

### 📿 Daily Dhikr & Azkar
Keep your tongue moist with the remembrance of Allah.
- **Azkar Library**: Comprehensive database including Morning/Evening and After-Salah remembrances.
- **Digital Tasbih**: A responsive counter with haptic feedback and common presets.
- **Custom Dhikr**: Add and track your own personal remembrances.
- **Scheduled Reminders**: Never miss your morning or evening Azkar with precise, silent-mode-respecting notifications.

### 🕒 Intelligent Automation
- **Automatic Time Sync**: Full global support for **Daylight Saving Time (Summer Time)**.
- **Timezone Awareness**: Automatically reschedules all notifications and recalculates prayer times when you travel.
- **Home Screen Widgets**: Stay updated with next prayer countdowns and your current Qada count directly on your home screen.

---

## 🎨 Premium Design
Fard isn't just functional; it's beautiful.
- **Islamic Aesthetics**: A stunning Emerald & Gold dark theme inspired by traditional mosque architecture.
- **Customizable Themes**: Choose from curated presets or create your own custom color palette.
- **Responsive Layout**: Designed for phones, tablets, and desktops with a fluid, modern interface.

---

## 🛠 Tech Stack & Architecture
Fard is built using industry-standard best practices to ensure long-term maintainability and performance.

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **Architecture**: **Clean Architecture** (Domain, Data, Presentation layers)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) for predictable, testable state transitions.
- **Local Storage**: [Hive CE](https://pub.dev/packages/hive_ce) — high-performance, NoSQL local database for a lightning-fast offline experience.
- **Dependency Injection**: [Get_It](https://pub.dev/packages/get_it) & [Injectable](https://pub.dev/packages/injectable).
- **Core Library**: [Adhan](https://pub.dev/packages/adhan) for astronomical prayer time calculations.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fard.git
   cd fard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required code**
   (Crucial for Hive adapters and Freezed models)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

---

## 🧪 Development & Testing

We maintain high code quality through rigorous testing and analysis.

- **Run Analysis**: `flutter analyze`
- **Unit & Widget Tests**: `flutter test`
- **Integration Tests**: `flutter test integration_test/`

---

## 📄 License
Private - All rights reserved. Built with ❤️ for the Ummah.
