import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/quran/domain/entities/page.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';

class GetPage implements UseCase<MushafPage, GetPageParams> {
  final QuranRepository repository;
  
  const GetPage(this.repository);
  
  @override
  Future<Result<MushafPage>> call(GetPageParams params) {
    return repository.getPage(
      params.pageNumber,
      translation: params.translation,
    );
  }
}

class GetPageParams {
  final int pageNumber;
  final String? translation;
  
  const GetPageParams({
    required this.pageNumber,
    this.translation,
  });
}
