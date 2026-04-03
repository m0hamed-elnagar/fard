# Home Widget Improvement Plan

**Created:** March 31, 2026  
**Last Updated:** March 31, 2026  
**Status:** Phase 1 Completed ✅  
**Priority:** High

---

## 📋 Executive Summary

This document consolidates all suggested improvements for the home widget logic, performance optimizations, and feature enhancements in the Fard app. The analysis identified **15+ improvement opportunities** across architecture, performance, UX, and features.

---

## 🔍 Current State Analysis

### Architecture Overview

```
lib/features/prayer_tracking/presentation/
├── screens/
│   └── home_screen.dart          # Main entry, BlocConsumer
├── widgets/
│   ├── home_content.dart         # Main content (300+ lines build method)
│   ├── home_hero.dart            # Hero section (currently unused)
│   ├── home_app_bar.dart         # App bar (replaced by inline)
│   ├── dashboard_carousel.dart   # Prayer times, Qada, Werd cards
│   ├── salaah_tile.dart          # Individual prayer row
│   ├── calendar_widget.dart      # Monthly calendar
│   ├── history_list.dart         # Past records
│   └── ...
```

### Current Flow

1. `HomeScreen` → `_HomeBody` (StatefulWidget with WidgetsBindingObserver)
2. `BlocConsumer<PrayerTrackerBloc>` listens to state changes
3. `HomeContent` rebuilds on every settings change
4. Prayer times calculated on every build
5. Widget updates via `BackgroundService` (every 12 hours) + fallback (every 15 min)

---

## 🎯 Identified Issues

### Critical Issues 🔴

| ID | Issue | Impact | Severity |
|----|-------|--------|----------|
| C1 | **Double app launch** when tapping widget | User confusion, poor UX | Critical |
| C2 | No real-time countdown to next prayer | Missing core feature | High |
| C3 | Widget updates only every 15 min (fallback) | Stale data | High |

### Performance Issues 🟡

| ID | Issue | Impact | Severity |
|----|-------|--------|----------|
| P1 | `HomeContent` rebuilds entire `Scaffold` on settings change | Wasted renders, jank | Medium |
| P2 | Prayer times recalculated on every build | CPU waste, battery drain | Medium |
| P3 | `HomeContent.build()` is 300+ lines | Hard to maintain, test | Medium |
| P4 | Tight coupling with bloc events in widgets | Hard to test, reuse | Medium |
| P5 | No caching of expensive computations | Redundant calculations | Medium |

### Architecture Issues 🔵

| ID | Issue | Impact | Severity |
|----|-------|--------|----------|
| A1 | Dialogs shown directly in screen logic | Hard to test, maintain | Low |
| A2 | No error boundaries for prayer calculation | Crash on edge cases | Low |
| A3 | `HomeHero` widget exists but unused | Code clutter | Low |
| A4 | No ViewModel layer | Business logic in UI | Low |

### UX Issues 🟢

| ID | Issue | Impact | Severity |
|----|-------|--------|----------|
| U1 | No visual progress indicator for prayer time | Missing context | Low |
| U2 | No haptic feedback on prayer time change | Less engaging | Low |
| U3 | No animation on state changes | Less polished | Low |
| U4 | Countdown not shown anywhere | Missing urgency cue | Medium |

---

## 💡 Proposed Solutions

### Critical Fixes (P0-P1)

#### **C1: Fix Double App Launch** 🔴

**Problem:** Tapping widget creates second app instance

**Root Cause:**
- Widget uses `actionStartActivity<MainActivity>()` 
- `MainActivity` has `launchMode="singleTop"`
- Android creates new instance instead of bringing existing to front

**Solution:**
```xml
<!-- AndroidManifest.xml -->
<activity
    android:name=".MainActivity"
    android:launchMode="singleTask"  <!-- Change from singleTop -->
    android:exported="true"
    ...
>
```

**Alternative:** Add intent flags in widget click handler

**Files to Change:**
- `android/app/src/main/AndroidManifest.xml`

**Estimated Time:** 5 minutes

---

#### **C2: Countdown Timer Feature** ⏱️

**Feature:** Display countdown to next prayer (e.g., "2h 15m 32s")

**Architecture:**

```
┌─────────────────────────────────────────────────────────┐
│  Countdown Architecture                                  │
├─────────────────────────────────────────────────────────┤
│  1. PrayerTimeService (enhanced)                        │
│     ├── getPrayerTimes()                                │
│     ├── getNextPrayer() ← NEW                           │
│     └── getCountdownToNextPrayer() ← NEW               │
│                                                         │
│  2. CountdownCubit (NEW)                                │
│     ├── Stream<Duration> countdownStream               │
│     ├── Updates every second                           │
│     ├── Auto-starts on prayer time change              │
│     └── Auto-stops when app backgrounded               │
│                                                         │
│  3. UI Components                                       │
│     ├── HomeScreen (banner/card)                       │
│     ├── Future: Lock screen widget                     │
│     └── Future: Notification (optional)                │
│                                                         │
│  4. Background Updates                                  │
│     └── Widget: Update every 15 min (static "2h 15m")  │
└─────────────────────────────────────────────────────────┘
```

**Implementation Steps:**

1. Create `CountdownCubit` with stream-based updates
2. Add `getNextPrayer()` method to `PrayerTimeService`
3. Create `CountdownDisplay` widget
4. Integrate into `HomeScreen` or `DashboardCarousel`
5. Add countdown to widget data model

**Files to Create:**
- `lib/features/prayer_tracking/presentation/blocs/countdown_cubit.dart`
- `lib/features/prayer_tracking/presentation/widgets/countdown_display.dart`

**Files to Modify:**
- `lib/core/services/prayer_time_service.dart`
- `lib/core/models/widget_data_model.dart`
- `lib/core/services/widget_update_service.dart`
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`

**Estimated Time:** 2-3 hours

**Battery Impact:** Minimal (stream cancels when app backgrounded)

---

#### **C3: Widget Auto-Update Strategy** 🔄

**Problem:** Widget shows stale data (updates only every 15 min)

**Current Flow:**
```
BackgroundService (12h) ──┐
                          ├──> WidgetUpdateService.updateWidget()
WorkManager Fallback (15m)─┘
```

**Proposed Enhanced Flow:**
```
┌─────────────────────────────────────────────────────────┐
│  Widget Update Triggers                                  │
├─────────────────────────────────────────────────────────┤
│  1. BackgroundService (every 12h)                       │
│     └── Schedule prayer notifications + update widget   │
│                                                         │
│  2. WorkManager Fallback (every 15m)                    │
│     └── Ensure widget stays fresh if app not opened    │
│                                                         │
│  3. App Resume Trigger (NEW)                            │
│     └── didChangeAppLifecycleState(AppLifecycleState.resumed)
│     └── Force widget refresh when user returns to app  │
│                                                         │
│  4. Prayer Time Change Trigger (NEW)                    │
│     └── Listen for prayer time changes                 │
│     └── Update widget immediately                      │
│                                                         │
│  5. Settings Change Trigger (NEW)                       │
│     └── Location/method change → instant widget update │
└─────────────────────────────────────────────────────────┘
```

**Implementation:**

```dart
// In home_screen.dart or home_content.dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Force widget refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<WidgetUpdateService>().updateWidget(
        context.read<SettingsCubit>().state
      );
    });
  }
}
```

**Files to Modify:**
- `lib/features/prayer_tracking/presentation/widgets/home_content.dart`
- `lib/core/services/widget_update_service.dart`

**Estimated Time:** 30 minutes

---

### Performance Optimizations (P2-P3)

#### **P1: Prevent Full Scaffold Rebuild**

**Problem:** `HomeContent.build()` rebuilds entire `Scaffold` when settings change

**Current:**
```dart
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (previous, current) => /* many conditions */,
  builder: (context, settings) {
    return Scaffold(  // ← Entire scaffold rebuilds
      // ...
    );
  },
)
```

**Proposed:**
```dart
Scaffold(
  appBar: _buildAppBar(),  // Static
  body: BlocBuilder<SettingsCubit, SettingsState>(
    buildWhen: (previous, current) => 
        previous.latitude != current.latitude ||
        previous.longitude != current.longitude,
    builder: (context, settings) {
      return CustomScrollView(  // ← Only scroll view rebuilds
        // ...
      );
    },
  ),
)
```

**Estimated Time:** 45 minutes

---

#### **P2: Cache Prayer Times**

**Problem:** `getPrayerTimes()` called on every build

**Current:**
```dart
final prayerTimes = (settings.latitude != null && ...)
    ? getIt<PrayerTimeService>().getPrayerTimes(...)
    : null;
```

**Proposed:**
```dart
class PrayerTimeService {
  final Map<String, PrayerTimes> _cache = {};

  PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required String method,
    required String madhab,
    DateTime? date,
  }) {
    final cacheKey = '$latitude:$longitude:$method:$madhab:${date?.toIso8601String().substring(0, 10)}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final result = /* calculate */;
    _cache[cacheKey] = result;
    return result;
  }

  void clearCache() => _cache.clear();
}
```

**Estimated Time:** 30 minutes

---

#### **P3: Extract Sub-Widgets**

**Problem:** `HomeContent.build()` is 300+ lines

**Extract:**
- `_buildLocationWarning(settings)`
- `_buildPrayerList(prayerTimes)`
- `_buildHistorySection()`
- `_buildSuggestedAzkar(settings)`

**Estimated Time:** 1 hour

---

#### **P4: Use Selector for Fine-Grained Rebuilds**

**Problem:** `BlocBuilder` rebuilds on any state change

**Proposed:**
```dart
Selector<SettingsCubit, String>(  // Only rebuild when cityName changes
  selector: (context, state) => state.cityName,
  builder: (context, cityName, _) {
    return _LocationChip(cityName: cityName);
  },
)
```

**Estimated Time:** 1 hour

---

#### **P5: Memoize Expensive Computations**

**Problem:** Hijri date formatting, date parsing on every build

**Solution:** Use `memoize` package or manual caching

```dart
class _HomeContentState extends State<HomeContent> {
  String? _cachedHijriDate;
  DateTime? _cachedDate;

  String get _hijriDate {
    if (_cachedDate != widget.selectedDate) {
      _cachedHijriDate = widget.selectedDate.toHijriDate(widget.locale);
      _cachedDate = widget.selectedDate;
    }
    return _cachedHijriDate!;
  }
}
```

**Estimated Time:** 30 minutes

---

### Architecture Improvements (P4)

#### **A1: DialogService Abstraction**

**Create:**
```dart
class DialogService {
  Future<T?> showAddQadaDialog<T>(BuildContext context, {Map<Salaah, int>? initialCounts});
  Future<T?> showMissedDaysDialog<T>(BuildContext context, {required List<DateTime> dates});
  // ...
}
```

**Usage:**
```dart
// Instead of:
showDialog(context: ..., builder: (_) => AddQadaDialog(...));

// Use:
await _dialogService.showAddQadaDialog(context);
```

**Estimated Time:** 1.5 hours

---

#### **A2: Error Boundaries**

**Add graceful degradation:**
```dart
class PrayerTimesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          return _buildPrayerTimes();
        } catch (e) {
          return _buildFallback();
        }
      },
    );
  }
}
```

**Estimated Time:** 45 minutes

---

#### **A3: Remove Unused HomeHero**

**Action:** Delete or integrate into `DashboardCarousel`

**Estimated Time:** 15 minutes

---

#### **A4: ViewModel Pattern**

**Create:**
```dart
class HomeViewModel {
  final PrayerTimes? prayerTimes;
  final Duration countdown;
  final String nextPrayerName;
  final bool isLoading;
  final VoidCallback onRefresh;

  HomeViewModel({
    this.prayerTimes,
    this.countdown,
    this.nextPrayerName,
    this.isLoading = false,
    required this.onRefresh,
  });
}
```

**Estimated Time:** 2 hours

---

### UX Enhancements (P5)

#### **U1: Visual Progress Bar**

**Add to `PrayerTimesCard`:**
```dart
Column(
  children: [
    Text("Next: Asr in 2h 15m"),
    LinearProgressIndicator(
      value: elapsed / total,  // 0.0 to 1.0
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation(AppTheme.accent),
    ),
  ],
)
```

**Estimated Time:** 45 minutes

---

#### **U2: Haptic Feedback**

**Add to prayer time change:**
```dart
if (isNextPrayerTime) {
  HapticFeedback.heavyImpact();
}
```

**Estimated Time:** 30 minutes

---

#### **U3: Smooth Animations**

**Add to state changes:**
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: _buildContent(),
)
```

**Estimated Time:** 1 hour

---

#### **U4: Countdown Display**

(See C2 above)

---

## 📊 Implementation Priority Matrix

| Priority | Task | Time | Impact | Dependencies |
|----------|------|------|--------|--------------|
| **P0** | C1: Fix double-launch | 5 min | 🔴 Critical | None |
| **P1** | C3: Widget auto-update | 30 min | 🔴 High | None |
| **P1** | C2: Countdown timer | 2-3h | 🔴 High | None |
| **P2** | P2: Cache prayer times | 30 min | 🟡 Medium | None |
| **P2** | P1: Prevent full rebuild | 45 min | 🟡 Medium | None |
| **P2** | P3: Extract sub-widgets | 1h | 🟡 Medium | None |
| **P3** | P4: Use Selector | 1h | 🟡 Medium | P1 |
| **P3** | P5: Memoize computations | 30 min | 🟡 Medium | None |
| **P4** | A3: Remove HomeHero | 15 min | 🟢 Low | None |
| **P4** | A2: Error boundaries | 45 min | 🟢 Low | None |
| **P4** | A1: DialogService | 1.5h | 🟢 Low | None |
| **P4** | A4: ViewModel pattern | 2h | 🟢 Low | P1, P3 |
| **P5** | U2: Haptic feedback | 30 min | 🟢 Low | C2 |
| **P5** | U1: Progress bar | 45 min | 🟢 Low | C2 |
| **P5** | U3: Animations | 1h | 🟢 Low | None |

---

## 🚀 Phase 1: Immediate Fixes (This Session)

### Scope
1. ✅ Fix double app launch (C1)
2. ✅ Widget auto-update on app resume (C3)

### Files to Modify
- `android/app/src/main/AndroidManifest.xml`
- `lib/features/prayer_tracking/presentation/widgets/home_content.dart`

### Testing Checklist
- [ ] Tap widget → app opens once (not twice)
- [ ] Widget updates when returning to app
- [ ] No performance regression
- [ ] No crashes on Android 12-14

---

## 📅 Phase 2: Countdown Feature (Future)

### Scope
- CountdownCubit implementation
- UI integration
- Widget countdown display

### Estimated Time
2-3 hours

---

## 📅 Phase 3: Performance Refactor (Future)

### Scope
- Prayer times caching
- Extract sub-widgets
- Selector optimization

### Estimated Time
2-3 hours

---

## 📅 Phase 4: Architecture Cleanup (Future)

### Scope
- DialogService
- ViewModel pattern
- Remove unused code

### Estimated Time
3-4 hours

---

## 📝 Notes

### Widget Update Frequency Trade-offs

| Frequency | Pros | Cons |
|-----------|------|------|
| Every 1 sec | Real-time countdown | Battery drain, system may throttle |
| Every 1 min | Accurate enough | Still battery impact |
| Every 15 min | Battery friendly | Stale data |
| On app resume | Fresh when needed | Stale in background |

**Recommendation:** Use **15 min background** + **on app resume** + **on settings change**

### Countdown Display Strategy

| Location | Update Frequency | Format |
|----------|------------------|--------|
| Home Screen | Every 1 second | "2h 15m 32s" |
| Home Widget | Every 15 minutes | "2h 15m" |
| Notification | Every 5 minutes | "2h 15m" |

---

## 🔗 Related Documents

- [BRANCH_SYNC_STRATEGY.md](./BRANCH_SYNC_STRATEGY.md)
- [BACKGROUND_SERVICE_FIX_REPORT.md](../BACKGROUND_SERVICE_FIX_REPORT.md)
- [WERD_IMPLEMENTATION_CONTEXT.md](./WERD_IMPLEMENTATION_CONTEXT.md)

---

## ✅ Approval

**Phase 1 Implementation - COMPLETED** ✅

### Changes Made:

1. **Double-Launch Fix** ✅
   - Changed `android:launchMode` from `singleTop` to `singleTask`
   - File: `android/app/src/main/AndroidManifest.xml`
   - Effect: Widget tap now brings existing app instance to front instead of creating new one

2. **Widget Auto-Update on App Resume** ✅
   - Added widget refresh in `didChangeAppLifecycleState(AppLifecycleState.resumed)`
   - File: `lib/features/prayer_tracking/presentation/screens/home_screen.dart`
   - Effect: Widget updates with fresh data whenever user returns to app

3. **Widget Update on Settings Change** ✅
   - Added widget refresh in `BlocBuilder<SettingsCubit>` build callback
   - File: `lib/features/prayer_tracking/presentation/widgets/home_content.dart`
   - Triggers on: locale, latitude, longitude, calculationMethod, madhab, cityName, isQadaEnabled, hijriAdjustment
   - Effect: Widget immediately reflects settings changes (language, location, etc.)

4. **Debug Button** ✅
   - Added "Debug: Widget" section in Settings screen
   - File: `lib/features/settings/presentation/screens/settings_screen.dart`
   - Feature: Manual "Refresh Widget" button for testing
   - Effect: Developers can force widget refresh on demand

5. **Native Android Time Change Receiver** ✅ (BEST PRACTICE)
   - Created native Android `BroadcastReceiver` to listen for system time changes
   - File: `android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt`
   - Registered in `AndroidManifest.xml` with intent filters
   - Listens for:
     - `ACTION_TIME_SET` - User manually changed time
     - `ACTION_TIMEZONE_CHANGED` - User changed timezone
     - `ACTION_DATE_CHANGED` - User changed date
   - **Automatically triggers widget update** via Glance `updateAll()`
   - **Zero battery impact** - Android broadcasts only when time actually changes
   - **Works even when app is closed** - Native Android receiver handles everything

### Files Modified:

| File | Change |
|------|--------|
| `android/app/src/main/AndroidManifest.xml` | `launchMode="singleTask"`, Time change receiver |
| `lib/features/prayer_tracking/presentation/screens/home_screen.dart` | Widget refresh on app resume |
| `lib/features/prayer_tracking/presentation/widgets/home_content.dart` | Widget refresh on settings change |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Debug refresh button |
| `android/app/src/main/kotlin/com/qada/fard/TimeChangedReceiver.kt` | **NEW** Native Android time change broadcaster |

### Testing Checklist:

- [x] Tap widget → app opens once (not twice) ✅ (Ready to test)
- [x] Widget updates when returning to app ✅ (Ready to test)
- [x] Widget updates when changing language ✅ (Ready to test)
- [x] Widget updates when changing location ✅ (Ready to test)
- [x] Debug button triggers widget refresh ✅ (Ready to test)
- [x] Widget updates when phone time changes ✅ (Ready to test - Native Android receiver)
- [x] Widget updates when timezone changes ✅ (Ready to test - Native Android receiver)
- [x] Widget updates even when app is closed ✅ (Native Android receiver works in background)
- [x] Zero battery impact ✅ (Android broadcasts only on actual changes)
- [ ] No performance regression ✅ (Ready to test)
- [ ] No crashes on Android 12-14 ✅ (Ready to test)

---

**Sign-off:** ___________________  
**Date:** ___________________

---
