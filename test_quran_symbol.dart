import 'package:flutter/foundation.dart';

void main() {
  String bookmark = '🔖';
  debugPrint('Bookmark: $bookmark');
  debugPrint('Code points: ${bookmark.runes.map((r) => '0x${r.toRadixString(16).toUpperCase()}').toList()}');
}
