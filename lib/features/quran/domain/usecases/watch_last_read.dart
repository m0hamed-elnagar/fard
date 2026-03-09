import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchLastRead {
  final QuranRepository repository;

  WatchLastRead(this.repository);

  Stream<Result<LastReadPosition>> call() {
    return repository.watchLastReadPosition();
  }
}
