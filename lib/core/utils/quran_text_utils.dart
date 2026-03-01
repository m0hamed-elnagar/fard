import 'package:fard/core/extensions/number_extension.dart';

class QuranTextUtils {
  static String formatWithQuranSymbols(String text) {
    // Replace comma with Ayah symbol ۝ and Arabic Indic numbers
    // Usually in Azkar data, ayahs are separated by comma or new line
    
    // Find numbers after a comma or space that look like ayah numbers
    final ayahPattern = RegExp(r'(\d+)');
    
    String formatted = text;
    
    // 1. Handle commas: replace with Ayah symbol if followed by number or at end of verse
    // Some azkar use commas as separators between ayahs
    formatted = formatted.replaceAll('،', ' ۝ ');
    
    // 2. Convert all digits to Arabic-Indic digits with the Ayah symbol prefix
    // We look for patterns that might be ayah numbers. 
    // In our Azkar data, ayahs often end with a comma or are just the text.
    // Let's make it more robust.
    
    // If the text contains specific Surah keywords, it might need special handling
    // but the user specifically mentioned symbols like we made in Quran.
    
    return formatted.replaceAllMapped(ayahPattern, (match) {
      final number = int.tryParse(match.group(1)!) ?? 0;
      return '۝${number.toArabicIndic()}';
    });
  }

  static bool isQuranicText(String reference) {
    final lowerRef = reference.toLowerCase();
    return lowerRef.contains('سورة') || 
           lowerRef.contains('آية') || 
           lowerRef.contains('الكرسى');
  }
}
