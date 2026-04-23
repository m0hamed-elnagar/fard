import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_symbol.freezed.dart';
part 'quran_symbol.g.dart';

@freezed
abstract class QuranSymbol with _$QuranSymbol {
  const QuranSymbol._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory QuranSymbol({
    required String id,
    required String char,
    required String arabicName,
    required String brief,
    required String ruleSummary,
    required int difficulty,
    required String color,
    required List<SymbolSource> sources,
    @Default([]) List<SymbolExample> examples,
  }) = _QuranSymbol;

  factory QuranSymbol.fromJson(Map<String, dynamic> json) => _$QuranSymbolFromJson(json);
}

@freezed
abstract class SymbolSource with _$SymbolSource {
  const SymbolSource._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SymbolSource({
    required String name,
    @JsonKey(name: 'type') required String sourceType, // 'book', 'website', 'video'
    @JsonKey(name: 'text') required String content,    // text or url
  }) = _SymbolSource;

  factory SymbolSource.fromJson(Map<String, dynamic> json) => _$SymbolSourceFromJson(json);
}

@freezed
abstract class SymbolExample with _$SymbolExample {
  const SymbolExample._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SymbolExample({
    required int surah,
    required int ayah,
    String? context,
  }) = _SymbolExample;

  factory SymbolExample.fromJson(Map<String, dynamic> json) => _$SymbolExampleFromJson(json);
}
