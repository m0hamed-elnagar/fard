import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class HomeAppBar extends StatelessWidget {
  final DateTime selectedDate;
  final String locale;
  final String? cityName;

  const HomeAppBar({
    super.key,
    required this.selectedDate,
    required this.locale,
    this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hijriDate = selectedDate.toHijriDate(locale);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.appName,
                    style: GoogleFonts.amiri(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (cityName != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cityName!,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMMEEEEd(locale).format(selectedDate),
              style: GoogleFonts.outfit(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              hijriDate,
              style: GoogleFonts.amiri(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (cityName == null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_off_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.locationNotSet,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
