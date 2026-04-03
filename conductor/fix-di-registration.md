# Fix DI Registration for IAzkarSource

## Objective
Resolve the runtime error `Bad state: GetIt: Object/factory with with name IAzkarSource and type IAzkarSource is not registered inside GetIt` by aligning the registration and injection of `IAzkarSource`.

## Key Files & Context
- `lib/core/services/notification/prayer_scheduler.dart`: Currently requests `IAzkarSource` with `@Named.from(IAzkarSource)`.
- `lib/features/azkar/data/azkar_repository.dart`: Implementation of `IAzkarSource`.

## Implementation Steps
1. **Modify `lib/core/services/notification/prayer_scheduler.dart`**:
   - Remove `@Named.from(IAzkarSource)` from the constructor to allow standard type-based injection.
2. **Modify `lib/features/azkar/data/azkar_repository.dart`**:
   - Remove `@Named.from(IAzkarSource)` to keep registration simple and consistent with other services.
3. **Regenerate Dependencies**:
   - Run `dart run build_runner build --delete-conflicting-outputs`.

## Verification & Testing
1. **Static Analysis**: Run `flutter analyze` to ensure no new errors.
2. **Launch App**: Run `flutter run -d RZCW70BM8PE` and verify the app starts without the `GetIt` registration exception.
