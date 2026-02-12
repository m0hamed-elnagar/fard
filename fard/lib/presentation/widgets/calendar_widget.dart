import 'package:fard/domain/models/daily_record.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — always visible
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppTheme.accent, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'التقويم',
                    style: GoogleFonts.amiri(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary),
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
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: TableCalendar(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
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
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppTheme.primaryLight, width: 2),
                  ),
                  todayTextStyle:
                      const TextStyle(color: AppTheme.textPrimary),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                  defaultTextStyle:
                      const TextStyle(color: AppTheme.textPrimary),
                  weekendTextStyle:
                      const TextStyle(color: AppTheme.textSecondary),
                  outsideTextStyle:
                      TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  cellMargin: const EdgeInsets.all(4),
                  markersMaxCount: 1,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppTheme.textSecondary),
                  rightChevronIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.outfit(
                      color: AppTheme.textSecondary, fontSize: 12),
                  weekendStyle: GoogleFonts.outfit(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final normalized = _normalize(date);
                    final record = widget.monthRecords[normalized];
                    if (record != null) {
                      final hasMissed = record.missedToday.isNotEmpty;
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                hasMissed ? AppTheme.missed : AppTheme.saved,
                            boxShadow: [
                              BoxShadow(
                                color: (hasMissed
                                        ? AppTheme.missed
                                        : AppTheme.saved)
                                    .withValues(alpha: 0.5),
                                blurRadius: 4,
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
