import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> main() async {
  // Quran.com API v4: Verse 1 of Surah Al-Fatiha
  final url = Uri.parse('https://api.quran.com/api/v4/verses/by_chapter/1?language=en&fields=text_uthmani,text_indopak&page=1&per_page=10');
  
  print('Requesting: $url');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final fileName = 'research/api_responses/quran_com_v4_sample.json';
    final file = File(fileName);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body)));
    print('Response saved to $fileName');
  } else {
    print('Failed to fetch data: ${response.statusCode}');
  }
}
