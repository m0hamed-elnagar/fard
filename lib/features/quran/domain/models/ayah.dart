import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah.freezed.dart';
part 'ayah.g.dart';

@freezed
sealed class Ayah with _$Ayah {
  const factory Ayah({
    required int number,
    required String text,
    required int numberInSurah,
    required int juz,
    required int manzil,
    required int page,
    required int ruku,
    required int hizbQuarter,
    @Default(false) bool sajda,
  }) = _Ayah;

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
}
