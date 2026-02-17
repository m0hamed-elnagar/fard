import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';

class GetSurah implements UseCase<Surah, GetSurahParams> {
  final QuranRepository repository;
  
  const GetSurah(this.repository);
  
  @override
  Future<Result<Surah>> call(GetSurahParams params) {
    return repository.getSurah(
      params.surahNumber,
      translation: params.translation,
    );
  }
}

class GetSurahParams {
  final SurahNumber surahNumber;
  final String? translation;
  
  const GetSurahParams({
    required this.surahNumber,
    this.translation,
  });
}
