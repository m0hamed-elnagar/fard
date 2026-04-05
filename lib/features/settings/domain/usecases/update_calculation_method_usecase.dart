import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use case: Updates the prayer calculation method and applies
/// the corresponding Hijri calendar adjustment automatically.
@injectable
class UpdateCalculationMethodUseCase {
  final SettingsRepository _settingsRepo;

  UpdateCalculationMethodUseCase(this._settingsRepo);

  /// Updates the method and returns the computed Hijri adjustment.
  Future<int> execute(String method) async {
    await _settingsRepo.updateCalculationMethod(method);

    final adjustment = _computeHijriAdjustment(method);
    await _settingsRepo.updateHijriAdjustment(adjustment);

    return adjustment;
  }

  int _computeHijriAdjustment(String method) {
    if (method == 'umm_al_qura') return 0;
    if (method == 'karachi' || method == 'muslim_league') return 1;
    return 0;
  }
}
