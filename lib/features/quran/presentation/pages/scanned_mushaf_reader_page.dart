import 'package:flutter/material.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';

import 'quran_reader_page.dart';

class ScannedMushafReaderPage extends StatefulWidget {
  final int initialPage;

  const ScannedMushafReaderPage({
    super.key,
    required this.initialPage,
  });

  static MaterialPageRoute route({int? pageNumber}) {
    return MaterialPageRoute(
      builder: (_) => ScannedMushafReaderPage(initialPage: pageNumber ?? 1),
    );
  }

  @override
  State<ScannedMushafReaderPage> createState() => _ScannedMushafReaderPageState();
}

class _ScannedMushafReaderPageState extends State<ScannedMushafReaderPage> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageData = quran.getPageData(_currentPage);
    String surahName = '';
    int juzNumber = 0;
    if (pageData.isNotEmpty) {
      final surahNum = pageData.first['surah'] as int;
      surahName = quran.getSurahNameArabic(surahNum);
      juzNumber = quran.getJuzNumber(surahNum, pageData.first['start'] as int);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F1), // Softer, more premium paper color
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D5D40), // Deep Islamic green
        elevation: 4,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              surahName.isNotEmpty ? 'سورة $surahName' : 'المصحف المصور',
              style: GoogleFonts.amiri(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'الجزء $juzNumber - صفحة $_currentPage',
              style: GoogleFonts.amiri(
                fontSize: 14, 
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_format_rounded, color: Colors.white),
            tooltip: 'مصحف نصي',
            onPressed: () {
              if (pageData.isNotEmpty) {
                final surahNum = pageData.first['surah'] as int;
                final ayahNum = pageData.first['start'] as int;
                
                Navigator.pushReplacement(
                  context,
                  QuranReaderPage.route(
                    surahNumber: surahNum,
                    ayahNumber: ayahNum,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 604,
                  reverse: true, // Mushaf is RTL
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page + 1;
                    });
                  },
                  itemBuilder: (context, index) {
                    final pageNum = index + 1;
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'assets/pages/$pageNum.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                  Text('الصفحة $pageNum غير متوفرة'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const AudioPlayerBar(),
            ],
          ),
          // Navigation Buttons
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height / 2 - 100,
            child: _PageNavButton(
              icon: Icons.chevron_right,
              onPressed: _currentPage < 604 
                  ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300), 
                      curve: Curves.easeInOut
                    )
                  : null,
            ),
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height / 2 - 100,
            child: _PageNavButton(
              icon: Icons.chevron_left,
              onPressed: _currentPage > 1 
                  ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300), 
                      curve: Curves.easeInOut
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageNavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF2D5D40), size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
