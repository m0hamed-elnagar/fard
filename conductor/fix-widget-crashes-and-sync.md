# Fix Widget Crashes, Build Errors, and Sync Logic

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve Android home widget crashes (NPE on finish), fix build errors in Kotlin widgets, standardize latitude/longitude storage across Flutter and Kotlin (using Strings), and optimize update logic while keeping WorkManager as a fail-safe.

**Architecture:** 
- **Standardization:** Both Flutter and Kotlin will store/read latitude/longitude as Strings in SharedPreferences to avoid `ClassCastException` and type mismatches.
- **Widget Lifecycle:** Remove manual `goAsync()`/`finish()` from Glance receivers to prevent lifecycle conflicts; rely on Glance's internal async management for standard updates and a dedicated CoroutineScope for custom actions.
- **Update Mechanism:** Primary updates via `AlarmManager` for scheduled prayer transitions and `ACTION_TIME_TICK` (every minute) for the countdown widget. **WorkManager** is retained as a 15-minute periodic "safety net" to ensure widgets are refreshed if other mechanisms fail.
- **Build Fixes:** Correct imports and structural errors in `NextPrayerCountdownWidget.kt` and `NextPrayerCountdownWidgetReceiver.kt`.

**Tech Stack:** 
- Kotlin / Android / Glance 1.1.1
- Dart / Flutter / shared_preferences
- Adhan Java Library

---

### Task 1: Standardize Latitude/Longitude Storage

**Files:**
- Modify: `lib/features/settings/presentation/blocs/settings_cubit.dart`
- Modify: `lib/core/services/settings_loader.dart`
- Modify: `android/app/src/main/kotlin/com/qada/fard/widget/WidgetCommitHelper.kt`

- [ ] **Step 1: Update SettingsCubit to save lat/long as String**
Change `setDouble` to `setString` for latitude and longitude.

```dart
// lib/features/settings/presentation/blocs/settings_cubit.dart

// Find refreshLocation and change:
await _prefs.setString(_latKey, position.latitude.toString());
await _prefs.setString(_lonKey, position.longitude.toString());
```

- [ ] **Step 2: Update SettingsLoader to handle String parsing only**
Remove fallback to `getDouble` if present, ensuring it always expects a `String`.

```dart
// lib/core/services/settings_loader.dart

static SettingsState loadSettings(SharedPreferences prefs) {
  final latStr = prefs.getString(_latKey);
  final lonStr = prefs.getString(_lonKey);
  
  return SettingsState(
    // ...
    latitude: latStr != null ? double.tryParse(latStr) : null,
    longitude: lonStr != null ? double.tryParse(lonStr) : null,
    // ...
  );
}
```

- [ ] **Step 3: Update WidgetCommitHelper to handle Double as String**
Add `Double` support to the `when` block in `saveAndUpdate`.

```kotlin
// android/app/src/main/kotlin/com/qada/fard/widget/WidgetCommitHelper.kt

when (value) {
    is String -> putString("flutter.$key", value)
    is Int -> putInt("flutter.$key", value)
    is Boolean -> putBoolean("flutter.$key", value)
    is Float -> putFloat("flutter.$key", value)
    is Long -> putLong("flutter.$key", value)
    is Double -> putString("flutter.$key", value.toString()) // Add this
    null -> remove("flutter.$key")
}
```

### Task 2: Fix Build Errors and Crashes in NextPrayerCountdownWidget

**Files:**
- Modify: `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidget.kt`
- Modify: `android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidgetReceiver.kt`

- [ ] **Step 1: Fix NextPrayerCountdownWidget.kt imports and structure**
Ensure all imports for `Intent` and `ActionCallback` are correct and the top-level callback is properly closed.

```kotlin
// android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidget.kt

import android.content.Context
import android.content.Intent
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
// ... existing imports

// Ensure SafeOpenAppCallback uses correct Intent flags
class SafeOpenAppCallback : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        context.startActivity(intent)
    }
}
```

- [ ] **Step 2: Fix NextPrayerCountdownWidgetReceiver.kt crashes and syntax**
Remove manual `goAsync()`/`finish()` and fix the brace issue causing `onDisabled` build error.

```kotlin
// android/app/src/main/kotlin/com/qada/fard/NextPrayerCountdownWidgetReceiver.kt

class NextPrayerCountdownWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = NextPrayerCountdownWidget()
    private val receiverScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // Standard Glance actions handled by super.onReceive()
        
        if (intent.action == ACTION_FORCE_UPDATE) {
            receiverScope.launch {
                glanceAppWidget.updateAll(context)
            }
        }
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        receiverScope.cancel()
    }

    companion object {
        const val ACTION_FORCE_UPDATE = "com.qada.fard.ACTION_FORCE_UPDATE"
    }
}
```

### Task 3: Fix PrayerWidgetReceiver and WidgetUpdateWorker Crashes

**Files:**
- Modify: `android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt`
- Modify: `android/app/src/main/kotlin/com/qada/fard/widget/WidgetUpdateWorker.kt`

- [ ] **Step 1: Remove manual async management in PrayerWidgetReceiver**
Simplify `onReceive` to avoid `NullPointerException` on `pendingResult.finish()`.

```kotlin
// android/app/src/main/kotlin/com/qada/fard/PrayerWidgetReceiver.kt

override fun onReceive(context: Context, intent: Intent) {
    super.onReceive(context, intent)
    
    val action = intent.action
    if (action == "com.qada.fard.UPDATE_WIDGET" || action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
        CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
            updateAll(context)
        }
    }
}
```

- [ ] **Step 2: Fix WidgetUpdateWorker.kt to ensure safety**
Ensure `WidgetUpdateWorker` uses the standardized settings loading and doesn't crash.

```kotlin
// android/app/src/main/kotlin/com/qada/fard/widget/WidgetUpdateWorker.kt

override suspend fun doWork(): Result {
    return withContext(Dispatchers.IO) {
        try {
            // Standardize update logic here
            PrayerWidget().updateAll(applicationContext)
            NextPrayerCountdownWidget().updateAll(applicationContext)
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}
```

### Task 4: Optimization and Cleanup

**Files:**
- Modify: `android/app/src/main/kotlin/com/qada/fard/FardApplication.kt`

- [ ] **Step 1: Ensure FardApplication.kt properly manages receivers and WorkManager**
Keep `scheduleWidgetSafetyNet()` as a fail-safe but ensure it's configured correctly.

```kotlin
// android/app/src/main/kotlin/com/qada/fard/FardApplication.kt

override fun onCreate() {
    super.onCreate()
    registerReceiver(timeReceiver, IntentFilter(Intent.ACTION_TIME_TICK))
    scheduleWidgetSafetyNet() // Retained as fail-safe
}
```

### Task 5: Verification

- [ ] **Step 1: Clean and Build Android**
Run: `cd android && ./gradlew clean assembleDebug`
Expected: SUCCESS

- [ ] **Step 2: Verify Flutter Settings Loading**
Run the app, update location, and ensure no "type 'double' is not a subtype of type 'String?'" errors occur.

- [ ] **Step 3: Verify Widget Updates**
Add both widgets to home screen. Change system time manually (by 1 min) and verify Countdown Widget updates. Verify Prayer Widget highlights correctly.

- [ ] **Step 4: Verify No Crashes**
Check `adb logcat` for any `NullPointerException` in `PrayerWidgetReceiver` or `NextPrayerCountdownWidgetReceiver` during updates.
