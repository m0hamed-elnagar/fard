import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/core/extensions/quran_extension.dart';

import 'package:fard/features/quran/presentation/widgets/scanned/mushaf_page_item.dart';
import 'package:fard/features/quran/presentation/widgets/scanned/download_all_dialog.dart';
import 'package:fard/features/quran/presentation/widgets/scanned/page_nav_button.dart';

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
  final _prefs = getIt<SharedPreferences>();
  bool _isDarkMode = false;
  static const _darkModeKey = 'scanned_mushaf_dark_mode';

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage - 1);
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;

    // Initial prefetch
    _downloadService.prefetchPages(_currentPage);

    // Update audio position and ensure banner is shown if playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAudioPosition();
      context.read<AudioPlayerBloc>().add(const ShowBanner());
    });
  }

  void _updateAudioPosition() {
    final pageData = quran.getPageData(_currentPage);
    if (pageData.isNotEmpty) {
      final surahNum = pageData.first['surah'] as int;
      final ayahNum = pageData.first['start'] as int;
      context.read<AudioPlayerBloc>().add(
        UpdateCurrentPosition(
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

      final startAbs = QuranHizbProvider.getAbsoluteAyahNumber(
        surahNum,
        startAyah,
      );
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
      builder: (context) => DownloadAllDialog(
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

    final bgColor = _isDarkMode ? context.backgroundColor : context.surfaceContainerColor;
    final appBarColor = _isDarkMode ? context.surfaceContainerColor : context.primaryColor;
    final navBarColor = _isDarkMode ? context.surfaceContainerColor : context.surfaceContainerHighestColor;
    final primaryTextColor = _isDarkMode ? context.onSurfaceColor : context.primaryColor;

    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : Theme.of(context),
      child: Scaffold(
        backgroundColor: bgColor,
        // Softer, more premium paper color
        appBar: AppBar(
          backgroundColor: appBarColor,
          // Deep Islamic green
          elevation: 4,
          foregroundColor: context.onSurfaceColor,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                surahName.isNotEmpty
                    ? l10n.surahWithVal(surahName)
                    : l10n.scannedMushaf,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor,
                ),
              ),
              Text(
                '${l10n.juzWithVal(juzNumber.toString())} - ${l10n.pageWithVal(_currentPage.toString())}',
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  color: _isDarkMode ? context.onSurfaceColor : context.primaryColor,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: context.onSurfaceColor,
              ),
              tooltip: _isDarkMode ? l10n.lightMode : l10n.darkMode,
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                  _prefs.setBool(_darkModeKey, _isDarkMode);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.text_format_rounded, color: context.onSurfaceColor),
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
              icon: Icon(Icons.download_rounded, color: context.onSurfaceColor),
              tooltip: l10n.downloadAll,
              onPressed: _showDownloadAllDialog,
            ),
          ],
        ),
        body: BlocListener<AudioPlayerBloc, AudioPlayerState>(
          listenWhen: (previous, current) =>
              current.isActive &&
              (previous.currentSurah != current.currentSurah ||
                  previous.currentAyah != current.currentAyah),
          listener: (context, state) {
            if (state.currentSurah != null && state.currentAyah != null) {
              final targetPage = quran.getPageNumber(
                state.currentSurah!,
                state.currentAyah!,
              );
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
                      return MushafPageItem(
                        pageNumber: index + 1,
                        downloadService: _downloadService,
                        isDarkMode: _isDarkMode,
                      );
                    },
                  ),
                ),
                // Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: navBarColor,
                    boxShadow: [
                      BoxShadow(
                        color: context.surfaceContainerColor.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageNavButton(
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
                      PageNavButton(
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
                AudioPlayerBar(
                  currentViewedSurah:
                      quran.getPageData(_currentPage).firstOrNull?['surah']
                          as int?,
                  onScrollRequest: (surah, ayah) {
                    final targetPage = quran.getPageNumber(surah, ayah);
                    if (targetPage != _currentPage) {
                      _pageController.animateToPage(
                        targetPage - 1,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
