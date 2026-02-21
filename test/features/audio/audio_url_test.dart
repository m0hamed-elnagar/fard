import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  final Map<String, Map<int, String>> everyAyahMapping = {
    'ar.alafasy': {64: 'Alafasy_64kbps', 128: 'Alafasy_128kbps'},
    'ar.husary': {64: 'Husary_64kbps', 128: 'Husary_128kbps'},
    'ar.minshawi': {128: 'Minshawy_Murattal_128kbps'},
    'ar.abdulbasitmurattal': {64: 'Abdul_Basit_Murattal_64kbps', 192: 'Abdul_Basit_Murattal_192kbps'},
    'ar.ahmedajamy': {128: 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net'},
    'ar.abdurrahmaansudais': {192: 'Abdurrahmaan_As-Sudais_192kbps'},
    'ar.saoodshuraym': {128: 'Saood_ash-Shuraym_128kbps'},
    'ar.mahermuaiqly': {128: 'MaherAlMuaiqly128kbps'},
    'ar.hudhaify': {128: 'Hudhaify_128kbps'},
    'ar.abdullahbasfar': {64: 'Abdullah_Basfar_64kbps', 192: 'Abdullah_Basfar_192kbps'},
    'ar.ghamadi': {64: 'Ghamadi_40kbps', 128: 'Ghamadi_40kbps'},
    'ar.shatree': {64: 'Abu_Bakr_Ash-Shaatree_64kbps', 128: 'Abu_Bakr_Ash-Shaatree_128kbps'},
    'ar.abdulbasitmujawwad': {128: 'Abdul_Basit_Mujawwad_128kbps'},
    'ar.minshawimujawwad': {64: 'Minshawy_Mujawwad_64kbps', 128: 'Minshawy_Mujawwad_192kbps'},
    'ar.husarymuallim': {128: 'Husary_Muallim_128kbps'},
    'ar.aymanswayd': {64: 'Ayman_Sowaid_64kbps'},
  };

  group('EveryAyah URL Validation', () {
    for (final reciterEntry in everyAyahMapping.entries) {
      final reciterId = reciterEntry.key;
      for (final bitrateEntry in reciterEntry.value.entries) {
        final bitrate = bitrateEntry.key;
        final folder = bitrateEntry.value;
        
        test('Verify $reciterId at ${bitrate}kbps ($folder)', () async {
          final url = 'https://everyayah.com/data/$folder/001001.mp3';
          final response = await http.head(Uri.parse(url));
          
          expect(response.statusCode, 200, 
            reason: 'URL should be valid: $url');
        });
      }
    }
  });

  group('Islamic Network CDN Fallback Validation', () {
    test('Verify Alafasy 128k fallback', () async {
       final url = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3';
       final response = await http.head(Uri.parse(url));
       expect(response.statusCode, 200);
    });
  });
}
