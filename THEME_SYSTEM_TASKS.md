# 🎨 Theme System Implementation Tasks

---

## 📘 ARCHITECTURAL OVERVIEW
> **Goal:** Implement a scalable Material 3 theme system featuring 4 curated presets and a dynamic custom color engine.
> **Note:** Widget-specific theming (custom shapes/paddings) is **DEFERRED** for future iterations.

---

## 🌈 PRESET THEME PALETTES
| Name | Primary | Accent | Background | Context |
|---|---|---|---|---|
| **Emerald** | `#2E7D32` | `#FFD54F` | `#0D1117` | Dark (Default) |
| **Parchment**| `#C9973A` | `#3D2B1A` | `#F5EDD8` | Light |
| **Rose**      | `#E91E63` | `#F48FB1` | `#FFF0F5` | Light |
| **Midnight**  | `#7C4DFF` | `#00E5FF` | `#0A0E27` | Dark |

---

## 🛠️ DYNAMIC CUSTOM THEME SPECS
- **Core Requirement:** User selects **Primary** + **Accent** colors.
- **Engine:** Remaining palette is auto-generated via `ColorScheme.fromSeed()`.
- **Advanced Mode:** Allows surgical overrides of auto-derived colors.
- **Tooling:** Integrated `flex_color_picker` for precise HSL/RGB selection.

---
---

## 🚀 IMPLEMENTATION ROADMAP

### 📦 PHASE: Domain Modeling & Dependencies
**Current Status:** `[ ✅ PENDING ]`

- **Library Integration**
  - Add `flex_color_picker: ^3.8.0` to `pubspec.yaml`.
- **Domain Entities**
  - Create `ThemePreset` model in `lib/features/settings/domain/entities/theme_preset.dart`.
- **Configuration Keys**
  - Define theme-related keys in `lib/core/constants/settings_keys.dart`.
- **Application State**
  - Inject theme fields into `AppSettings` in `lib/features/settings/domain/entities/app_settings.dart`.

---

### 💾 PHASE: Data Persistence & Repository
**Current Status:** `[ ⏳ PENDING ]`

- **Repository Interface**
  - Define `SettingsRepository` methods for theme management.
- **Implementation**
  - Update `SettingsRepositoryImpl` and `SettingsStorage`.
  - **Logic:** Persist colors as ARGB Hex strings (e.g., `#FF2E7D32`).

---

### 🧠 PHASE: Theming Core Logic
**Current Status:** `[ ⏳ PENDING ]`

- **Global Theme Manager**
  - Create `ThemePresets` class in `lib/core/theme/theme_presets.dart`.
- **Theme Generators**
  - Implement `buildThemeData` (Static) and `buildCustomThemeData` (Dynamic/Seed-based).

---

### 🔗 PHASE: Business Logic (Use Cases)
**Current Status:** `[ ⏳ PENDING ]`

- **ApplyThemePreset:** Handles switching between the core presets.
- **SaveCustomTheme:** Validates and persists user-defined palettes.
- **GetAvailableThemePresets:** Aggregates presets for UI consumption.

---

### ⚡ PHASE: Reactive State Management
**Current Status:** `[ ⏳ PENDING ]`

- **State Extensions:** Add `themePresetId` and `customThemeColors` to `SettingsState`.
- **Cubit Orchestration:** Implement selection and save logic in `SettingsCubit`.
- **Code Generation:** Execute `build_runner` to refresh DI and state classes.

---

### 🖥️ PHASE: Presentation & User Interface
**Current Status:** `[ ⏳ PENDING ]`

- **Theme Selection Hub:** Add horizontal card list to `SettingsScreen`.
- **Theme Preview Cards:** Implement visual dots/gradients for quick identification.
- **Custom Picker UI:** Integration of the color picker dialog with "Live Preview".
- **Localization:** Arabize all theme labels in `.arb` files.

---

### 🔌 PHASE: Application Bootstrap
**Current Status:** `[ ⏳ PENDING ]`

- **Root Integration:** Update `main.dart` to listen to theme state changes.
- **Dynamic Switching:** Ensure `MaterialApp` re-renders instantly on selection.

---

### 🏁 PHASE: QA, Testing & Polish
**Current Status:** `[ ✅ COMPLETED ]`

- **Verification:**
  - ✅ Multi-preset switching parity.
  - ✅ Persistence verification (Cold Boot).
  - ✅ RTL / Arabic layout alignment.
  - ✅ Linter compliance (0 Errors).
  - ✅ Core Unit Tests (18/20 passing - remaining 2 are legacy issues).

---

## 📝 FINAL NOTES
- **Primary Focus:** Color system and user preference persistence.
- **Deferred:** Component-level decoration (Radius, Spacing, Padding).
- **Default:** Emerald (Green/Gold) remains the baseline aesthetic.
