import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';

class SearchQuran implements UseCase<List<SearchResult>, SearchParams> {
  final QuranRepository repository;
  
  const SearchQuran(this.repository);
  
  @override
  Future<Result<List<SearchResult>>> call(SearchParams params) {
    return repository.search(params.query);
  }
}

class SearchParams {
  final String query;
  
  const SearchParams({required this.query});
}
