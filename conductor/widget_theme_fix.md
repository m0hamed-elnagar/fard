# Plan: Unified Dynamic Widget Theming & Synchronization

This plan outlines the steps to integrate the home screen widgets (Glance) with the app's theme presets and custom themes, ensuring they dynamically adapt to the user's color choices and selected theme mode (Light/Dark/Follow App).

## Objective
- Eliminate hardcoded colors in native widgets.
- Pass a full, derived color palette from Flutter to the native side.
- Ensure immediate widget refresh upon any theme-related change in the app.
- Support both theme presets (Emerald, Midnight, etc.) and custom user-defined themes in the widgets.

## Key Files
- `lib/core/models/widget_data_model.dart`: Data structure for widget synchronization.
- `lib/core/services/widget_update_service.dart`: Logic for generating the widget color palette.
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`: Native implementation for the prayer list widget.
- `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidget.kt`: Native implementation for the countdown widget.
- `lib/features/settings/presentation/blocs/settings_cubit.dart`: Triggering updates on theme changes.

## Implementation Steps

### 1. Data Model Enhancement
- Update `WidgetDataModel` in `lib/core/models/widget_data_model.dart` to include:
    - `textColorHex`: Primary text color.
    - `textSecondaryColorHex`: Secondary/muted text color.
- Run code generation: `dart run build_runner build --delete-conflicting-outputs`.

### 2. Adaptive Palette Logic (Dart)
- Refactor `WidgetUpdateService.updateWidget()` in `lib/core/services/widget_update_service.dart`:
    - Determine target `Brightness` based on `widgetThemeMode` (Light, Dark, or Platform).
    - Extract base colors (Primary, Accent) from the current `themePresetId` or `customThemeColors`.
    - Use `ColorScheme.fromSeed(seedColor: primary, brightness: targetBrightness)` to derive a harmonious and high-contrast palette.
    - Extract: `primary`, `secondary` (as Accent), `surface`, `onSurface` (as Text), `onSurfaceVariant` (as Secondary Text), and `background`.
    - Pass these 6 hex values to the `WidgetDataModel`.

### 3. Native Widget Refactoring (Kotlin)
- **PrayerWidget.kt**:
    - Update `WidgetData` data class to include `textColorHex` and `textSecondaryColorHex`.
    - Update `parseWidgetData` to read these new fields from the JSON.
    - Simplify `PrayerWidgetRoot` by removing the hardcoded `when` block. It should now use the 6 colors directly provided in the `data` object.
    - Fix the `Quintuple` class (or upgrade to a `Sextuple` if needed) to handle the full palette.
- **NextPrayerCountdownWidget.kt**:
    - Apply identical refactoring to match the new data-driven approach.

### 4. Synchronization Triggers
- Verify `SettingsCubit` in `lib/features/settings/presentation/blocs/settings_cubit.dart` triggers `_widget.updateWidget()` for:
    - `selectThemePreset`
    - `saveCustomTheme`
    - `activateCustomTheme`
    - `updateWidgetThemeMode` (already verified).

## Verification & Testing
1. **Dropdown Toggle**: Change "Widget Theme Mode" to Light/Dark/Follow App and verify the widget background and text colors update immediately.
2. **Preset Change**: Change the app theme to "Midnight" or "Rose" and verify the widget accent and primary colors align with the new preset.
3. **Custom Theme**: Modify a custom theme color and verify the widget reflects the change upon saving.
4. **Contrast Check**: Ensure text remains legible across all generated palettes, especially in Light mode.
