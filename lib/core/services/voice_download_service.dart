import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:fard/core/models/download_entry.dart';
import 'package:fard/core/services/download/download_manifest_service.dart';
import 'package:fard/core/utils/file_download_utils.dart';

@singleton
class VoiceDownloadService {
  final DownloadManifestService _manifestService;
  Future<void>? _activeDownloadTask;
  http.Client? _activeClient;

  VoiceDownloadService(this._manifestService);

  static const Map<String, String> azanVoices = {
    'Ibrahim Al-Arkani - إبراهيم الأركاني':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Ibrahim%20Al-Arkani.mp3',
    'Majed Al-Hamathani - ماجد الهمذاني':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Majed%20Al-hamathani.mp3',
    'Mansoor Az-Zahrani - منصور الزهراني':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Mansoor%20Az-Zahrani.mp3',
    'Makkah Haram (Beautiful) - مكة المكرمة':
        'https://www.islamcan.com/audio/adhan/azan16.mp3',
    'Ali Ahmed Mala (Madinah) - علي أحمد ملا':
        'https://www.islamcan.com/audio/adhan/azan20.mp3',
    'Abdul Basit - عبد الباسط':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Abed%20Albase6.mp3',
    'Mishary Rashid Alafasy - مشاري العفاسي':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Mishary%20Alafasi.mp3',
    'Ahmad Al-Nufais - أحمد النفيس':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Ahmad%20Nuyne3.mp3',
    'Saad Al-Ghamdi - سعد الغامدي':
        'https://www.islamcan.com/audio/adhan/azan21.mp3',
    'Nasser Al-Qatami - ناصر القطامي':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Nasser%20Alqatami.mp3',
    'Muhammad Siddiq Al-Minshawi - محمد صديق المنشاوي':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Mohammad%20Almenshawy.mp3',
    'Mahmoud Khalil Al-Husary - محمود خليل الحصري':
        'https://www.islamcan.com/audio/adhan/azan3.mp3',
    'Muhammad Refaat - محمد رفعت':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Mohammad%20Ref3at.mp3',
    'Mansour Al-Salimi - منصور السالمي':
        'https://www.islamcan.com/audio/adhan/azan6.mp3',
    'Muhammad Al-Luhaidan - محمد اللحيدان':
        'https://www.islamcan.com/audio/adhan/azan14.mp3',
    'Wadii Al-Yamani - وديع اليمني':
        'https://www.islamcan.com/audio/adhan/azan12.mp3',
    'Al-Aqsa Mosque (Palestine) - المسجد الأقصى':
        'https://www.islamcan.com/audio/adhan/azan2.mp3',
    'Turkish Style Adhan - أذان تركي':
        'https://www.islamcan.com/audio/adhan/azan19.mp3',
    'Bosnian Style Adhan - أذان البوسنة':
        'https://www.islamcan.com/audio/adhan/azan5.mp3',
    'Adhan Kuwait - أذان الكويت':
        'https://www.islamcan.com/audio/adhan/azan8.mp3',
    'Yasser Al-Filkawi - ياسر الفيلكاوي':
        'https://www.islamcan.com/audio/adhan/azan11.mp3',
    'Abdul Majid Al-Surehi - عبدالمجيد السريحي':
        'https://www.islamcan.com/audio/adhan/azan13.mp3',
    'Makkah Haram (Fajr) - أذان الفجر من مكة':
        'https://www.islamcan.com/audio/adhan/azan17.mp3',
    'Madinah Haram (Fajr) - أذان الفجر من المدينة':
        'https://www.islamcan.com/audio/adhan/azan18.mp3',
    'Makkah Haram (Old Style) - الحرم المكي':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Makkah.mp3',
    'Yusuf Islam - يوسف إسلام':
        'https://www.islamcan.com/audio/adhan/azan10.mp3',
    'Suhaib Khatba - صهيب خطبة':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Suhaib%20Khatba.mp3',
    'Hamad Deghreri - حمد دغريري':
        'https://raw.githubusercontent.com/abodehq/Athan-MP3/master/Sounds/Athan%20Hamad%20Deghreri.mp3',
  };

  String _getFileName(String voiceName) {
    // Extract a stable identifier from the URL to avoid re-downloading when renaming display names
    final url = azanVoices[voiceName];
    if (url != null) {
      final uri = Uri.parse(url);
      var fileName = uri.pathSegments.last;
      // Handle encoded spaces and special characters
      fileName = Uri.decodeComponent(fileName);
      // Ensure we don't have invalid filesystem characters
      fileName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      return 'voice_$fileName';
    }
    return '${voiceName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_azan.mp3';
  }

  Future<String?> downloadAzan(String voiceName) async {
    // 1. Cancel previous download if it's still running
    _activeClient?.close();
    _activeClient = null;

    if (_activeDownloadTask != null) {
      debugPrint(
        'VoiceDownloadService: Cancelling previous download to prioritize $voiceName...',
      );
      try {
        await _activeDownloadTask;
      } catch (_) {
        // Ignore errors from cancelled task
      }
    }

    final completer = Completer<void>();
    _activeDownloadTask = completer.future;

    try {
      final result = await _performDownload(voiceName);
      return result;
    } finally {
      completer.complete();
      // Only clear if we are still the active task (don't clear a newer task's state)
      if (_activeDownloadTask == completer.future) {
        _activeDownloadTask = null;
      }
    }
  }

  Future<String?> _performDownload(String voiceName) async {
    final url = azanVoices[voiceName];
    if (url == null) return null;

    final fileId = 'azan_${voiceName.replaceAll(' ', '_')}';
    var entry = await _manifestService.getEntry(fileId);

    // Detect URL changes and reset if necessary
    if (entry != null && entry.url != url) {
      debugPrint(
        'VoiceDownloadService: URL changed for $voiceName. Resetting.',
      );
      final oldPath = await getLocalPath(voiceName);
      final oldFile = File(oldPath);
      if (await oldFile.exists()) await oldFile.delete();
      entry = null;
    }

    entry ??= await _syncManifestForVoice(voiceName);

    if (entry.status == DownloadStatus.completed) {
      final path = await getLocalPath(voiceName);
      final file = File(path);
      if (await file.exists() && await file.length() > 1000) {
        return path;
      }
      // Corrupted or missing, reset
      entry = entry.copyWith(
        status: DownloadStatus.pending,
        downloadedBytes: 0,
      );
      await _manifestService.upsertEntry(entry);
    }

    // Assign the client to the instance variable so it can be cancelled
    _activeClient = http.Client();
    final client = _activeClient!;

    try {
      await _manifestService.upsertEntry(
        entry.copyWith(
          status: DownloadStatus.downloading,
          updatedAt: DateTime.now(),
        ),
      );

      final directory = await getApplicationSupportDirectory();
      final fileName = _getFileName(voiceName);
      final finalPath = '${directory.path}/$fileName';
      final file = File(finalPath);

      final Map<String, String> headers = {
        'User-Agent': 'FardApp/1.0 (Mobile; AzanDownloader)',
        'Accept': 'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
        'Connection': 'close',
      };

      int startByte = 0;
      if (await file.exists() && entry.downloadedBytes > 0) {
        startByte = await file.length();
        if (startByte > 0 && startByte < entry.expectedSize) {
          headers['Range'] = 'bytes=$startByte-';
        }
      }

      http.Response response;
      int retryCount = 0;
      const maxRetries = 3;

      while (true) {
        try {
          response = await client
              .get(Uri.parse(url), headers: headers)
              .timeout(const Duration(seconds: 60));
          break;
        } catch (e) {
          // If the client was closed from outside, don't retry, just propagate
          if (_activeClient != client) throw Exception('Download cancelled');

          if (retryCount < maxRetries) {
            retryCount++;
            debugPrint(
              'VoiceDownloadService: Retry $retryCount/3 for $voiceName: $e',
            );
            await Future.delayed(Duration(seconds: 2 * retryCount));
            continue;
          }
          rethrow;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 206) {
        final isPartial = response.statusCode == 206;

        if (isPartial) {
          await FileDownloadUtils.appendToFile(
            bytes: response.bodyBytes,
            path: finalPath,
          );
        } else {
          await FileDownloadUtils.atomicWriteFile(
            bytes: response.bodyBytes,
            finalPath: finalPath,
            fileType: 'audio',
          );
        }

        int totalSize = response.contentLength ?? response.bodyBytes.length;
        if (isPartial) {
          final contentRange = response.headers['content-range'];
          if (contentRange != null) {
            final parts = contentRange.split('/');
            if (parts.length > 1) {
              totalSize = int.tryParse(parts[1]) ?? totalSize;
            }
          }
          totalSize = startByte + response.bodyBytes.length;
        }

        final currentSize = isPartial
            ? (startByte + response.bodyBytes.length)
            : response.bodyBytes.length;
        final isDone = response.statusCode == 200 || currentSize >= totalSize;

        await _manifestService.upsertEntry(
          entry.copyWith(
            status: isDone
                ? DownloadStatus.completed
                : DownloadStatus.downloading,
            downloadedBytes: currentSize,
            expectedSize: totalSize,
            url: url,
            updatedAt: DateTime.now(),
          ),
        );

        if (isDone) {
          debugPrint('Successfully downloaded $voiceName to ${file.path}');
          return file.path;
        }
        return null;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (_activeClient != client) {
        debugPrint(
          'VoiceDownloadService: Download for $voiceName was cancelled.',
        );
        return null;
      }
      await _manifestService.upsertEntry(
        entry.copyWith(
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
          updatedAt: DateTime.now(),
          attemptCount: entry.attemptCount + 1,
        ),
      );
      debugPrint('VoiceDownloadService: Failed to download $voiceName: $e');
    } finally {
      if (_activeClient == client) {
        client.close();
        _activeClient = null;
      }
    }
    return null;
  }

  Future<bool> isDownloaded(String voiceName) async {
    final url = azanVoices[voiceName];
    if (url == null) return false;

    final fileId = 'azan_${voiceName.replaceAll(' ', '_')}';
    final entry = await _manifestService.getEntry(fileId);

    if (entry != null && entry.status == DownloadStatus.completed) {
      // Must match current URL and exist on disk
      if (entry.url != url) return false;

      final path = await getLocalPath(voiceName);
      final file = File(path);
      return await file.exists() && await file.length() > 1000;
    }

    // Check disk anyway in case manifest is out of sync
    final localPath = await getLocalPath(voiceName);
    final file = File(localPath);
    if (await file.exists() && await file.length() > 1000) {
      // Recover manifest state
      await _syncManifestForVoice(voiceName);
      return true;
    }

    return false;
  }

  Future<String> getLocalPath(String voiceName) async {
    final directory = await getApplicationSupportDirectory();
    final fileName = _getFileName(voiceName);
    return '${directory.path}/$fileName';
  }

  Future<DownloadEntry> _syncManifestForVoice(String voiceName) async {
    final url = azanVoices[voiceName] ?? '';
    final localPath = await getLocalPath(voiceName);
    final file = File(localPath);
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;

    final entry = DownloadEntry(
      fileId: 'azan_${voiceName.replaceAll(' ', '_')}',
      relativePath: _getFileName(voiceName),
      contentType: 'azan_voice',
      url: url,
      expectedSize: size > 0
          ? size
          : 2 * 1024 * 1024, // Estimate 2MB if not exists
      downloadedBytes: exists ? size : 0,
      status: exists ? DownloadStatus.completed : DownloadStatus.pending,
      updatedAt: DateTime.now(),
    );

    await _manifestService.upsertEntry(entry);
    return entry;
  }

  Future<String?> getAccessiblePath(String voiceName) async {
    final fileName = _getFileName(voiceName);
    final localPath = await getLocalPath(voiceName);
    final file = File(localPath);
    if (!(await file.exists())) {
      debugPrint('VoiceDownloadService: File does not exist at $localPath');
      return null;
    }

    if (Platform.isAndroid) {
      try {
        final List<Directory>? directories =
            await getExternalStorageDirectories(
              type: StorageDirectory.notifications,
            );
        final externalDir =
            directories?.firstOrNull ?? (await getExternalStorageDirectory());

        if (externalDir != null) {
          final dir = Directory('${externalDir.path}/azan_sounds');
          if (!(await dir.exists())) await dir.create(recursive: true);

          final accessibleFile = File('${dir.path}/$fileName');

          if (!(await accessibleFile.exists()) ||
              (await accessibleFile.length() != await file.length())) {
            debugPrint(
              'VoiceDownloadService: Copying Azan to system-accessible path: ${accessibleFile.path}',
            );
            await file.copy(accessibleFile.path);
          }
          return accessibleFile.path;
        }
      } catch (e) {
        debugPrint('VoiceDownloadService: Error preparing accessible path: $e');
      }
    }

    return localPath;
  }
}
