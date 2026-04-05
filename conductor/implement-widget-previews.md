# Plan: Implement Widget Previews (v2)

This plan implements high-quality widget previews for both `PrayerWidget` and `NextPrayerCountdownWidget`, using provided screenshots for `previewImage` and custom XML for `previewLayout`.

## Objective
- Provide accurate, premium-looking previews in the widget picker.
- Align widget sizes with user requirements (2x2 for PrayerWidget, 2x1 banner for CountdownWidget).
- Use provided screenshots for static previews (`previewImage`).

## Proposed Changes

### 1. Cleanup
- Remove `android/app/src/debug/kotlin/com/qada/fard/WidgetPreviewActivity.kt`.
- Remove `android/app/src/debug/AndroidManifest.xml`.

### 2. Static Previews (Provided Images)
- Copy `assets/home_widgets/peayer_tumes2x2.jpeg` to `android/app/src/main/res/drawable/widget_preview_prayer.jpg`.
- Copy `assets/home_widgets/count_down2x1.jpeg` to `android/app/src/main/res/drawable/widget_preview_countdown.jpg`.
- Note: Android resources can use `.jpg` or `.jpeg` extension (both become `@drawable/...`).

### 3. Widget Metadata (Android)
- **`android/app/src/main/res/xml/prayer_widget_info.xml`**:
    - Update `targetCellWidth="2"`, `targetCellHeight="2"`.
    - Set `android:previewLayout="@layout/widget_preview_prayer"`.
    - Set `android:previewImage="@drawable/widget_preview_prayer"`.
- **`android/app/src/main/res/xml/next_prayer_countdown_widget_info.xml`**:
    - Update `targetCellWidth="2"`, `targetCellHeight="1"`.
    - Set `android:previewLayout="@layout/widget_preview_countdown"`.
    - Set `android:previewImage="@drawable/widget_preview_countdown"`.

### 4. Interactive Preview Layouts (XML)
- Ensure `android/app/src/main/res/layout/widget_preview_prayer.xml` and `android/app/src/main/res/layout/widget_preview_countdown.xml` are polished.

## Implementation Steps

1.  Remove `WidgetPreviewActivity.kt` and its debug `AndroidManifest.xml`.
2.  Copy JPEG files from `assets/home_widgets/` to `android/app/src/main/res/drawable/`.
3.  Update `prayer_widget_info.xml` and `next_prayer_countdown_widget_info.xml` to correctly reference `@drawable/widget_preview_prayer` and `@drawable/widget_preview_countdown`.
4.  Remove the previously created vector fallbacks (if they conflict) or overwrite them with the JPGs.

## Verification
- Long-press home screen and check widget picker for both widgets.
- Verify naming ("Prayer Schedule" and "Next Prayer Countdown") is displayed correctly.
