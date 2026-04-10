# Werd History Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the Werd History screen to a premium, simple Emerald & Gold design that aligns with the rest of the Fard app.

**Architecture:** UI-only refactoring of `WerdHistoryPage`. We will replace custom styling with `AppTheme` tokens and consolidate information into a cleaner, card-based timeline.

**Tech Stack:** Flutter, BLoC, Google Fonts (Amiri, Outfit), AppTheme.

---

### Task 1: Refactor UI Constants and Component Colors

**Files:**
- Modify: `lib/features/werd/presentation/pages/werd_history_page.dart`

- [ ] **Step 1: Update status color logic**
Replace the complex color palette in `_buildHistoryItem` with simplified Gold/Emerald logic.

```dart
// Logic to implement:
final isCompleted = goalValue > 0 && amount >= (goalValue - 0.01);
final accentColor = isCompleted ? AppTheme.accent : AppTheme.primary;
final backgroundColor = accentColor.withValues(alpha: 0.1);
final borderColor = isCompleted ? AppTheme.accent.withValues(alpha: 0.5) : AppTheme.cardBorder;
```

- [ ] **Step 2: Commit**
```bash
git add lib/features/werd/presentation/pages/werd_history_page.dart
git commit -m "style(werd): simplify status color logic to Gold/Emerald"
```

---

### Task 2: Refactor Month Navigator

**Files:**
- Modify: `lib/features/werd/presentation/pages/werd_history_page.dart`

- [ ] **Step 1: Apply standard card styling to navigator**
Update `_buildMonthNavigator` to use `AppTheme.surface` and standard borders.

```dart
// Update decoration:
decoration: BoxDecoration(
  color: AppTheme.surface,
  borderRadius: BorderRadius.circular(24), // Unified radius
  border: Border.all(color: AppTheme.cardBorder, width: 1),
),
```

- [ ] **Step 2: Update navigation buttons**
Ensure buttons use `AppTheme.accent` for icons and subtle backgrounds.

- [ ] **Step 3: Commit**
```bash
git add lib/features/werd/presentation/pages/werd_history_page.dart
git commit -m "style(werd): update month navigator to match app card style"
```

---

### Task 3: Refactor Monthly Summary Dashboard

**Files:**
- Modify: `lib/features/werd/presentation/pages/werd_history_page.dart`

- [ ] **Step 1: Clean up Summary Card decoration**
Remove custom gradients. Use a flat header style.

- [ ] **Step 2: Implement "Daily Avg" pill**
Move the average text into a `Positioned` or `Stack` element at the top-right of the summary area as a Gold badge.

- [ ] **Step 3: Commit**
```bash
git add lib/features/werd/presentation/pages/werd_history_page.dart
git commit -m "style(werd): refactor monthly summary into a clean dashboard header"
```

---

### Task 4: Refactor History Item Card (The Daily Log)

**Files:**
- Modify: `lib/features/werd/presentation/pages/werd_history_page.dart`

- [ ] **Step 1: Implement "Metadata Row"**
Replace the `Wrap` of badges with a single row of icons and text.

```dart
// New metadata row style:
Row(
  children: [
    _buildMetadataItem(Icons.auto_stories_rounded, "$totalAyahs", isAr),
    const SizedBox(width: 12),
    _buildMetadataItem(Icons.pages_rounded, "$totalPages", isAr),
    // ... etc
  ],
)
```

- [ ] **Step 2: Add bottom Progress Bar**
Add a `LinearProgressIndicator` (height 4) at the very bottom of the item card.

- [ ] **Step 3: Standardize Card Radius**
Ensure all history items use `BorderRadius.circular(24)`.

- [ ] **Step 4: Commit**
```bash
git add lib/features/werd/presentation/pages/werd_history_page.dart
git commit -m "style(werd): simplify history item cards and add metadata row"
```

---

### Task 5: Refactor Streak Break and Empty State

**Files:**
- Modify: `lib/features/werd/presentation/pages/werd_history_page.dart`

- [ ] **Step 1: Update Streak Break divider**
Replace the red box with a simple gray divider and a small `neutral` icon.

- [ ] **Step 2: Update Empty State button**
Ensure the "Start Reading" button uses the standard `ElevatedButton` theme.

- [ ] **Step 3: Commit**
```bash
git add lib/features/werd/presentation/pages/werd_history_page.dart
git commit -m "style(werd): clean up streak break and empty state UI"
```

---

### Task 6: Final Validation

- [ ] **Step 1: Run Analysis**
`flutter analyze lib/features/werd/presentation/pages/werd_history_page.dart`

- [ ] **Step 2: Verify existing tests**
`flutter test test/features/werd/` (if any exist) or `flutter test test/prayer_tracker_bloc_test.dart` to ensure no regressions in data flow.

- [ ] **Step 3: Final Commit**
```bash
git commit -m "style(werd): finalize werd history enhancement"
```
