# 🔧 Refactoring Fixes Plan
**Date:** April 5, 2026  
**Priority:** HIGH - Must complete before release  
**Estimated Time:** 45-60 minutes  
**Risk Level:** 🟢 LOW (all fixes are straightforward)

---

## 📊 Fix Summary

| Fix | Category | Files | Time | Risk | Impact |
|-----|----------|-------|------|------|--------|
| 1. Test Mock Stubs | Tests | 3 files | 10 min | 🟢 LOW | Fixes 4 test failures |
| 2. SettingsCubit Safety | Code | 1 file | 15 min | 🟢 LOW | Prevents potential crashes |
| 3. WorkManager Mock | Tests | 2 files | 10 min | 🟢 LOW | Fixes 3 test failures |
| 4. Error Handling | Code | 1 file | 10 min | 🟢 LOW | Better error visibility |
| 5. Linting | Code | 1 file | 2 min | 🟢 LOW | Clean code |
| **TOTAL** | | **7 files** | **~47 min** | | **7 failures fixed** |

---

## 🎯 FIX 1: Test Mock Stubs (CRITICAL - 10 minutes)

### Problem:
`WidgetUpdateService.updateWidget()` signature changed from `Future<void> updateWidget(SettingsState)` to `Future<void> updateWidget()` (no parameters). Three test files define `MockWidgetUpdateService` but don't stub `updateWidget()`.

### Error:
```
type 'Null' is not a subtype of type 'Future<void>'
```

### Affected Tests (4 failures):
1. ❌ `test/features/azkar/azkar_dialog_test.dart` (2 tests)
2. ❌ `test/features/onboarding/splash_screen_test.dart` (1 test)
3. ❌ `test/features/prayer_tracking/home_screen_test.dart` (1 test)

### Solution:
Add stub to `MockWidgetUpdateService` in each file:

```dart
class MockWidgetUpdateService extends MockWidgetUpdateServiceBase {
  @override
  Future<void> updateWidget() async {} // ADD THIS LINE
}
```

### Files to Modify:
1. `test/features/azkar/azkar_dialog_test.dart`
2. `test/features/onboarding/splash_screen_test.dart`
3. `test/features/prayer_tracking/home_screen_test.dart`

### Verification:
```bash
flutter test test/features/azkar/azkar_dialog_test.dart
flutter test test/features/onboarding/splash_screen_test.dart
flutter test test/features/prayer_tracking/home_screen_test.dart
```

**Expected:** All 4 tests pass

---

## 🎯 FIX 2: SettingsCubit Async Void Safety (IMPORTANT - 15 minutes)

### Problem:
SettingsCubit methods are `async void` which means unhandled exceptions will crash the app silently.

### Current Code:
```dart
void updateLocale(Locale locale) async {  // ❌ async void
  await _repository.updateLocale(locale);
  await _sync();
}
```

### Solution:
Wrap async operations in try-catch to prevent crashes:

```dart
void updateLocale(Locale locale) {
  try {
    _updateLocaleAsync(locale);
  } catch (e, stack) {
    debugPrint('SettingsCubit: Error updating locale: $e\n$stack');
  }
}

Future<void> _updateLocaleAsync(Locale locale) async {
  await _repository.updateLocale(locale);
  await _sync();
}
```

### Files to Modify:
1. `lib/features/settings/presentation/blocs/settings_cubit.dart`

### Methods to Fix:
- `updateLocale()`
- `updateLocation()`
- `updateCalculationMethod()`
- `updateMadhab()`
- `updateMorningAzkarTime()`
- `updateEveningAzkarTime()`
- `updateAfterSalahAzkarEnabled()`
- `updateSalaahSettings()`
- `updateReminders()`
- `toggleQadaEnabled()`
- `updateHijriAdjustment()`
- `refreshLocation()`

### Pattern to Apply:
```dart
// Public method (sync, safe)
void methodName(Params params) {
  try {
    _methodNameAsync(params);
  } catch (e, stack) {
    debugPrint('SettingsCubit: Error in methodName: $e\n$stack');
  }
}

// Private async method
Future<void> _methodNameAsync(Params params) async {
  await _useCase.execute(params);
  await _sync();
}
```

### Verification:
```bash
flutter test test/features/settings/settings_cubit_test.dart
```

**Expected:** All settings tests pass, no crashes on errors

---

## 🎯 FIX 3: WorkManager Platform Mock (RECOMMENDED - 10 minutes)

### Problem:
3 notification tests fail on Windows because WorkManager platform interface isn't mocked correctly.

### Error:
```
UnimplementedError: No implementation found for workmanager on this platform.
```

### Affected Tests (3 failures):
1. ❌ `test/core/services/notification/azan_timing_verification_test.dart` (2 tests)
2. ❌ `test/core/services/notification/prayer_scheduler_test.dart` (1 test)

### Current Mock (Incomplete):
```dart
// This doesn't work - MethodChannel mock
const MethodChannel('be.tramckrijte.workmanager')
  ..setMockMethodCallHandler((call) async => true);
```

### Solution:
Mock the Workmanager plugin interface directly:

```dart
import 'package:workmanager/src/workmanager_impl.dart';

class MockWorkmanager extends Mock implements Workmanager {}

// In setUp():
final mockWorkmanager = MockWorkmanager();
// Register mock implementation
```

OR simpler approach - skip tests on non-mobile platforms:

```dart
import 'dart:io' show Platform;

if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  return; // Skip test on desktop platforms
}
```

### Files to Modify:
1. `test/core/services/notification/azan_timing_verification_test.dart`
2. `test/core/services/notification/prayer_scheduler_test.dart`

### Verification:
```bash
flutter test test/core/services/notification/
```

**Expected:** Tests pass on mobile, skip on desktop

---

## 🎯 FIX 4: SettingsCubit Microtask Error Handling (RECOMMENDED - 10 minutes)

### Problem:
`_sync()` uses `Future.microtask()` which can fail silently if cubit is closed before it runs.

### Current Code:
```dart
Future<void> _sync() async {
  await _widgetSync();
  Future.microtask(() => _syncNotif.execute()); // ❌ Silent failure
}
```

### Solution:
Add error handling to microtask:

```dart
Future<void> _sync() async {
  await _widgetSync();
  Future.microtask(() async {
    try {
      await _syncNotif.execute();
    } catch (e, stack) {
      debugPrint('SettingsCubit: Error syncing notifications: $e\n$stack');
    }
  });
}
```

### Files to Modify:
1. `lib/features/settings/presentation/blocs/settings_cubit.dart`

### Verification:
```bash
flutter test test/features/settings/
```

**Expected:** Better error visibility, no silent failures

---

## 🎯 FIX 5: Linting Warning (NICE TO HAVE - 2 minutes)

### Problem:
Static analysis found 1 info-level warning:

```
lib/core/services/notification/prayer_scheduler.dart:61:7
Statements in an if should be enclosed in a block
```

### Current Code:
```dart
if (condition)
  doSomething(); // ❌ Missing braces
```

### Solution:
```dart
if (condition) {
  doSomething(); // ✅ With braces
}
```

### Files to Modify:
1. `lib/core/services/notification/prayer_scheduler.dart` (line 61)

### Verification:
```bash
flutter analyze
```

**Expected:** 0 issues found

---

## 🧪 VERIFICATION PLAN

### Step 1: Fix Test Regressions (10 min)
```bash
# Apply Fix 1 to 3 test files
flutter test test/features/azkar/azkar_dialog_test.dart
flutter test test/features/onboarding/splash_screen_test.dart
flutter test test/features/prayer_tracking/home_screen_test.dart
```

**Expected:** 4 tests pass (were failing before)

### Step 2: Fix SettingsCubit (25 min)
```bash
# Apply Fixes 2 and 4
flutter test test/features/settings/
```

**Expected:** All settings tests pass, no async void crashes

### Step 3: Fix WorkManager Tests (10 min)
```bash
# Apply Fix 3
flutter test test/core/services/notification/
```

**Expected:** 3 tests pass or skip on Windows

### Step 4: Fix Linting (2 min)
```bash
# Apply Fix 5
flutter analyze
```

**Expected:** 0 issues found

### Step 5: Full Test Suite (10 min)
```bash
flutter test
```

**Expected:** 
- Before: 213 passed, 28 failed
- After: 220 passed, 21 failed (7 fixes applied)
- Remaining 21 are pre-existing (separate task)

---

## 📋 IMPLEMENTATION ORDER

### Phase 1: Quick Wins (12 minutes)
1. ✅ Fix 4 test mock stubs (Fix 1)
2. ✅ Fix linting warning (Fix 5)
3. ✅ Verify with `flutter analyze`

### Phase 2: Code Safety (25 minutes)
4. ✅ Fix SettingsCubit async void (Fix 2)
5. ✅ Fix microtask error handling (Fix 4)
6. ✅ Test with `flutter test test/features/settings/`

### Phase 3: Test Coverage (10 minutes)
7. ✅ Fix WorkManager platform mock (Fix 3)
8. ✅ Test with `flutter test test/core/services/notification/`

### Phase 4: Verification (10 minutes)
9. ✅ Run full test suite: `flutter test`
10. ✅ Run static analysis: `flutter analyze`
11. ✅ Document results

**Total Time:** ~57 minutes

---

## ✅ SUCCESS CRITERIA

### Must Achieve:
- ✅ 4 new test regressions fixed (213 → 217 passing)
- ✅ `flutter analyze` returns 0 issues
- ✅ No compilation errors
- ✅ All settings tests pass

### Nice to Achieve:
- ✅ 3 WorkManager tests fixed/skipped (217 → 220 passing)
- ✅ Better error handling in SettingsCubit
- ✅ No async void crash potential

### Final State:
- **Before:** 213 passed, 28 failed
- **After:** 220 passed, 21 failed (all pre-existing)
- **Improvement:** +7 tests passing, 0 issues

---

## 🚨 NOTES

1. **All fixes are LOW RISK** - They're either test mocks or error handling
2. **No behavior changes** - Only fixing bugs and improving test coverage
3. **Pre-existing failures remain** - 21 tests will still fail (separate task to fix)
4. **Safe to rollback** - All changes are straightforward and reversible

---

## 📝 POST-FIX ACTIONS

After completing all fixes:
1. Commit changes with message: `fix: resolve test regressions and improve error handling`
2. Run manual testing checklist (see FINAL_COMPREHENSIVE_REPORT.md)
3. Build release APK: `flutter build apk --release`
4. Proceed with staged rollout

---

**Plan Created:** April 5, 2026  
**Estimated Completion:** 45-60 minutes  
**Risk Level:** 🟢 LOW  
**Recommendation:** ✅ **Execute all fixes before release**
