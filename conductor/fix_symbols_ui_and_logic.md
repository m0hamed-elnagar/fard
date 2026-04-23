# Implementation Plan - Final Fix for Quranic Symbols (UI & Data)

## Objective
Provide a fully working Quranic symbol detection and explanation system with a polished UI.

## Analysis of Remaining Issues
1.  **JSON Serialization Failure:** The Dart models were expecting camelCase fields (`arabicName`), but the JSON used snake_case (`arabic_name`). This caused all symbol loading to fail silently or crash.
2.  **Missing Detail Screen:** The full explanation screen for symbols was planned but not fully implemented, leaving tiles non-interactive.
3.  **UI Layout:** The help overlay was not centered and lacked a "floating widget" feel with summary data.
4.  **Categorization:** Some symbols like `wasl_awla` were missing from the Waqf list due to strict prefix filtering.

## Changes Completed / Proposed

### 1. Domain Layer (Models)
*   **`lib/features/quran/domain/models/quran_symbol.dart`**
    *   Applied `@JsonSerializable(fieldRename: FieldRename.snake)` to all models.
    *   Added `@JsonKey(name: 'type')` and `@JsonKey(name: 'text')` to `SymbolSource` to match JSON keys.
    *   Kept classes `abstract` with mixins for proper Freezed generation.

### 2. Presentation Layer (UI)
*   **`lib/features/quran/presentation/widgets/quran_reader_help_overlay.dart`**
    *   Redesigned as a "little floating widget".
    *   Added a `FutureBuilder` to show real-time stats (count of Waqf vs Tajweed symbols).
    *   Centered alignment and added a close button.
*   **`lib/features/quran/presentation/pages/symbol_detail_screen.dart`** (New)
    *   Created a detailed view for a single symbol.
    *   Included a `SegmentedButton` to switch between different explanation sources (Book, Website, etc.).
    *   Added a section for Quranic examples with RTL text support.
*   **`lib/features/quran/presentation/pages/symbol_list_screen.dart`**
    *   Enabled navigation to `SymbolDetailScreen`.
    *   Improved layout with `initiallyExpanded: true` for categories.
*   **`lib/features/quran/presentation/widgets/ayah_info_sheet.dart`**
    *   Improved empty state with Arabic instructions.
    *   Enabled navigation to `SymbolDetailScreen` on tap.

### 3. Data Layer (Infrastructure)
*   **`lib/features/quran/data/repositories/quran_symbols_repository_impl.dart`**
    *   Fixed filtering logic to include `wasl_` prefixes in Waqf symbols.
    *   Added robust `try-catch` and error logging.
*   **`lib/core/utils/symbol_detector.dart`**
    *   Added character-level debug logs to verify matching in the console.

## Verification Steps
1.  **Overlay Check:** Tap the info icon in the reader; verify it shows "9 Waqf, 5 Tajweed" (or similar counts) and fits the screen.
2.  **Detection Check:** Long-press an ayah; verify symbols appear in the "الرموز" tab.
3.  **Navigation Check:** Tap a symbol in the list or the tab; verify it opens the detailed explanation screen.
4.  **Source Check:** In the detail screen, switch between sources; verify the text content updates.
