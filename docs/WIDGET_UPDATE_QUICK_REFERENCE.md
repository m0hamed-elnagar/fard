# Widget Update Quick Reference

**Last Updated:** March 31, 2026

---

## 🚀 Quick Start: How to Update Widget

```dart
// From anywhere in the app:
await getIt<WidgetUpdateService>().updateWidget(
  getIt<SettingsCubit>().state
);
```

---

## 📊 Update Triggers Cheat Sheet

| # | Trigger | How It Works | Latency | App Closed? |
|---|---------|--------------|---------|-------------|
| 1 | ⏰ Time Changed | Android Broadcast | Instant | ✅ Works |
| 2 | 🌍 Timezone Changed | Android Broadcast | Instant | ✅ Works |
| 3 | 📅 Date Changed | Android Broadcast | Instant | ✅ Works |
| 4 | 🗣️ Language Changed | Settings Cubit | < 500ms | ❌ No |
| 5 | 📍 Location Changed | Settings Cubit | < 500ms | ❌ No |
| 6 | ⚙️ Calc Method | Settings Cubit | < 500ms | ❌ No |
| 7 | 🕌 Madhab Changed | Settings Cubit | < 500ms | ❌ No |
| 8 | 📱 App Resumed | Lifecycle Observer | < 500ms | ❌ No |
| 9 | 🖱️ Debug Button | Manual Trigger | Instant | ❌ No |
| 10 | 🔄 Background (12h) | WorkManager | 12 hours | ✅ Works |
| 11 | 🔄 Background (15m) | WorkManager | 15 minutes | ✅ Works |

---

## 🗂️ Files Reference

### Flutter (Dart)

| File | Purpose | Key Function |
|------|---------|--------------|
| `lib/core/services/widget_update_service.dart` | Main update logic | `updateWidget()` |
| `lib/core/models/widget_data_model.dart` | Data structure | `WidgetDataModel` |
| `lib/features/prayer_tracking/presentation/widgets/home_content.dart` | Settings trigger | `BlocBuilder.buildWhen` |
| `lib/features/prayer_tracking/presentation/screens/home_screen.dart` | App resume trigger | `didChangeAppLifecycleState()` |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Debug button | `"Refresh Widget"` |
| `lib/core/services/background_service.dart` | Background updates | `callbackDispatcher()` |

### Android (Kotlin)

| File | Purpose | Key Function |
|------|---------|--------------|
| `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt` | Widget UI | `provideGlance()` |
| `android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt` | Widget receiver | `onReceive()` |
| `android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt` | Time change listener | `onReceive()` |
| `android/app/src/main/AndroidManifest.xml` | Receiver registration | `<receiver>` |

---

## 🔍 Debugging Commands

### Check if Widget Data Exists
```bash
adb shell "run-as com.qada.fard cat shared_prefs/HomeWidgetPreferences.xml"
```

### Watch Widget Updates
```bash
adb logcat | grep -E "WidgetUpdateService|PrayerWidget|TimeChangedReceiver"
```

### Check Receiver Registration
```bash
adb shell dumpsys package com.qada.fard | grep -A 5 "TimeChangedReceiver"
```

### Force Widget Update (ADB)
```bash
adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE \
  -n com.qada.fard/.PrayerWidgetReceiver \
  --ei android.appwidget.extra_APPWIDGET_ID 1
```

---

## 🎯 Common Scenarios

### Scenario 1: User Changes Language
```
User Action: Settings → Language → Arabic
↓
SettingsCubit emits new state with locale='ar'
↓
HomeContent BlocBuilder detects change (buildWhen)
↓
WidgetUpdateService.updateWidget() called
↓
SharedPreferences updated with Arabic data
↓
Widget re-renders with RTL layout
✅ Widget shows Arabic text
```

### Scenario 2: User Changes Phone Time
```
User Action: Settings → Date & Time → Manual → 3:00 PM
↓
Android sends ACTION_TIME_SET broadcast
↓
TimeChangedReceiver.onReceive() triggered
↓
PrayerWidget.updateAll() called
↓
Widget reads updated prayer times from SharedPreferences
✅ Widget shows new prayer times (instant, even if app closed)
```

### Scenario 3: User Returns to App
```
User Action: Tap app icon from home screen
↓
AppLifecycleState.resumed triggered
↓
HomeScreen.didChangeAppLifecycleState() called
↓
WidgetUpdateService.updateWidget() called
✅ Widget refreshed with latest data
```

### Scenario 4: Background Auto-Update
```
System: Every 15 minutes (WorkManager)
↓
BackgroundService.callbackDispatcher() runs
↓
Load settings from SharedPreferences
↓
Calculate new prayer times
↓
Update widget data
✅ Widget stays fresh even if app not opened
```

---

## 🧪 Test Checklist

Quick test for each trigger:

- [ ] **Time Change**: Change phone time → Widget updates instantly
- [ ] **Timezone**: Change timezone → Widget updates instantly
- [ ] **Language**: Switch EN↔AR → Widget updates, RTL works
- [ ] **Location**: Change location → New city, new times
- [ ] **App Resume**: Minimize → Reopen → Widget updates
- [ ] **Debug Button**: Settings → Refresh → Snackbar + update
- [ ] **Background**: Leave app closed 15 min → Widget updates

---

## 📦 Data Model

```dart
WidgetDataModel {
  gregorianDate: "31 March 2026"
  hijriDate: "٢ رمضان ١٤٤٧"
  dayOfWeek: "Tuesday"
  sunrise: "6:30 AM"
  isRtl: true/false
  prayers: [
    { name: "Fajr", time: "5:30 AM", minutesFromMidnight: 330 },
    { name: "Dhuhr", time: "12:30 PM", minutesFromMidnight: 750 },
    { name: "Asr", time: "3:45 PM", minutesFromMidnight: 945 },
    { name: "Maghrib", time: "6:15 PM", minutesFromMidnight: 1095 },
    { name: "Isha", time: "7:45 PM", minutesFromMidnight: 1185 }
  ]
}
```

---

## ⚠️ Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Widget shows "Open App" | No data in SharedPreferences | Call `updateWidget()` once |
| Widget not updating on time change | Receiver not registered | Check AndroidManifest.xml |
| Widget shows old times | Background service failed | Check WorkManager logs |
| Widget crashes | Null pointer in Kotlin | Add null checks |
| RTL not working | `isRtl` flag not set | Check locale in `updateWidget()` |

---

## 🔑 Key Code Patterns

### Update Widget on Settings Change
```dart
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (prev, curr) => 
      prev.locale != curr.locale ||
      prev.latitude != curr.latitude,
  builder: (context, settings) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<WidgetUpdateService>().updateWidget(settings);
    });
    return Scaffold(...);
  },
)
```

### Update Widget on App Resume
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<WidgetUpdateService>().updateWidget(
        context.read<SettingsCubit>().state
      );
    });
  }
}
```

### Native Android Time Change Receiver
```kotlin
class TimeChangedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        MainScope().launch {
            PrayerWidget().updateAll(context)
        }
    }
}
```

---

## 📞 Quick Troubleshooting

**Widget not updating?**
1. Check logs: `adb logcat | grep WidgetUpdateService`
2. Verify data: Check SharedPreferences for `prayer_data`
3. Test manually: Use debug button in Settings

**Widget crashes?**
1. Check Kotlin logs: `adb logcat | grep PrayerWidget`
2. Look for null pointer exceptions
3. Verify JSON structure matches data model

**Widget shows wrong times?**
1. Check location permissions
2. Verify calculation method in settings
3. Check timezone offset

---

## 📚 Full Documentation

For complete details, see:
- [`WIDGET_UPDATE_COMPLETE_GUIDE.md`](./WIDGET_UPDATE_COMPLETE_GUIDE.md) - Full guide
- [`HOME_WIDGET_IMPROVEMENT_PLAN.md`](./HOME_WIDGET_IMPROVEMENT_PLAN.md) - Implementation plan

---

**Quick Reference Card - Print This!** 📄
