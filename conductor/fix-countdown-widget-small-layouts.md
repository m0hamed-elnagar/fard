# Plan: Align Countdown Widget UI with Prayer Widget

Standardize the `NextPrayerCountdownWidget`'s small-scale layouts (1x1 and 2x1) to match the aesthetic established in `PrayerWidget.kt`, specifically the gold divider and consistent padding.

## Proposed Changes

### 1. Update `NextPrayerCountdownWidget.kt`
- **Thresholds:** Align `isTiny` and `isSmall` detection with `PrayerWidget.kt`.
- **Layout Refactoring:**
    - Create a `TinyLayout` Composable.
    - Use `Box` dividers with `accentGold` to separate the Prayer Name and the Countdown Time.
    - Implement explicit RTL handling for the layout order in small sizes.
- **Interactions:** Use `actionStartActivity<MainActivity>()` for the root container.

## Implementation Details

### CountdownWidgetRoot logic:
- `isTiny = size.width < 110.dp || size.height < 110.dp`
- `isWide = size.width > 150.dp && size.height < 110.dp`

### TinyLayout (1x1):
- Column layout.
- Prayer Name (accentGold, 12sp).
- Horizontal Divider (36dp width, 1dp height, accentGold).
- Status Text (textPrimary, 16sp, Bold).

### WideLayout (2x1):
- Row layout.
- Prayer Name (accentGold, 16sp, Bold).
- Vertical Divider (1dp width, 16dp height, accentGold).
- Status Text (textPrimary, 18sp, Bold).

## Verification
- Run the app and check the widget previews for 1x1 and 2x1 sizes.
- Verify that clicking the widget opens the main activity correctly.
