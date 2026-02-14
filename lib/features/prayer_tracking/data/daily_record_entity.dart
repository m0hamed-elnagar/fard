import 'package:hive/hive.dart';

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

  DailyRecordEntity({
    required this.id,
    required this.dateMillis,
    required this.missedIndices,
    required this.qadaValues,
  });
}
