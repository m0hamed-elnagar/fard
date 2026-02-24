import 'package:flutter/material.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

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
  final _downloadService = getIt<MushafDownloadService>();

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

  void _showDownloadAllDialog() {
    showDialog(
      context: context,
      builder: (context) => _DownloadAllDialog(downloadService: _downloadService),
    );
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
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'تحميل الكل',
            onPressed: _showDownloadAllDialog,
          ),
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
                    return _MushafPageItem(
                      pageNumber: index + 1,
                      downloadService: _downloadService,
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

class _MushafPageItem extends StatefulWidget {
  final int pageNumber;
  final MushafDownloadService downloadService;

  const _MushafPageItem({
    required this.pageNumber,
    required this.downloadService,
  });

  @override
  State<_MushafPageItem> createState() => _MushafPageItemState();
}

class _MushafPageItemState extends State<_MushafPageItem> {
  Future<File?>? _pageFileFuture;

  @override
  void initState() {
    super.initState();
    _checkAndDownload();
  }

  @override
  void didUpdateWidget(_MushafPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _checkAndDownload();
    }
  }

  void _checkAndDownload() {
    setState(() {
      _pageFileFuture = _getOrDownloadPage();
    });
  }

  Future<File?> _getOrDownloadPage() async {
    final file = await widget.downloadService.getLocalFile(widget.pageNumber);
    if (await file.exists()) {
      return file;
    }
    
    final path = await widget.downloadService.downloadPage(widget.pageNumber);
    if (path != null) {
      return File(path);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _pageFileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF2D5D40)),
                SizedBox(height: 16),
                Text('جاري تحميل الصفحة...', style: TextStyle(color: Color(0xFF2D5D40))),
              ],
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('الصفحة ${widget.pageNumber} غير متوفرة'),
                ElevatedButton(
                  onPressed: _checkAndDownload,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5D40)),
                  child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.file(
                snapshot.data!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DownloadAllDialog extends StatefulWidget {
  final MushafDownloadService downloadService;

  const _DownloadAllDialog({required this.downloadService});

  @override
  State<_DownloadAllDialog> createState() => _DownloadAllDialogState();
}

class _DownloadAllDialogState extends State<_DownloadAllDialog> {
  double _progress = 0;
  bool _isDownloading = false;

  void _startDownload() {
    setState(() {
      _isDownloading = true;
    });
    widget.downloadService.downloadAllPages().listen((progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
        if (progress >= 1.0) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحميل جميع الصفحات بنجاح')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحميل صفحات المصحف', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'سيتم تحميل 604 صفحة عالية الجودة. يرجى التأكد من الاتصال بالإنترنت.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_isDownloading) ...[
            LinearProgressIndicator(
              value: _progress,
              color: const Color(0xFF2D5D40),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 10),
            Text('${(_progress * 100).toStringAsFixed(1)}%'),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        if (!_isDownloading)
          ElevatedButton(
            onPressed: _startDownload,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5D40)),
            child: const Text('بدء التحميل', style: TextStyle(color: Colors.white)),
          ),
      ],
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

