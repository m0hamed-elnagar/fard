import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

abstract interface class BookmarkRepository {
  Future<Result<List<Bookmark>>> getBookmarks();
  Future<Result<void>> addBookmark(Bookmark bookmark);
  Future<Result<void>> removeBookmark(String id);
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber);
}
