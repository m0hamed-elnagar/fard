# Azan Sound Fix Tasks

## Phase 1: Diagnostics & Analysis
- [x] Read and analyze current `NotificationService` implementation. <!-- id: 0 -->
- [x] Read and analyze current `VoiceDownloadService` implementation. <!-- id: 1 -->
- [x] Run existing tests to see current state. <!-- id: 2 -->

## Phase 2: Fix Channel Management
- [x] Implement deterministic, unique channel IDs in `NotificationService`. <!-- id: 3 -->
- [x] Implement `_ensureChannelExists` logic to handle channel updates. <!-- id: 4 -->
- [x] Implement proper URI formatting for downloaded files. <!-- id: 5 -->

## Phase 3: Fix Notification Scheduling
- [x] Update `_scheduleAzan` to use the new channel management. <!-- id: 6 -->
- [x] Fix logic for `RawResourceAndroidNotificationSound` vs `UriAndroidNotificationSound`. <!-- id: 7 -->
- [x] Add consistent `AudioAttributesUsage.alarm` and `AndroidNotificationCategory.alarm`. <!-- id: 8 -->

## Phase 4: File Access & Fallbacks
- [x] Update `VoiceDownloadService` to ensure files are in accessible locations. <!-- id: 9 -->
- [x] Implement fallback to default raw resource if custom sound fails. <!-- id: 10 -->
- [x] (Optional) Implement FileProvider if `file://` URIs continue to fail on Android 7+. <!-- id: 11 -->

## Phase 5: Verification & Testing
- [x] Update `test/core/services/notification_service_test.dart` with new logic. <!-- id: 12 -->
- [x] Update `test/core/services/notification_sound_test.dart` with new logic. <!-- id: 13 -->
- [x] Add runtime diagnostics tool to `NotificationService`. <!-- id: 14 -->
- [x] Verify all tests pass. <!-- id: 15 -->
