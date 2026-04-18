# Tasbih Navigation Arrows Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add navigation arrows to the Tasbih page to allow moving to the next or previous Zikr, similar to the Azkar page.

**Architecture:** Use `Stack` with `PositionedDirectional` to overlay navigation arrows on the existing `TasbihView`. Manage index state to jump between items in `state.currentCategory.items`.

**Tech Stack:** Flutter, BLoC (for state), Material Design.

---

### Task 1: Update TasbihBloc to handle index changes

**Files:**
- Modify: `lib/features/tasbih/presentation/bloc/tasbih_bloc.dart`

- [ ] **Step 1: Add a navigation event to TasbihBloc**

Add a new event `TasbihEvent.changeItem(int newIndex)` to `TasbihBloc` and update the `on<ChangeItem>` handler to update `currentCycleIndex` (or a similar index tracking the Zikr item).

- [ ] **Step 2: Commit**

```bash
git add lib/features/tasbih/presentation/bloc/tasbih_bloc.dart
git commit -m "feat: add changeItem event to TasbihBloc"
```

### Task 2: Implement Navigation Arrows in TasbihView

**Files:**
- Modify: `lib/features/tasbih/presentation/pages/tasbih_page.dart`

- [ ] **Step 1: Add state for index**

If not already available in state, ensure `TasbihView` can access current index of the Zikr.

- [ ] **Step 2: Modify build method in TasbihView**

Wrap the body content in a `Stack` to add arrow buttons:

```dart
Stack(
  children: [
    // Existing content ...
    
    // Navigation arrows
    if (state.currentCycleIndex > 0)
      PositionedDirectional(
        start: 4, top: 0, bottom: 0,
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.read<TasbihBloc>().add(TasbihEvent.changeItem(state.currentCycleIndex - 1)),
          ),
        ),
      ),
    if (state.currentCycleIndex < state.currentCategory.items.length - 1)
      PositionedDirectional(
        end: 4, top: 0, bottom: 0,
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => context.read<TasbihBloc>().add(TasbihEvent.changeItem(state.currentCycleIndex + 1)),
          ),
        ),
      ),
  ],
)
```

- [ ] **Step 3: Run analysis**

Run: `flutter analyze`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/tasbih/presentation/pages/tasbih_page.dart
git commit -m "feat: add navigation arrows to TasbihPage"
```
