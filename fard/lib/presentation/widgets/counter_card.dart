import 'package:fard/domain/models/missed_counter.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CounterCard extends StatefulWidget {
  final Map<Salaah, MissedCounter> qadaStatus;
  final int todayMissedCount;
  final VoidCallback onAddPressed;

  const CounterCard({
    super.key,
    required this.qadaStatus,
    required this.todayMissedCount,
    required this.onAddPressed,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.primaryDark.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          // Main counter row
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Counter display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المتبقي',
                          style: GoogleFonts.amiri(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_totalRemaining',
                              style: GoogleFonts.outfit(
                                color: AppTheme.accent,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (widget.todayMissedCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.missed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          AppTheme.missed.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '+${widget.todayMissedCount}',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.missed,
                                    fontSize: 14,
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
                      color: AppTheme.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                    ),
                    child: IconButton(
                      onPressed: widget.onAddPressed,
                      icon: const Icon(Icons.add_rounded,
                          color: AppTheme.primaryLight, size: 28),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: Salaah.values.map((salaah) {
                      final count =
                          widget.qadaStatus[salaah]?.value ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: count > 0
                                    ? AppTheme.accent
                                    : AppTheme.neutral,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              salaah.label,
                              style: GoogleFonts.amiri(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$count',
                              style: GoogleFonts.outfit(
                                color: count > 0
                                    ? AppTheme.accent
                                    : AppTheme.textSecondary,
                                fontSize: 18,
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
