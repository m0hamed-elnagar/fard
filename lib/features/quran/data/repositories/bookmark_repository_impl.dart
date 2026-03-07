import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';
import 'package:hive_ce/hive_ce.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final Box<BookmarkEntity> _bookmarkBox;
  static const String boxName = 'quran_bookmarks';
  static const String _activeBookmarkKey = 'active_bookmark';

  BookmarkRepositoryImpl(this._bookmarkBox);

  @override
  Future<Result<Bookmark?>> getBookmark() async {
    try {
      final entity = _bookmarkBox.get(_activeBookmarkKey);
      return Result.success(entity != null ? _toDomain(entity) : null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Result<Bookmark?>> watchBookmark() {
    return _bookmarkBox.watch(key: _activeBookmarkKey).map((event) {
      try {
        final entity = _bookmarkBox.get(_activeBookmarkKey);
        return Result.success(entity != null ? _toDomain(entity) : null);
      } catch (e) {
        return Result.failure(UnknownFailure(e.toString()));
      }
    });
  }

  @override
  Future<Result<void>> setBookmark(Bookmark bookmark) async {
    try {
      final entity = _toEntity(bookmark);
      await _bookmarkBox.put(_activeBookmarkKey, entity);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearBookmark() async {
    try {
      await _bookmarkBox.delete(_activeBookmarkKey);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber) async {
    try {
      final entity = _bookmarkBox.get(_activeBookmarkKey);
      if (entity == null) return Result.success(false);
      
      final exists = entity.surahNumber == ayahNumber.surahNumber && 
                     entity.ayahNumber == ayahNumber.ayahNumberInSurah;
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
