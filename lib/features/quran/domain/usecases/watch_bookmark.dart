import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';

class WatchBookmark {
  final BookmarkRepository _repository;

  WatchBookmark(this._repository);

  Stream<Result<Bookmark?>> call() {
    return _repository.watchBookmark();
  }
}
