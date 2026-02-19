import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';

class WatchLastRead {
  final QuranRepository repository;

  WatchLastRead(this.repository);

  Stream<Result<LastReadPosition>> call() {
    return repository.watchLastReadPosition();
  }
}
