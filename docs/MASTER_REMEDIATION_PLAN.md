# Master Remediation Plan (v2)

## ⏩ RESUME PROMPT
*Copy and paste the following into a new session to resume this work:*
---
Project: fard-2 (Flutter)
Current State: Restoration phase complete. MASTER_REMEDIATION_PLAN.md created.
Objective: Start Session 1 (Reader Test Alignment). 
Branch: temp-restore-service-files
Goal: Replace AyahBlockWidget with AyahText in all tests.
---

## Objective
Systematically eliminate all 130+ analysis errors and stabilize the `temp-restore-service-files` branch for merging into `develop`.

## Session Strategy

### Session 1: Reader Test Alignment (High Priority)
**Goal:** Replace all remaining references to `AyahBlockWidget` with the stable `AyahText` in the test suite.
**Files:**
- `integration_test/werd_ux_test.dart`
- `integration_test/quran_rtl_numbering_test.dart`
- `test/features/quran/presentation/widgets/ayah_icons_position_test.dart`
- `test/features/quran/presentation/widgets/ayah_text_test.dart`
- `test/features/quran/presentation/widgets/reader_jump_buttons_test.dart`
- `test/widgets/ayah_text_test.dart`

### Session 2: Audio Service Stabilization
**Goal:** Ensure `AudioDownloadServiceImpl` and `AudioRepositoryImpl` are fully synchronized with the restored `AudioRepository` interface.
**Files:**
- `lib/features/audio/data/services/audio_download_service_impl.dart`
- `lib/features/audio/data/repositories/audio_repository_impl.dart`
- `lib/features/audio/domain/entities/audio_track.dart`

### Session 3: Dependency Injection & Generated Code
**Goal:** Resolve all "unregistered type" warnings and "ambiguous extension" errors in Bloc logic.
**Files:**
- `lib/core/di/configure_dependencies.dart`
- `lib/features/quran/presentation/blocs/reader_bloc.dart`
- `test/repro_mixing.dart`

### Session 4: Cleanup & Final Validation
**Goal:** Remove obsolete repro tests and perform a full project analysis.
**Actions:**
- Delete `test/repro_*` files that are no longer relevant.
- Run `flutter analyze` on the entire project.
- Run all integration tests.

---

## Progress Tracker
- [ ] Session 1: Reader Test Alignment
- [ ] Session 2: Audio Service Stabilization
- [ ] Session 3: Dependency Injection
- [ ] Session 4: Cleanup
