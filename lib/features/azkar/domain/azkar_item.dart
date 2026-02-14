import 'package:freezed_annotation/freezed_annotation.dart';

part 'azkar_item.freezed.dart';

@freezed
class AzkarItem with _$AzkarItem {
  const factory AzkarItem({
    required String category,
    required String zekr,
    required String description,
    required int count,
    required String reference,
    @Default(0) int currentCount,
  }) = _AzkarItem;
}
