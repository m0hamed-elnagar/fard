import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HomeHero extends StatelessWidget {
  final Map<Salaah, MissedCounter> qadaStatus;
  final DateTime selectedDate;
  final String locale;
  final String? cityName;
  final bool isQadaEnabled;
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onLocationTap;

  const HomeHero({
    super.key,
    required this.qadaStatus,
    required this.selectedDate,
    required this.locale,
    this.cityName,
    this.isQadaEnabled = true,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalQada = qadaStatus.values.fold(0, (sum, counter) => sum + counter.value);
    final hijriDate = selectedDate.toHijriDate(locale);

    return Container(
      width: double.infinity,
      color: AppTheme.background,
      child: Column(
        children: [
          Stack(
            children: [
              // 1. Authentic Islamic Background with Dome & Minarets
              ClipPath(
                clipper: IslamicMosqueClipper(),
                child: Container(
                  height: isQadaEnabled ? 480 : 380, // Reduced height when Qada is disabled
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF064E3B), // Emerald Green Dark
                        Color(0xFF065F46), // Emerald Green Medium
                        Color(0xFF047857), // Emerald Green Light
                      ],
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: GeometricPatternPainter(),
                    ),
                  ),
                ),
              ),
              
              // 2. Content Column - Using a Column inside the stack for vertical flow
              // but we'll use Positioned.fill to ensure it spans the whole height
              Positioned.fill(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // App Bar Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.appName,
                            style: GoogleFonts.amiri(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _LocationChip(
                            cityName: cityName,
                            onTap: onLocationTap,
                            l10n: l10n,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Crescent Icon at top of Dome
                    const Icon(Icons.nightlight_round, color: AppTheme.accent, size: 28),
                    const SizedBox(height: 8),
                    
                    if (isQadaEnabled) ...[
                      // Debt Info
                      Text(
                        l10n.totalQada,
                        style: GoogleFonts.amiri(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 22,
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
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        l10n.localeName == 'ar' ? 'صلوات مفروضة لإكمالها' : 'Fard Prayers to Complete',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ModernActionButton(
                            icon: Icons.add_circle_outline_rounded,
                            label: l10n.add,
                            onPressed: onAddPressed,
                          ),
                          const SizedBox(width: 16),
                          _ModernActionButton(
                            icon: Icons.edit_note_rounded,
                            label: l10n.edit,
                            onPressed: onEditPressed,
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 40),
                      Text(
                        l10n.appName,
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    const Spacer(),
                    // Date & Hijri - Positioned carefully above the cards
                    Container(
                      margin: EdgeInsets.only(bottom: isQadaEnabled ? 12 : 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat.yMMMMEEEEd(locale).format(selectedDate),
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            hijriDate,
                            style: GoogleFonts.amiri(
                              color: AppTheme.accent,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // This padding ensures we don't overlap with the cards at the very bottom
                    SizedBox(height: isQadaEnabled ? 80 : 20),
                  ],
                ),
              ),
              
              // 3. Prayer Cards - Floating perfectly at the bottom
              if (isQadaEnabled)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: Salaah.values.map((salaah) {
                      return _TraditionalPrayerCard(
                        salaah: salaah,
                        count: qadaStatus[salaah]?.value ?? 0,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String? cityName;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _LocationChip({
    this.cityName,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = cityName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasLocation ? Colors.white24 : AppTheme.missed.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasLocation ? Icons.location_on_rounded : Icons.location_off_rounded,
              size: 12,
              color: hasLocation ? AppTheme.accent : AppTheme.missed,
            ),
            const SizedBox(width: 4),
            Text(
              cityName ?? l10n.locationNotSet,
              style: TextStyle(
                color: hasLocation ? Colors.white : AppTheme.missed,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraditionalPrayerCard extends StatelessWidget {
  final Salaah salaah;
  final int count;

  const _TraditionalPrayerCard({
    required this.salaah,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 5.2,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            salaah.localizedName(l10n),
            style: GoogleFonts.amiri(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class IslamicMosqueClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final baseH = h * 0.95;

    path.moveTo(0, h);
    path.lineTo(w, h);
    path.lineTo(w, baseH);

    // Right Minaret
    path.lineTo(w * 0.95, baseH);
    path.lineTo(w * 0.95, baseH - 120);
    path.lineTo(w * 0.92, baseH - 130); // Tip
    path.lineTo(w * 0.89, baseH - 120);
    path.lineTo(w * 0.89, baseH);
    
    // Shoulder to Dome
    path.lineTo(w * 0.8, baseH);
    path.quadraticBezierTo(w * 0.8, baseH - 80, w * 0.5, baseH - 120); // Dome peak
    path.quadraticBezierTo(w * 0.2, baseH - 80, w * 0.2, baseH);

    // Left Minaret
    path.lineTo(w * 0.11, baseH);
    path.lineTo(w * 0.11, baseH - 120);
    path.lineTo(w * 0.08, baseH - 130); // Tip
    path.lineTo(w * 0.05, baseH - 120);
    path.lineTo(w * 0.05, baseH);
    
    path.lineTo(0, baseH);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 5, paint);
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 10, height: 10), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
