import 'package:intl/intl.dart';

class TimeUtils {
  /// Formats a time string in "HH:mm" format to a 12-hour format "h:mm a".
  /// If [currentTime] is invalid or empty, it returns the same string.
  static String formatTo12Hour(String currentTime) {
    if (currentTime.isEmpty || !currentTime.contains(':')) return currentTime;
    
    try {
      final parts = currentTime.split(':');
      if (parts.length != 2) return currentTime;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Using DateTime as a vessel for formatting
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, hour, minute);
      
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return currentTime;
    }
  }
}
