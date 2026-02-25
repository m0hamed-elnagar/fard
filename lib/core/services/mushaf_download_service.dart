import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class MushafDownloadService {
  // Reliable GitHub Raw Source
  static const String baseUrl = 'https://raw.githubusercontent.com/BetimShala/quran-images-api/master/quran-images/';
  
  // Track active downloads to prevent redundant requests
  final Map<int, Future<String?>> _activeDownloads = {};

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/mushaf_pages';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<File> getLocalFile(int pageNumber) async {
    final path = await _localPath;
    return File('$path/$pageNumber.png');
  }

  /// Clears all downloaded Mushaf pages
  Future<void> clearCache() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing mushaf cache: $e');
    }
  }

  Future<bool> isPageDownloaded(int pageNumber) async {
    try {
      final file = await getLocalFile(pageNumber);
      if (!await file.exists()) return false;
      // Ensure file is not empty
      final length = await file.length();
      return length > 512; // GitHub images for page 1/2 are around 40-50KB
    } catch (e) {
      return false;
    }
  }

  Future<String?> downloadPage(int pageNumber, {int retryCount = 2}) async {
    if (pageNumber < 1 || pageNumber > 604) return null;
    
    // Check if already being downloaded
    if (_activeDownloads.containsKey(pageNumber)) {
      return _activeDownloads[pageNumber];
    }

    final downloadTask = _performDownloadWithRetry(pageNumber, retryCount);
    _activeDownloads[pageNumber] = downloadTask;

    try {
      return await downloadTask;
    } finally {
      _activeDownloads.remove(pageNumber);
    }
  }

  Future<String?> _performDownloadWithRetry(int pageNumber, int retries) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final result = await _performDownload(pageNumber);
        if (result != null) return result;
        
        if (i < retries) {
          debugPrint('Retrying download for page $pageNumber (attempt ${i + 2})');
          await Future.delayed(Duration(seconds: i + 1));
        }
      } catch (e) {
        if (i == retries) rethrow;
      }
    }
    return null;
  }

  Future<String?> _performDownload(int pageNumber) async {
    try {
      final file = await getLocalFile(pageNumber);
      
      // Try primary API (GitHub)
      final url = '$baseUrl$pageNumber.png';
      debugPrint('Downloading page $pageNumber from $url');
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200 && response.bodyBytes.length > 1024) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Successfully downloaded page $pageNumber from GitHub');
        return file.path;
      } else {
        debugPrint('GitHub source failed for page $pageNumber (Status: ${response.statusCode})');
        return await _downloadFromFallback(pageNumber);
      }
    } catch (e) {
      debugPrint('Error downloading page $pageNumber: $e');
      return await _downloadFromFallback(pageNumber);
    }
  }

  Future<String?> _downloadFromFallback(int pageNumber) async {
    // Fallback 1: KSU (Adjusted offset if page 1 is cover)
    try {
      // If user says KSU page 1 is a cover, then KFC page 1 is KSU page 2 or 3
      // For now, we try to match page numbers directly or with +1/+2
      // But let's try direct first as KSU is very high quality
      final url = 'http://quran.ksu.edu.sa/png_big/$pageNumber.png';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 && response.bodyBytes.length > 5000) {
        final file = await getLocalFile(pageNumber);
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {}

    return null;
  }

  Future<void> prefetchPages(int currentPage, {int count = 3}) async {
    // Prefetch in a non-blocking way
    final List<int> pagesToFetch = [];
    
    // Next pages (priority)
    for (int i = 1; i <= count; i++) {
      int nextPage = currentPage + i;
      if (nextPage <= 604) pagesToFetch.add(nextPage);
    }
    
    // Previous pages
    for (int i = 1; i <= 2; i++) {
      int prevPage = currentPage - i;
      if (prevPage >= 1) pagesToFetch.add(prevPage);
    }

    for (var page in pagesToFetch) {
      if (!(await isPageDownloaded(page))) {
        downloadPage(page); // Don't await, let it run in background
      }
    }
  }

  Stream<double> downloadAllPages() async* {
    const int totalPages = 604;
    int downloadedCount = 0;
    
    // Initial count
    for (int i = 1; i <= totalPages; i++) {
      if (await isPageDownloaded(i)) downloadedCount++;
    }
    yield downloadedCount / totalPages;

    // Download in chunks to be faster but not overwhelm the system
    const int chunkSize = 5;
    for (int i = 1; i <= totalPages; i += chunkSize) {
      final List<Future<String?>> chunkFutures = [];
      
      for (int j = 0; j < chunkSize && (i + j) <= totalPages; j++) {
        final pageNum = i + j;
        if (!(await isPageDownloaded(pageNum))) {
          chunkFutures.add(downloadPage(pageNum, retryCount: 3));
        } else {
          // Already counted, but we need to keep the progress yielding logic consistent
        }
      }

      if (chunkFutures.isNotEmpty) {
        await Future.wait(chunkFutures);
        
        // Recalculate downloaded count
        int currentCount = 0;
        for (int k = 1; k <= totalPages; k++) {
          if (await isPageDownloaded(k)) currentCount++;
        }
        downloadedCount = currentCount;
        yield downloadedCount / totalPages;
      }
    }
    
    yield 1.0;
  }
}
