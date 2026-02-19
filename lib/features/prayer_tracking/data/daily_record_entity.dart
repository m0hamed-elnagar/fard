import 'package:hive_ce/hive_ce.dart';

part 'daily_record_entity.g.dart';

@HiveType(typeId: 0)
class DailyRecordEntity {
  @HiveField(0)
  String id;
  @HiveField(1)
  int dateMillis;
  @HiveField(2)
  List<int> missedIndices;
  @HiveField(3)
  Map<int, int> qadaValues;
  @HiveField(4)
  List<int>? completedIndices;

  DailyRecordEntity({
    required this.id,
    required this.dateMillis,
    required this.missedIndices,
    required this.qadaValues,
    this.completedIndices,
  });
}
