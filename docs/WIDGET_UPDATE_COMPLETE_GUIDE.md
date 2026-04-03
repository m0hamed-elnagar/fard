# Widget Update Complete Guide

**Created:** March 31, 2026  
**Last Updated:** March 31, 2026  
**Status:** Implemented ✅  
**Platform:** Android (Glance AppWidget) + Flutter (home_widget package)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Widget Update Flow](#widget-update-flow)
4. [Update Triggers](#update-triggers)
5. [Implementation Details](#implementation-details)
6. [Data Flow Diagram](#data-flow-diagram)
7. [Code Reference](#code-reference)
8. [Testing Guide](#testing-guide)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

---

## 📖 Overview

### What is the Prayer Widget?

The Fard app includes a **home screen widget** that displays:
- Current Gregorian & Hijri dates
- Day of the week
- All 5 prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha)
- Sunrise time
- Next prayer indicator (highlighted row)
- Location/city name
- RTL/LTR layout based on language

### Technology Stack

| Component | Technology |
|-----------|-----------|
| **Flutter Package** | `home_widget: ^0.9.0` |
| **Android Widget** | Glance AppWidget (Jetpack Glance) |
| **UI Framework** | Jetpack Compose for Widgets |
| **Language** | Kotlin (Android) + Dart (Flutter) |
| **Data Storage** | SharedPreferences (cross-platform) |

---

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FARD APP                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐    ┌──────────────────┐    ┌────────────┐ │
│  │    Flutter     │    │    Android       │    │   Widget   │ │
│  │    (Dart)      │◄──►│    (Kotlin)      │◄──►│   Data     │ │
│  │                │    │                  │    │   Model    │ │
│  │  - Settings    │    │  - Widget        │    │            │ │
│  │  - Prayer Times│    │    Receiver      │    │  - JSON    │ │
│  │  - Locale      │    │  - Glance        │    │  - Shared  │ │
│  │  - Location    │    │    Compose       │    │   Prefs     │ │
│  └────────────────┘    └──────────────────┘    └────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### File Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── widget_update_service.dart      # Main widget update logic
│   │   └── prayer_time_service.dart        # Prayer time calculations
│   └── models/
│       └── widget_data_model.dart          # Widget data structure
│
android/
└── app/
    └── src/
        └── main/
            └── kotlin/
                └── com/
                    └── qada/
                        └── fard/
                            ├── PrayerWidget.kt           # Widget UI (Glance)
                            ├── PrayerWidgetReceiver.kt   # Widget broadcast receiver
                            └── TimeChangedReceiver.kt    # Time change listener
```

---

## 🔄 Widget Update Flow

### Complete Update Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                         WIDGET UPDATE TRIGGER                        │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌────────────────┐   ┌─────────────────┐
│  Time Change  │   │  Settings      │   │  App Resume     │
│  (Android     │   │  Change        │   │  (User opens    │
│  Broadcast)   │   │  (In-App)      │   │   app)          │
└───────┬───────┘   └───────┬────────┘   └────────┬────────┘
        │                   │                      │
        │                   ▼                      │
        │          ┌────────────────┐             │
        │          │ SettingsCubit  │             │
        │          │ emits new state│             │
        │          └───────┬────────┘             │
        │                   │                      │
        │                   ▼                      │
        │          ┌────────────────┐             │
        │          │ HomeContent    │             │
        │          │ buildWhen      │             │
        │          │ detects change │             │
        │          └───────┬────────┘             │
        │                   │                      │
        └───────────────────┼──────────────────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ WidgetUpdateService │
                 │ .updateWidget()     │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 1. Get Settings     │
                 │    - locale         │
                 │    - latitude       │
                 │    - longitude      │
                 │    - calc method    │
                 │    - madhab         │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 2. Calculate Prayer │
                 │    Times for date   │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 3. Format Data      │
                 │    - Gregorian date │
                 │    - Hijri date     │
                 │    - Prayer times   │
                 │    - Localization   │
                 │    - RTL/LTR flag   │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 4. Save to SharedPreferences │
                 │    Key: 'prayer_data'       │
                 │    Value: JSON string       │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 5. Call HomeWidget  │
                 │    .updateWidget()  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Android:            │
                 │ PrayerWidgetReceiver│
                 │ .onReceive()        │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Glance:             │
                 │ PrayerWidget        │
                 │ .provideGlance()    │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 6. Read SharedPreferences │
                 │    Parse JSON data        │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ 7. Render Widget UI │
                 │    - Compose UI     │
                 │    - Highlight next │
                 │    - Apply RTL/LTR  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ ✅ Widget Updated!  │
                 └─────────────────────┘
```

---

## 🎯 Update Triggers

### Complete List of Widget Update Triggers

| # | Trigger | Type | Source | Latency | Works When App Closed |
|---|---------|------|--------|---------|----------------------|
| 1 | **Time Changed** | Native Android Broadcast | `TimeChangedReceiver.kt` | Instant ✅ | ✅ Yes |
| 2 | **Timezone Changed** | Native Android Broadcast | `TimeChangedReceiver.kt` | Instant ✅ | ✅ Yes |
| 3 | **Date Changed** | Native Android Broadcast | `TimeChangedReceiver.kt` | Instant ✅ | ✅ Yes |
| 4 | **Language Changed** | Flutter Settings Change | `home_content.dart` | < 1 second ✅ | ❌ No |
| 5 | **Location Changed** | Flutter Settings Change | `home_content.dart` | < 1 second ✅ | ❌ No |
| 6 | **Calc Method Changed** | Flutter Settings Change | `home_content.dart` | < 1 second ✅ | ❌ No |
| 7 | **Madhab Changed** | Flutter Settings Change | `home_content.dart` | < 1 second ✅ | ❌ No |
| 8 | **App Resume** | Flutter Lifecycle | `home_screen.dart` | < 1 second ✅ | ❌ No |
| 9 | **Manual Refresh** | User Action | Debug button | Instant ✅ | ❌ No |
| 10 | **Background Service** | WorkManager | `background_service.dart` | Every 12 hours | ✅ Yes |
| 11 | **Widget Fallback** | WorkManager | `background_service.dart` | Every 15 minutes | ✅ Yes |

---

### Trigger Details

#### 1. Time Changed (Native Android)

**File:** `android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt`

```kotlin
class TimeChangedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_TIME_CHANGED -> {
                Log.i(TAG, "System time changed by user")
            }
            Intent.ACTION_TIMEZONE_CHANGED -> {
                val timeZoneId = intent.getStringExtra("time-zone")
                Log.i(TAG, "System timezone changed to: $timeZoneId")
            }
            Intent.ACTION_DATE_CHANGED -> {
                Log.i(TAG, "System date changed by user")
            }
        }
        
        // Update widget immediately
        MainScope().launch {
            PrayerWidget().updateAll(context)
        }
    }
}
```

**Manifest Registration:**
```xml
<receiver android:name=".TimeChangedReceiver" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.TIME_SET" />
        <action android:name="android.intent.action.TIMEZONE_CHANGED" />
        <action android:name="android.intent.action.DATE_CHANGED" />
    </intent-filter>
</receiver>
```

---

#### 2. Settings Change (Flutter)

**File:** `lib/features/prayer_tracking/presentation/widgets/home_content.dart`

```dart
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (previous, current) =>
      previous.locale != current.locale ||          // Language
      previous.latitude != current.latitude ||      // Location
      previous.longitude != current.longitude ||    // Location
      previous.calculationMethod != current.calculationMethod || // Calc method
      previous.madhab != current.madhab ||          // Madhab
      previous.cityName != current.cityName ||      // City name
      previous.isQadaEnabled != current.isQadaEnabled || // Qada
      previous.hijriAdjustment != current.hijriAdjustment, // Hijri offset
  builder: (context, settings) {
    // Calculate prayer times
    final prayerTimes = getIt<PrayerTimeService>().getPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      date: widget.selectedDate,
    );

    // Update widget after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<WidgetUpdateService>().updateWidget(settings);
    });

    return Scaffold(...);
  },
)
```

---

#### 3. App Resume (Flutter)

**File:** `lib/features/prayer_tracking/presentation/screens/home_screen.dart`

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Refresh prayer data
    final bloc = context.read<PrayerTrackerBloc>();
    bloc.state.mapOrNull(
      loaded: (s) {
        bloc.add(PrayerTrackerEvent.load(s.selectedDate));
      },
    );

    // Refresh widget with latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsCubit>().state;
      getIt<WidgetUpdateService>().updateWidget(settings);
    });
  }
}
```

---

#### 4. Manual Refresh (Debug)

**File:** `lib/features/settings/presentation/screens/settings_screen.dart`

```dart
ListTile(
  title: const Text('Refresh Widget'),
  trailing: ElevatedButton.icon(
    onPressed: () {
      HapticFeedback.mediumImpact();
      getIt<WidgetUpdateService>().updateWidget(
        context.read<SettingsCubit>().state,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget refresh triggered!'),
          backgroundColor: AppTheme.primaryLight,
          duration: Duration(seconds: 2),
        ),
      );
    },
    icon: const Icon(Icons.refresh, size: 18),
    label: const Text('Refresh'),
  ),
)
```

---

#### 5. Background Service (WorkManager)

**File:** `lib/core/services/background_service.dart`

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Load settings
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsLoader.loadSettings(prefs);

    // Update widget
    final widgetUpdateService = WidgetUpdateService(prayerTimeService);
    await widgetUpdateService.updateWidget(settings);

    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    // Main task: Every 12 hours
    await Workmanager().registerPeriodicTask(
      'com.nagar.fard.prayer_scheduler_task',
      'prayer_scheduler_task',
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // Fallback: Every 15 minutes
    await Workmanager().registerPeriodicTask(
      'com.nagar.fard.widget_refresh_task',
      'widget_refresh_task',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }
}
```

---

## 💻 Implementation Details

### WidgetUpdateService (Flutter)

**File:** `lib/core/services/widget_update_service.dart`

```dart
@singleton
class WidgetUpdateService {
  final PrayerTimeService _prayerTimeService;

  WidgetUpdateService(this._prayerTimeService);

  Future<void> updateWidget(SettingsState settings) async {
    if (settings.latitude == null || settings.longitude == null) return;

    final now = DateTime.now();
    
    // 1. Calculate prayer times
    final prayerTimes = _prayerTimeService.getPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      date: now,
    );

    // 2. Calculate Hijri date with adjustment
    final hijriDate = HijriCalendar.fromDate(
      now.add(Duration(days: settings.hijriAdjustment)),
    );

    // 3. Format data with localization
    final lang = settings.locale.languageCode;
    final sunrise = DateFormat.jm(lang).format(prayerTimes.sunrise);
    final dayOfWeek = DateFormat('EEEE', lang).format(now);
    final isRtl = lang == 'ar';

    final data = WidgetDataModel(
      gregorianDate: DateFormat('d MMMM yyyy', lang).format(now),
      hijriDate: hijriDate.toVisualString(lang),
      dayOfWeek: dayOfWeek,
      sunrise: sunrise,
      isRtl: isRtl,
      prayers: [
        _createItem('fajr', prayerTimes.fajr, lang),
        _createItem('dhuhr', prayerTimes.dhuhr, lang),
        _createItem('asr', prayerTimes.asr, lang),
        _createItem('maghrib', prayerTimes.maghrib, lang),
        _createItem('isha', prayerTimes.isha, lang),
      ],
    );

    debugPrint('WidgetUpdateService: Saving data for widget: ${data.gregorianDate}');
    
    // 4. Save to SharedPreferences
    await HomeWidget.saveWidgetData('prayer_data', jsonEncode(data.toJson()));
    
    // 5. Trigger widget update
    final result = await HomeWidget.updateWidget(
      name: 'PrayerWidgetReceiver',
      androidName: 'com.qada.fard.PrayerWidgetReceiver',
    );
    
    debugPrint('WidgetUpdateService: Update result: $result');
  }

  PrayerTimeItem _createItem(String id, DateTime time, String lang) {
    return PrayerTimeItem(
      name: _getPrayerName(id, lang),
      time: DateFormat.jm(lang).format(time),
      minutesFromMidnight: time.hour * 60 + time.minute,
    );
  }

  String _getPrayerName(String id, String lang) {
    if (lang == 'ar') {
      switch (id) {
        case 'fajr': return 'الفجر';
        case 'dhuhr': return 'الظهر';
        case 'asr': return 'العصر';
        case 'maghrib': return 'المغرب';
        case 'isha': return 'العشاء';
        default: return id;
      }
    } else {
      switch (id) {
        case 'fajr': return 'Fajr';
        case 'dhuhr': return 'Dhuhr';
        case 'asr': return 'Asr';
        case 'maghrib': return 'Maghrib';
        case 'isha': return 'Isha';
        default: return id;
      }
    }
  }
}
```

---

### WidgetDataModel

**File:** `lib/core/models/widget_data_model.dart`

```dart
@JsonSerializable(explicitToJson: true)
class WidgetDataModel {
  final String gregorianDate;      // e.g. "31 March 2026"
  final String hijriDate;          // e.g. "٢ رمضان ١٤٤٧"
  final String dayOfWeek;          // e.g. "Tuesday" / "الثلاثاء"
  final String sunrise;            // e.g. "6:30 AM"
  final bool isRtl;                // true for Arabic, false for English
  final List<PrayerTimeItem> prayers;

  WidgetDataModel({
    required this.gregorianDate,
    required this.hijriDate,
    required this.dayOfWeek,
    required this.sunrise,
    required this.isRtl,
    required this.prayers,
  });

  factory WidgetDataModel.fromJson(Map<String, dynamic> json) => 
      _$WidgetDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$WidgetDataModelToJson(this);
}

@JsonSerializable()
class PrayerTimeItem {
  final String name;               // e.g. "Fajr" / "الفجر"
  final String time;               // e.g. "5:30 AM"
  final int minutesFromMidnight;   // e.g. 330 (for 5:30 AM)

  PrayerTimeItem({
    required this.name,
    required this.time,
    required this.minutesFromMidnight,
  });

  factory PrayerTimeItem.fromJson(Map<String, dynamic> json) => 
      _$PrayerTimeItemFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerTimeItemToJson(this);
}
```

---

### PrayerWidget (Android Glance)

**File:** `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`

```kotlin
class PrayerWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        // Read data from SharedPreferences
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", 
            Context.MODE_PRIVATE
        )
        val dataStr = prefs.getString("prayer_data", null)

        val data = if (dataStr != null) {
            try {
                JSONObject(dataStr)
            } catch (e: Exception) {
                null
            }
        } else null

        provideContent {
            val size = LocalSize.current
            PrayerWidgetRoot(data, size)
        }
    }

    @Composable
    private fun PrayerWidgetRoot(data: JSONObject?, size: DpSize) {
        val isRtl = data?.optBoolean("isRtl") ?: false
        
        // Render widget UI based on data
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ImageProvider(R.drawable.widget_background))
                .clickable(actionStartActivity<MainActivity>())
                .padding(horizontal = 16.dp, vertical = 14.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (data == null) {
                Text("Open App to Initialize")
                return@Column
            }

            // Render based on size (tiny, compact, full)
            if (size.height < 110.dp) {
                TinyLayout(data, size, isRtl)
            } else {
                FullLayout(data, size, isRtl)
            }
        }
    }

    private fun getNextPrayerIndex(data: JSONObject?): Int {
        if (data == null) return -1
        val prayersArray = data.optJSONArray("prayers") ?: return -1
        val calendar = Calendar.getInstance()
        val currentMinutes = calendar.get(Calendar.HOUR_OF_DAY) * 60 + 
                            calendar.get(Calendar.MINUTE)
        
        for (i in 0 until prayersArray.length()) {
            val p = prayersArray.getJSONObject(i)
            if (p.optInt("minutesFromMidnight") > currentMinutes) {
                return i
            }
        }
        return -1
    }
}
```

---

## 📊 Data Flow Diagram

### Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW OVERVIEW                           │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   Settings   │
│   Cubit      │
│              │
│ - locale     │
│ - latitude   │
│ - longitude  │
│ - method     │
│ - madhab     │
└──────┬───────┘
       │
       │ (1) Settings State
       ▼
┌──────────────────┐
│ WidgetUpdate     │
│ Service          │
│                  │
│ updateWidget()   │
└──────┬───────────┘
       │
       │ (2) Get Settings
       ▼
┌──────────────────┐
│ PrayerTime       │
│ Service          │
│                  │
│ getPrayerTimes() │
└──────┬───────────┘
       │
       │ (3) Prayer Times
       ▼
┌──────────────────┐
│ WidgetDataModel  │
│                  │
│ - gregorianDate  │
│ - hijriDate      │
│ - prayers[]      │
│ - isRtl          │
└──────┬───────────┘
       │
       │ (4) JSON Serialize
       ▼
┌──────────────────┐
│ SharedPreferences│
│                  │
│ Key: prayer_data │
│ Value: JSON      │
└──────┬───────────┘
       │
       │ (5) Update Broadcast
       ▼
┌──────────────────┐
│ PrayerWidget     │
│ Receiver         │
│                  │
│ onReceive()      │
└──────┬───────────┘
       │
       │ (6) Update All
       ▼
┌──────────────────┐
│ PrayerWidget     │
│ (Glance)         │
│                  │
│ provideGlance()  │
└──────┬───────────┘
       │
       │ (7) Read SharedPreferences
       ▼
┌──────────────────┐
│ SharedPreferences│
│                  │
│ Parse JSON       │
└──────┬───────────┘
       │
       │ (8) Widget Data
       ▼
┌──────────────────┐
│ Widget UI        │
│ (Compose)        │
│                  │
│ - Dates          │
│ - Prayer times   │
│ - Highlight next │
│ - RTL/LTR        │
└──────────────────┘
```

---

## 📎 Code Reference

### Key Files

| File | Purpose | Lines of Code |
|------|---------|---------------|
| `lib/core/services/widget_update_service.dart` | Main widget update logic | ~90 |
| `lib/core/models/widget_data_model.dart` | Data structure | ~40 |
| `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt` | Widget UI | ~250 |
| `android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt` | Widget receiver | ~20 |
| `android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt` | Time change listener | ~50 |
| `lib/features/prayer_tracking/presentation/widgets/home_content.dart` | Settings trigger | ~330 |
| `lib/features/prayer_tracking/presentation/screens/home_screen.dart` | App resume trigger | ~150 |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Debug button | ~2000 |
| `lib/core/services/background_service.dart` | Background updates | ~120 |

---

### Important Code Snippets

#### How to Trigger Widget Update from Anywhere

```dart
// Get the service
final widgetService = getIt<WidgetUpdateService>();

// Get current settings
final settings = getIt<SettingsCubit>().state;

// Update widget
await widgetService.updateWidget(settings);
```

#### How to Check if Widget Update Succeeded

```dart
final result = await HomeWidget.updateWidget(
  name: 'PrayerWidgetReceiver',
  androidName: 'com.qada.fard.PrayerWidgetReceiver',
);

debugPrint('Update result: $result');
// true = success, false = failed
```

#### How to Read Widget Data (for debugging)

```dart
final prefs = await SharedPreferences.getInstance();
final dataStr = prefs.getString('prayer_data');

if (dataStr != null) {
  final data = jsonDecode(dataStr);
  debugPrint('Widget data: $data');
}
```

---

## 🧪 Testing Guide

### Test 1: Time Change

```bash
# 1. Add widget to home screen
# 2. Note current prayer times
# 3. Close app completely
# 4. Change phone time: Settings → Date & Time → Manual → Set +1 hour
# 5. Check widget immediately
# ✅ Expected: Widget shows updated prayer times
```

### Test 2: Timezone Change

```bash
# 1. Add widget to home screen
# 2. Note current timezone
# 3. Close app completely
# 4. Change timezone: Settings → Date & Time → Select different timezone
# 5. Check widget immediately
# ✅ Expected: Widget shows prayer times for new timezone
```

### Test 3: Language Change

```bash
# 1. Open app → Settings → Language
# 2. Switch from English to Arabic
# 3. Check widget
# ✅ Expected: Widget shows Arabic text, RTL layout
```

### Test 4: Location Change

```bash
# 1. Open app → Settings → Location → Refresh
# 2. Allow new location (or mock location)
# 3. Check widget
# ✅ Expected: Widget shows new city name and prayer times
```

### Test 5: App Resume

```bash
# 1. Open app, let it load
# 2. Minimize app (home button)
# 3. Wait 1 minute
# 4. Reopen app
# 5. Check widget
# ✅ Expected: Widget updated with latest prayer times
```

### Test 6: Debug Button

```bash
# 1. Open app → Settings → Scroll to "Debug: Widget"
# 2. Tap "Refresh"
# 3. Check for snackbar message
# 4. Check widget
# ✅ Expected: Snackbar says "Widget refresh triggered!", widget updates
```

---

## 🔧 Troubleshooting

### Widget Not Updating?

**Check 1: Is widget initialized?**
```dart
// Look for this in logcat:
adb logcat | grep WidgetUpdateService
# Should see: "Saving data for widget: [date]"
```

**Check 2: Is receiver registered?**
```bash
adb shell dumpsys package com.qada.fard | grep -A 5 "TimeChangedReceiver"
```

**Check 3: Are permissions granted?**
```bash
adb shell dumpsys package com.qada.fard | grep "granted=true" | grep -E "RECEIVE_BOOT_COMPLETED|POST_NOTIFICATIONS"
```

**Check 4: Is SharedPreferences working?**
```dart
// In Flutter debug console:
final prefs = await SharedPreferences.getInstance();
final data = prefs.getString('prayer_data');
print('Widget data: $data');
```

### Widget Shows "Open App"?

This means SharedPreferences is empty. Trigger an update:
```dart
getIt<WidgetUpdateService>().updateWidget(
  getIt<SettingsCubit>().state
);
```

### Widget Shows Old Data?

Force refresh:
1. Open app → Settings → Debug: Widget → Refresh
2. Or change any setting (language, location, etc.)

### Widget Crashes on Update?

Check Android logs:
```bash
adb logcat | grep -E "PrayerWidget|TimeChangedReceiver|FATAL"
```

Common issues:
- Missing null checks in Kotlin
- JSON parsing errors
- Glance size constraints

---

## ✅ Best Practices

### DO ✅

1. **Always update widget on settings change**
   - Language, location, calculation method, madhab

2. **Use native Android broadcasts for system events**
   - Time change, timezone change, date change

3. **Update widget when app resumes**
   - Ensures fresh data after background time

4. **Cache prayer times**
   - Don't recalculate on every build

5. **Handle null/missing data gracefully**
   - Show "Open App" instead of crashing

6. **Log widget updates**
   - Helps with debugging

7. **Test on multiple widget sizes**
   - Tiny (1x1), Compact (2x2), Full (4x2)

### DON'T ❌

1. **Don't update widget every second**
   - Battery drain, system may throttle

2. **Don't rely only on Flutter timers**
   - Doesn't work when app closed

3. **Don't update widget without checking location**
   - Will crash if latitude/longitude is null

4. **Don't forget to dispose listeners**
   - Memory leaks

5. **Don't update widget on every state change**
   - Use `buildWhen` to filter

6. **Don't ignore RTL/LTR**
   - Arabic users need RTL layout

---

## 📈 Performance Metrics

### Update Latency

| Trigger | Expected Latency |
|---------|-----------------|
| Time Change (Native) | < 100ms |
| Settings Change | < 500ms |
| App Resume | < 500ms |
| Manual Refresh | < 500ms |
| Background Service | 12 hours |
| WorkManager Fallback | 15 minutes |

### Battery Impact

| Component | Impact | Frequency |
|-----------|--------|-----------|
| TimeChangedReceiver | Zero | On time change only |
| Settings Change Listener | Low | User-initiated |
| App Resume Listener | Low | When user opens app |
| WorkManager (12h) | Very Low | Twice daily |
| WorkManager (15m) | Low | Every 15 min |

---

## 📚 References

- [Android Glance AppWidget Documentation](https://developer.android.com/guide/topics/ui/appwidgets)
- [Flutter home_widget Package](https://pub.dev/packages/home_widget)
- [Android Broadcast Receivers](https://developer.android.com/guide/components/broadcast-receivers)
- [Jetpack Glance Documentation](https://developer.android.com/jetpack/androidx/releases/glance)

---

## 🎯 Summary

### Widget Update System at a Glance

```
┌────────────────────────────────────────────────────────────┐
│                    WIDGET UPDATE SYSTEM                     │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Triggers: 11 different ways to update widget              │
│  - 3 Native Android broadcasts (instant, works offline)    │
│  - 5 Flutter settings changes (instant, app open)          │
│  - 1 App resume trigger (instant, app open)                │
│  - 1 Manual debug button (on-demand)                       │
│  - 2 Background services (periodic fallback)               │
│                                                             │
│  Data Flow: Settings → PrayerTimes → JSON → SharedPreferences → Widget UI
│                                                             │
│  Latency: < 500ms for all user-initiated updates           │
│  Battery: Zero impact from native broadcasts               │
│  Reliability: Multiple redundant update paths              │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

**End of Document**

For questions or issues, refer to `docs/HOME_WIDGET_IMPROVEMENT_PLAN.md`
