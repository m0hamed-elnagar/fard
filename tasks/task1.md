# Task 1: Infrastructure & DI Fixes

**Context:**
The Fard project has 50 failing tests, with initial focus on DI registration and plugin mocking.

**Task:**
1. In `test/features/onboarding/splash_screen_test.dart`: Register `AudioDownloadService` in the `setUp` method of the test using `sl.registerLazySingleton<AudioDownloadService>(() => MockAudioDownloadService());`.
2. Ensure `MockAudioDownloadService` is implemented as a class that implements `AudioDownloadService` (or `Mock`).

**Code Quality:** Ensure mocks are clean and registration is idiomatic.

**Deliverable:**
- Modified test files with DI and Mock fixes.
- Run tests to verify the specific failures for Task 1 are resolved.
