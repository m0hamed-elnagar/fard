import 'package:fard/features/settings/domain/repositories/settings_repository.dart';

/// Utility functions for RTL (Right-to-Left) text handling.
///
/// These functions ensure that RTL text (like Arabic) is displayed correctly
/// across all platforms by adding Unicode RTL marks.
class RtlTextUtil {
  /// Unicode Right-to-Left Mark (U+200F)
  static const String _rlm = '\u200F';

  /// Right-to-Left Embedding (U+202B)
  static const String _rle = '\u202B';

  /// Pop Directional Formatting (U+202C)
  static const String _pdf = '\u202C';

  /// Applies RTL formatting to text if the current locale is RTL (e.g., Arabic).
  ///
  /// Uses Right-to-Left Mark (U+200F) + Right-to-Left Embedding (U+202B)
  /// to ensure the entire string is treated as RTL and aligned correctly.
  ///
  /// [text] The text to format
  /// [isRtl] Whether the current locale is RTL (e.g., locale.languageCode == 'ar')
  static String applyRtl(String text, {required bool isRtl}) {
    if (isRtl) {
      return '$_rlm$_rle$text$_pdf';
    }
    return text;
  }

  /// Applies RTL formatting based on a [SettingsRepository] locale.
  static String applyRtlFromSettings(String text, SettingsRepository settings) {
    final isRtl = settings.locale.languageCode == 'ar';
    return applyRtl(text, isRtl: isRtl);
  }
}
