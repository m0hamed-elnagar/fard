import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fard/features/quran/data/models/surah_model.dart';
import 'package:fard/features/quran/data/models/ayah_model.dart';
import 'package:fard/core/errors/failure.dart';

abstract interface class QuranRemoteSource {
  Future<List<SurahModel>> getAllSurahs();
  Future<SurahModel> getSurahDetail(int surahNumber);
  Future<List<AyahModel>> getSurahVerses(int surahNumber, {String? translationId});
  Future<String> getTafsir(int surahNumber, int ayahNumber, {int? tafsirId});
}

class QuranRemoteSourceImpl implements QuranRemoteSource {
  final http.Client client;
  static const String baseUrl = 'https://api.quran.com/api/v4';

  QuranRemoteSourceImpl({required this.client});

  @override
  Future<List<SurahModel>> getAllSurahs() async {
    final response = await client.get(
      Uri.parse('$baseUrl/chapters'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List chapters = data['chapters'];
      return chapters.map((json) => SurahModel.fromJson(json)).toList();
    } else {
      throw ServerFailure();
    }
  }

  @override
  Future<SurahModel> getSurahDetail(int surahNumber) async {
    final response = await client.get(
      Uri.parse('$baseUrl/chapters/$surahNumber'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SurahModel.fromJson(data['chapter']);
    } else {
      throw ServerFailure();
    }
  }

  @override
  Future<List<AyahModel>> getSurahVerses(int surahNumber, {String? translationId}) async {
    final fields = [
      'text_uthmani',
      'chapter_id',
      'hizb_number',
      'rub_el_hizb_number',
      'sajdah_number',
      'sajdah_type',
      'page_number',
      'juz_number'
    ].join(',');

    // Using audio=7 (Alafasy) as default for better reliability
    final response = await client.get(
      Uri.parse('$baseUrl/verses/by_chapter/$surahNumber?language=en&words=true&fields=$fields&per_page=300&audio=7'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List verses = data['verses'];
      return verses.map((json) => AyahModel.fromJson(json)).toList();
    } else {
      throw ServerFailure();
    }
  }

  @override
  Future<String> getTafsir(int surahNumber, int ayahNumber, {int? tafsirId}) async {
    final id = tafsirId ?? 16;
    final response = await client.get(
      Uri.parse('$baseUrl/tafsirs/$id/by_ayah/$surahNumber:$ayahNumber'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['tafsir'] != null && data['tafsir']['text'] != null) {
        return data['tafsir']['text'] as String;
      }
      return 'لا يوجد تفسير متاح حالياً';
    } else {
      throw ServerFailure('Failed to load Tafsir: ${response.statusCode}');
    }
  }
}
