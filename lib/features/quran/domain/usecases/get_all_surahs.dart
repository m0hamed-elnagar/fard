import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';

class GetAllSurahs implements UseCase<List<Surah>, NoParams> {
  final QuranRepository repository;
  
  const GetAllSurahs(this.repository);
  
  @override
  Future<Result<List<Surah>>> call(NoParams params) {
    // We need to add getAllSurahs to QuranRepository interface
    return repository.getSurahs();
  }
}
