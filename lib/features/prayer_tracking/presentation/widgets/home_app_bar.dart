import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

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
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _MosqueIcon(),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    l10n.appName,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textPrimary,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52.0, top: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMEEEEd(locale).format(selectedDate),
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    hijriDate,
                    style: GoogleFonts.amiri(
                      color: AppTheme.accent,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (cityName != null)
              Padding(
                padding: const EdgeInsets.only(left: 52.0),
                child: Text(
                  cityName!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.0,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 52.0, top: 4.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.location_off_rounded, size: 14, color: AppTheme.missed),
                      const SizedBox(width: 4),
                      Text(
                        l10n.locationNotSet,
                        style: const TextStyle(
                          color: AppTheme.missed,
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

class _MosqueIcon extends StatelessWidget {
  const _MosqueIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryLight,
            AppTheme.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Icon(Icons.mosque_rounded, color: AppTheme.onPrimary, size: 22.0),
    );
  }
}
