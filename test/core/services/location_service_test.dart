import 'package:fard/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationService.cleanCityName Unit Tests', () {
    test('Returns null if name is null', () {
      expect(LocationService.cleanCityName(null), isNull);
    });

    test('Strips Arabic "مدينة" and "مدينه" prefixes and collapses spaces', () {
      expect(LocationService.cleanCityName('مدينة نصر'), 'نصر');
      expect(LocationService.cleanCityName('مدينه نصر'), 'نصر');
      expect(LocationService.cleanCityName('مدينة الشروق'), 'الشروق');
      expect(LocationService.cleanCityName('مدينه الشيخ زايد'), 'الشيخ زايد');
    });

    test('Strips English "madinet" / "madina" / "medinah" variations case-insensitively', () {
      expect(LocationService.cleanCityName('Madinet Nasr'), 'Nasr');
      expect(LocationService.cleanCityName('madina nasr'), 'nasr');
      expect(LocationService.cleanCityName('MADINAH NASR'), 'NASR');
      expect(LocationService.cleanCityName('Medinah Nasr'), 'Nasr');
      expect(LocationService.cleanCityName('medina nasr'), 'nasr');
      expect(LocationService.cleanCityName('Madinat Nasr'), 'Nasr');
    });

    test('Strips suffix occurrences of the word', () {
      expect(LocationService.cleanCityName('Nasr Madinet'), 'Nasr');
      expect(LocationService.cleanCityName('Nasr Madina'), 'Nasr');
      expect(LocationService.cleanCityName('Nasr مدينة'), 'Nasr');
      expect(LocationService.cleanCityName('Nasr مدينه'), 'Nasr');
    });

    test('Returns null if the name consists only of reference words', () {
      expect(LocationService.cleanCityName('مدينة'), isNull);
      expect(LocationService.cleanCityName('مدينه'), isNull);
      expect(LocationService.cleanCityName('Madinet'), isNull);
      expect(LocationService.cleanCityName('madina'), isNull);
      expect(LocationService.cleanCityName('medinah'), isNull);
      expect(LocationService.cleanCityName('مدينة   madinet'), isNull);
    });

    test('Does not strip words containing the patterns as substrings', () {
      // "Madinaty" or "Madinety" contains "madinet" but shouldn't be stripped
      expect(LocationService.cleanCityName('Madinety'), 'Madinety');
      expect(LocationService.cleanCityName('Madinaty'), 'Madinaty');
      
      // "المدينة المنورة" has "المدينة" (with "ال" prefix) so it shouldn't match "مدينة"
      expect(LocationService.cleanCityName('المدينة المنورة'), 'المدينة المنورة');
    });

    test('Collapses extra spaces and trims results', () {
      expect(LocationService.cleanCityName('   مدينة    الشيخ    زايد   '), 'الشيخ زايد');
    });
  });
}
