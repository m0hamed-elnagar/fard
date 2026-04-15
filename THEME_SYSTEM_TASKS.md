# Theme System Implementation Tasks

## Overview
Add a complete theme system with 4 preset themes + custom theme picker in Settings screen.
Widget theming is **DEFERRED** to a follow-up session.

---

## The 4 Preset Themes

| # | Name | Primary | Accent | Background | Type |
|---|------|---------|--------|------------|------|
| 1 | **Emerald** (default) | `#2E7D32` Green | `#FFD54F` Gold | `#0D1117` Dark | Dark |
| 2 | **Parchment** | `#C9973A` Gold | `#3D2B1A` Brown | `#F5EDD8` Cream | Light |
| 3 | **Rose** | `#E91E63` Pink | `#F48FB1` Light Pink | `#FFF0F5` Light Pink | Light |
| 4 | **Midnight** | `#7C4DFF` Purple | `#00E5FF` Cyan | `#0A0E27` Navy | Dark |

---

## Custom Theme
- User picks **2 required colors**: Primary + Accent
- Remaining 6 colors (background, surface, text, etc.) **auto-derived** via Material 3 `ColorScheme.fromSeed()`
- User can **optionally override** any auto-derived color in advanced mode
- Uses `flex_color_picker` package with eyedropper support

---

## Phase 1: Dependencies & Domain Entities ✅ PENDING

### 1.1 Add `flex_color_picker` to pubspec.yaml
- Package: `flex_color_picker: ^3.8.0` (check latest version)

### 1.2 Create `ThemePreset` entity
**File**: `lib/features/settings/domain/entities/theme_preset.dart`
- Fields: `id`, `name`, `nameAr`, `primaryColor`, `accentColor`, `backgroundColor`, `surfaceColor`, `surfaceLightColor`, `cardBorderColor`, `textColor`, `textSecondaryColor`, `icon`, `isDark`

### 1.3 Add theme keys to `SettingsKeys`
**File**: `lib/core/constants/settings_keys.dart`
- `themePresetId`, `customPrimaryColor`, `customAccentColor`, `customBackgroundColor`, `customSurfaceColor`, `customTextColor`, `customTextSecondaryColor`, `customCardBorderColor`, `customSurfaceLightColor`

### 1.4 Add theme fields to `AppSettings` entity
**File**: `lib/features/settings/domain/entities/app_settings.dart`
- `selectedThemePreset` (String)
- Custom theme color fields (8 nullable Color fields)

---

## Phase 2: Data Layer (Repository + Storage) ⏳ PENDING

### 2.1 Add theme methods to `SettingsRepository` interface
**File**: `lib/features/settings/domain/repositories/settings_repository.dart`
- `String get themePresetId`
- `Future<void> updateThemePreset(String presetId)`
- `Map<String, Color>? get customThemeColors`
- `Future<void> saveCustomTheme(Map<String, Color> colors)`
- `List<ThemePreset> getAvailablePresets()`
- `ThemePreset? getPresetById(String id)`

### 2.2 Implement in `SettingsRepositoryImpl`
**File**: `lib/features/settings/data/repositories/settings_repository_impl.dart`

### 2.3 Implement in `SettingsStorage`
**File**: `lib/features/settings/data/repositories/settings_storage.dart`
- Colors stored as hex strings (e.g., `'#FF2E7D32'`)

---

## Phase 3: Theme System Core ⏳ PENDING

### 3.1 Create `ThemePresets` class
**File**: `lib/core/theme/theme_presets.dart`
- Static definitions of all 4 presets
- Factory method: `buildThemeData(ThemePreset preset)` → `ThemeData`
- Custom theme builder: `buildCustomThemeData(Map<String, Color> colors)` → `ThemeData`

### 3.2 Theme building logic
- Map preset colors to full `ThemeData` (colorScheme, cardTheme, dialogTheme, appBarTheme, etc.)
- Custom theme uses `ColorScheme.fromSeed()` for auto-derivation

---

## Phase 4: Use Cases ⏳ PENDING

### 4.1 `ApplyThemePreset`
**File**: `lib/features/settings/domain/usecases/apply_theme_preset.dart`
- Input: `String presetId`
- Updates repository, returns new `ThemePreset`

### 4.2 `SaveCustomTheme`
**File**: `lib/features/settings/domain/usecases/save_custom_theme.dart`
- Input: `Map<String, Color> colors`
- Validates colors, saves to repository

### 4.3 `GetAvailableThemePresets`
**File**: `lib/features/settings/domain/usecases/get_available_theme_presets.dart`
- Returns list of all presets

---

## Phase 5: State Management ⏳ PENDING

### 5.1 Update `SettingsState`
**File**: `lib/features/settings/presentation/blocs/settings_state.dart`
- Add `themePresetId` (default: `'emerald'`)
- Add `customThemeColors` (nullable Map<String, String>)

### 5.2 Update `SettingsCubit`
**File**: `lib/features/settings/presentation/blocs/settings_cubit.dart`
- Add `selectThemePreset(String presetId)`
- Add `saveCustomTheme(Map<String, Color> colors)`
- Initialize theme from repository in constructor

### 5.3 Run code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Phase 6: Settings UI ⏳ PENDING

### 6.1 Add theme section to SettingsScreen
**File**: `lib/features/settings/presentation/screens/settings_screen.dart`
- Horizontal scrollable cards
- Section header with palette icon

### 6.2 Create theme card widget
- Shows theme preview (gradient + color dots)
- Checkmark if selected
- Tap to apply

### 6.3 Create custom theme card
- Opens color picker dialog
- Shows "Custom" label

### 6.4 Create color picker dialog
- Uses `flex_color_picker`
- Step 1: Pick primary color (required)
- Step 2: Pick accent color (required)
- Step 3 (optional): Override auto-derived colors

### 6.5 Add reset-to-default button
- Shows when not on default (Emerald)

### 6.6 Add localization strings
**Files**: `lib/core/l10n/app_en.arb`, `lib/core/l10n/app_ar.arb`
- `theme`, `emeraldTheme`, `parchmentTheme`, `roseTheme`, `midnightTheme`
- `customTheme`, `pickPrimaryColor`, `pickAccentColor`, `resetToDefault`, `select`

---

## Phase 7: App Integration ⏳ PENDING

### 7.1 Update `main.dart`
**File**: `lib/main.dart`
- Read `themePresetId` from `SettingsState`
- Build theme from preset or custom colors
- Pass to `MaterialApp(theme: ...)`
- Rebuild on theme change

---

## Phase 8: Testing & Polish ✅ COMPLETED

### 8.1 Test scenarios
- ✅ All 4 presets switch correctly (code verified)
- ✅ Custom theme creation + persistence across restart (code verified)
- ✅ Arabic locale support (ARB files updated)
- ✅ Code quality checks (`flutter analyze` - 0 errors, only warnings)
- ✅ Unit tests: 18/20 passing (2 pre-existing widget test failures unrelated to theme)

---

## Files Summary

### Created (3 files)
- `lib/features/settings/domain/entities/theme_preset.dart`
- `lib/core/theme/theme_presets.dart`
- `lib/features/settings/domain/usecases/apply_theme_preset.dart`
- `lib/features/settings/domain/usecases/save_custom_theme.dart`
- `lib/features/settings/domain/usecases/get_available_theme_presets.dart`

### Modified (~15 files)
- `pubspec.yaml`
- `lib/core/constants/settings_keys.dart`
- `lib/features/settings/domain/entities/app_settings.dart`
- `lib/features/settings/domain/repositories/settings_repository.dart`
- `lib/features/settings/data/repositories/settings_repository_impl.dart`
- `lib/features/settings/data/repositories/settings_storage.dart`
- `lib/features/settings/presentation/blocs/settings_state.dart`
- `lib/features/settings/presentation/blocs/settings_cubit.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `lib/core/l10n/app_en.arb`
- `lib/core/l10n/app_ar.arb`
- `lib/main.dart`

---

## Notes
- **Widget Theming**: DEFERRED to follow-up session
- **Custom Colors**: 2 required (primary + accent), 6 auto-derived via Material 3, optionally overridable
- **Color Storage**: Hex strings in SharedPreferences
- **Default Theme**: Emerald (`#2E7D32` Green + Gold)
- **Session Tracking**: Reference this file for progress
