import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchBookmarks {
  final BookmarkRepository _repository;

  WatchBookmarks(this._repository);

  Stream<Result<List<Bookmark>>> call() {
    return _repository.watchBookmarks();
  }
}
