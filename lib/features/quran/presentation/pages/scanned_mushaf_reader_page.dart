import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/core/extensions/quran_extension.dart';

class ScannedMushafReaderPage extends StatefulWidget {
  final int initialPage;

  const ScannedMushafReaderPage({super.key, required this.initialPage});

  static MaterialPageRoute route({int? pageNumber}) {
    return MaterialPageRoute(
      builder: (_) => ScannedMushafReaderPage(initialPage: pageNumber ?? 1),
    );
  }

  @override
  State<ScannedMushafReaderPage> createState() =>
      _ScannedMushafReaderPageState();
}

class _ScannedMushafReaderPageState extends State<ScannedMushafReaderPage> {
  late PageController _pageController;
  int _currentPage = 1;
  final _downloadService = getIt<MushafDownloadService>();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage - 1);

    // Initial prefetch
    _downloadService.prefetchPages(_currentPage);

    // Update audio position and ensure banner is shown if playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAudioPosition();
      context.read<AudioBloc>().add(AudioEvent.showBanner());
    });
  }

  void _updateAudioPosition() {
    final pageData = quran.getPageData(_currentPage);
    if (pageData.isNotEmpty) {
      final surahNum = pageData.first['surah'] as int;
      final ayahNum = pageData.first['start'] as int;
      context.read<AudioBloc>().add(
        AudioEvent.updateCurrentPosition(
          surahNumber: surahNum,
          ayahNumber: ayahNum,
        ),
      );
    }
  }

  void _trackWerdProgress() {
    final pageData = quran.getPageData(_currentPage);
    for (final data in pageData) {
      final surahNum = data['surah'] as int;
      final startAyah = data['start'] as int;
      final endAyah = data['end'] as int;
      
      final startAbs = QuranHizbProvider.getAbsoluteAyahNumber(surahNum, startAyah);
      final endAbs = QuranHizbProvider.getAbsoluteAyahNumber(surahNum, endAyah);
      
      context.read<WerdBloc>().add(WerdEvent.trackRangeRead(startAbs, endAbs));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showDownloadAllDialog() {
    showDialog(
      context: context,
      builder: (context) => _DownloadAllDialog(
        downloadService: _downloadService,
        currentPage: _currentPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pageData = quran.getPageData(_currentPage);
    String surahName = '';
    int juzNumber = 0;
    if (pageData.isNotEmpty) {
      final surahNum = pageData.first['surah'] as int;
      surahName = quran.getSurahNameArabic(surahNum);
      juzNumber = quran.getJuzNumber(surahNum, pageData.first['start'] as int);
    }

    final bgColor = _isDarkMode ? AppTheme.background : const Color(0xFFFBF9F1);
    final appBarColor = _isDarkMode ? AppTheme.surface : const Color(0xFF2D5D40);
    final navBarColor = _isDarkMode ? AppTheme.surface : const Color(0xFFFBF9F1);
    final primaryTextColor = _isDarkMode ? AppTheme.textPrimary : const Color(0xFF2D5D40);

    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : Theme.of(context),
      child: Scaffold(
        backgroundColor: bgColor,
        // Softer, more premium paper color
        appBar: AppBar(
          backgroundColor: appBarColor,
          // Deep Islamic green
          elevation: 4,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                surahName.isNotEmpty ? l10n.surahWithVal(surahName) : l10n.scannedMushaf,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${l10n.juzWithVal(juzNumber.toString())} - ${l10n.pageWithVal(_currentPage.toString())}',
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Colors.white,
              ),
              tooltip: _isDarkMode ? l10n.lightMode : l10n.darkMode,
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.text_format_rounded, color: Colors.white),
              tooltip: l10n.textMushaf,
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
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: l10n.downloadAll,
              onPressed: _showDownloadAllDialog,
            ),
          ],
        ),
        body: BlocListener<AudioBloc, AudioState>(
          listenWhen: (previous, current) =>
              current.isActive &&
              (previous.currentSurah != current.currentSurah ||
                  previous.currentAyah != current.currentAyah),
          listener: (context, state) {
            if (state.currentSurah != null && state.currentAyah != null) {
              final targetPage =
                  quran.getPageNumber(state.currentSurah!, state.currentAyah!);
              if (targetPage != _currentPage) {
                _pageController.animateToPage(
                  targetPage - 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 604,
                    reverse: false,
                    // Standard RTL: Index 0 is on the Right
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page + 1;
                      });
                      _updateAudioPosition();
                      // Track Werd progress
                      _trackWerdProgress();
                      // Prefetch next pages when user navigates
                      _downloadService.prefetchPages(_currentPage);
                    },
                    itemBuilder: (context, index) {
                      return _MushafPageItem(
                        pageNumber: index + 1,
                        downloadService: _downloadService,
                        isDarkMode: _isDarkMode,
                      );
                    },
                  ),
                ),
                // Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  decoration: BoxDecoration(
                    color: navBarColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PageNavButton(
                        // Arabic RTL: Next Page (Right side). 
                        // The user considers Right-pointing as 'Next'. DO NOT SWAP ICONS.
                        icon: Icons.chevron_left,
                        isDarkMode: _isDarkMode,
                        onPressed: _currentPage > 1
                            ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                      Text(
                        l10n.pageWithVal(_currentPage.toString()),
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      _PageNavButton(
                        // Arabic RTL: Previous Page (Left side).
                        // The user considers Left-pointing as 'Previous'. DO NOT SWAP ICONS.
                        icon: Icons.chevron_right,
                        isDarkMode: _isDarkMode,
                        onPressed: _currentPage < 604
                            ? () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                    ],
                  ),
                ),
                const AudioPlayerBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MushafPageItem extends StatefulWidget {
  final int pageNumber;
  final MushafDownloadService downloadService;
  final bool isDarkMode;

  const _MushafPageItem({
    required this.pageNumber,
    required this.downloadService,
    required this.isDarkMode,
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
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = widget.isDarkMode ? AppTheme.textPrimary : const Color(0xFF2D5D40);

    return FutureBuilder<File?>(
      future: _pageFileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  l10n.loadingPage,
                  style: TextStyle(color: primaryColor),
                ),
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
                Text(
                  l10n.pageNotAvailable(widget.pageNumber),
                  style: TextStyle(color: primaryColor),
                ),
                ElevatedButton(
                  onPressed: _checkAndDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Text(
                    l10n.retry,
                    style: TextStyle(color: widget.isDarkMode ? Colors.black : Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        Widget image = Image.file(snapshot.data!, fit: BoxFit.contain);

        if (widget.isDarkMode) {
          image = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              -0.85, 0, 0, 0, 235,
              0, -0.85, 0, 0, 235,
              0, -0.85, 0, 0, 235,
              0, 0, 0, 1, 0,
            ]),
            child: image,
          );
        }

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: image,
            ),
          ),
        );
      },
    );
  }
}

class _DownloadAllDialog extends StatefulWidget {
  final MushafDownloadService downloadService;
  final int currentPage;

  const _DownloadAllDialog({
    required this.downloadService,
    required this.currentPage,
  });

  @override
  State<_DownloadAllDialog> createState() => _DownloadAllDialogState();
}

class _DownloadAllDialogState extends State<_DownloadAllDialog> {
  double _progress = 0;
  bool _isDownloading = false;

  void _startDownload(AppLocalizations l10n) {
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
            SnackBar(content: Text(l10n.pagesDownloadedSuccess)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.downloadMushafPages, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.downloadMushafDesc,
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
          if (!_isDownloading) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () async {
                await widget.downloadService.clearCache();
                if (!context.mounted) return;

                // Refresh the whole page to trigger re-downloads
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  ScannedMushafReaderPage.route(
                    pageNumber: widget.currentPage,
                  ),
                );
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.cacheClearedReloading),
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              label: Text(
                l10n.clearCache,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        if (!_isDownloading)
          ElevatedButton(
            onPressed: () => _startDownload(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5D40),
            ),
            child: Text(
              l10n.startDownload,
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDarkMode;

  const _PageNavButton({
    required this.icon,
    this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? AppTheme.textPrimary : const Color(0xFF2D5D40);
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceLight.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color.withValues(alpha: 0.7), size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
