# Widget Theme Testing Guide

## What's Been Added:

### Extensive Debug Logging

**Flutter Side:**
```
SettingsCubit: Updating widget theme mode to: light
SettingsCubit: Theme mode saved to repo, triggering widget update
WidgetUpdateService: Widget theme mode: light
WidgetUpdateService: Primary color: #2E7D32, Background: #0D1117
SettingsCubit: Widget update triggered for theme: light
```

**Android Native Side:**
```
MainActivity: === SETTINGS CHANGED VIA METHOD CHANNEL ===
MainActivity: Settings payload: {prayer_data: {...}, ...}
MainActivity: Prayer data present: true
MainActivity: Updating PrayerWidget...
MainActivity: Updating NextPrayerCountdownWidget...
MainActivity: All widget updates completed
WidgetDebug: WidgetThemeMode: light, BackgroundHex: #F5F5F5
```

## How to Test:

### Step 1: Build and Install
```bash
flutter run
```

### Step 2: Open LogCat to Watch All Logs
```bash
adb logcat | findstr "SettingsCubit\|WidgetUpdateService\|MainActivity\|WidgetDebug"
```

Or on PowerShell:
```powershell
adb logcat | Select-String "SettingsCubit|WidgetUpdateService|MainActivity|WidgetDebug"
```

### Step 3: Add Widget to Home Screen
1. Long press on home screen
2. Select "Widgets"
3. Find "Fard" widgets
4. Add "Prayer Widget" to home screen

### Step 4: Change Widget Theme
1. Open app
2. Go to Settings → Appearance
3. Find "Widget Theme Mode" dropdown
4. Change from "Dark" to "Light"
5. **Watch the logs!**

### Expected Log Flow:

```
SettingsCubit: Updating widget theme mode to: light
SettingsCubit: Theme mode saved to repo, triggering widget update
WidgetUpdateService: Widget theme mode: light
WidgetUpdateService: Primary color: #2E7D32, Background: #0D1117
WidgetUpdateService: Saving data for widget: 14 April 2026
WidgetUpdateService: Saved to SharedPreferences with key: prayer_data
WidgetUpdateService: Settings synced to native
WidgetUpdateService: Update complete!
SettingsCubit: Widget update triggered for theme: light
MainActivity: === SETTINGS CHANGED VIA METHOD CHANNEL ===
MainActivity: Settings payload: {calculation_method: 0, latitude: 24.0, ...}
MainActivity: Prayer data present: true
MainActivity: Settings saved to SharedPreferences
MainActivity: Updating PrayerWidget...
MainActivity: Updating NextPrayerCountdownWidget...
MainActivity: All widget updates completed
WidgetDebug: WidgetThemeMode: light, BackgroundHex: #F5F5F5
```

## Troubleshooting:

### If you DON'T see "SETTINGS CHANGED VIA METHOD CHANNEL":
**Problem:** Flutter is not triggering the native sync
**Solution:** Check if `_syncNative` is being called in `WidgetUpdateService`

### If you DON'T see "WidgetThemeMode: light":
**Problem:** Native widget is reading old data
**Solution:** The SharedPreferences might not have committed yet - the 100ms delay should handle this

### If you see logs but widget doesn't change visually:
**Problem:** Widget rendering issue
**Solution:** 
1. Try removing and re-adding the widget
2. Check if `backgroundColor` variable is being used in the widget (line 144 in PrayerWidget.kt)

### If dropdown doesn't change at all:
**Problem:** UI issue, not a widget issue
**Solution:** Check if `updateWidgetThemeMode` is being called from the dropdown's `onChanged`

## Quick Test Commands:

### View only widget theme logs:
```bash
adb logcat | findstr "WidgetThemeMode"
```

### View only Flutter widget update logs:
```bash
adb logcat | findstr "WidgetUpdateService"
```

### View only native widget update logs:
```bash
adb logcat | findstr "MainActivity" | findstr "Widget"
```

### Clear logcat and start fresh:
```bash
adb logcat -c
adb logcat | findstr "SettingsCubit|WidgetUpdateService|MainActivity|WidgetDebug"
```

## What Each Theme Should Show:

### Dark Theme:
```
WidgetThemeMode: dark
BackgroundHex: #0D1117 (very dark)
WidgetDebug: WidgetThemeMode: dark, BackgroundHex: #0D1117
```

### Light Theme:
```
WidgetThemeMode: light  
BackgroundHex: #F5F5F5 (very light)
WidgetDebug: WidgetThemeMode: light, BackgroundHex: #F5F5F5
```

### Follow App Theme:
```
WidgetThemeMode: follow_app
BackgroundHex: #0D1117 or custom color from theme
WidgetDebug: WidgetThemeMode: follow_app, BackgroundHex: #0D1117
```

## Common Issues:

### 1. Widget Shows Same Colors After Theme Change
**Cause:** Widget hasn't refreshed yet
**Fix:** 
- Wait 1-5 minutes for automatic refresh
- Or use Debug section → "Refresh Widget" button
- Or remove and re-add widget

### 2. Logs Show "dark" When You Selected "light"
**Cause:** State not updating properly
**Fix:** Check if `state.widgetThemeMode` in the UI is actually updating

### 3. Native Side Shows Different Theme Than Flutter Side
**Cause:** Data not being saved/loaded correctly
**Fix:** Check SharedPreferences directly in Android Studio Device File Explorer

## Success Indicators:

✅ You see all the log messages in the correct order
✅ The `WidgetThemeMode` in logs matches what you selected
✅ The `BackgroundHex` changes appropriately:
   - Dark: `#0D1117`
   - Light: `#F5F5F5`
   - Follow App: Your theme's background color
✅ The widget visually changes to match the theme

## If Everything Fails:

As a last resort, you can manually verify the data is being saved:

1. Open Android Studio
2. Go to Device File Explorer
3. Navigate to: `/data/data/com.nagar.fard/shared_prefs/`
4. Open `FlutterSharedPreferences.xml`
5. Look for: `flutter.widget_theme_mode`
6. It should show the value you selected (dark/light/follow_app)
