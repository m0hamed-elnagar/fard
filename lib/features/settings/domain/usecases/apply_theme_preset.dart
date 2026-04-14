import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use case: Applies a theme preset and persists the selection.
///
/// Input: [String] presetId - The ID of the theme preset to apply
@injectable
class ApplyThemePreset {
  final SettingsRepository _settingsRepo;

  ApplyThemePreset(this._settingsRepo);

  /// Applies the theme preset.
  Future<void> execute(String presetId) async {
    await _settingsRepo.updateThemePreset(presetId);
  }
}
