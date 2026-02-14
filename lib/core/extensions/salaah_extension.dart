import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/l10n/app_localizations.dart';

extension SalaahLocalization on Salaah {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case Salaah.fajr:
        return l10n.fajr;
      case Salaah.dhuhr:
        return l10n.dhuhr;
      case Salaah.asr:
        return l10n.asr;
      case Salaah.maghrib:
        return l10n.maghrib;
      case Salaah.isha:
        return l10n.isha;
    }
  }
}
