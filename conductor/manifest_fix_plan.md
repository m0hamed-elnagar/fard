# Plan: Fix Quran Audio Download Manifest Logic

## Current Problem
The `DownloadManifestServiceImpl` incorrectly marks partially downloaded files as `pending` (resetting progress) because `isValidAudioFile` only returns `true` for *complete* files. This causes constant download restarts and inaccurate progress tracking.

## Implementation Steps

1. **Service Utility Update (`FileDownloadUtils`)**:
   - Add `static Future<int> getExistingFileSizeBytes(String path)` to safely get the current size of a partially downloaded file without integrity checks.

2. **Sync Logic Update (`AudioDownloadServiceImpl._syncManifestForSurah`)**:
   - Update `_syncManifestForSurah` to:
     - Use `getExistingFileSizeBytes` to set the `downloadedBytes` for partial files.
     - Change logic: If a file exists and is not complete, set status to `DownloadStatus.paused` (or `downloading`) instead of `pending`.
     - Remove the 250KB hardcoded fallback estimate; use server header info or actual file length.

3. **Verification**:
   - Add a test in `test/core/services/download/download_manifest_test.dart` that simulates a partial file (e.g., 50KB exists, expected 200KB) and ensures the `DownloadEntry` status is `paused` and `downloadedBytes` matches the file length.

4. **Integration**:
   - Ensure the UI listens to the Hive box for status updates to reflect resumed state automatically.
