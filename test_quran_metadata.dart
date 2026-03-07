import 'package:quran/quran.dart' as quran;

void main() {
  print('Total Pages: ${quran.totalPagesCount}');
  print('Total Surahs: ${quran.totalSurahCount}');
  print('Total Verses: ${quran.totalVerseCount}');
  
  // To get surah/verse for a page, we can search:
  for(int s=1; s<=114; s++) {
    int verses = quran.getVerseCount(s);
    for(int v=1; v<=verses; v++) {
      if(quran.getPageNumber(s, v) == 1) {
        print('Page 1 contains: Surah $s, Ayah $v');
      }
    }
  }
}
