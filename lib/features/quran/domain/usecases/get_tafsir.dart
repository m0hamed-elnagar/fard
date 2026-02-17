import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';

class GetTafsir implements UseCase<String, GetTafsirParams> {
  final QuranRepository repository;

  const GetTafsir(this.repository);

  @override
  Future<Result<String>> call(GetTafsirParams params) {
    return repository.getTafsir(
      params.surahNumber,
      params.ayahNumber,
      tafsirId: params.tafsirId,
    );
  }
}

class GetTafsirParams {
  final int surahNumber;
  final int ayahNumber;
  final int? tafsirId;

  const GetTafsirParams({
    required this.surahNumber,
    required this.ayahNumber,
    this.tafsirId,
  });
}
