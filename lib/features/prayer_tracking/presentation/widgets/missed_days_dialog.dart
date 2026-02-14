import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

class MissedDaysDialog extends StatefulWidget {
  final List<DateTime> missedDates;
  final void Function(List<DateTime> selectedDates) onResponse;

  const MissedDaysDialog({
    super.key,
    required this.missedDates,
    required this.onResponse,
  });

  @override
  State<MissedDaysDialog> createState() => _MissedDaysDialogState();
}

class _MissedDaysDialogState extends State<MissedDaysDialog> {
  late Set<DateTime> _selectedDates;
  final Set<int> _draggedIndices = {};
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedDates = Set<DateTime>.from(widget.missedDates);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(Offset localPosition, BoxConstraints constraints) {
    final double scrolledY = localPosition.dy + _scrollController.offset;
    final double itemWidth = constraints.maxWidth / 7;
    const double itemHeight = 60.0;

    final direction = Directionality.of(context);
    final bool isRtl = direction == TextDirection.rtl;
    
    int column;
    if (isRtl) {
      column = 6 - (localPosition.dx / itemWidth).floor();
    } else {
      column = (localPosition.dx / itemWidth).floor();
    }
    
    final int row = (scrolledY / itemHeight).floor();

    if (column < 0 || column >= 7 || row < 0) return;

    final int index = row * 7 + column;
    if (index >= 0 && index < widget.missedDates.length) {
      if (!_draggedIndices.contains(index)) {
        setState(() {
          _draggedIndices.add(index);
          final date = widget.missedDates[index];
          if (_selectedDates.contains(date)) {
            _selectedDates.remove(date);
          } else {
            _selectedDates.add(date);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450.0, maxHeight: 650.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.missedDaysTitle,
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              l10n.missedDaysMessage(widget.missedDates.length),
              style: GoogleFonts.amiri(
                color: AppTheme.textSecondary,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              "Swipe or tap to toggle dates",
              style: GoogleFonts.amiri(
                color: AppTheme.accent,
                fontSize: 13.0,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildWeekdayHeader(),
            const SizedBox(height: 8.0),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: (details) {
                      _draggedIndices.clear();
                      _handleDragUpdate(details.localPosition, constraints);
                    },
                    onPanUpdate: (details) {
                      _handleDragUpdate(details.localPosition, constraints);
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: widget.missedDates.length,
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisExtent: 60.0,
                      ),
                      itemBuilder: (context, index) {
                        final date = widget.missedDates[index];
                        final isSelected = _selectedDates.contains(date);
                        return _CalendarDayItem(
                          date: date,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedDates.remove(date);
                              } else {
                                _selectedDates.add(date);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onResponse([]);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(l10n.skip, style: GoogleFonts.amiri()),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onResponse(_selectedDates.toList());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(l10n.addAll,
                        style: GoogleFonts.amiri(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: (isRtl ? weekdays.reversed.toList() : weekdays)
          .map((d) => Text(d,
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600)))
          .toList(),
    );
  }
}

class _CalendarDayItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarDayItem({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.95,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 16.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Text(
                _getMonthName(date.month),
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppTheme.textSecondary,
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}
