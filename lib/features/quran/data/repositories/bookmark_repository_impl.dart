import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';
import 'package:hive_ce/hive_ce.dart';
import 'dart:async';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookmarkRepository)
class BookmarkRepositoryImpl implements BookmarkRepository {
  final Box<BookmarkEntity> _bookmarkBox;
  static const String boxName = 'quran_bookmarks';

  BookmarkRepositoryImpl(@Named('bookmarkBox') this._bookmarkBox);

  String _getKey(AyahNumber ayahNumber) => 
      '${ayahNumber.surahNumber}_${ayahNumber.ayahNumberInSurah}';

  @override
  Future<Result<List<Bookmark>>> getBookmarks() async {
    try {
      final entities = _bookmarkBox.values.toList();
      return Result.success(entities.map(_toDomain).toList());
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Result<List<Bookmark>>> watchBookmarks() {
    // Using a StreamController to emit the initial value and then any subsequent changes
    final controller = StreamController<Result<List<Bookmark>>>();
    
    void emitCurrent() {
      if (controller.isClosed) return;
      try {
        final entities = _bookmarkBox.values.toList();
        controller.add(Result.success(entities.map(_toDomain).toList()));
      } catch (e) {
        controller.add(Result.failure(UnknownFailure(e.toString())));
      }
    }

    // Emit initial values
    emitCurrent();

    // Listen for changes and emit
    final subscription = _bookmarkBox.watch().listen((_) => emitCurrent());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<Result<void>> addBookmark(Bookmark bookmark) async {
    try {
      final entity = _toEntity(bookmark);
      await _bookmarkBox.put(_getKey(bookmark.ayahNumber), entity);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeBookmark(AyahNumber ayahNumber) async {
    try {
      // 1. Try deleting by current key format
      await _bookmarkBox.delete(_getKey(ayahNumber));
      
      // 2. Scan for any remaining entities with same surah/ayah (handles old key formats)
      final keysToDelete = <dynamic>[];
      for (var i = 0; i < _bookmarkBox.length; i++) {
        final entity = _bookmarkBox.getAt(i);
        if (entity != null && 
            entity.surahNumber == ayahNumber.surahNumber && 
            entity.ayahNumber == ayahNumber.ayahNumberInSurah) {
          keysToDelete.add(_bookmarkBox.keyAt(i));
        }
      }
      
      if (keysToDelete.isNotEmpty) {
        await _bookmarkBox.deleteAll(keysToDelete);
      }
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearAllBookmarks() async {
    try {
      await _bookmarkBox.clear();
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber) async {
    try {
      final exists = _bookmarkBox.containsKey(_getKey(ayahNumber));
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
