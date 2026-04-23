s stts# Widget Theme Fix Plan

## Objective
Fix the widget theme synchronization bug where selecting "Reset to Default" applies Emerald colors in the preview but incorrect colors on the actual Android Home Widget. Also, improve the Settings UI by wrapping widget color customization inside an expandable section and updating "Reset to Default" to a clearer "Follow App Theme" behavior.

## Background & Motivation
Currently, when the widget preview uses the default Emerald/Gold colors, the Android widget logic explicitly ignores these colors (because it checks against a hardcoded list of defaults). It then falls back to the `prayer_data` colors, which dynamically track the app's *active* theme. This results in the Android widget rendering with dynamic colors while the Settings preview incorrectly shows the fixed Emerald/Gold theme.

## Implementation Steps

### 1. Fix Kotlin Theme Override Detection
- **`SettingsRepository.kt`**: Add a `hasWidgetThemeOverride()` function that strictly checks if the `flutter.widget_theme_primary` key exists in SharedPreferences, rather than doing an equality check against hardcoded defaults.
- **`PrayerWidget.kt` & `NextPrayerCountdownWidget.kt`**: Update `hasThemeOverride` calculation to use `SettingsRepository.hasWidgetThemeOverride()`. This guarantees any explicitly saved theme is respected, preventing the fallback logic from falsely kicking in.

### 2. Implement Clear Widget Theme Method Channel
- **`WidgetUpdateService.dart`**: Add a `clearWidgetTheme()` method that invokes a new `clearWidgetTheme` method channel to the native layer.
- **`MainActivity.kt`**: Listen for `clearWidgetTheme` in the method call handler and execute `SettingsRepository.clearWidgetTheme()`. This gives the Flutter app the ability to wipe the override completely so the Android widget dynamically tracks the app's theme.

### 3. Improve Settings UI (`settings_screen.dart`)
- **Expandable Clean-up**: Move the `WidgetColorPicker` list (Primary, Accent, Background, Text, Secondary Text) into its own expandable section (e.g. `_buildExpandableSection` or an `ExpansionTile`) to declutter the settings screen.
- **Rename & Repurpose "Reset to Default"**: Change the text to reflect "Follow App Theme" (adding a new `.arb` string if needed).
- **Follow App Theme Behavior**: When clicked, it will update `_widgetPreviewTheme` to `WidgetPreviewTheme.fromColorScheme(Theme.of(context).colorScheme)` so the user instantly sees the preview follow the app theme. Tapping Apply will then call `clearWidgetTheme()` to purge the overrides.

## Verification
- Customize a widget theme and verify the Android home widget updates correctly.
- Click "Follow App Theme" and verify the settings preview adjusts to the app's current theme (e.g. light or dark mode colors).
- Verify the Android home widget reverts to dynamic app theme tracking.
- Ensure the settings UI is cleaner with the new expandable layout.