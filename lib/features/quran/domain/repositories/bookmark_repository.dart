import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

abstract interface class BookmarkRepository {
  Future<Result<Bookmark?>> getBookmark();
  Stream<Result<Bookmark?>> watchBookmark();
  Future<Result<void>> setBookmark(Bookmark bookmark);
  Future<Result<void>> clearBookmark();
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber);
}
