import 'dart:math' as math;
import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      child: Stack(
        children: [
          // 1. Authentic Islamic Background with Dome & Minarets
          Positioned.fill(
            child: ClipPath(
              clipper: IslamicMosqueClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF064E3B), // Emerald Green Dark
                      Color(0xFF065F46), // Emerald Green Medium
                      Color(0xFF047857), // Emerald Green Light
                    ],
                  ),
                ),
                child: Opacity(
                  opacity: 0.08,
                  child: CustomPaint(
                    painter: IslamicGeometricPatternPainter(),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Content Column
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isQadaEnabled ? 460 : 360,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
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
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      _LocationChip(
                        cityName: cityName,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onLocationTap();
                        },
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
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      shadows: [
                        Shadow(
                          color: AppTheme.accent.withValues(alpha: 0.5),
                          blurRadius: 20,
                        ),
                      ],
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
                  const SizedBox(height: 24),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ModernActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: l10n.add,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onAddPressed();
                        },
                      ),
                      const SizedBox(width: 16),
                      _ModernActionButton(
                        icon: Icons.edit_note_rounded,
                        label: l10n.edit,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onEditPressed();
                        },
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

                const SizedBox(height: 40),
                
                // Date & Hijri
                Container(
                  margin: EdgeInsets.only(bottom: isQadaEnabled ? 12 : 32),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.yMMMMEEEEd(locale).format(selectedDate),
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hijriDate,
                        style: GoogleFonts.amiri(
                          color: AppTheme.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isQadaEnabled ? 90 : 20),
              ],
            ),
          ),
          
          // 3. Prayer Cards
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasLocation ? Colors.white.withValues(alpha: 0.2) : AppTheme.missed.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasLocation ? Icons.location_on_rounded : Icons.location_off_rounded,
              size: 14,
              color: hasLocation ? AppTheme.accent : AppTheme.missed,
            ),
            const SizedBox(width: 6),
            Text(
              cityName ?? l10n.locationNotSet,
              style: TextStyle(
                color: hasLocation ? Colors.white : AppTheme.missed,
                fontSize: 12,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            salaah.localizedName(l10n),
            style: GoogleFonts.amiri(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: GoogleFonts.outfit(
              fontSize: 18,
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
    
    path.lineTo(w, 0);
    final baseH = h * 0.9; 
    path.lineTo(w, baseH);

    // Right Minaret
    path.lineTo(w * 0.96, baseH);
    path.quadraticBezierTo(w * 0.96, baseH - 80, w * 0.93, baseH - 95); // Pointy top
    path.quadraticBezierTo(w * 0.90, baseH - 80, w * 0.90, baseH);
    
    // Shoulder to Dome
    path.lineTo(w * 0.85, baseH);
    path.cubicTo(
      w * 0.80, baseH - 10, 
      w * 0.75, baseH - 100, 
      w * 0.5, baseH - 110
    ); // Dome peak
    path.cubicTo(
      w * 0.25, baseH - 100, 
      w * 0.20, baseH - 10, 
      w * 0.15, baseH
    );

    // Left Minaret
    path.lineTo(w * 0.10, baseH);
    path.quadraticBezierTo(w * 0.10, baseH - 80, w * 0.07, baseH - 95);
    path.quadraticBezierTo(w * 0.04, baseH - 80, w * 0.04, baseH);
    
    path.lineTo(0, baseH);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class IslamicGeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 60.0;
    for (double x = 0; x <= size.width + spacing; x += spacing) {
      for (double y = 0; y <= size.height + spacing; y += spacing) {
        _drawEightPointStar(canvas, Offset(x, y), 20, paint);
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Inner point for star effect
      double innerAngle = angle + math.pi / 8;
      double ix = center.dx + (radius * 0.7) * math.cos(innerAngle);
      double iy = center.dy + (radius * 0.7) * math.sin(innerAngle);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw a small circle in center
    canvas.drawCircle(center, 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
