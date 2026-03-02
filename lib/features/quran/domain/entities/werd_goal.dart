import 'package:equatable/equatable.dart';

enum WerdGoalType {
  fixedAmount,
  finishInDays,
}

enum WerdUnit {
  ayah,
  page,
  quarter,
  hizb,
  juz,
}

class WerdGoal extends Equatable {
  final WerdGoalType type;
  final int value;
  final WerdUnit unit;
  final DateTime startDate;

  const WerdGoal({
    required this.type,
    required this.value,
    this.unit = WerdUnit.ayah,
    required this.startDate,
  });

  @override
  List<Object?> get props => [type, value, unit, startDate];
  
  Map<String, dynamic> toJson() => {
    'type': type.index,
    'value': value,
    'unit': unit.index,
    'startDate': startDate.toIso8601String(),
  };

  factory WerdGoal.fromJson(Map<String, dynamic> json) => WerdGoal(
    type: WerdGoalType.values[json['type']],
    value: json['value'],
    unit: json['unit'] != null ? WerdUnit.values[json['unit']] : WerdUnit.ayah,
    startDate: DateTime.parse(json['startDate']),
  );

  // Conversion helpers to Ayahs (approximate for UI/progress)
  int get valueInAyahs {
    if (type == WerdGoalType.finishInDays) {
      return (6236 / value).ceil();
    }
    switch (unit) {
      case WerdUnit.ayah: return value;
      case WerdUnit.page: return value * 10; // Approx 10 ayahs per page
      case WerdUnit.quarter: return value * 26; // Approx 26 ayahs per quarter (6236/240)
      case WerdUnit.hizb: return value * 104; // Approx 104 ayahs per hizb
      case WerdUnit.juz: return value * 208; // Approx 208 ayahs per juz
    }
  }
}
