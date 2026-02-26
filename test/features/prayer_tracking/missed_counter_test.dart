import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MissedCounter', () {
    test('should prevent negative values during construction', () {
      expect(const MissedCounter(-1).value, 0);
      expect(const MissedCounter(0).value, 0);
      expect(const MissedCounter(10).value, 10);
    });

    test('addMissed should increment value', () {
      const counter = MissedCounter(5);
      final updated = counter.addMissed();
      expect(updated.value, 6);
    });

    test('removeMissed should decrement value but not go below zero', () {
      const counter = MissedCounter(1);
      
      final updated1 = counter.removeMissed();
      expect(updated1.value, 0);
      
      final updated2 = updated1.removeMissed();
      expect(updated2.value, 0);
    });

    test('equality works as expected', () {
      expect(const MissedCounter(5), const MissedCounter(5));
      expect(const MissedCounter(5), isNot(const MissedCounter(6)));
    });
  });
}
