# Design: Enhanced Islamic Prayer Home Widget (UI/UX Improvement)

**Date:** 2026-03-29
**Status:** Approved

## 1. Objective
Enhance the current Home Widget for the "Fard" app with a premium Islamic aesthetic, better responsiveness, and missing data points (Sunrise, Day of Week, and RTL fixes).

## 2. Requirements
- **Data:** Add `sunrise` time, separate `dayOfWeek` field, and both Hijri and Gregorian dates.
- **Aesthetics:** "Midnight Emerald" theme with Forest Green background, Gold accents, and rounded corners (16dp).
- **Responsiveness:**
    - **1x1 (Tiny):** Keep current "Next Prayer" focus as-is.
    - **2x2 / 4x1 / 4x2 / 4x4:** Show full list (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) with a prominent date header.
- **RTL Support:** Fix alignment issues in Arabic so the Prayer Name and Time are correctly positioned and never overlap or swap incorrectly.

## 3. Architecture & Data Flow

### 3.1 Data Model Changes (`lib/core/models/widget_data_model.dart`)
- Add `dayOfWeek` (String).
- Add `sunrise` (String).
- Add `isRtl` (bool) based on locale.

### 3.2 Service Changes (`lib/core/services/widget_update_service.dart`)
- Extract `sunrise` from `adhan` `PrayerTimes`.
- Extract `dayOfWeek` using `DateFormat('EEEE', lang)`.
- Pass `isRtl = lang == 'ar'`.

### 3.3 Android Implementation (`android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`)
- **Theme:**
    - Background: `#0D1B1E` (Dark Forest Green).
    - Accent: `#FFD54F` (Gold).
    - Highlight: `#2E7D32` (Emerald Green).
- **RTL Handling:** Use `GlanceModifier` and `horizontalArrangement = Arrangement.SpaceBetween` in rows to ensure name/time alignment respects the `isRtl` flag.
- **Layouts:**
    - `TinyLayout`: Unchanged (Next Prayer + Time).
    - `FullLayout`: 
        - Header: Day of Week (Large), Hijri & Gregorian below it.
        - List: PrayerRow items including Sunrise.

## 4. Visual Mockup (Conceptual)
```
+---------------------------+
| [Day of Week] (Large)     |
| [Hijri Date] | [Gregorian]|
|---------------------------|
| Fajr            05:30 AM  |
| Sunrise         07:00 AM  |
| *Dhuhr*         12:30 PM  | <-- Active Highlighted
| Asr             03:45 PM  |
| Maghrib         06:15 PM  |
| Isha            07:45 PM  |
+---------------------------+
```

## 5. Testing & Validation
- **Unit Tests:** Verify `WidgetUpdateService` correctly populates the new fields.
- **Manual Verification:** Ensure the widget renders correctly in both LTR (English) and RTL (Arabic) orientations on Android.
