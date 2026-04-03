# Widget Update Visual Diagrams

**Created:** March 31, 2026  
**Purpose:** Visual representation of widget update flows

---

## 📊 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          FARD WIDGET SYSTEM                              │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│   Flutter Layer      │         │   Android Layer      │
│   (Dart)             │         │   (Kotlin)           │
│                      │         │                      │
│  ┌────────────────┐  │         │  ┌────────────────┐  │
│  │ WidgetUpdate   │  │         │  │ PrayerWidget   │  │
│  │ Service        │──┼─────────┼─►│ Receiver       │  │
│  └────────────────┘  │ Shared  │  └────────────────┘  │
│         ▲            │ Prefs   │         ▲            │
│         │            │         │         │            │
│  ┌────────────────┐  │ JSON    │  ┌────────────────┐  │
│  │ Settings       │  │         │  │ TimeChanged    │  │
│  │ Cubit          │──┤         │◄─┤ Receiver       │  │
│  └────────────────┘  │         │  └────────────────┘  │
│         ▲            │         │         ▲            │
│         │            │         │         │            │
│  ┌────────────────┐  │         │  ┌────────────────┐  │
│  │ HomeContent    │  │         │  │ Android System │  │
│  │ Widget         │──┤         │◄─┤ (Time/Date/    │  │
│  └────────────────┘  │         │  │  Timezone)     │  │
│                      │         │  └────────────────┘  │
└──────────────────────┘         └──────────────────────┘
         ▲                              ▲
         │                              │
         └──────────┬───────────────────┘
                    │
              User Actions
         (Settings, Time Change,
          App Resume, etc.)
```

---

## 🔄 Complete Update Flow (Step-by-Step)

```
┌────────────────────────────────────────────────────────────────────┐
│ STEP 1: UPDATE TRIGGER                                            │
└────────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌─────────────────┐
│ Native Android│   │ Flutter Settings│   │  App Lifecycle  │
│ Broadcast     │   │ Change          │   │  (App Resume)   │
│               │   │                 │   │                 │
│ • Time Set    │   │ • Language      │   │ • User opens    │
│ • Timezone    │   │ • Location      │   │   app           │
│ • Date        │   │ • Calc Method   │   │ • Returns from  │
│               │   │ • Madhab        │   │   background    │
└───────┬───────┘   └────────┬────────┘   └────────┬────────┘
        │                    │                      │
        └────────────────────┼──────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────────┐
│ STEP 2: WIDGET UPDATE SERVICE                                      │
│ File: lib/core/services/widget_update_service.dart                │
└────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  1. Get Settings from SettingsCubit    │
        │     - locale (for language)            │
        │     - latitude, longitude (location)   │
        │     - calculationMethod                │
        │     - madhab                           │
        └────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  2. Calculate Prayer Times             │
        │     PrayerTimeService.getPrayerTimes() │
        │                                        │
        │     Input:                            │
        │     - Lat: 21.4225                    │
        │     - Lng: 39.8262                    │
        │     - Method: UMM_AL_QURA             │
        │     - Madhab: SHAFI                   │
        │     - Date: 2026-03-31                │
        │                                        │
        │     Output:                           │
        │     - Fajr: 05:30 AM                  │
        │     - Dhuhr: 12:30 PM                 │
        │     - Asr: 03:45 PM                   │
        │     - Maghrib: 06:15 PM               │
        │     - Isha: 07:45 PM                  │
        └────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  3. Format Data with Localization      │
        │                                        │
        │  WidgetDataModel {                     │
        │    gregorianDate: "31 March 2026"     │
        │    hijriDate: "٢ رمضان ١٤٤٧"          │
        │    dayOfWeek: "Tuesday"               │
        │    sunrise: "6:30 AM"                 │
        │    isRtl: true (for Arabic)           │
        │    prayers: [ ... ]                   │
        │  }                                     │
        └────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  4. Serialize to JSON                  │
        │                                        │
        │  {                                     │
        │    "gregorianDate": "31 March 2026",  │
        │    "hijriDate": "٢ رمضان ١٤٤٧",       │
        │    "dayOfWeek": "Tuesday",            │
        │    "sunrise": "6:30 AM",              │
        │    "isRtl": true,                     │
        │    "prayers": [                       │
        │      {"name":"Fajr","time":"5:30 AM", │
        │       "minutesFromMidnight":330},     │
        │      ...                              │
        │    ]                                   │
        │  }                                     │
        └────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────────┐
│ STEP 3: SAVE TO SHARED PREFERENCES                                 │
│ Key: "prayer_data"                                                 │
│ Value: JSON string                                                 │
└────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  5. Call HomeWidget.updateWidget()     │
        │     name: "PrayerWidgetReceiver"       │
        │     androidName: "com.qada.fard...     │
        └────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────────┐
│ STEP 4: ANDROID WIDGET RECEIVER                                    │
│ File: android/.../kotlin/com/qada/fard/PrayerWidgetReceiver.kt    │
└────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  6. onReceive(Context, Intent)         │
        │     MainScope.launch {                 │
        │       glanceAppWidget.updateAll(ctx)   │
        │     }                                  │
        └────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────────┐
│ STEP 5: GLANCE WIDGET UPDATE                                       │
│ File: android/.../kotlin/com/qada/fard/PrayerWidget.kt            │
└────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  7. provideGlance(Context, GlanceId)   │
        │                                        │
        │  - Read SharedPreferences              │
        │  - Parse JSON data                     │
        │  - Get widget size                     │
        └────────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │  8. Render Widget UI (Compose)         │
        │                                        │
        │  Column {                             │
        │    Text(gregorianDate)                │
        │    Text(hijriDate)                     │
        │    Row {                              │
        │      prayers.forEach { prayer ->      │
        │        PrayerRow(                     │
        │          name: prayer.name,           │
        │          time: prayer.time,           │
        │          isNext: isNextPrayer(prayer) │
        │        )                              │
        │      }                                │
        │    }                                  │
        │    if (isRtl) {                       │
        │      applyRTLLayout()                 │
        │    }                                  │
        │  }                                     │
        └────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────────┐
│ STEP 6: WIDGET UPDATED! ✅                                         │
│ Home screen widget now shows:                                      │
│ - Updated dates (Gregorian & Hijri)                               │
│ - Correct prayer times for location                               │
│ - Next prayer highlighted                                         │
│ - Proper RTL/LTR layout                                           │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Trigger-Specific Flows

### Flow A: Time Change (Native Android)

```
┌──────────────────────────────────────────────────────────┐
│ User Changes Phone Time                                  │
│ Settings → Date & Time → Manual → 3:00 PM               │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ Android System Broadcast                                 │
│ Intent.ACTION_TIME_SET                                   │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ TimeChangedReceiver.onReceive()                          │
│ File: android/.../TimeChangedReceiver.kt                │
│                                                          │
│ Log: "System time changed by user"                      │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ MainScope.launch {                                       │
│   PrayerWidget().updateAll(context)                     │
│ }                                                        │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ Glance: provideGlance()                                  │
│ - Read SharedPreferences                                │
│ - Parse JSON                                             │
│ - Re-render widget UI                                    │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ ✅ Widget Shows Updated Prayer Times                    │
│ (Even if app is closed!)                                │
└──────────────────────────────────────────────────────────┘
```

### Flow B: Language Change (Flutter)

```
┌──────────────────────────────────────────────────────────┐
│ User Changes Language                                    │
│ Settings → Language → Arabic                             │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ SettingsCubit.toggleLocale()                             │
│ emit(state.copyWith(locale: Locale('ar')))              │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ BlocBuilder<SettingsCubit>                               │
│ buildWhen: (prev, curr) =>                               │
│   prev.locale != curr.locale  // TRUE!                  │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ HomeContent.build() rebuilds                             │
│ - Calculate prayer times                                 │
│ - Format with Arabic locale                              │
│ - isRtl = true                                           │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ WidgetsBinding.addPostFrameCallback {                    │
│   getIt<WidgetUpdateService>()                          │
│     .updateWidget(settings)                             │
│ }                                                        │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ WidgetUpdateService.updateWidget()                       │
│ - Create WidgetDataModel with Arabic text               │
│ - gregorianDate: "٣١ مارس ٢٠٢٦"                        │
│ - hijriDate: "٢ رمضان ١٤٤٧"                            │
│ - prayers: ["الفجر", "الظهر", ...]                     │
│ - isRtl: true                                            │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ Save to SharedPreferences                                │
│ Key: "prayer_data"                                       │
│ Value: JSON with Arabic text                             │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ HomeWidget.updateWidget()                                │
│ → PrayerWidgetReceiver.onReceive()                      │
│ → PrayerWidget.provideGlance()                          │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ ✅ Widget Shows Arabic Text with RTL Layout             │
└──────────────────────────────────────────────────────────┘
```

### Flow C: App Resume (Flutter Lifecycle)

```
┌──────────────────────────────────────────────────────────┐
│ User Opens App (from background or cold start)          │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ AppLifecycleState.resumed                                │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ HomeScreen.didChangeAppLifecycleState()                 │
│ override fun didChangeAppLifecycleState(state) {        │
│   if (state == AppLifecycleState.resumed) {             │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ // 1. Refresh prayer data                               │
│ bloc.add(PrayerTrackerEvent.load(selectedDate))         │
│                                                          │
│ // 2. Refresh widget                                    │
│ WidgetsBinding.addPostFrameCallback {                   │
│   getIt<WidgetUpdateService>()                          │
│     .updateWidget(settings)                             │
│ }                                                        │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ Widget updated with latest prayer times                 │
│ (Ensures widget is fresh after app was in background)   │
└──────────────────────────────────────────────────────────┘
```

---

## 📊 Data Structure Flow

```
┌─────────────────────────────────────────────────────────┐
│ SETTINGS STATE (SettingsCubit)                          │
├─────────────────────────────────────────────────────────┤
│ locale: Locale('ar')                                    │
│ latitude: 21.4225                                       │
│ longitude: 39.8262                                      │
│ calculationMethod: 'umm_al_qura'                       │
│ madhab: 'shafi'                                         │
│ hijriAdjustment: 0                                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼ (GetPrayerTimes)
┌─────────────────────────────────────────────────────────┐
│ PRAYER TIMES (PrayerTimes object)                       │
├─────────────────────────────────────────────────────────┤
│ fajr: DateTime(2026, 3, 31, 5, 30)                     │
│ dhuhr: DateTime(2026, 3, 31, 12, 30)                   │
│ asr: DateTime(2026, 3, 31, 15, 45)                     │
│ maghrib: DateTime(2026, 3, 31, 18, 15)                 │
│ isha: DateTime(2026, 3, 31, 19, 45)                    │
│ sunrise: DateTime(2026, 3, 31, 6, 30)                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼ (Create WidgetDataModel)
┌─────────────────────────────────────────────────────────┐
│ WIDGET DATA MODEL (WidgetDataModel)                     │
├─────────────────────────────────────────────────────────┤
│ gregorianDate: "31 March 2026"                         │
│ hijriDate: "٢ رمضان ١٤٤٧"                             │
│ dayOfWeek: "Tuesday"                                   │
│ sunrise: "6:30 AM"                                     │
│ isRtl: true                                             │
│ prayers: [                                              │
│   PrayerTimeItem("Fajr", "5:30 AM", 330),              │
│   PrayerTimeItem("Dhuhr", "12:30 PM", 750),            │
│   PrayerTimeItem("Asr", "3:45 PM", 945),               │
│   PrayerTimeItem("Maghrib", "6:15 PM", 1095),          │
│   PrayerTimeItem("Isha", "7:45 PM", 1185)              │
│ ]                                                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼ (JSON Serialize)
┌─────────────────────────────────────────────────────────┐
│ JSON STRING                                             │
├─────────────────────────────────────────────────────────┤
│ {                                                       │
│   "gregorianDate": "31 March 2026",                    │
│   "hijriDate": "٢ رمضان ١٤٤٧",                        │
│   "dayOfWeek": "Tuesday",                              │
│   "sunrise": "6:30 AM",                                │
│   "isRtl": true,                                       │
│   "prayers": [                                         │
│     {"name":"Fajr","time":"5:30 AM",                  │
│      "minutesFromMidnight":330}, ... ]}                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼ (Save)
┌─────────────────────────────────────────────────────────┐
│ SHARED PREFERENCES                                      │
├─────────────────────────────────────────────────────────┤
│ Key: "prayer_data"                                     │
│ Value: [JSON STRING]                                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼ (Read & Parse)
┌─────────────────────────────────────────────────────────┐
│ WIDGET UI (Jetpack Compose)                             │
├─────────────────────────────────────────────────────────┤
│ Column {                                                │
│   Text("Tuesday, 31 March")                            │
│   Text("٢ رمضان ١٤٤٧")                                │
│   Row {                                                 │
│     PrayerRow("الفجر", "5:30 AM", isNext=false)       │
│     PrayerRow("الظهر", "12:30 PM", isNext=true) ⭐    │
│     PrayerRow("العصر", "3:45 PM", isNext=false)       │
│     PrayerRow("المغرب", "6:15 PM", isNext=false)      │
│     PrayerRow("العشاء", "7:45 PM", isNext=false)      │
│   }                                                     │
│ }                                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🎨 Widget Size Variations

```
┌──────────────────────────────────────────────────────────┐
│ TINY (1x1) - Height < 110dp                             │
├──────────────────────────────────────────────────────────┤
│ ┌─────────────────┐                                     │
│ │   Dhuhr  │ 12:30│                                     │
│ │    PM    │  ⭐  │                                     │
│ └─────────────────┘                                     │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ COMPACT (2x2) - Height 110-220dp                        │
├──────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────┐                         │
│ │ Tuesday, 31 March           │                         │
│ │ ٢ رمضان ١٤٤٧                │                         │
│ ├─────────────────────────────┤                         │
│ │ Fajr      5:30 AM           │                         │
│ │ Dhuhr    12:30 PM  ⭐       │                         │
│ │ Asr       3:45 PM           │                         │
│ └─────────────────────────────┘                         │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ FULL (4x2) - Height > 220dp                             │
├──────────────────────────────────────────────────────────┤
│ ┌───────────────────────────────────────────┐           │
│ │ Tuesday, 31 March 2026                    │           │
│ │ ٢ رمضان ١٤٤٧ هـ                           │           │
│ ├───────────────────────────────────────────┤           │
│ │ Fajr       5:30 AM                        │           │
│ │ Sunrise    6:30 AM                        │           │
│ │ Dhuhr     12:30 PM  ⭐                    │           │
│ │ Asr        3:45 PM                        │           │
│ │ Maghrib    6:15 PM                        │           │
│ │ Isha       7:45 PM                        │           │
│ └───────────────────────────────────────────┘           │
└──────────────────────────────────────────────────────────┘
```

---

## 🔐 SharedPreferences Storage

```
File: /data/data/com.qada.fard/shared_prefs/HomeWidgetPreferences.xml

┌──────────────────────────────────────────────────────────┐
│ <?xml version='1.0' encoding='utf-8'?>                  │
│ <map>                                                    │
│   <string name="prayer_data">                           │
│     {                                                    │
│       "gregorianDate": "31 March 2026",                 │
│       "hijriDate": "٢ رمضان ١٤٤٧",                     │
│       "dayOfWeek": "Tuesday",                           │
│       "sunrise": "6:30 AM",                             │
│       "isRtl": true,                                    │
│       "prayers": [ ... ]                                │
│     }                                                    │
│   </string>                                             │
│ </map>                                                  │
└──────────────────────────────────────────────────────────┘
```

---

## 📡 Broadcast Receiver Registration

```xml
File: android/app/src/main/AndroidManifest.xml

┌──────────────────────────────────────────────────────────┐
│ <manifest ...>                                          │
│   <application ...>                                     │
│                                                          │
│     <!-- Widget Receiver -->                            │
│     <receiver                                           │
│       android:name=".PrayerWidgetReceiver"             │
│       android:exported="true">                          │
│       <intent-filter>                                   │
│         <action                                        │
│           android:name="android.appwidget.action.       │
│                        APPWIDGET_UPDATE" />             │
│       </intent-filter>                                  │
│       <meta-data                                       │
│         android:name="android.appwidget.provider"      │
│         android:resource="@xml/prayer_widget_info" />  │
│     </receiver>                                         │
│                                                          │
│     <!-- Time Change Receiver -->                       │
│     <receiver                                           │
│       android:name=".TimeChangedReceiver"              │
│       android:exported="true">                          │
│       <intent-filter>                                   │
│         <action                                        │
│           android:name="android.intent.action.         │
│                        TIME_SET" />                     │
│         <action                                        │
│           android:name="android.intent.action.         │
│                        TIMEZONE_CHANGED" />             │
│         <action                                        │
│           android:name="android.intent.action.         │
│                        DATE_CHANGED" />                 │
│       </intent-filter>                                  │
│     </receiver>                                         │
│                                                          │
│   </application>                                        │
│ </manifest>                                             │
└──────────────────────────────────────────────────────────┘
```

---

**End of Visual Diagrams**

For more details, see:
- [`WIDGET_UPDATE_COMPLETE_GUIDE.md`](./WIDGET_UPDATE_COMPLETE_GUIDE.md)
- [`WIDGET_UPDATE_QUICK_REFERENCE.md`](./WIDGET_UPDATE_QUICK_REFERENCE.md)
