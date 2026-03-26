# Branch Synchronization & Feature Integration Strategy

## Objective
Merge the best features and fixes from multiple experimental branches (`feature/sccroll_to_ayah`, `fix/scrolling-stable-base`, `temp-restore-service-files`) into a unified, stable `develop` branch.

## Branch Analysis

### 1. `temp-restore-service-files` (Current Focus)
- **Goal**: Restore foundational background and asset migration services.
- **Status**: Stable baseline with critical services (`BackgroundService`, `MigrationService`) and audio entities restored.
- **Unique Assets**: Robust Workmanager integration and verified asset migration path.

### 2. `fix/scrolling-stable-base` (Target Integration)
- **Goal**: Resolve scrolling performance and layout stability issues.
- **Status**: Contains the stable `AyahText` widget (no `AyahBlockWidget` refactor).
- **Unique Assets**: Optimized reader stability, scroll controller fixes.

### 3. `feature/sccroll_to_ayah`
- **Goal**: Implement scroll-to-ayah functionality.
- **Status**: Experimental. Needs review for compatibility with the stable base.
- **Unique Assets**: Scroll-to-ayah logic.

## Integration Plan

### Phase 1: Stabilization (Current Session)
- Finish resolving dependency injection and type errors in the audio feature.
- Confirm all tests pass on the current `temp-restore-service-files` base.

### Phase 2: Feature Merging
1. **Merge Stable Base**: Merge `fix/scrolling-stable-base` into `temp-restore-service-files` to ensure scrolling stability is prioritized.
2. **Feature Porting**: Port the "Scroll to Ayah" logic from `feature/sccroll_to_ayah` into the new stable base.
3. **Regression Testing**: Execute the `integration_test/` suite specifically for the Reader flow.

### Phase 3: Final Integration
- Merge the synchronized `temp-restore-service-files` into the main `develop` branch.
- Perform a final cleanup of temporary files (`test/repro_*`) and regenerate DI code.

## Best Practices for Integration
- **Preserve Tests**: Never overwrite existing tests. Merge logic must include the test coverage from both branches.
- **Surgical Merges**: Use `git checkout -p` to selectively bring in features from experimental branches to minimize conflict footprint.
- **Verification**: Run `flutter analyze` after every merge commit.
