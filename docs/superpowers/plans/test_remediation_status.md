# Test Failure Tracking & Remediation - Session Persistence
Date: 2026-04-18
Branch: `feature/test-remediation`
Worktree: `C:/Users/NAGAR/IdeaProjects/fard-2/.worktrees/test-remediation`

## Summary
- **Initial Failures:** 50
- **Current Failures:** 16
- **Resolved:** `WerdRepository` (Business logic), `WidgetPreview` widgets, partial `SetWerdGoalDialog` fixes.

## Failing Tests Categorization
| Category | Failure Count | Status | Notes |
| :--- | :--- | :--- | :--- |
| **Onboarding/Splash** | 2/2 | PENDING | Investigating Bloc state propagation. |
| **Settings** | 10/18 | IMPROVED | Some failures resolved. |
| **Quran/Werd Dialogs** | 4/10 | IMPROVED | 3 failures addressed in `set_werd_goal_dialog_test.dart`. |

## Next Task Priority
1. **Quran/Werd (Medium):** Address finder failures in `set_werd_goal_dialog_test.dart` (UI lookup issues for remaining Arabic text).
2. **Settings (High):** Resolve RTL/localization failures in `widget_preview_widget_test.dart`.
3. **Onboarding/Splash (Critical):** Fix `MockSettingsCubit` initialization in `splash_screen_test.dart`.

## Context for Resuming
- **Current Issue:** 16 tests are failing due to UI lookup errors (finders failing to find text/widgets).
- **Hypothesis:** Dropdown items/Arabic text in `SetWerdGoalDialog` aren't being pumped or located correctly in tests despite proper DI.
- **Next Step:** Investigate why `Al-Fatihah` and numeric text aren't being found in `SetWerdGoalDialog` tests, likely related to `pumpAndSettle` timing for dropdowns.


---

### Resume Prompt
Copy and paste the following into the next session:

"I am resuming the restoration phase of the Fard app. Current state: 49/523 tests failing. We have fixed the `WerdRepository` logic. The current focus is the `splash_screen_test.dart` failing with a `_TypeError: type 'Null' is not a subtype of type 'SettingsState'`. Please refer to `docs/superpowers/plans/test_remediation_status.md` for the current failure breakdown and resume addressing the Splash Screen failures."
