# Offline-First Library & Download Management Progress

## Objective
Enable a seamless offline experience by making the app automatically adapt to connectivity, provide a "Stop" control for batch downloads, and add confirmation for bulk actions.

## Tasks & Progress
- [x] 1. Add `connectivity_plus` dependency.
- [x] 2. Create `ConnectivityService` and `ConnectivityBloc`.
- [x] 3. Update `QuranPage`/`AudioScreen` for reactive UI.
- [x] 4. Implement confirmation dialogs for bulk downloads.
- [x] 5. Implement "Stop" functionality in `AudioDownloadService` and `MushafDownloadService`.
- [x] 6. Prune partial files on cancellation.
- [x] 7. Update repository to cache Surah metadata locally.
- [x] 8. Set default download quality to Low (64kbps).

## Verification Checklist
- [x] Offline Test (QuranPage auto-switches)
- [x] Download Test (Stop clears queue/partial files)
- [x] Playback Test (Works offline for downloaded content)
- [x] UI Test (Confirmation dialog present)
- [x] Default Quality Test (Downloads use 64kbps by default)
