import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

abstract interface class BookmarkRepository {
  Future<Result<List<Bookmark>>> getBookmarks();
  Stream<Result<List<Bookmark>>> watchBookmarks();
  Future<Result<void>> addBookmark(Bookmark bookmark);
  Future<Result<void>> removeBookmark(AyahNumber ayahNumber);
  Future<Result<void>> clearAllBookmarks();
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber);
}
