import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fard/features/quran/domain/models/surah.dart';
import 'package:fard/features/quran/domain/models/ayah.dart';

class QuranRepository {
  final http.Client _client;
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  QuranRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Surah>> getSurahs() async {
    final response = await _client.get(Uri.parse('$_baseUrl/surah'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surahsJson = data['data'];
      return surahsJson.map((json) => Surah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  Future<List<Ayah>> getSurahAyahs(int surahNumber, {String edition = 'quran-uthmani'}) async {
    final response = await _client.get(Uri.parse('$_baseUrl/surah/$surahNumber/$edition'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ayahsJson = data['data']['ayahs'];
      return ayahsJson.map((json) => Ayah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ayahs for surah $surahNumber');
    }
  }

  Future<SurahDetail> getSurahDetail(int surahNumber, {String edition = 'quran-uthmani'}) async {
    final response = await _client.get(Uri.parse('$_baseUrl/surah/$surahNumber/$edition'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SurahDetail.fromJson(data['data']);
    } else {
      throw Exception('Failed to load detail for surah $surahNumber');
    }
  }

  Future<List<Ayah>> searchAyahs(String query) async {
    // Note: The API search endpoint might have limitations or require specific editions.
    // This is a basic implementation using the search endpoint.
    final response = await _client.get(Uri.parse('$_baseUrl/search/$query/all/en.pickthall'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['data']['matches'];
      // Mapping might be different for search results
      return results.map((json) => Ayah.fromJson(json)).toList();
    } else {
      throw Exception('Search failed');
    }
  }
}
