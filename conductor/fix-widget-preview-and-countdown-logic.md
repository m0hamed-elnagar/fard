# Implementation Plan - Prayer Widget Previews and Countdown Responsiveness

This plan details the steps to implement two distinct preview widgets (1x1 and 2x2) for the Prayer Widget, fix the infinite recursion in the update logic, and enhance the responsiveness of the Countdown Widget.

## Objective
- Create separate 1x1 and 2x2 widget entries in the Android widget picker with accurate previews.
- Resolve the infinite recursion bug in `PrayerWidgetReceiver.kt`.
- Make the `NextPrayerCountdownWidget` truly responsive to any size.

## Key Files & Context
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`: Shared UI logic for prayer list.
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt`: Base receiver with update logic.
- `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidget.kt`: Countdown widget UI.
- `android/app/src/main/res/xml/prayer_widget_small_info.xml`: Config for 1x1.
- `android/app/src/main/res/xml/prayer_widget_large_info.xml`: Config for 2x2.

## Implementation Steps

### 1. Stage Untracked Files
- Stage the new receiver classes and XML configurations that were recently added but not tracked.
  - `PrayerWidgetSmallReceiver.kt`, `PrayerWidgetLargeReceiver.kt`
  - `prayer_widget_small_info.xml`, `prayer_widget_large_info.xml`
  - `widget_prayer_small_preview.xml`, `widget_prayer_large_preview.xml`

### 2. Fix Infinite Recursion and Update API Usage
- **Modify `PrayerWidgetReceiver.kt`**:
  - Rename the `updateAll(context: Context)` instance method to `refreshDataAndWidgets(context: Context)`.
  - In `refreshDataAndWidgets`, call `PrayerWidget().updateAll(context)` and `NextPrayerCountdownWidget().updateAll(context)`.
  - Update `onReceive` to call `refreshDataAndWidgets(context)`.
- **Update Callers**:
  - Modify `TimeChangedReceiver.kt` and `WidgetUpdateWorker.kt` to use correct `updateAll` calls on Widget classes instead of Receiver classes.

### 3. Enhance Countdown Widget Responsiveness
- **Modify `NextPrayerCountdownWidget.kt`**:
  - Define more granular size thresholds: `isCompact` (h < 100), `isWide` (w > 150), `isLarge` (h > 150).
  - Implement dynamic font scaling based on `DpSize`.
  - For very small sizes, simplify the layout to just the prayer name and countdown value.
  - For larger sizes, add back the "Next Prayer" label and increase font sizes.

### 4. UI/UX Polishing
- Ensure consistent color usage (Gold for next prayer, white for others).
- Verify that `prayer_widget_small_info.xml` correctly uses the 1x1 preview and `prayer_widget_large_info.xml` uses the 2x2 preview.

## Verification & Testing
- **Analysis**: Run `flutter analyze` to ensure no errors.
- **Visual Inspection**: Manually check the widget picker in the Android emulator (if possible) or verify the XML configuration matches the desired target cell sizes.
- **Logic Check**: Verify that `refreshDataAndWidgets` is called only once per update cycle and triggers the `GlanceAppWidget.updateAll` correctly.
