import 'package:fard/core/utils/salawat_schedule_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalawatScheduleHelper', () {
    test('generates times within the same day', () {
      final baseDate = DateTime(2023, 10, 27, 8, 0); // Friday 8:00 AM
      final times = SalawatScheduleHelper.generateTimes(
        startTimeStr: "09:00",
        endTimeStr: "12:00",
        frequencyHours: 1,
        daysToSchedule: 1,
        baseDate: baseDate,
      );

      expect(times.length, 4);
      expect(times[0], DateTime(2023, 10, 27, 9, 0));
      expect(times[1], DateTime(2023, 10, 27, 10, 0));
      expect(times[2], DateTime(2023, 10, 27, 11, 0));
      expect(times[3], DateTime(2023, 10, 27, 12, 0));
    });

    test('handles midnight crossover', () {
      final baseDate = DateTime(2023, 10, 27, 20, 0); // 8:00 PM
      final times = SalawatScheduleHelper.generateTimes(
        startTimeStr: "22:00",
        endTimeStr: "02:00",
        frequencyHours: 1,
        daysToSchedule: 1,
        baseDate: baseDate,
      );

      expect(times.length, 5);
      expect(times[0], DateTime(2023, 10, 27, 22, 0));
      expect(times[1], DateTime(2023, 10, 27, 23, 0));
      expect(times[2], DateTime(2023, 10, 28, 0, 0));
      expect(times[3], DateTime(2023, 10, 28, 1, 0));
      expect(times[4], DateTime(2023, 10, 28, 2, 0));
    });

    test('only includes future times', () {
      final baseDate = DateTime(2023, 10, 27, 10, 30);
      final times = SalawatScheduleHelper.generateTimes(
        startTimeStr: "09:00",
        endTimeStr: "12:00",
        frequencyHours: 1,
        daysToSchedule: 1,
        baseDate: baseDate,
      );

      expect(times.length, 2);
      expect(times[0], DateTime(2023, 10, 27, 11, 0));
      expect(times[1], DateTime(2023, 10, 27, 12, 0));
    });

    test('schedules for multiple days', () {
      final baseDate = DateTime(2023, 10, 27, 8, 0);
      final times = SalawatScheduleHelper.generateTimes(
        startTimeStr: "09:00",
        endTimeStr: "10:00",
        frequencyHours: 1,
        daysToSchedule: 3,
        baseDate: baseDate,
      );

      expect(times.length, 6); // (9, 10) * 3 days
      expect(times[0], DateTime(2023, 10, 27, 9, 0));
      expect(times[1], DateTime(2023, 10, 27, 10, 0));
      expect(times[2], DateTime(2023, 10, 28, 9, 0));
      expect(times[3], DateTime(2023, 10, 28, 10, 0));
      expect(times[4], DateTime(2023, 10, 29, 9, 0));
      expect(times[5], DateTime(2023, 10, 29, 10, 0));
    });
  });
}
