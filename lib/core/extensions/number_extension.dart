extension NumberExtension on int {
  String toArabicIndic() {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return toString()
        .split('')
        .map((d) {
          final val = int.tryParse(d);
          return val != null ? arabicDigits[val] : d;
        })
        .join();
  }
}
