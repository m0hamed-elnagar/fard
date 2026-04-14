import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use case: Saves custom theme colors and persists them.
///
/// Input: [Map<String, String>] colors - Hex color values for custom theme
@injectable
class SaveCustomTheme {
  final SettingsRepository _settingsRepo;

  SaveCustomTheme(this._settingsRepo);

  /// Saves custom theme colors and sets theme preset to 'custom'.
  Future<void> execute(Map<String, String> colors) async {
    // 1. Save custom colors
    await _settingsRepo.saveCustomTheme(colors);

    // 2. Set theme preset to custom
    await _settingsRepo.updateThemePreset('custom');
  }
}
