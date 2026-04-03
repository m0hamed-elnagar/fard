import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  debugPrint(
    'arabicNumeral: true -> ${quran.getVerseEndSymbol(1, arabicNumeral: true)}',
  );
  debugPrint(
    'arabicNumeral: false -> ${quran.getVerseEndSymbol(1, arabicNumeral: false)}',
  );
}
