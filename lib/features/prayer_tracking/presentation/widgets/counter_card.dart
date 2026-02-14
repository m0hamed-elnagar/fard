import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class CounterCard extends StatefulWidget {
  final Map<Salaah, MissedCounter> qadaStatus;
  final int todayMissedCount;
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;

  const CounterCard({
    super.key,
    required this.qadaStatus,
    required this.todayMissedCount,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  int get _totalRemaining =>
      widget.qadaStatus.values.fold(0, (sum, c) => sum + c.value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.primaryDark.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          // Main counter row
          InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Counter display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.remaining,
                          style: GoogleFonts.amiri(
                            color: AppTheme.textSecondary,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_totalRemaining',
                              style: GoogleFonts.outfit(
                                color: AppTheme.accent,
                                fontSize: 36.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (widget.todayMissedCount > 0) ...[
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.missed.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color:
                                          AppTheme.missed.withOpacity(0.30)),
                                ),
                                child: Text(
                                  '+${widget.todayMissedCount}',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.missed,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Add button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: AppTheme.primaryLight.withOpacity(0.30)),
                    ),
                    child: IconButton(
                      onPressed: widget.onAddPressed,
                      icon: const Icon(Icons.add_rounded,
                          color: AppTheme.primaryLight, size: 28.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Expand arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          // Expanded per-salaah breakdown
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.dailyPrayers,
                        style: GoogleFonts.amiri(
                          color: AppTheme.textSecondary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onEditPressed,
                        icon: const Icon(Icons.edit_rounded, size: 16.0),
                        label: Text(
                          l10n.edit,
                          style: GoogleFonts.amiri(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryLight,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                  child: Column(
                    children: Salaah.values.map((salaah) {
                      final count =
                          widget.qadaStatus[salaah]?.value ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 4.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: count > 0
                                    ? AppTheme.accent
                                    : AppTheme.neutral,
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              salaah.localizedName(l10n),
                              style: GoogleFonts.amiri(
                                color: AppTheme.textPrimary,
                                fontSize: 16.0,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$count',
                              style: GoogleFonts.outfit(
                                color: count > 0
                                    ? AppTheme.accent
                                    : AppTheme.textSecondary,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
