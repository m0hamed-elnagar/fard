# Android & Kotlin Linting Guide

This document tracks how to perform linting and common fixes for the Android/Kotlin portion of the project.

## Running Lint

To run lint without being overwhelmed by errors in third-party Flutter plugins, always target the `:app` module:

```powershell
cd android
./gradlew :app:lintDebug
```

## Common Fixes Applied

### 1. Windows Path Escaping (`local.properties`)
On Windows, `local.properties` requires colons and backslashes to be escaped, or you can use forward slashes. 
**Incorrect:** `sdk.dir=D:\development\sdk`
**Correct:** `sdk.dir=D\:\\development\\sdk` or `sdk.dir=D:/development/sdk` (Note: Colons may still need escaping as `\:` depending on the Gradle version's strictness).

### 2. SharedPreferences KTX
Use `androidx.core:core-ktx` for cleaner and safer SharedPreferences edits:
```kotlin
// Before
prefs.edit().apply { ... }.commit()

// After (Using KTX)
prefs.edit(commit = true) {
    // putString, putInt, etc.
}
```

### 3. Android Manifest Storage Permissions
When targeting Android 13 (API 33)+, `READ_EXTERNAL_STORAGE` is deprecated. Add `maxSdkVersion` to avoid lint warnings:
```xml
<uses-permission 
    android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
```

### 4. Obsolete SDK Checks
If `minSdkVersion` is 24+, checks for `Build.VERSION.SDK_INT >= Build.VERSION_CODES.M` (API 23) are unnecessary and should be removed.

### 5. Adhan Library Usage (Kotlin)
The `CalculationParameters` class in the `adhan-java` library is not a data class and does not support `copy()`. Modify parameters in-place:
```kotlin
### 6. Ensuring Single App Instance
Remove `android:taskAffinity=""` from `MainActivity` in `AndroidManifest.xml` to allow Android to correctly group the activity into the existing task. Maintain `android:launchMode="singleTask"`.

### 7. Fully Qualified Receiver Names
Always use fully qualified names (e.g., `com.qada.fard.PrayerWidgetReceiver`) in `AndroidManifest.xml` instead of relative names (`.PrayerWidgetReceiver`). This prevents `ClassNotFoundException` when the `applicationId` has a suffix (like `.debug1`) that differs from the package `namespace`.

### 8. Robust goAsync() in BroadcastReceivers
When using `goAsync()` in a `BroadcastReceiver`, always use a `try-finally` block to ensure `finish()` is called, and consider calling `super.onReceive()` outside the async block if using Glance to avoid session races.
