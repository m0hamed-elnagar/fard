import 'package:quran/quran.dart' as quran;

void main() {
  String bookmark = '🔖';
  print('Bookmark: $bookmark');
  print('Code points: ${bookmark.runes.map((r) => '0x${r.toRadixString(16).toUpperCase()}').toList()}');
}
