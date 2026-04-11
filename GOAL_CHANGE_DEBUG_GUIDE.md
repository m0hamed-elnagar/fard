# Goal Change Debug Guide

**Date:** 2026-04-11  
**Issue:** History shows nothing after changing goal

---

## 🔍 What We Know

✅ **Unit tests pass** - Logic is correct  
✅ **Integration tests pass** - Flow is correct  
✅ **History filtering works** - Page shows data correctly  

❌ **In the actual app** - User sees nothing in history after goal change

---

## 📊 Diagnostic Steps

### Step 1: Enable Debug Logging

The code now has extensive debug logging. When you change the goal, look for these logs in the console:

```
🔍 [Goal Change] Before saving to history:
   totalAmountReadToday: X
   segmentsToday: X
   history entries: X

💾 [Goal Change] Saving to history with key: 2026-04-11
💾 [Goal Change] Saved today's sessions to history: 2026-04-11 - X ayahs
   History entries now: X

📊 [Goal Change] After reset:
   totalAmountReadToday: 0
   segmentsToday: 0
   history entries: X

✅ [Goal Change] Progress reset for new goal
🔄 [Goal Change] Loading progress for new goal: default
```

### Step 2: Check What's in SharedPreferences

After changing the goal, the data is saved to SharedPreferences. We need to verify what's actually stored.

Add this debug code temporarily to `werd_history_page.dart`:

```dart
// At the top of the build method, after getting progress
if (progress != null) {
  debugPrint('🔍 [HistoryPage] Progress state:');
  debugPrint('   totalAmountReadToday: ${progress.totalAmountReadToday}');
  debugPrint('   segmentsToday: ${progress.segmentsToday.length}');
  debugPrint('   history entries: ${progress.history.length}');
  debugPrint('   history keys: ${progress.history.keys.toList()}');
  
  for (final entry in progress.history.entries) {
    debugPrint('   - ${entry.key}: ${entry.value.totalAyahsRead} ayahs, ${entry.value.pagesRead} pages');
  }
}
```

### Step 3: Check Repository Load

When `WerdEvent.load` is called after goal change, add this to see what's loaded:

In `werd_bloc.dart`, the load event already has logging:

```dart
debugPrint('📦 [WerdBloc] Loaded from storage:');
progressRes.fold(
  (failure) => debugPrint('   ❌ Failed to load progress: ${failure.message}'),
  (progress) {
    debugPrint('   ✅ Progress loaded');
    debugPrint('   - Segments today: ${progress.segmentsToday.length}');
    debugPrint('   - Total ayahs today: ${progress.totalAmountReadToday}');
    debugPrint('   - History entries: ${progress.history.length}');
    for (var i = 0; i < progress.history.length; i++) {
      // Can't iterate map this way, use:
    }
    progress.history.forEach((key, value) {
      debugPrint('   - History[$key]: ${value.totalAyahsRead} ayahs');
    });
  },
);
```

---

## 🎯 Possible Root Causes

### Hypothesis 1: segmentsToday not reset in storage

**What to check:**
After goal change, you said edit dialog shows sessions. This means `segmentsToday` is NOT empty.

**Possible cause:**
The `copyWith` might not be resetting `segmentsToday` properly, or the repository isn't saving it.

**How to verify:**
Check the debug log after "After reset:" - does it show `segmentsToday: 0`?

---

### Hypothesis 2: History entry saved but with wrong date key

**What to check:**
Maybe the date key format is inconsistent between save and load.

**Possible cause:**
Timezone issues or date formatting differences.

**How to verify:**
Check "history keys" in the debug output - does it show today's date in `YYYY-MM-DD` format?

---

### Hypothesis 3: Load event overwrites with old data

**What to check:**
When `add(WerdEvent.load(id: e.goal.id))` is called, maybe it's loading STALE data from before our save.

**Possible cause:**
The repository might be caching or the save didn't complete before load.

**How to verify:**
Check the "Loaded from storage" log - does it show the history entries we just saved?

---

### Hypothesis 4: You're looking at a different month

**What to check:**
The history page filters by the focused month (defaults to current month).

**Possible cause:**
If the history entry has a date from a different month, it won't show.

**How to verify:**
Check the history page month navigator - is it showing the current month?

---

## 🔧 Temporary Diagnostic Build

Run the app with verbose logging:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run --verbose 2>&1 | tee debug_log.txt

# Then change the goal and open history
# Search the log for "Goal Change" and "HistoryPage"
```

---

## 📋 What to Report Back

Please run the app and provide:

1. **Console logs** after changing goal (search for "Goal Change")
2. **What you see in the edit dialog** (screenshot or description)
3. **What you see in the history page** (screenshot or description)
4. **SharedPreferences data** (if you can access it)

With this information, I can pinpoint the exact issue!

---

## 💡 Quick Fix to Try

If the issue is that `segmentsToday` isn't being reset, try this manual test:

1. Read some ayahs
2. Change the goal
3. **Hot restart the app** (press 'R' in console)
4. Open history

If data shows up after restart, it means the save is working but the UI isn't updating properly.
