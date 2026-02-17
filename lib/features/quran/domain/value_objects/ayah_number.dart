import 'package:equatable/equatable.dart';
import 'package:fard/core/errors/failure.dart';

class AyahNumber extends Equatable {
  final int surahNumber;
  final int ayahNumberInSurah;
  
  const AyahNumber._({
    required this.surahNumber,
    required this.ayahNumberInSurah,
  });

  static Result<AyahNumber> create({
    required int surahNumber,
    required int ayahNumberInSurah,
  }) {
    if (surahNumber < 1 || surahNumber > 114) {
      return Result.failure(const InvalidSurahNumberFailure());
    }
    if (ayahNumberInSurah < 1) {
      return Result.failure(const InvalidAyahNumberFailure());
    }
    
    return Result.success(AyahNumber._(
      surahNumber: surahNumber,
      ayahNumberInSurah: ayahNumberInSurah,
    ));
  }

  @override
  List<Object> get props => [surahNumber, ayahNumberInSurah];
}
