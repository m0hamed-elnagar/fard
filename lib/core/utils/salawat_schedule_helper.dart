
class SalawatScheduleHelper {
  /// Generates scheduled times for Salawat reminders over a specific number of days.
  ///
  /// [startTimeStr] and [endTimeStr] are in "HH:mm" format.
  /// [frequencyHours] is the interval between reminders.
  /// [daysToSchedule] is how many days ahead to schedule (default 3).
  /// [baseDate] is the starting point (usually DateTime.now()).
  static List<DateTime> generateTimes({
    required String startTimeStr,
    required String endTimeStr,
    required int frequencyHours,
    int daysToSchedule = 3,
    DateTime? baseDate,
  }) {
    if (frequencyHours <= 0) return [];

    final List<DateTime> results = [];
    final startParts = startTimeStr.split(':');
    final endParts = endTimeStr.split(':');

    if (startParts.length != 2 || endParts.length != 2) return [];

    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    final now = baseDate ?? DateTime.now();

    for (int i = 0; i < daysToSchedule; i++) {
      final currentDay = now.add(Duration(days: i));
      
      DateTime start = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
        startHour,
        startMinute,
      );

      DateTime end = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
        endHour,
        endMinute,
      );

      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }

      DateTime current = start;
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        // Only add if it's in the future relative to 'now'
        if (current.isAfter(now)) {
          results.add(current);
        }
        current = current.add(Duration(hours: frequencyHours));
      }
    }

    // Sort and remove duplicates (though duplicates shouldn't happen with this logic)
    results.sort();
    return results.toSet().toList();
  }
}
