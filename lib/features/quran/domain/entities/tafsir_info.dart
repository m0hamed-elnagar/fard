class TafsirInfo {
  final int id;
  final String name;
  final String authorName;
  final String languageName;

  const TafsirInfo({
    required this.id,
    required this.name,
    required this.authorName,
    required this.languageName,
  });

  static const List<TafsirInfo> availableTafsirs = [
    TafsirInfo(
      id: 16,
      name: "التفسير الميسر",
      authorName: "جماعة من العلماء",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 14,
      name: "تفسير ابن كثير",
      authorName: "الإمام ابن كثير",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 15,
      name: "تفسير الطبري",
      authorName: "الإمام الطبري",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 90,
      name: "تفسير القرطبي",
      authorName: "الإمام القرطبي",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 91,
      name: "تفسير السعدي",
      authorName: "الشيخ عبد الرحمن السعدي",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 94,
      name: "تفسير البغوي",
      authorName: "الإمام البغوي",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 93,
      name: "التفسير الوسيط",
      authorName: "د. محمد سيد طنطاوي",
      languageName: "arabic",
    ),
    TafsirInfo(
      id: 169,
      name: "Ibn Kathir (Abridged)",
      authorName: "Hafiz Ibn Kathir",
      languageName: "english",
    ),
    TafsirInfo(
      id: 168,
      name: "Ma'arif al-Qur'an",
      authorName: "Mufti Muhammad Shafi",
      languageName: "english",
    ),
    TafsirInfo(
      id: 817,
      name: "Tazkirul Quran",
      authorName: "Maulana Wahiduddin Khan",
      languageName: "english",
    ),
  ];
}
