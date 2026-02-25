import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/usecases/get_tafsir.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/domain/entities/tafsir_info.dart';

import 'package:fard/core/extensions/number_extension.dart';

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
          length: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${l10n.ayah} ${ayah.number.ayahNumberInSurah.toArabicIndic()}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  BlocBuilder<ReaderBloc, ReaderState>(
                                    builder: (context, state) {
                                      final isLastRead = state.maybeMap(
                                        loaded: (s) => s.lastReadAyah?.number == ayah.number,
                                        orElse: () => false,
                                      );
                                      
                                      final isBookmarked = state.maybeMap(
                                        loaded: (s) => s.isBookmarked,
                                        orElse: () => false,
                                      );

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                              color: isBookmarked ? Colors.amber : null,
                                            ),
                                            tooltip: isBookmarked ? 'إزالة من الإشارات' : 'إضافة إلى الإشارات',
                                            onPressed: () {
                                              context.read<ReaderBloc>().add(ReaderEvent.toggleBookmark(ayah));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(isBookmarked ? 'تمت الإزالة من الإشارات' : 'تمت الإضافة إلى الإشارات'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isLastRead ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                                              color: isLastRead ? Theme.of(context).colorScheme.primary : null,
                                            ),
                                            tooltip: 'تحديد كآخر قراءة',
                                            onPressed: () {
                                              context.read<ReaderBloc>().add(ReaderEvent.saveLastRead(ayah));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('تم التحديد كآخر قراءة'),
                                                  duration: Duration(seconds: 1),
                                                ),
                                              );
                                            },
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
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
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
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'التفسير'),
                          Tab(text: 'صوتيات'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _TafsirTab(ayah: ayah),
                  _AudioTab(
                    ayah: ayah, 
                    surahAyahCount: surahAyahCount,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'اختر التفسير',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        style: isArabic ? GoogleFonts.amiri(fontWeight: FontWeight.bold) : null,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      subtitle: Text(
                        tafsir.authorName,
                        style: isArabic ? GoogleFonts.amiri(fontSize: 14) : null,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      leading: !isArabic && tafsir.id == currentId ? const Icon(Icons.check, color: Colors.green) : null,
                      trailing: isArabic && tafsir.id == currentId ? const Icon(Icons.check, color: Colors.green) : null,
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

        return Column(
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.translate, size: 20),
              title: Text(
                'التفسير: ${selectedTafsir.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _showTafsirSelector(context, tafsirId),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<String>(
                key: ValueKey(tafsirId), // Re-fetch when tafsirId changes
                future: getIt<GetTafsir>().call(GetTafsirParams(
                  surahNumber: ayah.number.surahNumber,
                  ayahNumber: ayah.number.ayahNumberInSurah,
                  tafsirId: tafsirId,
                )).then((res) => res.fold((f) => 'خطأ في تحميل التفسير: ${f.message}', (d) => d)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final tafsir = snapshot.data ?? 'لا يوجد تفسير متاح';
                  
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      Text(
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
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AudioTab extends StatelessWidget {
  final Ayah ayah;
  final int? surahAyahCount;

  const _AudioTab({
    required this.ayah, 
    this.surahAyahCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final status = state.status;
        final isLoading = state.isLoading;
        final isPlaying = state.isPlaying;
        final isError = state.hasError;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.headset_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isError ? 'خطأ في تشغيل الصوت: ${state.error}' : 'تلاوة القرآن الكريم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isError ? Colors.red : null,
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
                  label: 'الآية',
                  onPressed: () {
                    context.read<AudioBloc>().add(AudioEvent.playAyah(
                      surahNumber: ayah.number.surahNumber,
                      ayahNumber: ayah.number.ayahNumberInSurah,
                      reciter: state.currentReciter,
                    ));
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isError ? Colors.red : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isError ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading 
                        ? const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : IconButton(
                            icon: Icon(
                              isError ? Icons.refresh_rounded : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded), 
                              size: 40, 
                              color: Colors.white
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                context.read<AudioBloc>().add(AudioEvent.pause());
                              } else if (status == AudioStatus.paused) {
                                context.read<AudioBloc>().add(AudioEvent.resume());
                              } else {
                                context.read<AudioBloc>().add(AudioEvent.playSurah(
                                  surahNumber: ayah.number.surahNumber,
                                  startAyah: ayah.number.ayahNumberInSurah,
                                  ayahCount: surahAyahCount,
                                  reciter: state.currentReciter,
                                ));
                              }
                            },
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPlaying ? 'إيقاف مؤقت' : 'تشغيل السورة',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                  ],
                ),
                _AudioButton(
                  icon: Icons.stop_rounded,
                  label: 'إيقاف',
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
              title: const Text('القاريء'),
              subtitle: Text(state.currentReciter?.name ?? 'اختر القاريء'),
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
