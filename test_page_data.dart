import 'package:quran/quran.dart' as quran;

void main() {
  print('Finding data for Page 1...');
  for (int s = 1; s <= 114; s++) {
    int verses = quran.getVerseCount(s);
    for (int v = 1; v <= verses; v++) {
      if (quran.getPageNumber(s, v) == 1) {
        print('Page 1 contains: Surah $s, Ayah $v');
      }
    }
  }
}
