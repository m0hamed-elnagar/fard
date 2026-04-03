# Plan: Restore PrayerWidget UI

## Objective
Restore the "look" (UI/Layout) of `PrayerWidget.kt` to match the user-provided code, while maintaining the current underlying logic (`PrayerTimesCalculator`, `SettingsRepository`).

## Key Files
- `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`: The file to be updated.

## Proposed Changes
1. **Update `TinyLayout`**:
    - Add the gold vertical bar divider for wide layouts (`size.width > 150.dp`).
    - Add the short gold line divider for narrow layouts.
2. **Update `FullLayout`**:
    - Adjust font scaling logic to match user's provided structure.
    - Format `combinedDate` to exclude the year if present.
    - Ensure gold divider and spacers match the provided styling.
    - Use `defaultWeight()` on the prayer column and individual prayer boxes to ensure even distribution.
3. **Update `PrayerRow`**:
    - Match horizontal paddings, dot sizes, and gaps.
    - Ensure RTL layout has time on the left and name on the right as per the "look" requirements.
4. **General Styling**:
    - Retain use of `actionStartActivity<MainActivity>()` for the main clickable area.
    - Maintain `primaryGreen`, `accentGold`, `textPrimary`, and `textSecondary` color constants.

## Verification
- Run `./gradlew :app:assembleDebug` in the `android` directory to ensure compilation.
- Run `./gradlew :app:lintDebug` to ensure no new lint regressions.
