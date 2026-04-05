# Plan: Widget 1x1 Sizing and Static Previews

## Objective
1. Allow home widgets to be resized down to 1x1 cell.
2. Switch to static image previews (Choice 2) for stability.
3. Ensure the UI adapts gracefully to small 1x1 sizes.

## Implementation Steps

### 1. Android Widget Configuration (XML)
- **next_prayer_countdown_widget_info.xml**:
    - `minWidth="40dp"`, `minHeight="40dp"` (1x1 support).
    - `targetCellWidth="1"`, `targetCellHeight="1"`.
    - `android:previewImage="@drawable/widget_preview_countdown"`.
- **prayer_widget_info.xml**:
    - `minWidth="40dp"`, `minHeight="40dp"` (1x1 support).
    - `targetCellWidth="1"`, `targetCellHeight="1"`.
    - `android:previewImage="@drawable/widget_preview_prayer"`.

### 2. Glance UI Adaptation (Kotlin)
- **NextPrayerCountdownWidget.kt**:
    - Check `LocalSize.current`.
    - If width/height < 100dp (approx 1x1), hide the "Next Prayer" label and show only the prayer name and timer in a more compact stack.
- **PrayerWidget.kt**:
    - Check `LocalSize.current`.
    - If width/height < 100dp, show only the next 1-2 prayers or a very condensed list.

### 3. Reliability (Kotlin)
- Finalize `goAsync()` implementation in receivers (as planned previously) to ensure updates never fail in the background.

## Verification Plan
1. Add widgets to home screen; verify they start as 1x1 squares.
2. Resize them up to 2x2 or 4x2 and verify the UI expands to show more detail.
3. Check the widget picker (after user adds images) to verify previews.
