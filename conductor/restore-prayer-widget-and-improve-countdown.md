# Plan: Restore Prayer Widget and Improve Countdown Responsiveness

## Objective
1. Restore the `PrayerWidget` to its original resizable vertical list design.
2. Make `NextPrayerCountdownWidget` responsive to its size (switching between horizontal/vertical layouts).
3. Maintain the 1x1 and 2x2 widget providers for the `PrayerWidget` using the restored UI.

## Implementation Steps

### 1. Restore PrayerWidget (Kotlin)
- **PrayerWidget.kt**: 
    - Revert the `PrayerWidgetRoot` implementation to the original version (vertical list of all prayers).
    - Remove the `isTiny` check that was showing only one prayer.
    - Keep the class structure that supports the new small/large receivers.

### 2. Responsive Countdown Widget (Kotlin)
- **NextPrayerCountdownWidget.kt**:
    - Update `CountdownWidgetRoot` to detect if the widget is in a "horizontal" aspect ratio (e.g., width > height * 1.5).
    - If horizontal: Show the prayer name and countdown side-by-side using a `Row`.
    - If vertical: Keep the stacked look.
    - Improve font scaling for tiny 1x1 sizes.

### 3. XML Updates
- Ensure `prayer_widget_small_info.xml` and `prayer_widget_large_info.xml` both point to the same `PrayerWidget` logic but keep their respective `targetCellWidth/Height` and previews.

## Verification Plan
1. Add both "Prayer Today" and "Prayer List" to the home screen; verify they both show the full list and are resizable.
2. Add "Next Prayer Countdown"; resize it to be wide (e.g., 4x1) and verify it switches to a horizontal layout.
3. Resize it back to 1x1 or 2x2 and verify it returns to a vertical layout.
