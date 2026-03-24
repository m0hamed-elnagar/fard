# Context for Qada Logic Regression
The Qada calculation is currently suffering from a double-counting bug during the transition from "acknowledging missed days" (which saves a record for today) to the subsequent `load()` event (which triggers `_onLoad`).

## The Core Rule
In `_onLoad`, if `record != null` (meaning today's record exists, likely created by `_onAcknowledgeMissedDays`):
1. **TRUST THE RECORD**: Use `record.missedToday`, `record.completedToday`, and `record.qada` directly.
2. **NO MODIFICATION**: Do not re-run `_prayerTimeService.isPassed()` or attempt to add/increment Qada.
3. **ONLY IF `record == null`**: Derive `missedToday` via `isPassed()`, calculate initial `qada`, and save.

## Current Status
- `_onAcknowledgeMissedDays` correctly handles the gap days and saves the record for "today".
- `_onLoad` still attempts some logic when `record != null`, which causes the observed `11 vs 10` and `12 vs 13` discrepancies in `test/repro_missed_days_test.dart`.

## Next Step
Implement the strict "Trust the record if it exists" logic in `_onLoad` and remove all logic that attempts to modify `qada` when `record != null`.
