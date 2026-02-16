import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class VoiceDownloadService {
  static const Map<String, String> azanVoices = {
    'Abdul Basit (Egypt) - عبد الباسط (مصر)': 'https://www.ayouby.com/multimedia/Call_of_Prayer/Athan_AB.mp3',
    'Mishary Alafasy - مشاري العفاسي': 'https://www.islamcan.com/audio/adhan/azan7.mp3',
    'Ali Ahmed Mala (Madinah) - علي أحمد ملا': 'https://www.islamcan.com/audio/adhan/azan20.mp3',
    'Al-Minshawi (Egypt) - المنشاوي (مصر)': 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    'Al-Aqsa Mosque - المسجد الأقصى': 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    'Turkey Azan - أذان تركيا': 'https://www.islamcan.com/audio/adhan/azan3.mp3',
    'Makkah Beautiful - مكة المكرمة': 'https://www.islamcan.com/audio/adhan/azan10.mp3',
    'Bosnia Azan - أذان البوسنة': 'https://www.islamcan.com/audio/adhan/azan5.mp3',
    'Nasser Al-Qatami - ناصر القطامي': 'https://www.islamcan.com/audio/adhan/azan15.mp3',
    'Muhammad Al-Luhaidan - محمد اللحيدان': 'https://www.islamcan.com/audio/adhan/azan14.mp3',
    'Makkah Fajr - مكة المكرمة (فجر)': 'https://www.islamcan.com/audio/adhan/azan16.mp3',
    'Madinah Fajr - المدينة المنورة (فجر)': 'https://www.islamcan.com/audio/adhan/azan17.mp3',
    'Saad Al-Ghamdi - سعد الغامدي': 'https://www.islamcan.com/audio/adhan/azan21.mp3',
    'Azan 4 (Egypt) - أذان 4 (مصر)': 'https://www.islamcan.com/audio/adhan/azan4.mp3',
    'Azan 6 (Yusuf Islam) - أذان 6 (يوسف إسلام)': 'https://www.islamcan.com/audio/adhan/azan6.mp3',
    'Azan 8 (Makkah) - أذان 8 (مكة)': 'https://www.islamcan.com/audio/adhan/azan8.mp3',
  };

  String _getFileName(String voiceName) {
    return '${voiceName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_azan.mp3';
  }

  Future<String?> downloadAzan(String voiceName) async {
    final url = azanVoices[voiceName];
    if (url == null) return null;

    try {
      // Use a client that follows redirects
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = _getFileName(voiceName);
        final file = File('${directory.path}/$fileName');
        
        // Ensure directory exists
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes);
        
        if (response.bodyBytes.length < 1000) {
          debugPrint('Warning: Downloaded file for $voiceName is very small (${response.bodyBytes.length} bytes)');
        }
        
        debugPrint('Successfully downloaded $voiceName to ${file.path}');
        return file.path;
      } else {
        debugPrint('Failed to download azan: Server returned status ${response.statusCode} for $url');
      }
    } catch (e) {
      debugPrint('Exception during azan download ($voiceName) from $url: $e');
    }
    return null;
  }

  Future<bool> isDownloaded(String voiceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getFileName(voiceName);
    return File('${directory.path}/$fileName').exists();
  }
  
  Future<String> getLocalPath(String voiceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getFileName(voiceName);
    return '${directory.path}/$fileName';
  }

  Future<String?> getAccessiblePath(String voiceName) async {
    final fileName = _getFileName(voiceName);
    final localPath = await getLocalPath(voiceName);
    final file = File(localPath);
    if (!(await file.exists())) return null;

    try {
      // For Android, we often need the file in a directory that the system notification service can access
      // Using getExternalFilesDir(null) is often better than cache
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final dir = Directory('${externalDir.path}/azan_sounds');
        if (!(await dir.exists())) await dir.create(recursive: true);
        
        final accessibleFile = File('${dir.path}/$fileName');
        if (!(await accessibleFile.exists())) {
          await file.copy(accessibleFile.path);
        }
        return accessibleFile.path;
      }
      return localPath;
    } catch (e) {
      debugPrint('Error getting accessible path: $e');
      return localPath;
    }
  }
}
