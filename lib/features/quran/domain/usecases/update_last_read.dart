import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';

class UpdateLastRead {
  final QuranRepository repository;

  UpdateLastRead(this.repository);

  Future<Result<void>> call(LastReadPosition position) async {
    return repository.updateLastReadPosition(position);
  }
}
