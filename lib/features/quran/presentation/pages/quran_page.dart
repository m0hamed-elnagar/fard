import 'dart:async';

import 'package:fard/core/blocs/connectivity/connectivity_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/widgets/fast_scroll_scrollbar.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:fard/features/audio/presentation/utils/offline_audio_helper.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/bookmark_list.dart';


import '../widgets/download_center_sheet.dart';
import '../widgets/hizb_list.dart';
import '../widgets/juz_list.dart';
import 'scanned_mushaf_reader_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _surahScrollController = ScrollController();
  String _searchQuery = '';
  bool _isSearching = false;

  Set<int> _downloadedSurahIds = {};
  Set<int> _downloadedTextSurahIds = {};
  final Map<int, double> _downloadingSurahs = {};
  final Set<int> _downloadingTextSurahs = {};
  StreamSubscription? _downloadSubscription;
  String? _lastReciterId;

  @override
  void initState() {
    super.initState();
    _initDownloadTracking();
  }

  void _initDownloadTracking() {
    _updateDownloadedSurahs();
    _updateDownloadedTextSurahs();
    _downloadSubscription = getIt<AudioDownloadService>().progressStream.listen((progress) {
      if (!mounted) return;
      
      final currentReciter = context.read<ReciterManagerBloc>().state.currentReciter;
      if (progress.reciterId != currentReciter?.identifier) return;

      if (progress.isCompleted && progress.surahNumber != null) {
        if (mounted) {
          setState(() {
            _downloadedSurahIds.add(progress.surahNumber!);
            _downloadingSurahs.remove(progress.surahNumber);
          });
        }
      } else if (progress.surahNumber != null) {
        if (mounted) {
          setState(() {
            _downloadingSurahs[progress.surahNumber!] = progress.percentage;
          });
        }
      }
    });
  }

  Future<void> _downloadSurah(int surahNumber) async {
    final reciter = context.read<ReciterManagerBloc>().state.currentReciter;
    if (reciter == null) return;

    setState(() {
      _downloadingSurahs[surahNumber] = 0.0;
    });

    try {
      await getIt<AudioDownloadService>().downloadSurah(
        reciter: reciter,
        surahNumber: surahNumber,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadingSurahs.remove(surahNumber);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _updateDownloadedSurahs() async {
    final reciter = context.read<ReciterManagerBloc>().state.currentReciter;
    if (reciter == null) return;

    if (_lastReciterId == reciter.identifier && _downloadedSurahIds.isNotEmpty) return;

    final downloaded = await getIt<AudioDownloadService>()
        .getDownloadedSurahIdsForReciter(reciter.identifier);
    
    if (mounted) {
      setState(() {
        _downloadedSurahIds = downloaded;
        _lastReciterId = reciter.identifier;
      });
    }
  }

  Future<void> _updateDownloadedTextSurahs() async {
    final downloaded = await getIt<QuranRepository>().getDownloadedTextSurahIds();
    if (mounted) {
      setState(() {
        _downloadedTextSurahIds = downloaded;
      });
    }
  }

  Future<void> _downloadSurahText(int surahNumber) async {
    setState(() => _downloadingTextSurahs.add(surahNumber));
    try {
      final result = await getIt<QuranRepository>().getSurah(
        SurahNumber.create(surahNumber).data!,
      );
      if (result.isSuccess && mounted) {
        _updateDownloadedTextSurahs();
      }
    } finally {
      if (mounted) setState(() => _downloadingTextSurahs.remove(surahNumber));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _surahScrollController.dispose();
    _downloadSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchSurah,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: context.onSurfaceColor).copyWith(fontSize: 14, color: context.onSurfaceColor.withValues(alpha: 0.7)),
                  ),
                  style: TextStyle(color: context.onSurfaceColor, fontSize: 18),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
              : Text(
                  l10n.quran,
                  style: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_for_offline_outlined),
              tooltip: l10n.downloadCenterBtn,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const DownloadCenterSheet(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              tooltip: l10n.scannedMushaf,
              onPressed: () =>
                  Navigator.push(context, ScannedMushafReaderPage.route()),
            ),
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearching = false;
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            isScrollable: true,
            tabs: [
              Tab(text: l10n.surahsTab),
              Tab(text: l10n.juzTab),
              Tab(text: l10n.hizbTab),
              Tab(text: l10n.bookmarksTab),
            ],
          ),
        ),
        body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connState) {
            final isConnected = connState is ConnectivityStatus ? connState.isConnected : true;

            return Column(
              children: [
                if (!isConnected)
                  Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.amber.shade700,
                child:
                Text(
                    l10n.offlineModeBanner,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                  ),

                Expanded(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<ReciterManagerBloc, ReciterManagerState>(
                        listenWhen: (prev, curr) => prev.currentReciter?.identifier != curr.currentReciter?.identifier,
                        listener: (context, state) => _updateDownloadedSurahs(),
                      ),
                    ],
                    child: BlocBuilder<QuranBloc, QuranState>(
                      builder: (context, state) {
                        if (state.isLoading && state.surahs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(l10n.loadingQuran, style: GoogleFonts.amiri()),
                              ],
                            ),
                          );
                        }

                        if (state.error != null && state.surahs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: context.errorColor,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.errorLoadingQuran,
                                    style: GoogleFonts.amiri(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: context.errorColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.error!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: context.onSurfaceVariantColor),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => context.read<QuranBloc>().add(
                                      const QuranEvent.loadSurahs(),
                                    ),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(l10n.retry),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final filteredSurahs = state.surahs.where((surah) {
                          return surah.name.contains(_searchQuery) ||
                              surah.number.value.toString().contains(_searchQuery);
                        }).toList();

                        final lastRead = state.lastReadPosition;
                        final hasLastRead = lastRead != null && state.surahs.isNotEmpty;
                        Surah? lastReadSurah;
                        if (hasLastRead) {
                          try {
                            lastReadSurah = state.surahs.firstWhere(
                              (s) => s.number.value == lastRead.ayahNumber.surahNumber,
                            );
                          } catch (_) {}
                        }

                        return TabBarView(
                          children: [
                            // Surah Tab
                            filteredSurahs.isEmpty && !state.isLoading
                                ? Center(child: Text(l10n.noSearchResults))
                                : Stack(
                                    children: [
                                      ListView.separated(
                                        key: const Key('surah_list_view'),
                                        padding: const EdgeInsets.all(16),
                                        controller: _surahScrollController,
                                        physics: const ScrollPhysics(),
                                        itemCount:
                                            filteredSurahs.length +
                                            (hasLastRead && _searchQuery.isEmpty ? 1 : 0),
                                        separatorBuilder: (context, index) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          if (hasLastRead &&
                                              _searchQuery.isEmpty &&
                                              index == 0) {
                                            return _ContinueReadingCard(
                                              surah: lastReadSurah!,
                                              ayahNumber: lastRead.ayahNumber.ayahNumberInSurah,
                                              isDownloaded: _downloadedSurahIds.contains(lastReadSurah.number.value),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  QuranReaderPage.route(
                                                    surahNumber: lastReadSurah!.number.value,
                                                    ayahNumber:
                                                        lastRead.ayahNumber.ayahNumberInSurah,
                                                    allSurahs: state.surahs,
                                                  ),
                                                );
                                              },
                                              onPlayTap: () {
                                                OfflineAudioHelper.handlePlayRequest(
                                                  context: context,
                                                  surahNumber: lastReadSurah!.number.value,
                                                  startAyah: lastRead.ayahNumber.ayahNumberInSurah,
                                                  isDownloaded: _downloadedSurahIds.contains(lastReadSurah.number.value),
                                                );
                                              },
                                            );
                                          }

                                          final surahIndex = hasLastRead && _searchQuery.isEmpty
                                              ? index - 1
                                              : index;
                                          final surah = filteredSurahs[surahIndex];
                                          final isAudioDownloaded = _downloadedSurahIds.contains(surah.number.value);
                                          final isTextDownloaded = _downloadedTextSurahIds.contains(surah.number.value);

                                          return _SurahListTile(
                                            surah: surah,
                                            isAudioDownloaded: isAudioDownloaded,
                                            isTextDownloaded: isTextDownloaded,
                                            isDownloadingAudio: _downloadingSurahs.containsKey(surah.number.value),
                                            audioDownloadProgress: _downloadingSurahs[surah.number.value],
                                            isDownloadingText: _downloadingTextSurahs.contains(surah.number.value),
                                            isConnected: isConnected,
                                            lastReadAyahNumber: (lastRead?.ayahNumber.surahNumber == surah.number.value)
                                                ? lastRead?.ayahNumber.ayahNumberInSurah
                                                : null,
                                            onDownloadAudio: () => _downloadSurah(surah.number.value),
                                            onDownloadText: () => _downloadSurahText(surah.number.value),
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                QuranReaderPage.route(
                                                  surahNumber: surah.number.value,
                                                  allSurahs: state.surahs,
                                                ),
                                              );
                                              // Refresh download status when returning from reader
                                              if (mounted) {
                                                _updateDownloadedTextSurahs();
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    // Fast scroll scrollbar
                                    FastScrollScrollbar(
                                      scrollController: _surahScrollController,
                                      itemCount: filteredSurahs.length +
                                          (hasLastRead && _searchQuery.isEmpty ? 1 : 0),
                                      labelBuilder: (context, index) {
                                        if (hasLastRead && _searchQuery.isEmpty && index == 0) {
                                          return Text(
                                            'Continue',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          );
                                        }
                                        final surahIndex = hasLastRead && _searchQuery.isEmpty
                                            ? index - 1
                                            : index;
                                        if (surahIndex >= 0 && surahIndex < filteredSurahs.length) {
                                          final surah = filteredSurahs[surahIndex];
                                          return Text(
                                            '${surah.number.value}. ${surah.name}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),

                          // Juz Tab
                          JuzList(searchQuery: _searchQuery),

                          // Hizb Tab
                          HizbList(searchQuery: _searchQuery),

                          // Bookmarks Tab
                          BookmarkList(searchQuery: _searchQuery),
                        ],
                      );
                    },
                  ),
                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final Surah surah;
  final int ayahNumber;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final bool isDownloaded;

  const _ContinueReadingCard({
    required this.surah,
    required this.ayahNumber,
    required this.onTap,
    required this.onPlayTap,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            color: context.onSurfaceColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.continueReading,
                            style: GoogleFonts.amiri(
                              color: context.onSurfaceColor.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        surah.name,
                        style: GoogleFonts.amiri(
                          color: context.onSurfaceColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          wordSpacing: 2,
                        ),
                      ),
                      Text(
                        l10n.ayahNumberWithVal(ayahNumber.toArabicIndic()),
                        style: GoogleFonts.amiri(
                          color: context.onSurfaceColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, audioState) {
                    final isThisSurah = audioState.currentSurah == surah.number.value;
                    final isPlaying = audioState.isPlaying && isThisSurah;
                    final isLoading = audioState.isLoading && isThisSurah;

                    return IconButton(
                      onPressed: onPlayTap,
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.onSurfaceColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(context.onSurfaceColor),
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: context.onSurfaceColor,
                                size: 32,
                              ),
                      ),
                    );
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

class _SurahListTile extends StatelessWidget {
  final Surah surah;
  final bool isAudioDownloaded;
  final bool isTextDownloaded;
  final bool isDownloadingAudio;
  final double? audioDownloadProgress;
  final bool isDownloadingText;
  final bool isConnected;
  final int? lastReadAyahNumber;
  final VoidCallback onDownloadAudio;
  final VoidCallback onDownloadText;
  final VoidCallback onTap;

  const _SurahListTile({
    required this.surah,
    required this.isAudioDownloaded,
    required this.isTextDownloaded,
    required this.isDownloadingAudio,
    this.audioDownloadProgress,
    required this.isDownloadingText,
    required this.isConnected,
    this.lastReadAyahNumber,
    required this.onDownloadAudio,
    required this.onDownloadText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          surah.number.value.toArabicIndic(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              surah.name,
              style: GoogleFonts.amiri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
                wordSpacing: 2,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      subtitle: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '${surah.numberOfAyahs.toArabicIndic()} ${l10n.ayah}',
          style: TextStyle(
            fontSize: 12,
            color: context.onSurfaceVariantColor,
          ),
          textAlign: TextAlign.right,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text Download / Status
          if (!isTextDownloaded)
            isDownloadingText
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      !isConnected ? Icons.text_snippet_outlined : Icons.file_download_outlined,
                      size: 18,
                      color: !isConnected ? context.onSurfaceVariantColor.withValues(alpha: 0.5) : context.onSurfaceVariantColor,
                    ),
                    onPressed: !isConnected
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.noInternetConnection)),
                            );
                          }
                        : onDownloadText,
                    tooltip: 'Download Text',
                  )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                Icons.text_snippet,
                size: 18,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
            ),

          // Audio Download / Progress Button
          if (!isAudioDownloaded)
            isDownloadingAudio
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: audioDownloadProgress,
                      strokeWidth: 2,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      !isConnected ? Icons.cloud_off_outlined : Icons.download_for_offline_outlined,
                      size: 20,
                      color: !isConnected ? context.onSurfaceVariantColor.withValues(alpha: 0.5) : null,
                    ),
                    onPressed: !isConnected
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.noInternetConnection)),
                            );
                          }
                        : onDownloadAudio,
                    tooltip: !isConnected ? l10n.noInternetConnection : l10n.startDownload,
                  )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                Icons.audiotrack,
                size: 18,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
            ),
          
          // Play / Pause Button
          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, audioState) {
              final isThisSurah = audioState.currentSurah == surah.number.value;
              final isPlaying = audioState.isPlaying && isThisSurah;
              final isLoading = audioState.isLoading && isThisSurah;

              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => OfflineAudioHelper.handlePlayRequest(
                  context: context,
                  surahNumber: surah.number.value,
                  startAyah: lastReadAyahNumber ?? 1,
                  isDownloaded: isAudioDownloaded,
                ),
              );
            },
          ),
          // Arabic RTL: Disclosure arrow points Left. DO NOT CHANGE.
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }
}
