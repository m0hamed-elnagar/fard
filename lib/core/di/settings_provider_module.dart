// This module is intentionally disabled.
// SettingsCubit and SettingsProvider are manually registered in configure_dependencies.dart
// to avoid circular dependency issues with injectable.
//
// SettingsCubit depends on NotificationService
// NotificationService depends on SettingsProvider (which is SettingsCubit)
//
// This circular dependency cannot be resolved by injectable automatically.

// @module
// abstract class SettingsProviderModule {
//   @injectable
//   SettingsProvider provideSettingsProvider(SettingsCubit settingsCubit) {
//     return settingsCubit;
//   }
// }
