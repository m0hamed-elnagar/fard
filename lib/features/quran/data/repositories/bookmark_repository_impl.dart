import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';
import 'package:hive_ce/hive_ce.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final Box<BookmarkEntity> _bookmarkBox;
  static const String boxName = 'quran_bookmarks';

  BookmarkRepositoryImpl(this._bookmarkBox);

  @override
  Future<Result<List<Bookmark>>> getBookmarks() async {
    try {
      final bookmarks = _bookmarkBox.values.map(_toDomain).toList();
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Result.success(bookmarks);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addBookmark(Bookmark bookmark) async {
    try {
      final entity = _toEntity(bookmark);
      await _bookmarkBox.put(entity.id, entity);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeBookmark(String id) async {
    try {
      await _bookmarkBox.delete(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber) async {
    try {
      final exists = _bookmarkBox.values.any((e) => 
        e.surahNumber == ayahNumber.surahNumber && 
        e.ayahNumber == ayahNumber.ayahNumberInSurah
      );
      return Result.success(exists);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Bookmark _toDomain(BookmarkEntity e) {
    return Bookmark(
      id: e.id,
      ayahNumber: AyahNumber.create(
        surahNumber: e.surahNumber,
        ayahNumberInSurah: e.ayahNumber,
      ).data!,
      createdAt: e.createdAt,
      note: e.note,
    );
  }

  BookmarkEntity _toEntity(Bookmark b) {
    return BookmarkEntity(
      id: b.id,
      surahNumber: b.ayahNumber.surahNumber,
      ayahNumber: b.ayahNumber.ayahNumberInSurah,
      createdAt: b.createdAt,
      note: b.note,
    );
  }
}
