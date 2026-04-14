import 'package:injectable/injectable.dart';

import '../../../../../core/theme/theme_presets.dart' show ThemePresets;
import '../entities/theme_preset.dart';

/// Use case: Returns all available theme presets.
@injectable
class GetAvailableThemePresets {
  GetAvailableThemePresets();

  /// Returns list of all available theme presets.
  List<ThemePreset> execute() {
    return ThemePresets.all;
  }
}
