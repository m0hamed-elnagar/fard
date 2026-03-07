import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/presentation/widgets/surah_header.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_detail_sheet.dart';
import 'package:fard/features/quran/presentation/widgets/reader_settings_sheet.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fard/features/quran/presentation/widgets/reader_info_bar.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'scanned_mushaf_reader_page.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
  });

  static MaterialPageRoute route({
    required int surahNumber,
    int? ayahNumber,
  }) {
    return MaterialPageRoute(
      builder: (_) => QuranReaderPage(
        surahNumber: surahNumber,
        initialAyahNumber: ayahNumber,
      ),
    );
  }

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  double _baseScale = 1.0;
  bool _hasHandledInitialAyah = false;
  bool _isSheetShowing = false;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  final ValueNotifier<int?> _currentVisibleAyah = ValueNotifier<int?>(null);
  DateTime _lastScrollCheck = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _currentVisibleAyah.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_ayahKeys.isEmpty || !mounted) return;

    // Throttle checks to every 100ms
    final now = DateTime.now();
    if (now.difference(_lastScrollCheck).inMilliseconds < 100) return;
    _lastScrollCheck = now;

    int? topAyah;
    double minDistance = double.infinity;
    const double topThreshold = 140.0;

    // Only check keys that are somewhat likely to be visible? 
    // Actually, localToGlobal is the expensive part.
    // We could try to optimize by starting from the last known visible ayah and searching outwards.
    
    for (final entry in _ayahKeys.entries) {
      final context = entry.value.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final distance = (position - topThreshold).abs();
          if (distance < minDistance) {
            minDistance = distance;
            topAyah = entry.key;
          }
          // If we found something close and now distances are increasing, we can stop
          if (distance > minDistance && minDistance < 500) break;
        }
      }
    }

    if (topAyah != null && topAyah != _currentVisibleAyah.value) {
      _currentVisibleAyah.value = topAyah;
    }
  }

  void _scrollToAyah(int ayahNumber, {int retryCount = 0}) {
    Future.delayed(Duration(milliseconds: retryCount == 0 ? 300 : 200), () {
      if (!mounted) return;
      final key = _ayahKeys[ayahNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.1, // Show near top of screen
        );
      } else if (retryCount < 5) {
        _scrollToAyah(ayahNumber, retryCount: retryCount + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final surahNumResult = SurahNumber.create(widget.surahNumber);
            return getIt<ReaderBloc>()
              ..add(ReaderEvent.loadSurah(surahNumber: surahNumResult.data!));
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: BlocBuilder<ReaderBloc, ReaderState>(
                builder: (context, state) {
                  return state.maybeMap(
                    loaded: (s) => Text(s.surah.name, style: GoogleFonts.amiri()),
                    orElse: () => Text(l10n.quranReader),
                  );
                },
              ),
              actions: [
                BlocBuilder<ReaderBloc, ReaderState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: const Icon(Icons.photo_library_outlined),
                      tooltip: l10n.scannedMushaf,
                      onPressed: () {
                        int page = 1;
                        state.maybeMap(
                          loaded: (s) {
                            final targetAyah = s.highlightedAyah ?? s.lastReadAyah ?? s.surah.ayahs.firstOrNull;
                            if (targetAyah != null) {
                              page = quran.getPageNumber(
                                s.surah.number.value,
                                targetAyah.number.ayahNumberInSurah,
                              );
                            }
                          },
                          orElse: () {},
                        );
                        Navigator.pushReplacement(
                          context,
                          ScannedMushafReaderPage.route(pageNumber: page),
                        );
                      },
                    );
                  },
                ),
                BlocBuilder<ReaderBloc, ReaderState>(
                  builder: (context, state) {
                    final readerBloc = context.read<ReaderBloc>();
                    return IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: state.maybeMap(
                        loaded: (_) => () async {
                          if (_isSheetShowing) return;
                          _isSheetShowing = true;
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => BlocProvider.value(
                              value: readerBloc,
                              child: const ReaderSettingsSheet(),
                            ),
                          );
                          _isSheetShowing = false;
                        },
                        orElse: () => null,
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<ReaderBloc, ReaderState>(
                        listenWhen: (prev, curr) {
                          final prevAyah = prev.maybeMap(loaded: (s) => s.highlightedAyah, orElse: () => null);
                          final currAyah = curr.maybeMap(loaded: (s) => s.highlightedAyah, orElse: () => null);
                          
                          // Trigger when transitioning to loaded or when highlight changes
                          return (prev.maybeMap(loaded: (_) => false, orElse: () => true) && 
                                  curr.maybeMap(loaded: (_) => true, orElse: () => false)) ||
                                 (prevAyah != currAyah);
                        },
                        listener: (context, state) {
                          state.mapOrNull(
                            loaded: (s) {
                              // Generate keys for all ayahs if not already done
                              if (_ayahKeys.isEmpty) {
                                for (final ayah in s.surah.ayahs) {
                                  _ayahKeys[ayah.number.ayahNumberInSurah] = GlobalKey();
                                }
                              }

                              if (!_hasHandledInitialAyah && widget.initialAyahNumber != null) {
                                _hasHandledInitialAyah = true;
                                try {
                                  final ayah = s.surah.ayahs.firstWhere(
                                    (a) => a.number.ayahNumberInSurah == widget.initialAyahNumber
                                  );
                                  context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                                  _scrollToAyah(widget.initialAyahNumber!);
                                } catch (_) {}
                              } else if (s.highlightedAyah != null) {
                                // If highlight changed (e.g. from navigation elsewhere), scroll to it
                                _scrollToAyah(s.highlightedAyah!.number.ayahNumberInSurah);
                              }

                              // Update audio bloc with current surah and first ayah for the player bar
                              context.read<AudioBloc>().add(
                                AudioEvent.updateCurrentPosition(
                                  surahNumber: s.surah.number.value,
                                  ayahNumber: s.surah.ayahs.isNotEmpty ? s.surah.ayahs.first.number.ayahNumberInSurah : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      BlocListener<ReaderBloc, ReaderState>(
                        listenWhen: (prev, curr) {
                          final prevLast = prev.maybeMap(loaded: (s) => s.lastReadAyah, orElse: () => null);
                          final currLast = curr.maybeMap(loaded: (s) => s.lastReadAyah, orElse: () => null);
                          return currLast != null && currLast != prevLast;
                        },
                        listener: (context, state) {
                          state.mapOrNull(
                            loaded: (s) {
                              if (s.lastReadAyah != null) {
                                final abs = QuranHizbProvider.getAbsoluteAyahNumber(
                                  s.surah.number.value, 
                                  s.lastReadAyah!.number.ayahNumberInSurah
                                );
                                context.read<WerdBloc>().add(WerdEvent.trackItemRead(abs));
                              }
                            },
                          );
                        },
                      ),
                    ],
                    child: BlocBuilder<ReaderBloc, ReaderState>(
                      builder: (context, state) {
                        return state.map(
                          initial: (_) => const Center(child: CircularProgressIndicator()),
                          loading: (_) => const Center(child: CircularProgressIndicator()),
                          error: (e) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(e.message, textAlign: TextAlign.center),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                       final surahNumResult = SurahNumber.create(widget.surahNumber);
                                       context.read<ReaderBloc>().add(ReaderEvent.loadSurah(surahNumber: surahNumResult.data!));
                                    },
                                    child: Text(l10n.retry),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          loaded: (s) {
                            final double screenHeight = MediaQuery.of(context).size.height;
                            final double expandedHeight = screenHeight < 600 ? 180 : 240;

                            return GestureDetector(
                              onScaleStart: (details) {
                                _baseScale = s.textScale;
                              },
                              onScaleUpdate: (details) {
                                context.read<ReaderBloc>().add(
                                      ReaderEvent.updateScale(_baseScale * details.scale),
                                    );
                              },
                              child: CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: const SizedBox(height: 16),
                                  ),
                                  SliverAppBar(
                                    automaticallyImplyLeading: false,
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    floating: true,
                                    snap: true,
                                    pinned: false,
                                    toolbarHeight: 0,
                                    collapsedHeight: 0,
                                    expandedHeight: expandedHeight,
                                    flexibleSpace: FlexibleSpaceBar(
                                      background: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: SurahHeader(
                                          surah: s.surah,
                                          onNext: widget.surahNumber < 114 
                                            ? () => Navigator.pushReplacement(
                                                context,
                                                QuranReaderPage.route(surahNumber: widget.surahNumber + 1),
                                              )
                                            : null,
                                          onPrevious: widget.surahNumber > 1
                                            ? () => Navigator.pushReplacement(
                                                context,
                                                QuranReaderPage.route(surahNumber: widget.surahNumber - 1),
                                              )
                                            : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.all(20.0),
                                    sliver: SliverList(
                                      delegate: SliverChildListDelegate([
                                        // Bismillah logic
                                        if (widget.surahNumber != 9 && 
                                            s.surah.ayahs.isNotEmpty && 
                                            !s.surah.ayahs.first.uthmaniText.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ'))
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 32.0),
                                            child: Text(
                                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                                              style: GoogleFonts.amiri(
                                                fontSize: 32 * s.textScale,
                                                fontWeight: FontWeight.bold,
                                                height: 2.2,
                                                wordSpacing: 4,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          
                                        BlocBuilder<AudioBloc, AudioState>(
                                          builder: (context, audioState) {
                                            final isThisSurah = audioState.currentSurah == widget.surahNumber;
                                            final playingAyah = isThisSurah && audioState.isActive 
                                              ? s.surah.ayahs.firstWhere(
                                                  (a) => a.number.ayahNumberInSurah == audioState.currentAyah,
                                                  orElse: () => s.surah.ayahs.first,
                                                ) 
                                              : null;

                                            return BlocBuilder<WerdBloc, WerdState>(
                                              builder: (context, werdState) {
                                                Ayah? dayStartAyah;
                                                Ayah? lastReadAyah;
                                                
                                                // 1. Calculate Day Start (where they started or will start today)
                                                // If they haven't started today, sessionStartAbsolute is where they will start
                                                final startAbs = werdState.progress?.sessionStartAbsolute;
                                                
                                                if (startAbs != null) {
                                                  final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
                                                  if (pos[0] == widget.surahNumber) {
                                                    try {
                                                      dayStartAyah = s.surah.ayahs.firstWhere(
                                                        (a) => a.number.ayahNumberInSurah == pos[1],
                                                      );
                                                    } catch (_) {}
                                                  }
                                                }

                                                // 2. Calculate Last Read Position (where they reached)
                                                if (werdState.progress?.lastReadAbsolute != null) {
                                                  final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(werdState.progress!.lastReadAbsolute!);
                                                  if (pos[0] == widget.surahNumber) {
                                                    try {
                                                      lastReadAyah = s.surah.ayahs.firstWhere(
                                                        (a) => a.number.ayahNumberInSurah == pos[1],
                                                      );
                                                    } catch (_) {}
                                                  }
                                                }

                                                return AyahText(
                                                  ayahs: s.surah.ayahs,
                                                  highlightedAyah: playingAyah ?? s.highlightedAyah,
                                                  dayStartAyah: dayStartAyah,
                                                  lastReadAyah: (werdState.progress?.totalAmountReadToday ?? 0) > 0 ? lastReadAyah : null,
                                                  bookmark: s.bookmark,
                                                  textScale: s.textScale,
                                                  ayahKeys: _ayahKeys,
                                                  separator: s.separator,
                                                  onAyahTap: (ayah) {
                                                    context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                                                  },
                                                  onAyahLongPress: (ayah) {
                                                    _showAyahDetail(context, ayah);
                                                  },
                                                  onAyahDoubleTap: (ayah) {
                                                    _showAyahDetail(context, ayah);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        
                                        const SizedBox(height: 120),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BlocBuilder<ReaderBloc, ReaderState>(
                    builder: (context, state) {
                      return state.maybeMap(
                        loaded: (s) {
                          return ValueListenableBuilder<int?>(
                            valueListenable: _currentVisibleAyah,
                            builder: (context, visibleAyah, _) {
                              final currentAyahNum = visibleAyah ?? (s.highlightedAyah ?? s.lastReadAyah ?? s.surah.ayahs.firstOrNull)?.number.ayahNumberInSurah;
                              if (currentAyahNum == null) return const AudioPlayerBar();
                              
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ReaderInfoBar(
                                    surahNumber: widget.surahNumber,
                                    ayahNumber: currentAyahNum,
                                    onJumpToStart: () {
                                      final werdState = context.read<WerdBloc>().state;
                                      final startAbs = werdState.progress?.sessionStartAbsolute;
                                      if (startAbs == null) return;

                                      final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
                                      if (pos[0] == widget.surahNumber) {
                                        try {
                                          final ayah = s.surah.ayahs.firstWhere(
                                            (a) => a.number.ayahNumberInSurah == pos[1],
                                          );
                                          context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                                        } catch (_) {}
                                        _scrollToAyah(pos[1]);
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          QuranReaderPage.route(surahNumber: pos[0], ayahNumber: pos[1]),
                                        );
                                      }
                                    },
                                    onJumpToBookmark: () {
                                      final werdState = context.read<WerdBloc>().state;
                                      final lastAbs = werdState.progress?.lastReadAbsolute;
                                      if (lastAbs == null) return;

                                      final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(lastAbs);
                                      if (pos[0] == widget.surahNumber) {
                                        try {
                                          final ayah = s.surah.ayahs.firstWhere(
                                            (a) => a.number.ayahNumberInSurah == pos[1],
                                          );
                                          context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                                        } catch (_) {}
                                        _scrollToAyah(pos[1]);
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          QuranReaderPage.route(surahNumber: pos[0], ayahNumber: pos[1]),
                                        );
                                      }
                                    },
                                  ),
                                  const AudioPlayerBar(),
                                ],
                              );
                            }
                          );
                        },
                        orElse: () => const AudioPlayerBar(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAyahDetail(BuildContext context, Ayah ayah) async {
    if (_isSheetShowing) return;
    
    final readerBloc = context.read<ReaderBloc>();
    final readerState = readerBloc.state;
    int? count;
    readerState.maybeMap(
      loaded: (s) => count = s.surah.numberOfAyahs,
      orElse: () => null,
    );
    
    _isSheetShowing = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: readerBloc,
        child: AyahDetailSheet(ayah: ayah, surahAyahCount: count),
      ),
    );
    _isSheetShowing = false;
  }
}
