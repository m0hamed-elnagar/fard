# Context for Werd (Goal Tracking) Implementation

## 1. Objective
Implement a robust "Werd" (Daily Goal) feature that tracks Quran reading progress.
**Constraint:** The UI must match the existing `WerdProgressCard` visual design (Dashboard circles/progress bars), but the underlying logic must be "Context Aware" and support better tracking granularity (Pages vs Ayahs).

## 2. Requirements
- **Visuals:** Keep the exact look of `WerdProgressCard` (see below).
- **Tracking:**
    - Support setting goals in **Pages** or **Ayahs**.
    - If the goal is in Pages, the UI must show "X / Y Pages read", not converted to Ayahs.
    - If the goal is in Ayahs, show Ayahs.
- **Context Awareness:**
    - The feature must listen to `ReaderBloc` (or `WatchLastRead`) to automatically update progress when the user reads.
    - It should know where the user *started* the session vs where they are *now* to calculate "Session Progress".
- **Avoid:** Do NOT use the "Werd Calculation" logic from previous failed attempts (which involved complex scroll math). Use standard `ReaderBloc` positions.

## 3. Current State & Files

### A. Data Model (`WerdGoal.dart`)
Already supports units.
```dart
enum WerdUnit { ayah, page, quarter, hizb, juz }
class WerdGoal {
  final WerdUnit unit; // Use this to determine UI display
  final int value;     // The target amount (e.g. 10 pages)
  // ...
}
```

### B. The UI Goal (`WerdProgressCard.dart`)
This is the visual reference. Note how it currently hardcodes `goal.valueInAyahs`. This needs to change to support `goal.unit`.

```dart
// CURRENT (To be improved):
int current = progress?.totalAmountReadToday ?? 0; // Currently in Ayahs
int total = goal.valueInAyahs; // Forces conversion to Ayahs

// DESIRED:
// If unit is Page:
// int current = progress?.pagesReadToday;
// int total = goal.value; // e.g. 20 Pages
```

### C. Logic (`WerdBloc.dart`)
The current Bloc is too simplistic. It assumes linear reading from a start point.
**Needs:**
- A robust way to calculate "Pages Read" based on `startAyah` and `currentAyah`.
- Helper: `QuranHizbProvider` (or similar) likely has methods to convert Ayah <-> Page.

## 4. Integration Strategy
1.  **Repository:** Ensure `WerdRepository` persists progress correctly (Day, Amount, Unit).
2.  **Bloc:**
    - Listen to `ReaderBloc.state.lastReadAyah`.
    - When `lastRead` updates, calculate the difference from `sessionStartAyah`.
    - Convert that difference to the user's Goal Unit (Pages/Ayahs).
    - Update `WerdState`.
3.  **UI:** Update `WerdProgressCard` to display the correct unit label and value.

## 5. Critical Resources
- `lib/features/werd/presentation/blocs/werd_bloc.dart` (Logic to improve)
- `lib/features/prayer_tracking/presentation/widgets/werd_progress_card.dart` (Visual Goal)
- `lib/core/extensions/quran_extension.dart` (Use this for Ayah <-> Page math)

## 6. How to Start
1.  Analyze `WerdGoal` to see if `unit` is properly passed to the Bloc.
2.  Modify `WerdProgress` entity to store `pagesRead` (or dynamic `amountRead` generic).
3.  Update `WerdBloc` to use `QuranHizbProvider.getPageNumber(ayah)` to calculate page progress if the unit is Page.
4.  Update `WerdProgressCard` to respect `goal.unit`.
