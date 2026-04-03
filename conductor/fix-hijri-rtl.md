# Plan: Fix Hijri Date RTL Formatting in Home Widget

The user reports that the Hijri date in the home widget is formatted incorrectly in Arabic (RTL). Specifically, the year appears between the month and the day, and they want a specific format: `Day Month Yearهـ`.

## Problem Analysis
1.  **Current Formatting:** The current code in `lib/core/extensions/hijri_extension.dart` and `lib/core/services/widget_update_service.dart` uses `'$hDay ${getLongMonthName()} $hYear هـ'`.
2.  **Bidi Rendering Issues:** In an RTL context, the mix of Western Arabic numerals (LTR) and Arabic text (RTL) can lead to the "numbers jumping around" if the Bidi algorithm doesn't have enough context.
3.  **User's Desired Format:** `9 شوال 1447هـ`. The user also mentioned `9ه شوال` but later clarified the preference for `Day Month Yearهـ`.

## Proposed Solution
1.  **Use Explicit RTL Marker:** Add `\u200F` (Right-to-Left Mark) at the beginning of the Hijri date string for the Arabic locale.
2.  **Use Arabic-Indic Digits:** Use the `toArabicIndic()` extension to convert `hDay` and `hYear` to Eastern Arabic numerals (١, ٢, ٣). This provides stronger RTL context and is standard for formal Arabic Hijri dates.
3.  **Refine Suffix:** Ensure `هـ` is attached correctly (with or without space as preferred, standard is a space but user said "ه should be with the year", implying `1447هـ`).
4.  **Consolidate Logic:** Remove the duplicated `toVisualString` implementation in `widget_update_service.dart` and use the one in `hijri_extension.dart`.

## Implementation Steps
1.  **Modify `lib/core/extensions/hijri_extension.dart`:**
    *   Update `toVisualString` to include `\u200F` and `toArabicIndic()`.
    *   Adjust the format to `'$hDay ${getLongMonthName()} $hYear هـ'`.
2.  **Modify `lib/core/services/widget_update_service.dart`:**
    *   Remove the private `HijriVisual` extension.
    *   Ensure it uses the `HijriCalendarVisual` extension from `hijri_extension.dart`.
3.  **Verify with Tests:**
    *   Update `test/core/extensions/hijri_extension_test.dart` to expect the new format.
    *   Add a specific test case for the RTL order if possible.

## Verification Plan
1.  **Unit Tests:** Run `flutter test test/core/extensions/hijri_extension_test.dart`.
2.  **Manual Verification:** Since it involves the home widget, manual verification on an Android device/emulator would be ideal to see the actual rendering.
3.  **Static Analysis:** Run `flutter analyze` to ensure no issues with duplicated extensions or imports.
