import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';
import '../../features/settings/presentation/blocs/location_prayer_cubit.dart';

class LocationDialogHelper {
  static void showLocationStatusDialog(
    BuildContext context,
    LocationStatus status,
  ) {
    if (status == LocationStatus.success) return;

    final l10n = AppLocalizations.of(context)!;
    String title = '';
    String desc = '';
    String primaryBtnLabel = l10n.tryAgain;
    VoidCallback onPrimary = () =>
        context.read<LocationPrayerCubit>().refreshLocation();

    switch (status) {
      case LocationStatus.serviceDisabled:
        title = l10n.locationDisabledTitle;
        desc = l10n.locationDisabledDesc;
        primaryBtnLabel = l10n.enableGPS;
        onPrimary = () =>
            context.read<LocationPrayerCubit>().openLocationSettings();
        break;
      case LocationStatus.denied:
        title = l10n.locationDeniedTitle;
        desc = l10n.locationDeniedDesc;
        break;
      case LocationStatus.deniedForever:
        title = l10n.locationDeniedForeverTitle;
        desc = l10n.locationDeniedForeverDesc;
        primaryBtnLabel = l10n.openSettings;
        onPrimary = () => context.read<LocationPrayerCubit>().openAppSettings();
        break;
      default:
        title = l10n.errorOccurred;
        desc = l10n.errorOccurred;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Text(desc, style: GoogleFonts.amiri()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.later),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onPrimary();
            },
            child: Text(primaryBtnLabel),
          ),
        ],
      ),
    );
  }
}
