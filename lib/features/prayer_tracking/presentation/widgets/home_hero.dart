import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class HomeHero extends StatelessWidget {
  final Map<Salaah, MissedCounter> qadaStatus;
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;

  const HomeHero({
    super.key,
    required this.qadaStatus,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalQada = qadaStatus.values.fold(0, (sum, counter) => sum + counter.value);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F6F1), // Cream background
      child: Stack(
        children: [
          ClipPath(
            clipper: DomeClipper(),
            child: Container(
              height: 340,
              width: double.infinity,
              color: const Color(0xFF006064), // Teal color
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l10n.totalQada,
                    style: GoogleFonts.amiri(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    totalQada.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.localeName == 'ar' ? 'صلوات مفروضة لإكمالها' : 'Fard Prayers to Complete',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: Salaah.values.map((salaah) {
                  return _PrayerCard(
                    salaah: salaah,
                    count: qadaStatus[salaah]?.value ?? 0,
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
              onPressed: onEditPressed,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.add_box_rounded, color: Colors.white),
              onPressed: onAddPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final Salaah salaah;
  final int count;

  const _PrayerCard({
    required this.salaah,
    required this.count,
  });

  IconData _getIcon(Salaah salaah) {
    switch (salaah) {
      case Salaah.fajr:
        return Icons.nightlight_round;
      case Salaah.dhuhr:
        return Icons.mosque;
      case Salaah.asr:
        return Icons.wb_sunny;
      case Salaah.maghrib:
        return Icons.auto_awesome;
      case Salaah.isha:
        return Icons.nights_stay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 5,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(salaah), size: 24, color: const Color(0xFF006064)),
          const SizedBox(height: 4),
          Text(
            salaah.localizedName(l10n),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF006064),
            ),
          ),
          Text(
            count.toString(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF006064),
            ),
          ),
        ],
      ),
    );
  }
}

class DomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;
    double domeTop = 0;
    double sideHeight = height * 0.7;

    path.moveTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, sideHeight);
    
    // Dome shoulders
    path.quadraticBezierTo(width, sideHeight - 40, width * 0.85, sideHeight - 60);
    path.quadraticBezierTo(width * 0.7, sideHeight - 80, width * 0.5, domeTop);
    path.quadraticBezierTo(width * 0.3, sideHeight - 80, width * 0.15, sideHeight - 60);
    path.quadraticBezierTo(0, sideHeight - 40, 0, sideHeight);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
