import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:hijri/hijri_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Map<DateTime, DailyRecord> monthRecords;
  final ValueChanged<DateTime> onDaySelected;
  final void Function(int year, int month) onMonthChanged;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.monthRecords,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _isExpanded = false;
  late DateTime _focusedDay;
  final Map<DateTime, HijriCalendar> _hijriCache = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  HijriCalendar _getHijriDate(DateTime date) {
    final normalized = _normalize(date);
    return _hijriCache.putIfAbsent(normalized, () => HijriCalendar.fromDate(date));
  }

  Widget _buildCell(DateTime day, bool isSelected, {bool isToday = false}) {
    final hijri = _getHijriDate(day);
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accent
            : (isToday ? AppTheme.primaryLight.withValues(alpha: 0.20) : null),
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: AppTheme.primaryLight, width: 1.0)
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black87 : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${hijri.hDay}',
                style: GoogleFonts.amiri(
                  color: isSelected
                      ? Colors.black54
                      : AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 9.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.cardBorder, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — always visible
          InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppTheme.accent, size: 22.0),
                  const SizedBox(width: 12.0),
                  Text(
                    AppLocalizations.of(context)!.calendar,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary, size: 24.0),
                  ),
                ],
              ),
            ),
          ),
          // Calendar body
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: TableCalendar(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
                rowHeight: 48.0,
                selectedDayPredicate: (day) =>
                    isSameDay(day, widget.selectedDate),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  widget.onDaySelected(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  widget.onMonthChanged(focusedDay.year, focusedDay.month);
                },
                calendarStyle: const CalendarStyle(
                  todayTextStyle: TextStyle(color: AppTheme.textPrimary),
                  selectedTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                  defaultTextStyle: TextStyle(color: AppTheme.textPrimary),
                  weekendTextStyle: TextStyle(color: AppTheme.textSecondary),
                  outsideTextStyle: TextStyle(color: Color(0x66C9D1D9)),
                  cellMargin: EdgeInsets.all(4),
                  markersMaxCount: 1,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppTheme.textSecondary,
                      size: 24.0),
                  rightChevronIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                      size: 24.0),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.outfit(
                      color: AppTheme.textSecondary, fontSize: 12.0),
                  weekendStyle: GoogleFonts.outfit(
                      color: AppTheme.textSecondary, fontSize: 12.0),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) => _buildCell(day, false),
                  selectedBuilder: (context, day, focusedDay) => _buildCell(day, true),
                  todayBuilder: (context, day, focusedDay) => _buildCell(day, false, isToday: true),
                  markerBuilder: (context, date, events) {
                    final normalized = _normalize(date);
                    final record = widget.monthRecords[normalized];
                    if (record != null) {
                      final hasMissed = record.missedToday.isNotEmpty;
                      return Positioned(
                        bottom: 4.0,
                        child: Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                hasMissed ? AppTheme.missed : AppTheme.saved,
                            boxShadow: [
                              BoxShadow(
                                color: (hasMissed
                                        ? AppTheme.missed
                                        : AppTheme.saved)
                                    .withValues(alpha: 0.50),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
