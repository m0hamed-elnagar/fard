# Widget Robustness Plan

## Objective
Finalize the stability and robustness of the Android home widgets by preventing color parsing crashes, handling null/stale data gracefully, and validating data before it reaches the UI.

## Key Files & Context
- `android/app/src/main/kotlin/com/qada/fard/widget/WidgetUpdateWorker.kt`
- `android/app/src/main/kotlin/com/qada/fard/widget/WidgetPreviewContent.kt`
- `android/app/src/main/kotlin/com/qada/fard/prayer/SettingsRepository.kt`

## Implementation Steps

### 1. Optimize `WidgetUpdateWorker.kt` (Data Validation)
- Add validation logic to verify that the generated JSON data is well-formed before committing it to `SharedPreferences`.
- Ensure that color strings preserved from existing JSON are validated using the new `ColorUtils` before being re-applied.

### 2. Strengthen `SettingsRepository.kt`
- Update `saveWidgetTheme` to validate color hex strings before saving them to `SharedPreferences`. If an invalid hex string is received from Flutter, fallback to the default theme color.

### 3. Enhance UI Fallbacks in `WidgetPreviewContent.kt`
- Replace the generic "Open App" text with a proper error layout (e.g., "Tap to Sync") for when data is null, stale (>24h), or malformed. 
- Ensure that the widget always renders a visually appealing state rather than failing silently or looking broken.

### 4. Verification & Testing
- Run `./gradlew :app:lintDebug` to ensure all Kotlin code compiles and adheres to linting standards.
- Run `./gradlew :app:assembleDebug` to verify the Android build.
- Request manual verification on a connected Android device.