# Implementation Plan: Fix Audio Download 99% Stall

## Objective
The goal is to fix the audio download stall that leaves the UI at 99% by implementing a robust verification test for `isValidAudioFile` and ensuring `AudioDownloadService` handles the final completion state definitively.

## Background & Motivation
The user reports that large surahs (like Surah 2) stall at 99% instead of reaching 100%. Analysis indicates this is a discrepancy between file verification and UI progress reporting.

## Implementation Steps

### 1. Create Integrity Verification Test
- Add a new test file `test/features/audio/audio_integrity_test.dart` to verify `FileDownloadUtils.isValidAudioFile`.
- Test cases:
    - Non-existent file.
    - Empty file (0 bytes).
    - Corrupted file (invalid syncword).
    - Valid MP3 file (valid size and syncword).

### 2. Audit Completion Logic
- Review `AudioDownloadServiceImpl` (specifically the sequential cleanup pass).
- Verify that `verifiedCount == totalFiles` is the only path to `isCompleted: true`.
- Ensure that if `verifiedCount < totalFiles`, we provide an explicit `_emitError` to the UI, triggering the retry button, rather than leaving it in an ambiguous state.

### 3. Verification & Testing
- Run `flutter test test/features/audio/audio_integrity_test.dart`.
- Verify the 99% stall is resolved by triggering a download and checking if the icon correctly updates to a checkmark upon completion.

## Verification
- Confirm that the UI reports 100% completion (or a clear error) instead of 99%.
- Verify that all surahs, especially Surahs 2 and 3, complete their download and mark as downloaded.
