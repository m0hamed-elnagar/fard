# Plan: Fix Failed Tests in PrayerTrackerBloc

## Objective
Identify and resolve the test failures in `test/prayer_tracker_bloc_test.dart` and investigate the root cause of the Qada double-counting logic regression.

## Key Files & Context
- `test/prayer_tracker_bloc_test.dart`: Primary target for testing.
- `lib/features/prayer_tracking/domain/blocs/prayer_tracker_bloc.dart`: Likely source of the Qada logic regression (implied by `docs/fix_qada_logic.md`).
- `docs/fix_qada_logic.md`: Describes the known issue with double-counting.

## Implementation Steps
1. **Reproduce Failures**:
   - Run `flutter test test/prayer_tracker_bloc_test.dart` to confirm the specific failing test cases.
   - Analyze the stack traces and error messages.
2. **Investigate Root Cause**:
   - Trace the logic in `PrayerTrackerBloc._onCheckMissedDays` and `_onAcknowledgeMissedDays`.
   - Use debugging logs to monitor state changes.
3. **Draft Fix**:
   - Decouple "today" handling from gap day processing as suggested by the project memory.
4. **Verification**:
   - Run `flutter test` for `prayer_tracker_bloc_test.dart` to verify the fix.
   - Run `flutter analyze` to ensure no new errors were introduced.
5. **Regression Testing**:
   - Run `test/missed_counter_test.dart` and `test/qada_scenarios_test.dart` to ensure no side effects on related features.

## Verification & Testing
- Automated testing using existing BLoC tests.
- Manual verification of the "acknowledge missed days" flow via integration tests if needed.
