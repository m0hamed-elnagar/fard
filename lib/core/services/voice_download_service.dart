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
  final http.Client _client = http.Client();

  VoiceDownloadService(this._manifestService);

  static const Map<String, String> azanVoices = {
    'Abdul Basit - عبد الباسط':
        'https://www.ayouby.com/multimedia/Call_of_Prayer/Athan_AB.mp3',
    'Mishary Rashid Alafasy - مشاري العفاسي':
        'https://media.assabile.com/media/adhan/mishary-rashid-alafasy/mishary-rashid-alafasy-1.mp3',
    'Ali Ahmed Mala (Madinah) - علي أحمد ملا':
        'https://www.islamcan.com/audio/adhan/azan20.mp3',
    'Muhammad Siddiq Al-Minshawi - محمد صديق المنشاوي':
        'https://www.islamcan.com/audio/adhan/azan1.mp3',
    'Al-Aqsa Mosque (Palestine) - المسجد الأقصى':
        'https://www.islamcan.com/audio/adhan/azan2.mp3',
    'Turkish Style Adhan - أذان تركي':
        'https://aladhan.com/storage/audio/mustafa_ozcan/1.mp3',
    'Makkah Haram (Beautiful) - مكة المكرمة':
        'https://www.islamcan.com/audio/adhan/azan10.mp3',
    'Bosnian Style Adhan - أذان البوسنة':
        'https://www.islamcan.com/audio/adhan/azan5.mp3',
    'Nasser Al-Qatami - ناصر القطامي':
        'https://www.islamcan.com/audio/adhan/azan15.mp3',
    'Muhammad Al-Luhaidan - محمد اللحيدان':
        'https://www.islamcan.com/audio/adhan/azan14.mp3',
    'Makkah Haram (Fajr) - أذان الفجر من مكة':
        'https://www.islamcan.com/audio/adhan/azan16.mp3',
    'Madinah Haram (Fajr) - أذان الفجر من المدينة':
        'https://www.islamcan.com/audio/adhan/azan17.mp3',
    'Saad Al-Ghamdi - سعد الغامدي':
        'https://www.islamcan.com/audio/adhan/azan21.mp3',
    'Egyptian Style Adhan - أذان مصري':
        'https://www.islamcan.com/audio/adhan/azan4.mp3',
    'Yusuf Islam - يوسف إسلام':
        'https://www.islamcan.com/audio/adhan/azan6.mp3',
    'Makkah Haram (Old Style) - الحرم المكي':
        'https://www.islamcan.com/audio/adhan/azan8.mp3',
    'Mahmoud Khalil Al-Husary - محمود خليل الحصري':
        'https://media.assabile.com/media/adhan/mahmoud-khalil-al-hussary/mahmoud-khalil-al-hussary-1.mp3',
    'Mansour Al-Salimi - منصور السالمي':
        'https://archive.org/download/adhan_202102/Mansour%20Al-Salimi.mp3',
    'Wadii Al-Yamani - وديع اليمني':
        'https://archive.org/download/adhan_202102/Wadih%20Al-Yamani.mp3',
  };

  String _getFileName(String voiceName) {
    // Extract a stable identifier from the URL to avoid re-downloading when renaming display names
    final url = azanVoices[voiceName];
    if (url != null) {
      final uri = Uri.parse(url);
      final fileName = uri.pathSegments.last;
      return 'voice_$fileName';
    }
    return '${voiceName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_azan.mp3';
  }

  Future<String?> downloadAzan(String voiceName) async {
    final url = azanVoices[voiceName];
    if (url == null) return null;

    final fileId = 'azan_${voiceName.replaceAll(' ', '_')}';
    var entry = await _manifestService.getEntry(fileId);

    entry ??= await _syncManifestForVoice(voiceName);

    if (entry.status == DownloadStatus.completed) {
      final path = await getLocalPath(voiceName);
      if (await File(path).exists()) return path;
      // If manifest says completed but file is gone, reset entry
      entry = entry.copyWith(status: DownloadStatus.pending, downloadedBytes: 0);
      await _manifestService.upsertEntry(entry);
    }

    try {
      await _manifestService.upsertEntry(entry.copyWith(
        status: DownloadStatus.downloading,
        updatedAt: DateTime.now(),
      ));

      final directory = await getApplicationSupportDirectory();
      final fileName = _getFileName(voiceName);
      final finalPath = '${directory.path}/$fileName';
      final file = File(finalPath);
      
      final Map<String, String> headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
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
      const maxRetries = 2;

      while (true) {
        try {
          response = await _client
              .get(Uri.parse(url), headers: headers)
              .timeout(const Duration(seconds: 45));
          break;
        } catch (e) {
          if (retryCount < maxRetries && (e.toString().contains('Connection closed') || e is http.ClientException)) {
            retryCount++;
            debugPrint('VoiceDownloadService: Retry $retryCount for $voiceName due to connection error: $e');
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

        // Get total size from headers
        int totalSize = entry.expectedSize;
        if (isPartial) {
          final contentRange = response.headers['content-range'];
          if (contentRange != null) {
            final parts = contentRange.split('/');
            if (parts.length > 1) {
              totalSize = int.tryParse(parts[1]) ?? totalSize;
            }
          }
        } else {
          totalSize = response.contentLength ?? response.bodyBytes.length;
        }

        final currentSize = isPartial ? (startByte + response.bodyBytes.length) : response.bodyBytes.length;
        final isDone = currentSize >= totalSize;

        await _manifestService.upsertEntry(entry.copyWith(
          status: isDone ? DownloadStatus.completed : DownloadStatus.downloading,
          downloadedBytes: currentSize,
          expectedSize: totalSize,
          updatedAt: DateTime.now(),
        ));

        if (isDone) {
          debugPrint('Successfully downloaded $voiceName to ${file.path}');
          return file.path;
        } else {
          debugPrint('Partial download for $voiceName: $currentSize/$totalSize');
          return null;
        }
      } else {
        await _manifestService.upsertEntry(entry.copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'Status code: ${response.statusCode}',
          updatedAt: DateTime.now(),
          attemptCount: entry.attemptCount + 1,
        ));
        debugPrint(
          'Failed to download azan: Server returned status ${response.statusCode} for $url',
        );
      }
    } catch (e) {
      await _manifestService.upsertEntry(entry.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
        attemptCount: entry.attemptCount + 1,
      ));
      debugPrint('Exception during azan download ($voiceName) from $url: $e');
    }
    return null;
  }

  Future<bool> isDownloaded(String voiceName) async {
    final fileId = 'azan_${voiceName.replaceAll(' ', '_')}';
    final entry = await _manifestService.getEntry(fileId);
    
    if (entry != null) {
      return entry.status == DownloadStatus.completed;
    }

    // Lazy sync if manifest missing
    final synced = await _syncManifestForVoice(voiceName);
    return synced.status == DownloadStatus.completed;
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
      expectedSize: size > 0 ? size : 2 * 1024 * 1024, // Estimate 2MB if not exists
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
        // On Android, we need the file in a directory that the system notification service can access.
        // The app's external files directory (with StorageDirectory.notifications) is ideal.
        final List<Directory>? directories = await getExternalStorageDirectories(
          type: StorageDirectory.notifications,
        );
        final externalDir = directories?.firstOrNull ?? (await getExternalStorageDirectory());
        
        if (externalDir != null) {
          final dir = Directory('${externalDir.path}/azan_sounds');
          if (!(await dir.exists())) await dir.create(recursive: true);

          final accessibleFile = File('${dir.path}/$fileName');
          
          // Copy if not exists or size mismatch (indicates update)
          if (!(await accessibleFile.exists()) || 
              (await accessibleFile.length() != await file.length())) {
            debugPrint('VoiceDownloadService: Copying Azan to system-accessible path: ${accessibleFile.path}');
            await file.copy(accessibleFile.path);
          }
          return accessibleFile.path;
        }
      } catch (e) {
        debugPrint('VoiceDownloadService: Error preparing accessible path: $e');
        // Fallback to local path if external storage fails
      }
    }

    return localPath;
  }
}
