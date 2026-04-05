import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use case: Toggles the global "after-salah azkar" setting and propagates
/// the change to all individual prayer (Salaah) settings.
///
/// This is coordination/orchestration logic that does NOT belong in the
/// repository (which should be persistence-only).
@injectable
class ToggleAfterSalahAzkarUseCase {
  final SettingsRepository _settingsRepo;

  ToggleAfterSalahAzkarUseCase(this._settingsRepo);

  /// Toggles the global flag and updates all individual salaah settings.
  /// Returns the new value.
  Future<bool> execute() async {
    // 1. Read current state
    final currentFlag = _settingsRepo.isAfterSalahAzkarEnabled;
    final newValue = !currentFlag;

    // 2. Persist the global toggle
    await _settingsRepo.updateAfterSalahAzkarEnabled(newValue);

    // 3. Propagate to all individual salaah settings
    final updatedSalaahSettings = _settingsRepo.salaahSettings
        .map((s) => s.copyWith(isAfterSalahAzkarEnabled: newValue))
        .toList();
    await _settingsRepo.updateSalaahSettings(updatedSalaahSettings);

    return newValue;
  }
}
