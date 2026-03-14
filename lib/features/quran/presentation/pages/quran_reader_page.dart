import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/core/extensions/quran_extension.dart';

import 'package:fard/features/quran/presentation/widgets/reader/reader_app_bar.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_header.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_body.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_bottom_bar.dart';
import 'package:fard/features/quran/presentation/controllers/reader_scroll_controller.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;
  final bool playOnLoad;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
    this.playOnLoad = false,
  });

  static Route route({
    required int surahNumber,
    int? ayahNumber,
    bool playOnLoad = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => QuranReaderPage(
        surahNumber: surahNumber,
        initialAyahNumber: ayahNumber,
        playOnLoad: playOnLoad,
      ),
    );
  }

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late ReaderScrollController _scrollController;
  bool _hasHandledInitialAyah = false;
  bool _hasHandledPlayOnLoad = false;
  ReaderBloc? _readerBloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ReaderScrollController();
    
    // Listen to scroll changes and update last read position
    _scrollController.currentVisibleAyah.addListener(_onAyahVisibleChanged);
  }

  void _onAyahVisibleChanged() {
    if (!mounted || _readerBloc == null) return;
    
    final currentAyah = _scrollController.currentVisibleAyah.value;
    if (currentAyah == null) return;

    try {
      final state = _readerBloc!.state;
      
      state.mapOrNull(
        loaded: (s) {
          // Only update if it's different to avoid redundant events
          if (s.lastReadAyah?.number.ayahNumberInSurah != currentAyah) {
            try {
              final ayah = s.surah.ayahs.firstWhere(
                (a) => a.number.ayahNumberInSurah == currentAyah,
              );
              _readerBloc!.add(ReaderEvent.saveLastRead(ayah));
            } catch (_) {}
          }
        },
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.currentVisibleAyah.removeListener(_onAyahVisibleChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahNumResult = SurahNumber.create(widget.surahNumber);
    
    return BlocProvider(
      create: (context) => getIt<ReaderBloc>()
        ..add(ReaderEvent.loadSurah(surahNumber: surahNumResult.data!)),
      child: Builder(
        builder: (context) {
          _readerBloc = context.read<ReaderBloc>();
          return Scaffold(
            appBar: const QuranReaderAppBar(),
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
                              _scrollController.generateKeys(s.surah.ayahs);

                              if (!_hasHandledInitialAyah && widget.initialAyahNumber != null) {
                                _hasHandledInitialAyah = true;
                                try {
                                  final ayah = s.surah.ayahs.firstWhere(
                                    (a) => a.number.ayahNumberInSurah == widget.initialAyahNumber
                                  );
                                  context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                                  _scrollController.scrollToAyah(widget.initialAyahNumber!);
                                } catch (_) {}
                              } else if (s.highlightedAyah != null) {
                                // If highlight changed (e.g. from navigation elsewhere), scroll to it
                                _scrollController.scrollToAyah(s.highlightedAyah!.number.ayahNumberInSurah);
                              }

                              // Play on load logic
                              if (!_hasHandledPlayOnLoad && widget.playOnLoad) {
                                _hasHandledPlayOnLoad = true;
                                context.read<AudioBloc>().add(
                                  AudioEvent.playSurah(
                                    surahNumber: widget.surahNumber,
                                    startAyah: widget.initialAyahNumber ?? 1,
                                  ),
                                );
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
                      BlocListener<AudioBloc, AudioState>(
                        listenWhen: (prev, curr) {
                          // Only trigger if ayah changed while active in the current surah
                          return curr.currentSurah == widget.surahNumber &&
                                 curr.currentAyah != null &&
                                 curr.currentAyah != prev.currentAyah &&
                                 curr.isActive;
                        },
                        listener: (context, state) {
                          _scrollController.scrollToAyah(state.currentAyah!);
                        },
                      ),
                    ],
                    child: CustomScrollView(
                      controller: _scrollController.scrollController,
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16),
                        ),
                        QuranReaderHeader(
                          surahNumber: widget.surahNumber,
                          onNextSurah: widget.surahNumber < 114 
                            ? () => Navigator.pushReplacement(
                                context,
                                QuranReaderPage.route(surahNumber: widget.surahNumber + 1),
                              )
                            : null,
                          onPreviousSurah: widget.surahNumber > 1
                            ? () => Navigator.pushReplacement(
                                context,
                                QuranReaderPage.route(surahNumber: widget.surahNumber - 1),
                              )
                            : null,
                        ),
                        QuranReaderBody(scrollController: _scrollController),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: QuranReaderBottomBar(
                    surahNumber: widget.surahNumber,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
