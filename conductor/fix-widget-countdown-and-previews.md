# Plan: Improve Countdown Widget and Add Previews

## Objective
1. Make the Next Prayer Countdown widget count up after the prayer starts ("from 1 by one and up").
2. Ensure high reliability of widget updates in the background.
3. Add visual previews for both home widgets (Prayer List and Countdown).

## Implementation Steps

### 1. Android Native (Kotlin)
- **NextPrayerCountdownWidgetReceiver.kt**: 
    - Use `goAsync()` in `onReceive` to prevent the process from being killed before updates complete.
- **PrayerWidgetReceiver.kt**:
    - Use `goAsync()` in `onReceive`.
    - Add `NextPrayerCountdownWidget().updateAll(context)` inside the update logic to ensure both widgets refresh when a prayer time is reached.
- **NextPrayerCountdownWidget.kt**:
    - Update `CountdownWidgetRoot` to handle the case where `diff <= 0`.
    - Instead of showing "Now" indefinitely, calculate the elapsed time since `nextPrayerTime` and show it as "+1m", "+2m", etc.
    - Ensure the countdown remains precise.

### 2. Android Resources (XML)
- **Layouts**:
    - Create `android/app/src/main/res/layout/widget_prayer_preview.xml`.
    - Create `android/app/src/main/res/layout/widget_countdown_preview.xml`.
    - These will use standard `TextView` and `ImageView` elements to simulate the Compose Glance UI for the widget picker.
- **Widget Info**:
    - Edit `android/app/src/main/res/xml/prayer_widget_info.xml` to add `android:previewLayout="@layout/widget_prayer_preview"`.
    - Edit `android/app/src/main/res/xml/next_prayer_countdown_widget_info.xml` to add `android:previewLayout="@layout/widget_countdown_preview"`.

## Verification Plan
1. **Countdown/Count-up**:
    - Observe the countdown reaching 0.
    - Verify it transitions to "Now" or "+0m" and then starts counting up ("+1m", "+2m").
2. **Background Updates**:
    - Kill the app and verify the countdown continues to update every minute.
    - Verify both widgets update immediately when a prayer time is reached.
3. **Previews**:
    - Open the Android widget picker and verify that both widgets show a realistic preview instead of the app icon or a loading state.
