import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
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

  bool _isOutsideMonth(DateTime day) {
    return day.month != _focusedDay.month || day.year != _focusedDay.year;
  }

  HijriCalendar _getHijriDate(DateTime date) {
    final normalized = _normalize(date);
    return _hijriCache.putIfAbsent(normalized, () {
      // HijriCalendar (Umm al-Qura) only supports dates from 1356 AH (1937 CE) to 1500 AH (2077 CE)
      // We clamp the year to prevent crashes from TableCalendar's padding cells for years like 1900
      DateTime safeDate = date;
      if (safeDate.year < 1937) {
        safeDate = DateTime(1937, safeDate.month, safeDate.day);
      } else if (safeDate.year > 2077) {
        safeDate = DateTime(2077, safeDate.month, safeDate.day);
      }

      final adjustedDate = safeDate.add(Duration(days: widget.hijriAdjustment));
      return HijriCalendar.fromDate(adjustedDate);
    });
  }

  Widget _buildCell(DateTime day, bool isSelected, {bool isToday = false, bool isOutside = false}) {
    final hijri = _getHijriDate(day);
    final today = DateTime.now();
    final isTodayDate = day.year == today.year && day.month == today.month && day.day == today.day;

    // Always show BOTH calendar values for EVERY day
    final primaryValue = _hijriFocused ? '${hijri.hDay}' : '${day.day}';
    final secondaryValue = _hijriFocused ? '${day.day}' : '${hijri.hDay}';

    // All days at full opacity - no distinction between inside/outside
    final cellOpacity = 1.0;

    final primaryStyle = _hijriFocused
        ? GoogleFonts.amiri(
            color: isSelected
                ? context.onSurfaceColor
                : isTodayDate && !isSelected
                    ? context.primaryColor
                    : context.onSurfaceColor.withValues(alpha: cellOpacity),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            fontSize: isSelected ? 18.0 : 16.0,
          )
        : GoogleFonts.outfit(
            color: isSelected
                ? context.onSurfaceColor
                : isTodayDate && !isSelected
                    ? context.primaryColor
                    : context.onSurfaceColor.withValues(alpha: cellOpacity),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: isSelected ? 16.0 : 14.0,
          );

    final secondaryStyle = _hijriFocused
        ? GoogleFonts.outfit(
            color: isSelected
                ? context.onSurfaceVariantColor
                : isTodayDate && !isSelected
                    ? context.primaryColor.withValues(alpha: 0.7)
                    : context.onSurfaceVariantColor.withValues(
                        alpha: 0.7 * cellOpacity,
                      ),
            fontWeight: FontWeight.bold,
            fontSize: isSelected ? 11.0 : 10.0,
            height: 1.1,
          )
        : GoogleFonts.amiri(
            color: isSelected
                ? context.onSurfaceVariantColor
                : isTodayDate && !isSelected
                    ? context.primaryColor.withValues(alpha: 0.7)
                    : context.onSurfaceVariantColor.withValues(
                        alpha: 0.7 * cellOpacity,
                      ),
            fontWeight: FontWeight.bold,
            fontSize: isSelected ? 12.0 : 11.0,
            height: 1.1,
          );

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: isSelected
            ? context.primaryColor.withValues(alpha: 0.15)
            : (isTodayDate && !isSelected ? context.primaryColor.withValues(alpha: 0.1) : null),
        shape: BoxShape.circle,
        border: isTodayDate && !isSelected
            ? Border.all(
                color: context.primaryColor.withValues(alpha: 0.8),
                width: 2.5,
              )
            : isSelected
            ? Border.all(
                color: context.primaryColor.withValues(alpha: 0.5),
                width: 2.0,
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : isTodayDate && !isSelected
            ? [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: Offset.zero,
                ),
              ]
            : [],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(primaryValue, style: primaryStyle),
              const SizedBox(height: 1),
              Text(secondaryValue, style: secondaryStyle),
            ],
          ),
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: context.outlineColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: context.outlineColor,
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
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _hijriFocused
                          ? Icons.nightlight_round
                          : Icons.calendar_month_rounded,
                      color: context.secondaryColor,
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
                            color: context.onSurfaceColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isExpanded)
                          Text(
                            _hijriFocused
                                ? '$gregMonth $gregYear'
                                : '$hijriMonth $hijriYear هـ',
                            style: GoogleFonts.outfit(
                              color: context.onSurfaceVariantColor.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (_isExpanded)
                          Text(
                            focusedMonthText,
                            style: GoogleFonts.outfit(
                              color: context.onSurfaceVariantColor,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Focus Switcher - Always visible in header for discoverability
                  Material(
                    color: context.surfaceContainerColor,
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
                          color: context.secondaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.secondaryColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: context.secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _hijriFocused
                                  ? AppLocalizations.of(context)!.hijriCalendar
                                  : AppLocalizations.of(
                                      context,
                                    )!.gregorianCalendar,
                              style: GoogleFonts.outfit(
                                color: context.secondaryColor,
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
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.onSurfaceVariantColor,
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
              lastDay: DateTime(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _isExpanded
                  ? CalendarFormat.month
                  : CalendarFormat.week,
              rowHeight: 56.0,
              daysOfWeekHeight: 28.0,
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
                // Prevent selecting future dates
                final today = DateTime.now();
                final normalizedSelected = DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                );
                final normalizedToday = DateTime(
                  today.year,
                  today.month,
                  today.day,
                );
                if (normalizedSelected.isBefore(normalizedToday) ||
                    normalizedSelected.isAtSameMomentAs(normalizedToday)) {
                  widget.onDaySelected(selectedDay);
                }
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
                widget.onMonthChanged(focusedDay.year, focusedDay.month);
              },
              calendarStyle: CalendarStyle(
                // Today: ring highlight with primary color text
                todayTextStyle: TextStyle(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.primaryColor,
                    width: 2.0,
                  ),
                ),
                // Selected: primary color tint with onSurface text
                selectedTextStyle: TextStyle(
                  color: context.onSurfaceColor,
                  fontWeight: FontWeight.w800,
                ),
                selectedDecoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.5),
                    width: 2.0,
                  ),
                ),
                defaultTextStyle: TextStyle(color: context.onSurfaceColor),
                weekendTextStyle: TextStyle(color: context.onSurfaceVariantColor),
                cellMargin: const EdgeInsets.all(2),
                markersMaxCount: 1,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.outfit(
                  color: context.onSurfaceColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: context.onSurfaceVariantColor,
                  size: 24.0,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: context.onSurfaceVariantColor,
                  size: 24.0,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.outfit(
                  color: context.onSurfaceVariantColor.withValues(alpha: 0.8),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: GoogleFonts.outfit(
                  color: context.onSurfaceVariantColor.withValues(alpha: 0.8),
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
                          color: context.onSurfaceColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.outfit(
                          color: context.onSurfaceColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        );

                  final secondaryStyle = _hijriFocused
                      ? GoogleFonts.outfit(
                          color: context.onSurfaceVariantColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        )
                      : GoogleFonts.amiri(
                          color: context.onSurfaceVariantColor,
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
                    _buildCell(day, false, isOutside: _isOutsideMonth(day)),
                outsideBuilder: (context, day, focusedDay) =>
                    _buildCell(day, false, isOutside: true),
                selectedBuilder: (context, day, focusedDay) =>
                    _buildCell(day, true, isOutside: _isOutsideMonth(day)),
                todayBuilder: (context, day, focusedDay) =>
                    _buildCell(day, false, isToday: true, isOutside: _isOutsideMonth(day)),
                markerBuilder: (context, date, events) {
                  final normalized = _normalize(date);
                  final record = widget.monthRecords[normalized];
                  if (record != null) {
                    final hasMissed = record.missedToday.isNotEmpty;
                    return Positioned(
                      bottom: 2.0,
                      child: Container(
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasMissed ? context.errorColor : context.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (hasMissed ? context.errorColor : context.primaryColor)
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
