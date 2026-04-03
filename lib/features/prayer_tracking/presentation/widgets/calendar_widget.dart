import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Map<DateTime, DailyRecord> monthRecords;
  final ValueChanged<DateTime> onDaySelected;
  final void Function(int year, int month) onMonthChanged;
  final int hijriAdjustment;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.monthRecords,
    required this.onDaySelected,
    required this.onMonthChanged,
    this.hijriAdjustment = 0,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _isExpanded = false;
  bool _hijriFocused = false;
  late DateTime _focusedDay;
  final Map<DateTime, HijriCalendar> _hijriCache = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hijriAdjustment != widget.hijriAdjustment) {
      _hijriCache.clear();
    }
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  HijriCalendar _getHijriDate(DateTime date) {
    final normalized = _normalize(date);
    return _hijriCache.putIfAbsent(normalized, () {
      final adjustedDate = date.add(Duration(days: widget.hijriAdjustment));
      return HijriCalendar.fromDate(adjustedDate);
    });
  }

  Widget _buildCell(DateTime day, bool isSelected, {bool isToday = false}) {
    final hijri = _getHijriDate(day);

    final primaryValue = _hijriFocused ? '${hijri.hDay}' : '${day.day}';
    final secondaryValue = _hijriFocused ? '${day.day}' : '${hijri.hDay}';

    final primaryStyle = _hijriFocused
        ? GoogleFonts.amiri(
            color: isSelected ? Colors.black87 : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            fontSize: 16.0,
          )
        : GoogleFonts.outfit(
            color: isSelected ? Colors.black87 : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14.0,
          );

    final secondaryStyle = _hijriFocused
        ? GoogleFonts.outfit(
            color: isSelected
                ? Colors.black54
                : AppTheme.textSecondary.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            fontSize: 9.0,
            height: 1.0,
          )
        : GoogleFonts.amiri(
            color: isSelected
                ? Colors.black54
                : AppTheme.textSecondary.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            height: 1.0,
          );

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accent
            : (isToday ? AppTheme.primaryLight.withValues(alpha: 0.15) : null),
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.5),
                width: 1.5,
              )
            : isSelected
            ? Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1.0)
            : null,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.accent.withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: isSelected ? 8 : 0,
            offset: isSelected ? const Offset(0, 2) : Offset.zero,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(primaryValue, style: primaryStyle),
            Text(secondaryValue, style: secondaryStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final hijri = _getHijriDate(_focusedDay);

    // Calculate display strings for the header
    final gregMonth = DateFormat.MMMM(locale).format(_focusedDay);
    final gregYear = DateFormat.y(locale).format(_focusedDay);

    HijriCalendar.setLocal(locale);
    final hijriMonth = hijri.getLongMonthName();
    final hijriYear = hijri.hYear;

    final focusedMonthText = _hijriFocused
        ? '$hijriMonth $hijriYear هـ'
        : '$gregMonth $gregYear';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — always visible
          InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _hijriFocused
                          ? Icons.nightlight_round
                          : Icons.calendar_month_rounded,
                      color: AppTheme.accent,
                      size: 18.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded
                              ? AppLocalizations.of(context)!.calendar
                              : focusedMonthText,
                          style: GoogleFonts.amiri(
                            color: AppTheme.textPrimary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isExpanded)
                          Text(
                            focusedMonthText,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Focus Switcher - Always visible in header for discoverability
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _hijriFocused = !_hijriFocused);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accent.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _hijriFocused
                                  ? AppLocalizations.of(context)!.hijriCalendar
                                  : AppLocalizations.of(
                                      context,
                                    )!.gregorianCalendar,
                              style: GoogleFonts.outfit(
                                color: AppTheme.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Calendar body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TableCalendar(
              firstDay: DateTime(1900, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              calendarFormat: _isExpanded
                  ? CalendarFormat.month
                  : CalendarFormat.week,
              rowHeight: 54.0,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              headerVisible: _isExpanded,
              selectedDayPredicate: (day) =>
                  isSameDay(day, widget.selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                HapticFeedback.selectionClick();
                setState(() => _focusedDay = focusedDay);
                widget.onDaySelected(selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
                widget.onMonthChanged(focusedDay.year, focusedDay.month);
              },
              calendarStyle: const CalendarStyle(
                todayTextStyle: TextStyle(color: AppTheme.textPrimary),
                selectedTextStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
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
                  size: 24.0,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                  size: 24.0,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.outfit(
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: GoogleFonts.outfit(
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  final h = _getHijriDate(day);
                  final loc = Localizations.localeOf(context).languageCode;

                  // Localize Gregorian Month
                  final gM = DateFormat.MMMM(loc).format(day);
                  final gY = DateFormat.y(loc).format(day);

                  // Localize Hijri Month
                  HijriCalendar.setLocal(loc);
                  final hM = h.getLongMonthName();
                  final hY = h.hYear;

                  final primaryMonth = _hijriFocused ? hM : gM;
                  final primaryYear = _hijriFocused ? '$hY هـ' : gY;
                  final secondaryMonth = _hijriFocused ? gM : hM;
                  final secondaryYear = _hijriFocused ? gY : '$hY هـ';

                  final primaryStyle = _hijriFocused
                      ? GoogleFonts.amiri(
                          color: AppTheme.textPrimary,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        );

                  final secondaryStyle = _hijriFocused
                      ? GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        )
                      : GoogleFonts.amiri(
                          color: AppTheme.textSecondary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$primaryMonth $primaryYear',
                        style: primaryStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$secondaryMonth $secondaryYear',
                        style: secondaryStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
                defaultBuilder: (context, day, focusedDay) =>
                    _buildCell(day, false),
                selectedBuilder: (context, day, focusedDay) =>
                    _buildCell(day, true),
                todayBuilder: (context, day, focusedDay) =>
                    _buildCell(day, false, isToday: true),
                markerBuilder: (context, date, events) {
                  final normalized = _normalize(date);
                  final record = widget.monthRecords[normalized];
                  if (record != null) {
                    final hasMissed = record.missedToday.isNotEmpty;
                    return Positioned(
                      bottom: 6.0,
                      child: Container(
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasMissed ? AppTheme.missed : AppTheme.saved,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (hasMissed ? AppTheme.missed : AppTheme.saved)
                                      .withValues(alpha: 0.4),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
