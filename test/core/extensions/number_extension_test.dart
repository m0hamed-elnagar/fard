import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/extensions/number_extension.dart';

void main() {
  group('NumberExtension', () {
    test('toArabicIndic converts digits correctly', () {
      expect(0.toArabicIndic(), '٠');
      expect(1.toArabicIndic(), '١');
      expect(9.toArabicIndic(), '٩');
      expect(10.toArabicIndic(), '١٠');
      expect(123.toArabicIndic(), '١٢٣');
    });

    test('toArabicIndic maintains digit order', () {
      // 12 should be "one" then "two", which is ١٢
      expect(12.toArabicIndic(), '١٢');
    });
  });
}
