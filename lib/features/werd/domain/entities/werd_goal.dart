import 'package:equatable/equatable.dart';
import 'package:fard/core/extensions/quran_extension.dart';

enum WerdGoalType {
  fixedAmount, // E.g. 10 ayahs/pages/counts daily
  finishInDays, // E.g. Finish in 30 days
}

enum WerdCategory {
  quran,
  dhikr,
  custom,
}

enum WerdUnit {
  // Quran units
  ayah,
  page,
  quarter,
  hizb,
  juz,
  // Generic units
  count,
}

class WerdGoal extends Equatable {
  final String id;
  final WerdCategory category;
  final WerdGoalType type;
  final int value;
  final WerdUnit unit;
  final DateTime startDate;
  final int? startAbsolute; // E.g. starting ayah absolute number for Quran

  const WerdGoal({
    required this.id,
    this.category = WerdCategory.quran,
    required this.type,
    required this.value,
    this.unit = WerdUnit.ayah,
    required this.startDate,
    this.startAbsolute,
  });

  @override
  List<Object?> get props => [id, category, type, value, unit, startDate, startAbsolute];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.index,
    'type': type.index,
    'value': value,
    'unit': unit.index,
    'startDate': startDate.toIso8601String(),
    'startAbsolute': startAbsolute,
  };

  factory WerdGoal.fromJson(Map<String, dynamic> json) => WerdGoal(
    id: json['id'] ?? 'default',
    category: json['category'] != null ? WerdCategory.values[json['category']] : WerdCategory.quran,
    type: WerdGoalType.values[json['type']],
    value: json['value'],
    unit: json['unit'] != null ? WerdUnit.values[json['unit']] : WerdUnit.ayah,
    startDate: DateTime.parse(json['startDate']),
    startAbsolute: json['startAbsolute'],
  );

  // Conversion helpers to Ayahs (for Quran category)
  int get valueInAyahs {
    if (category != WerdCategory.quran) return value;
    
    final startAbs = startAbsolute ?? 1;

    if (type == WerdGoalType.finishInDays) {
      final remainingAyahs = 6236 - startAbs + 1;
      return (remainingAyahs / value).ceil();
    }
    
    return QuranHizbProvider.getGoalRequiredAyahs(startAbs, unit, value);
  }
}
