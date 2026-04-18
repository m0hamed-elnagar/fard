# Fard: Qada Tracker - Gap Analysis & Improvement Roadmap

This document outlines the current limitations, missing features, and technical gaps identified during the codebase analysis, along with a roadmap for future improvements.

## 1. Identified Gaps & Missing Features

### A. Core Functionality (Prayer Tracking)
- **Initial Qada Debt Calculation:** The app lacks a setup wizard during onboarding to help users estimate their existing Qada backlog based on age, years of practice, etc.
- **Prayer Times (Adhan):** There is no integration for calculating local prayer times based on geolocation.
- **Notifications & Reminders:** No push notifications to remind users to log their prayers or alert them when a prayer time has passed.
- **Advanced Statistics:** Missing visual charts (bar/pie charts) to show progress over weeks/months/years or "estimated completion date" for current Qada debt.
- **Optional/Sunnah Prayers:** The `Salaah` enum is hardcoded to the 5 obligatory prayers; it doesn't support Witr (often tracked as Qada in some schools of thought) or Sunnah prayers.

### B. Onboarding & UX
- **Interactive Onboarding:** The current onboarding is static. It should include a multi-step process for:
    1. Language & Theme selection.
    2. Location setup (for prayer times).
    3. Initial Qada count entry.
- **Missed Days Logic:** While the app detects "missed days" (gaps in usage), the "Acknowledge All" feature is binary. Users cannot currently specify *which* prayers were missed during a 3-day gap; it marks all 15 prayers as missed by default.

### C. Data & Reliability
- **Backup & Restore:** Data is stored locally in Hive. If the user changes phones or clears app data, all records are lost. Integration with Google Drive/iCloud or a simple JSON export/import is missing.
- **Cloud Sync:** No backend integration to sync data across multiple devices.

### D. Settings
- **Calculation Methods:** No settings for choosing different calculation methods for prayer times (e.g., MWL, ISNA, Egypt, etc.).
- **Customization:** Users cannot rename prayers or adjust the order.

---

## 2. Technical Debt & Architectural Improvements

### A. Performance Optimization
- **Repository Efficiency:** `PrayerRepoImpl.loadMonth` currently iterates through the entire Hive box to filter records for a specific month. This will become a performance bottleneck as the user's history grows over years.
    - *Proposed Fix:* Use indexed keys (e.g., `yyyy-MM`) or a separate box for monthly metadata.
- **BLOC Logic:** The `PrayerTrackerBloc` performs list sorting and heavy object manipulation on every UI toggle.
    - *Proposed Fix:* Keep the history sorted in the state or use a more efficient data structure (like a Map).

### B. Scalability
- **Hardcoded Enums:** The `Salaah` enum limits the app's flexibility.
    - *Proposed Fix:* Transition to a configuration-based model where "Trackable Items" can be defined by the user.

---

## 3. Recommended Improvement Roadmap

### Phase 1: Quality of Life (Short-term)
1. **Initial Qada Calculator:** Add a screen in onboarding to help users calculate their starting debt.
2. **Notification System:** Implement local notifications for daily reminders.
3. **Backup/Restore:** Add functionality to export and import data as JSON files.

### Phase 2: Feature Expansion (Mid-term)
1. **Prayer Times Integration:** Use a library (like `adhan`) and `geolocator` to show daily prayer times.
2. **Interactive Gap Resolution:** Allow users to check/uncheck specific prayers when filling in missed days.
3. **Visual Analytics:** Add a "Progress" tab with charts using `fl_chart`.

### Phase 3: Advanced Features (Long-term)
1. **Cloud Sync:** Implement Firebase or a custom backend for cross-device synchronization.
2. **Social/Community Features:** Optional features like "Group Challenges" or sharing progress.
3. **Wearable Support:** Integration with Apple Watch or Wear OS for quick logging.
