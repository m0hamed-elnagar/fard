# Fard (Qada Tracker) - Comprehensive Feature Report

This document provides a detailed breakdown of all features currently implemented in the Fard application. It serves as a reference for the current state of the codebase and as a foundation for future enhancements.

---

## 1. Core Module: Prayer Tracking & Qada
**Purpose:** Help users track their daily prayers and manage their missed (Qada) prayers count.

### Key Functionalities:
- **Daily Status Logging:** Users can mark prayers as "Done", "Missed", or "Qada Done" for the current date.
- **Persistent Qada Counters:** Maintains a cumulative total of missed prayers for each of the 5 Salaahs.
- **Bulk Qada Adjustment:** Dialogs to manually add or subtract missed days/years of prayers.
- **Calendar Integration:** A `TableCalendar` based view to see prayer history across different dates.
- **Missed Days Detection:** Automatically identifies days the user didn't log and prompts for status updates.

### UI Components:
- `HomeScreen`: The main landing page showing daily prayer status and Qada cards.
- `SalaahTile`: Interactive tile for logging status.
- `CounterCard`: Displays the total Qada count for a specific prayer.
- `CalendarWidget`: Month-view calendar for navigation and history review.
- `AddQadaDialog`: UI for manual counter adjustments.

### Data & State:
- **BLoC:** `PrayerTrackerBloc` manages the logic for loading, saving, and updating records.
- **Storage:** `Hive` (Box: `daily_records`) for efficient local persistence of `DailyRecord` entities.

---

## 2. Quran Feature
**Purpose:** A complete Quranic reading and listening experience with Tafsir support.

### Key Functionalities:
- **Surah List:** Browse all 114 Surahs with metadata (revelation type, ayah count).
- **Reader View:** Optimized Arabic text rendering with support for `Uthmani` script.
- **Interactive Ayahs:** Tap to select/highlight, double-tap or long-press to open details.
- **Audio Playback:**
  - **Single Ayah Mode:** Plays the selected ayah and stops.
  - **Continuous Surah Mode:** Continues playing until the end of the Surah.
  - **Reciter Selection:** Support for multiple reciters (e.g., Alafasy, Abdul Basit).
- **Tafsir:** Fetch and display Arabic Tafsir (Al-Jalalayn) for any Ayah.
- **Pinch-to-Zoom:** Dynamic resizing of Arabic text for better readability.

### UI Components:
- `QuranPage`: The Surah browser.
- `QuranReaderPage`: The main reading interface.
- `AyahText`: Custom RichText widget for rendering Arabic with high interaction precision.
- `AyahDetailSheet`: Bottom sheet for Tafsir and Audio controls.
- `SurahHeader`: Displays Surah info and a global "Play Surah" action.

### Data & State:
- **BLoC:** `ReaderBloc` (reading state, scaling, selection) and `AudioBloc` (playback management).
- **Service:** `AudioPlayerServiceImpl` using `just_audio`.
- **Repository:** `QuranRepositoryImpl` (cached Surahs and Ayahs) and `AudioRepositoryImpl`.

---

## 3. Adhan & Prayer Notifications
**Purpose:** Accurate prayer time calculation and reliable reminders.

### Key Functionalities:
- **Geo-Calculation:** Uses device coordinates and multiple calculation methods (Umm Al-Qura, MWL, etc.).
- **Customizable Adhan:** Each prayer can have Adhan enabled/disabled individually.
- **Downloadable Voices:** Users can download and select different voices for the call to prayer.
- **Short Reminders:** Option for a short notification (e.g., 10 mins) before the prayer time.
- **Reliable Alarms:** Uses `exactAllowWhileIdle` and `fullScreenIntent` on Android to ensure notifications trigger on time.
- **Timezone Awareness:** Schedules notifications using local device time via `flutter_timezone`.

### UI Components:
- `SettingsScreen`: Integrated Adhan/Reminder configuration toggles.
- `SalaahSettingsDialog`: Detailed per-prayer configuration (sound, reminder time).
- `LocationWarning`: UI element to prompt for location permissions if missing.

### Data & State:
- **Service:** `NotificationService`, `PrayerTimeService`, and `VoiceDownloadService`.
- **Logic:** Dynamic Android Channel creation to support custom notification sounds.

---

## 4. Azkar & Reminders
**Purpose:** Daily dhikr and post-prayer Azkar with progress tracking.

### Key Functionalities:
- **Categorized Azkar:** Morning, Evening, Post-Prayer, etc.
- **Interactive Counter:** Tap-to-count interface with vibration feedback.
- **Progress Persistence:** Remembers the last count even if the app is closed.
- **Automatic Reset:** Resets Azkar daily or manually per item/category.
- **Post-Prayer Trigger:** Prompt to read specific Azkar after marking a prayer as "Done".

### UI Components:
- `AzkarCategoriesScreen`: Grid/List view of available Azkar groups.
- `AzkarListScreen`: The counting interface.
- `AzkarCounter`: The main interaction widget for dhikr.

### Data & State:
- **BLoC:** `AzkarBloc` manages counts and reset logic.
- **Repository:** `AzkarRepository` using Hive for count persistence.

---

## 5. Qibla Compass
**Purpose:** Help users find the direction of the Kaaba.

### Key Functionalities:
- **Real-time Direction:** Uses the device's magnetometer and location to calculate Qibla angle.
- **Smooth Animation:** Visual compass needle that reacts to device rotation.

### UI Components:
- `QiblaScreen`: Dedicated screen with a graphical compass.

---

## 6. App Infrastructure & Settings
- **Onboarding:** A one-time setup flow for language and initial Qada entry.
- **Localization:** Full support for **English** and **Arabic** (RTL support throughout).
- **Theming:** Clean, Material 3 based Light and Dark themes.
- **DI:** Robust dependency injection using `GetIt`.
- **Testing:** Comprehensive test suite including unit, widget, and integration tests.

---

# PROMPT: Enhancing Fard (Functionalities & UI)

**Role:** You are an expert Flutter Developer and UI/UX Designer specializing in Islamic apps.

**Context:** The application "Fard" is already a robust Qada and Quran tracker with features like Adhan notifications, Azkar, and Qibla. Your task is to take it to the "Gold Standard" level.

**Instructions for Enhancement:**

1. **UI/UX Polish:**
   - Review all screens (`HomeScreen`, `QuranReaderPage`, `SettingsScreen`) and suggest a more modern, cohesive aesthetic using Material 3.
   - Implement smoother transitions and animations (e.g., Hero animations between Surah list and Reader).
   - Improve the "Reading Experience" in the Quran module (e.g., better typography, night-mode optimized colors).

2. **Functional Depth:**
   - **Quran:** Add a "Bookmark" system that persists to local storage. Implement a search feature for Surahs and Ayahs.
   - **Prayer Tracking:** 
     - Add a **"Statistics"** view with visual charts (using `fl_chart`) showing progress over weeks/months.
     - Add support for **Witr** and **Sunnah** prayers as optional trackable items.
     - Implement an **"Estimated Completion"** calculator for current Qada debt.
   - **Backup & Restore:** Add a simple JSON export/import system to prevent data loss.
   - **Notifications:** Improve battery optimization handling with a dedicated settings guide.
   - **Azkar:** Add a "Custom Azkar" feature where users can add their own dhikr.

3. **Technical Optimization:**
   - Ensure all network calls (Quran data, Tafsir) have proper caching and offline support.
   - Refactor UI components into smaller, more reusable widgets.
   - Optimize the `AudioPlayerService` for gapless playback between ayahs in Surah mode.

4. **Reliability:**
   - Verify all edge cases for Adhan (e.g., phone restart, timezone changes, silent mode overrides).

**Output Expectation:** Provide a step-by-step implementation plan for these enhancements, including code snippets for critical logic and design descriptions for UI changes.
