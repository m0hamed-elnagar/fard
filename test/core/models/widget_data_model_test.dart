import 'package:fard/core/models/widget_data_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WidgetDataModel should include new fields in JSON', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final model = WidgetDataModel(
      gregorianDate: '29 March 2026',
      hijriDate: '10 Ramadan 1447',
      dayOfWeek: 'Sunday',
      sunrise: '06:00 AM',
      isRtl: false,
      prayers: [],
      nextPrayerName: 'Fajr',
      nextPrayerTime: now + 10000,
      lastUpdated: now,
    );
    final json = model.toJson();
    expect(json['dayOfWeek'], 'Sunday');
    expect(json['sunrise'], '06:00 AM');
    expect(json['isRtl'], false);
    expect(json['nextPrayerName'], 'Fajr');
    expect(json['nextPrayerTime'], now + 10000);
    expect(json['lastUpdated'], now);
  });
}
