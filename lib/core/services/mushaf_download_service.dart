import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class MushafDownloadService {
  // Using everyayah.com as it is more reliable for individual PNGs
  static const String baseUrl = 'https://everyayah.com/data/images_png/';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/mushaf_pages';
  }

  Future<File> getLocalFile(int pageNumber) async {
    final path = await _localPath;
    return File('$path/$pageNumber.png');
  }

  Future<bool> isPageDownloaded(int pageNumber) async {
    final file = await getLocalFile(pageNumber);
    return file.exists();
  }

  Future<String?> downloadPage(int pageNumber) async {
    try {
      // everyayah.com uses 1.png, 2.png etc.
      final url = '$baseUrl$pageNumber.png';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final file = await getLocalFile(pageNumber);
        
        // Ensure directory exists
        final directory = Directory(file.parent.path);
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        debugPrint('Failed to download page $pageNumber: status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading page $pageNumber: $e');
    }
    return null;
  }

  Stream<double> downloadAllPages() async* {
    int totalPages = 604;
    int downloadedCount = 0;

    for (int i = 1; i <= totalPages; i++) {
      if (await isPageDownloaded(i)) {
        downloadedCount++;
        yield downloadedCount / totalPages;
        continue;
      }

      final result = await downloadPage(i);
      if (result != null) {
        downloadedCount++;
      }
      yield downloadedCount / totalPages;
    }
  }
}
