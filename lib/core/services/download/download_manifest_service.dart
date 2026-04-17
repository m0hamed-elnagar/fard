import 'dart:io';

import 'package:fard/core/models/download_entry.dart';
import 'package:fard/core/utils/file_download_utils.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

abstract class DownloadManifestService {
  Future<DownloadEntry?> getEntry(String fileId);
  Future<void> upsertEntry(DownloadEntry entry);
  Future<List<DownloadEntry>> getEntriesByStatus(DownloadStatus status);
  Future<List<DownloadEntry>> getEntriesByContentType(String contentType);
  Future<List<DownloadEntry>> getEntriesByReciter(String reciterId);
  Future<void> deleteEntry(String fileId);
  Future<void> deleteEntriesByReciter(String reciterId);
  Future<void> deleteEntriesByContentType(String contentType);
  Future<void> deleteEntriesBySurah(String reciterId, int surahNumber);
  Future<List<DownloadEntry>> getEntriesBySurah(String reciterId, int surahNumber);
  Future<void> clearAll();
  Future<bool> verifyIntegrity(String fileId);
  Stream<DownloadEntry?> watchEntry(String fileId);
  Stream<BoxEvent> watchAll();
}

@LazySingleton(as: DownloadManifestService)
class DownloadManifestServiceImpl implements DownloadManifestService {
  static const String boxName = 'download_manifest_box';

  Box<DownloadEntry> get _box => Hive.box<DownloadEntry>(boxName);

  @override
  Future<DownloadEntry?> getEntry(String fileId) async {
    return _box.get(fileId);
  }

  @override
  Future<void> upsertEntry(DownloadEntry entry) async {
    await _box.put(entry.fileId, entry);
  }

  @override
  Future<List<DownloadEntry>> getEntriesByStatus(DownloadStatus status) async {
    return _box.values.where((e) => e.status == status).toList();
  }

  @override
  Future<List<DownloadEntry>> getEntriesByContentType(String contentType) async {
    return _box.values.where((e) => e.contentType == contentType).toList();
  }

  @override
  Future<List<DownloadEntry>> getEntriesByReciter(String reciterId) async {
    return _box.values.where((e) => e.reciterId == reciterId).toList();
  }

  @override
  Future<List<DownloadEntry>> getEntriesBySurah(String reciterId, int surahNumber) async {
    return _box.values
        .where((e) => e.reciterId == reciterId && e.surahNumber == surahNumber)
        .toList();
  }

  @override
  Future<void> deleteEntry(String fileId) async {
    await _box.delete(fileId);
  }

  @override
  Future<void> deleteEntriesByReciter(String reciterId) async {
    final keys = _box.values
        .where((e) => e.reciterId == reciterId)
        .map((e) => e.fileId)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<void> deleteEntriesByContentType(String contentType) async {
    final keys = _box.values
        .where((e) => e.contentType == contentType)
        .map((e) => e.fileId)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<void> deleteEntriesBySurah(String reciterId, int surahNumber) async {
    final keys = _box.values
        .where((e) => e.reciterId == reciterId && e.surahNumber == surahNumber)
        .map((e) => e.fileId)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  Future<bool> verifyIntegrity(String fileId) async {
    final entry = await getEntry(fileId);
    if (entry == null) return false;

    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/audio/${entry.relativePath}');
    
    if (!await file.exists()) {
      if (entry.status == DownloadStatus.completed) {
        await upsertEntry(entry.copyWith(
          status: DownloadStatus.pending,
          downloadedBytes: 0,
        ));
      }
      return false;
    }

    final actualSize = await file.length();
    
    // If it's supposed to be completed, verify strictly
    if (entry.status == DownloadStatus.completed) {
      if (actualSize != entry.expectedSize) {
        await upsertEntry(entry.copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'Size mismatch: expected ${entry.expectedSize}, got $actualSize',
        ));
        return false;
      }
      
      // Content specific checks
      if (entry.contentType == 'audio') {
        final isValid = await FileDownloadUtils.isValidAudioFile(file.path);
        if (!isValid) {
          await upsertEntry(entry.copyWith(status: DownloadStatus.failed, errorMessage: 'Invalid audio header'));
          return false;
        }
      }
    } else {
      // If it's pending/downloading/failed, just update the downloadedBytes to match disk
      if (entry.downloadedBytes != actualSize) {
        await upsertEntry(entry.copyWith(downloadedBytes: actualSize));
      }
    }

    return true;
  }

  @override
  Stream<DownloadEntry?> watchEntry(String fileId) {
    return _box.watch(key: fileId).map((event) => event.value as DownloadEntry?);
  }

  @override
  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }
}
