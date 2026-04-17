# Quran Download Manifest Implementation Plan

## Goal
Replace inconsistent filesystem-based download tracking with a robust, database-backed `DownloadManifest` system using Hive. This resolves the 99% stall issue, enables resumable downloads, and provides instantaneous status checks.

## Proposed Architecture

### 1. Data Model: `DownloadEntry`
Stored in a dedicated Hive box `download_manifest_box`.

```dart
enum DownloadStatus {
  pending,      // 0
  downloading,  // 1
  completed,    // 2
  failed,       // 3
  paused        // 4
}

@HiveType(typeId: HiveTypeId.downloadEntry)
class DownloadEntry {
  @HiveField(0)
  final String fileId; // Unique key: e.g., "audio_husary_001_001" or "mushaf_page_001"

  @HiveField(1)
  final String relativePath; // Relative to app support dir: "audio/husary/001001.mp3"

  @HiveField(2)
  final String? checksum; // MD5 or SHA-256 for integrity verification

  @HiveField(3)
  final int expectedSize; // Expected file size from server header

  @HiveField(4)
  final int downloadedBytes; // For resumable Range requests

  @HiveField(5)
  final int statusIndex; // Maps to DownloadStatus enum

  @HiveField(6)
  final DateTime updatedAt; // Last status/progress change

  @HiveField(7)
  final String? errorMessage; // Last failure details

  @HiveField(8)
  final int attemptCount; // For retry backoff logic

  @HiveField(9)
  final String reciterId; // "husary", "minshawi", or "mushaf" for scoping

  @HiveField(10)
  final String contentType; // "audio" | "mushaf_page"

  @HiveField(11)
  final String url; // The original source URL for resumption resilience
}
```

### 2. Granularity: Per-Ayah (Confirmed)
The system will track at the **Ayah level** (~6,236 entries per reciter). 
- **Pros**: Fine-grained progress reporting, resumable per-ayah, handles "mixed" states (where a surah is 80% downloaded).
- **Memory**: 6,000 entries in Hive is manageable (< 2MB in RAM), but we will monitor memory on low-end devices.

## Implementation Steps

### Phase 1: Core Infrastructure
1.  **Define Model**: Create `lib/features/audio/data/models/download_entry.dart`.
2.  **Generate Adapter**: Run `build_runner` to generate Hive adapters.
3.  **Register Box**: Update `lib/main.dart` or `HiveRegistrar` to open `download_manifest_box`.
4.  **Manifest Service**: Create `DownloadManifestService` with the following interface:
    ```dart
    abstract class DownloadManifestService {
      Future<DownloadEntry?> getEntry(String fileId);
      Future<void> upsertEntry(DownloadEntry entry);
      Future<List<DownloadEntry>> getEntriesByStatus(DownloadStatus status);
      Future<List<DownloadEntry>> getEntriesByReciter(String reciterId);
      Future<void> clearAll(); 
      Future<void> verifyIntegrity(String fileId);
      Stream<DownloadEntry?> watchEntry(String fileId); // Driven by Hive .watch()
    }
    ```

### Phase 2: Refactoring Services
1.  **Audio Service**: Refactor `AudioDownloadServiceImpl` to check manifest before downloading and update it during progress.
2.  **Mushaf Service**: Refactor `MushafDownloadService` to leverage the manifest for page status and batch downloads.
3.  **Cleanup Logic**: Implement safe `clearCache()`:
    - Mark entries as `pending` in DB.
    - Delete physical files.
    - Clear DB entries.

### Phase 3: UI & Verification
1.  **Progress Reporting**: Shift from ephemeral `StreamController` to manifest-backed streams where appropriate.
2.  **Integrity Test**: Implement the test described in `fix_offline_download.md` using the manifest's `expectedSize`.

## Verification & Testing
- **Unit Test**: `test/features/audio/download_manifest_test.dart` for DB operations.
- **Integration Test**: Kill app mid-download of Surah 2 and verify it resumes from the exact `downloadedBytes` using `Range` headers.
- **Verification**: Ensure the "99% stall" is impossible because the manifest only marks `completed` after successful `isValidAudioFile` verification.

## Verdict: Importance
**High.** This is the definitive fix for the reported download stalls and provides the underlying architecture for a professional, resumable offline experience.
