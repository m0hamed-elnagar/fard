import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

class QuranLibraryPage extends StatelessWidget {
  const QuranLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Library requires Material 2 - wrap with Theme
    return Theme(
      data: ThemeData.dark(useMaterial3: false),

      child: QuranLibraryScreen(
        parentContext: context,
        isDark: Theme.of(context).brightness == Brightness.dark,
        appLanguageCode: 'ar', // Arabic interface
        withPageView: true,
        useDefaultAppBar: true,
        isShowAudioSlider: true,
        showAyahBookmarkedIcon: true,
        enableWordSelection: true,
        // Optional: Customize colors to match your app
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        textColor: Theme.of(context).colorScheme.onSurface,
        ayahIconColor: Theme.of(context).colorScheme.primary,
        // Optional: Style overrides
        topBarStyle: QuranTopBarStyle.defaults(
          isDark: Theme.of(context).brightness == Brightness.dark,
          context: context,
        ).copyWith(
          tabIndexLabel: 'الفهرس',
          tabBookmarksLabel: 'العلامات',
          tabSearchLabel: 'البحث',
        ),
        indexTabStyle: IndexTabStyle.defaults(
          isDark: Theme.of(context).brightness == Brightness.dark,
          context: context,
        ).copyWith(
          tabSurahsLabel: 'السور',
          tabJozzLabel: 'الأجزاء',
        ),
        bookmarksTabStyle: BookmarksTabStyle.defaults(
          isDark: Theme.of(context).brightness == Brightness.dark,
          context: context,
        ).copyWith(
          emptyStateText: 'لا توجد علامات مرجعية',
          greenGroupText: 'أخضر',
          yellowGroupText: 'أصفر',
          redGroupText: 'أحمر',
        ),
        tafsirStyle: TafsirStyle.defaults(
          isDark: Theme.of(context).brightness == Brightness.dark,
          context: context,
        ).copyWith(
          tafsirName: 'التفسير',
          translateName: 'الترجمة',
        ),
      ),
    );
  }
}
