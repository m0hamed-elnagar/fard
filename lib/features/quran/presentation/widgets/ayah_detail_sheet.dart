import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/usecases/get_tafsir.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/jump_dialog.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/domain/entities/tafsir_info.dart';

import 'package:fard/core/extensions/number_extension.dart';

import '../../../audio/domain/repositories/audio_player_service.dart';

import 'package:fard/features/quran/presentation/widgets/ayah_info_sheet.dart';
import 'package:fard/core/utils/symbol_detector.dart';
import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';

class AyahDetailSheet extends StatelessWidget {
  final Ayah ayah;
  final int? surahAyahCount;

  const AyahDetailSheet({super.key, required this.ayah, this.surahAyahCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return DefaultTabController(
          length: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: NestedScrollView(
              controller: scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${l10n.ayah} ${ayah.number.ayahNumberInSurah.toArabicIndic()}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  BlocBuilder<ReaderBloc, ReaderState>(
                                    builder: (context, state) {
                                      final isLastRead = state.maybeMap(
                                        loaded: (s) =>
                                            s.lastReadAyah?.number ==
                                            ayah.number,
                                        orElse: () => false,
                                      );

                                      final isBookmarked = state.maybeMap(
                                        loaded: (s) => s.bookmarks.any(
                                          (b) => b.ayahNumber == ayah.number,
                                        ),
                                        orElse: () => false,
                                      );

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isBookmarked
                                                  ? Icons.bookmark_rounded
                                                  : Icons
                                                        .bookmark_border_rounded,
                                              color: isBookmarked
                                                  ? context.secondaryColor
                                                  : null,
                                            ),
                                            tooltip: isBookmarked
                                                ? l10n.removeFromBookmarks
                                                : l10n.addToBookmarks,
                                            onPressed: () async {
                                              bool shouldToggle = true;
                                              if (isBookmarked) {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (dialogContext) => AlertDialog(
                                                    title: Text(
                                                      l10n.removeFromBookmarks,
                                                      style: GoogleFonts.amiri(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                    content: Text(
                                                      'هل أنت متأكد من حذف هذه الإشارة المرجعية؟',
                                                      style:
                                                          GoogleFonts.amiri(),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              dialogContext,
                                                              false,
                                                            ),
                                                        child: Text(
                                                          'إلغاء',
                                                          style:
                                                              GoogleFonts.amiri(
                                                                color:
                                                                    context.onSurfaceVariantColor,
                                                              ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              dialogContext,
                                                              true,
                                                            ),
                                                        child: Text(
                                                          'حذف',
                                                          style:
                                                              GoogleFonts.amiri(
                                                                color:
                                                                    context.errorColor,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                shouldToggle =
                                                    confirmed ?? false;
                                              }

                                              if (shouldToggle &&
                                                  context.mounted) {
                                                context.read<ReaderBloc>().add(
                                                  ReaderEvent.toggleBookmark(
                                                    ayah,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isBookmarked
                                                          ? l10n.removedFromBookmarks
                                                          : l10n.addedToBookmarks,
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 1,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          _MarkAsLastReadButton(
                                            ayah: ayah,
                                            isLastRead: isLastRead,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: SelectableText(
                                  ayah.uthmaniText,
                                  style: GoogleFonts.amiri(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 2.2,
                                    wordSpacing: 4,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        labelStyle: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: l10n.tafsir),
                          Tab(text: l10n.audio),
                          const Tab(text: 'الرموز'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _TafsirTab(ayah: ayah),
                  _AudioTab(ayah: ayah, surahAyahCount: surahAyahCount),
                  AyahInfoSheet(
                    ayahText: ayah.uthmaniText,
                    repository: getIt<QuranSymbolsRepository>(),
                    detector: getIt<SymbolDetectorService>(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _TafsirTab extends StatelessWidget {
  final Ayah ayah;

  const _TafsirTab({required this.ayah});

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  void _showTafsirSelector(BuildContext context, int currentId) {
    final readerBloc = context.read<ReaderBloc>();
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: readerBloc,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.selectTafsir,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: TafsirInfo.availableTafsirs.length,
                  itemBuilder: (context, index) {
                    final tafsir = TafsirInfo.availableTafsirs[index];
                    final isArabic = tafsir.languageName == 'arabic';
                    return ListTile(
                      title: Text(
                        tafsir.name,
                        style: isArabic
                            ? GoogleFonts.amiri(fontWeight: FontWeight.bold)
                            : null,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      subtitle: Text(
                        tafsir.authorName,
                        style: isArabic
                            ? GoogleFonts.amiri(fontSize: 14)
                            : null,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      leading: !isArabic && tafsir.id == currentId
                          ? Icon(Icons.check, color: context.primaryColor)
                          : null,
                      trailing: isArabic && tafsir.id == currentId
                          ? Icon(Icons.check, color: context.primaryColor)
                          : null,
                      onTap: () {
                        readerBloc.add(ReaderEvent.updateTafsir(tafsir.id));
                        Navigator.pop(modalContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        final tafsirId = state.maybeMap(
          loaded: (s) => s.selectedTafsirId,
          orElse: () => 16,
        );

        final selectedTafsir = TafsirInfo.availableTafsirs.firstWhere(
          (t) => t.id == tafsirId,
          orElse: () => TafsirInfo.availableTafsirs.first,
        );

        return FutureBuilder<String>(
          key: ValueKey(tafsirId),
          future: getIt<GetTafsir>()
              .call(
                GetTafsirParams(
                  surahNumber: ayah.number.surahNumber,
                  ayahNumber: ayah.number.ayahNumberInSurah,
                  tafsirId: tafsirId,
                ),
              )
              .then(
                (res) => res.fold(
                  (f) => l10n.errorLoadingTafsir(f.message),
                  (d) => d,
                ),
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tafsir = snapshot.data ?? l10n.noTafsirAvailable;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.translate, size: 20),
                  title: Text(
                    l10n.tafsirWithVal(selectedTafsir.name),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => _showTafsirSelector(context, tafsirId),
                ),
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: SelectableText(
                    _cleanHtml(tafsir),
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      height: 2.2,
                      wordSpacing: 2,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AudioTab extends StatelessWidget {
  final Ayah ayah;
  final int? surahAyahCount;

  const _AudioTab({required this.ayah, this.surahAyahCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final status = state.status;

        final isCurrentAyah =
            state.currentSurah == ayah.number.surahNumber &&
            state.currentAyah == ayah.number.ayahNumberInSurah;

        final isLoading = state.isLoading && isCurrentAyah;
        final isPlaying = state.isPlaying && isCurrentAyah;
        final isError = state.hasError && isCurrentAyah;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headset_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isError
                  ? l10n.errorPlayingAudio(state.error ?? '')
                  : l10n.quranRecitation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isError ? context.errorColor : null,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 16,
              children: [
                _AudioButton(
                  icon: Icons.repeat_one_rounded,
                  label: l10n.ayahBtn,
                  onPressed: () {
                    context.read<AudioBloc>().add(
                      AudioEvent.playAyah(
                        surahNumber: ayah.number.surahNumber,
                        ayahNumber: ayah.number.ayahNumberInSurah,
                        reciter: state.currentReciter,
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isError
                            ? context.errorColor
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isError
                                        ? context.errorColor
                                        : Theme.of(context).colorScheme.primary)
                                    .withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? Padding(
                              padding: EdgeInsets.all(18.0),
                              child: CircularProgressIndicator(
                                color: context.onSurfaceColor,
                                strokeWidth: 3,
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                isError
                                    ? Icons.refresh_rounded
                                    : (isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded),
                                size: 40,
                                color: context.onSurfaceColor,
                              ),
                              onPressed: () {
                                if (isPlaying) {
                                  context.read<AudioBloc>().add(
                                    AudioEvent.pause(),
                                  );
                                } else if (status == AudioStatus.paused &&
                                    isCurrentAyah) {
                                  context.read<AudioBloc>().add(
                                    AudioEvent.resume(),
                                  );
                                } else {
                                  context.read<AudioBloc>().add(
                                    AudioEvent.playSurah(
                                      surahNumber: ayah.number.surahNumber,
                                      startAyah: ayah.number.ayahNumberInSurah,
                                      ayahCount: surahAyahCount,
                                      reciter: state.currentReciter,
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPlaying ? l10n.pause : l10n.playSurah,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
                _AudioButton(
                  icon: Icons.stop_rounded,
                  label: l10n.stop,
                  onPressed: () {
                    context.read<AudioBloc>().add(AudioEvent.stop());
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.reciter),
              subtitle: Text(
                state.currentReciter != null
                    ? (l10n.localeName == 'ar'
                          ? state.currentReciter!.name
                          : state.currentReciter!.englishName)
                    : l10n.selectReciter,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showReciterSelector(context),
            ),
          ],
        );
      },
    );
  }

  void _showReciterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AudioBloc>(),
        child: const ReciterSelector(),
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AudioButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: IconButton(
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _MarkAsLastReadButton extends StatefulWidget {
  final Ayah ayah;
  final bool isLastRead;

  const _MarkAsLastReadButton({required this.ayah, required this.isLastRead});

  @override
  State<_MarkAsLastReadButton> createState() => _MarkAsLastReadButtonState();
}

class _MarkAsLastReadButtonState extends State<_MarkAsLastReadButton> {
  DateTime? _lastMarkTapTime;

  Future<void> _showUndoConfirmationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final werdBloc = context.read<WerdBloc>();
    final progress = werdBloc.state.progress;
    final segments = progress?.segmentsToday;
    final lastSegment = segments?.isNotEmpty == true ? segments!.last : null;

    if (lastSegment == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.werdNothingToUndo),
            content: Text(l10n.werdNoSessionToRemove),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.werdClose),
              ),
            ],
          ),
        );
      }
      return;
    }

    final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(
      lastSegment.startAyah,
    );
    final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(
      lastSegment.endAyah,
    );
    final isAr = l10n.localeName == 'ar';
    final startSurah = isAr
        ? quran.getSurahNameArabic(startPos[0])
        : quran.getSurahName(startPos[0]);
    final endSurah = isAr
        ? quran.getSurahNameArabic(endPos[0])
        : quran.getSurahName(endPos[0]);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.werdUndoTitle),
        content: Text(l10n.werdUndoMessage(
          lastSegment.ayahsCount,
          startSurah,
          endSurah,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.werdCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.werdUndo,
              style: TextStyle(color: context.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      werdBloc.add(const WerdEvent.undoLastAction());
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _markAsRead() async {
    final l10n = AppLocalizations.of(context)!;

    if (!mounted) return;

    // Get current progress to check for jumps
    final werdState = context.read<WerdBloc>().state;
    final currentProgress = werdState.progress;
    final lastReadAbs = currentProgress?.lastReadAbsolute;

    // Calculate absolute ayah number for the ayah we're trying to mark
    final absAyah = QuranHizbProvider.getAbsoluteAyahNumber(
      widget.ayah.number.surahNumber,
      widget.ayah.number.ayahNumberInSurah,
    );

    debugPrint('📖 [MarkAsRead] Attempting to mark ayah $absAyah as last read');
    debugPrint('   Last read position: $lastReadAbs');

    // Show jump dialog only if gap is at least 50 ayahs
    if (lastReadAbs != null) {
      final gap = (absAyah - lastReadAbs).abs();
      const jumpThreshold = 50;

      debugPrint('📖 [MarkAsRead] Gap: $gap ayahs (threshold: $jumpThreshold)');

      if (gap >= jumpThreshold) {
        // Show jump dialog BEFORE saving
        debugPrint('📖 [MarkAsRead] Showing jump dialog');
        final choice = await JumpDialog.show(
          context,
          lastReadAyah: lastReadAbs,
          targetAyah: absAyah,
          currentTotalToday: currentProgress?.totalAmountReadToday ?? 0,
        );

        debugPrint('📖 [MarkAsRead] Jump dialog result: $choice');

        // User dismissed - don't mark as read
        if (choice == null || choice == 0) {
          debugPrint('📖 [MarkAsRead] Dismissed - no changes saved');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jump dismissed - ayah not marked'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          return;
        }

        // User chose "Mark All" - save the ayah and track the range
        if (choice == 1 && mounted) {
          debugPrint('📖 [MarkAsRead] Mark All - saving ayah $absAyah');
          context.read<ReaderBloc>().add(
                ReaderEvent.saveLastRead(widget.ayah),
              );

          context.read<WerdBloc>().add(
                WerdEvent.trackItemReadMarkAll(
                  startAbsolute: lastReadAbs,
                  endAbsolute: absAyah,
                ),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.markAsLastReadSuccess),
              duration: const Duration(seconds: 1),
            ),
          );
          _lastMarkTapTime = DateTime.now();
        }

        // User chose "Start New Session" - mark only current ayah, don't count gap
        if (choice == 2 && mounted) {
          debugPrint('🚀 [MarkAsRead] New Session - jumping to ayah $absAyah');
          context.read<ReaderBloc>().add(
                ReaderEvent.saveLastRead(widget.ayah),
              );

          context.read<WerdBloc>().add(
                WerdEvent.jumpToNewSession(absAyah),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.newSessionStartedSuccess),
              duration: const Duration(seconds: 1),
            ),
          );
          _lastMarkTapTime = DateTime.now();
        }
        } else {        // Gap is small (< 50 ayahs) - save normally without jump dialog
        debugPrint('📖 [MarkAsRead] Gap too small ($gap < $jumpThreshold) - saving normally');
        context.read<ReaderBloc>().add(
          ReaderEvent.saveLastRead(widget.ayah),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markAsLastReadSuccess),
            duration: const Duration(seconds: 1),
          ),
        );
        _lastMarkTapTime = DateTime.now();
      }
    } else {
      // No previous position - save normally
      debugPrint('📖 [MarkAsRead] No previous position - saving ayah $absAyah');
      context.read<ReaderBloc>().add(
        ReaderEvent.saveLastRead(widget.ayah),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.markAsLastReadSuccess),
          duration: const Duration(seconds: 1),
        ),
      );
      _lastMarkTapTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.isLastRead
            ? Icons.menu_book_rounded
            : Icons.menu_book_outlined,
        color: widget.isLastRead
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      tooltip: AppLocalizations.of(context)!.markAsLastRead,
      onPressed: () {
        if (_lastMarkTapTime != null) {
          _showUndoConfirmationDialog();
        } else {
          _markAsRead();
        }
      },
    );
  }
}
