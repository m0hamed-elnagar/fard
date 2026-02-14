import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MissedCounter', () {
    test('initializes with 0 if negative value is provided', () {
      const counter = MissedCounter(-5);
      expect(counter.value, 0);
    });

    test('addMissed increments value', () {
      const counter = MissedCounter(5);
      final updated = counter.addMissed();
      expect(updated.value, 6);
    });

    test('removeMissed decrements value', () {
      const counter = MissedCounter(5);
      final updated = counter.removeMissed();
      expect(updated.value, 4);
    });

    test('removeMissed does not decrement below 0', () {
      const counter = MissedCounter(0);
      final updated = counter.removeMissed();
      expect(updated.value, 0);
    });

    test('props contains value', () {
      const counter = MissedCounter(10);
      expect(counter.props, [10]);
    });

    test('equality works', () {
      expect(const MissedCounter(10), const MissedCounter(10));
      expect(const MissedCounter(10), isNot(const MissedCounter(5)));
    });
  });
}
