# Widget Theme Debugging Guide

## What's Been Added:

### 1. Debug Logging (Flutter Side)
When the widget updates, you'll now see these logs:
```
WidgetUpdateService: Widget theme mode: dark/light/follow_app
WidgetUpdateService: Primary color: #2E7D32, Background: #0D1117
```

### 2. Debug Logging (Android Native Side)
When the widget renders, you'll see in LogCat:
```
WidgetDebug: WidgetThemeMode: dark, BackgroundHex: #0D1117
WidgetDebug: CountdownWidget - ThemeMode: dark, BackgroundHex: #0D1117
```

## How to Test:

### Step 1: Build and Run
```bash
flutter run
```

### Step 2: View Logs
Open a terminal and run:
```bash
adb logcat | findstr "WidgetDebug"
```

This will show only widget-related logs.

### Step 3: Change Widget Theme
1. Go to Settings → Appearance
2. Change "Widget Theme" dropdown
3. Observe the logs

### Step 4: Force Refresh Widget
1. Scroll to Debug section in Settings
2. Tap "Refresh Widget" button
3. Check logs to see:
   - Flutter logs the theme mode being saved
   - Native logs the theme mode being read

## Expected Behavior:

### When Widget Theme = "dark":
- Background: `#0D1117` (dark black)
- Text: `#F0F6FC` (light gray)
- Accent: `#FFD54F` (gold)

### When Widget Theme = "light":
- Background: `#F5F5F5` (light gray/white)
- Text: `#1A1A1A` (dark black)
- Accent: `#FFA000` (orange/gold)

### When Widget Theme = "follow_app":
- Uses whatever theme colors are set in the app
- Emerald theme: Green primary, dark background
- Midnight theme: Blue tones
- Custom theme: Your custom colors

## Troubleshooting:

### If theme doesn't change:
1. Check Flutter logs - does it show the correct theme mode?
2. Check Native logs - does it read the correct theme mode?
3. Try force-refreshing the widget manually

### If widget shows wrong colors:
1. Check if `backgroundColorHex` is being passed correctly
2. Verify the widget is reading from SharedPreferences
3. Re-add the widget to home screen (sometimes widgets cache old data)

### Common Issues:
- **Widget not updating**: App might need to be in foreground for widget refresh
- **Old theme showing**: Widget might be caching - remove and re-add widget
- **Colors look wrong**: Check if `follow_app` mode has valid hex colors in JSON

## How It Works:

```
User changes theme in Settings
    ↓
SettingsCubit.updateWidgetThemeMode('dark'|'light'|'follow_app')
    ↓
WidgetUpdateService.updateWidget() called
    ↓
Extracts theme colors from current theme
    ↓
Creates WidgetDataModel with:
  - widgetThemeMode
  - primaryColorHex
  - backgroundColorHex
  - accentColorHex
  - surfaceColorHex
    ↓
Saves to SharedPreferences as JSON
    ↓
Native widget reads JSON from SharedPreferences
    ↓
PrayerWidgetRoot() applies colors based on widgetThemeMode
    ↓
Widget displays with new theme!
```

## Code Locations:

- **Flutter widget update**: `lib/core/services/widget_update_service.dart`
- **Native widget**: `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`
- **Native countdown widget**: `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidget.kt`
- **Settings cubit**: `lib/features/settings/presentation/blocs/settings_cubit.dart`
