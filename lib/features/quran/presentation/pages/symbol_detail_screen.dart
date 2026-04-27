import 'package:fard/core/di/injection.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/features/quran/presentation/utils/quran_fonts.dart';
import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:url_launcher/url_launcher.dart';

class SymbolDetailScreen extends StatefulWidget {
  final QuranSymbol symbol;

  const SymbolDetailScreen({super.key, required this.symbol});

  @override
  State<SymbolDetailScreen> createState() => _SymbolDetailScreenState();
}

class _SymbolDetailScreenState extends State<SymbolDetailScreen> {
  late String selectedSourceId;

  @override
  void initState() {
    super.initState();
    selectedSourceId = widget.symbol.sources.isNotEmpty
        ? widget.symbol.sources.first.name
        : 'default';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(
      int.parse(widget.symbol.color.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol.arabicName, style: GoogleFonts.amiri()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Big Symbol Header
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                widget.symbol.char,
                style: TextStyle(fontSize: 64, color: color),
              ),
            ),
            const SizedBox(height: 24),

            // Brief
            Text(
              widget.symbol.brief,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Rule Summary Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gavel_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'القاعدة العامة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.symbol.ruleSummary,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sources Section
            if (widget.symbol.sources.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مصادر ومراجع',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified_user_rounded,
                        size: 16, color: Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.symbol.sources.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final s = widget.symbol.sources[index];
                    final isSelected = selectedSourceId == s.name;
                    return ChoiceChip(
                      label: Text(s.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedSourceId = s.name);
                        }
                      },
                      avatar: Icon(
                        _getSourceIcon(s.sourceType),
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildSourceContent(context),
            ],

            const SizedBox(height: 32),

            // Examples Section
            if (widget.symbol.examples.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'أمثلة من القرآن الكريم:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              ...widget.symbol.examples.map(
                (ex) => _SymbolExampleCard(
                  example: ex,
                  symbolChar: widget.symbol.char,
                  highlightColor: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSourceIcon(String type) {
    switch (type) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'website':
        return Icons.language_rounded;
      case 'video':
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  Widget _buildSourceContent(BuildContext context) {
    final source = widget.symbol.sources.firstWhere(
      (s) => s.name == selectedSourceId,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            source.content,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          if (source.url != null && source.url!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => _launchUrl(source.url!),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text(
                  'الانتقال إلى المصدر',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SymbolExampleCard extends StatefulWidget {
  final SymbolExample example;
  final String symbolChar;
  final Color highlightColor;

  const _SymbolExampleCard({
    required this.example,
    required this.symbolChar,
    required this.highlightColor,
  });

  @override
  State<_SymbolExampleCard> createState() => _SymbolExampleCardState();
}

class _SymbolExampleCardState extends State<_SymbolExampleCard> {
  String? _ayahText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.example.context == null) {
      _fetchAyahText();
    } else {
      _ayahText = widget.example.context;
    }
  }

  Future<void> _fetchAyahText() async {
    setState(() => _isLoading = true);
    final repo = getIt<QuranRepository>();
    final surahNumResult = SurahNumber.create(widget.example.surah);

    if (surahNumResult.isFailure) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final result = await repo.getSurah(surahNumResult.data!);

    result.fold(
      (failure) {
        if (mounted) setState(() => _isLoading = false);
      },
      (surah) {
        if (mounted) {
          setState(() {
            final ayah = surah.ayahs.firstWhere(
              (a) => a.number.ayahNumberInSurah == widget.example.ayah,
            );
            _ayahText = ayah.uthmaniText;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahNameAr = quran.getSurahNameArabic(widget.example.surah);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_ayahText != null)
              _buildHighlightedText(_ayahText!)
            else
              const Text('تعذر تحميل نص الآية'),

            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'سورة $surahNameAr، آية ${widget.example.ayah.toArabicIndic()}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      QuranReaderPage.route(
                        surahNumber: widget.example.surah,
                        ayahNumber: widget.example.ayah,
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  tooltip: 'ذهاب إلى السورة',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAudioControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    // Split by space to preserve word-level ligatures and combining marks
    final words = text.split(' ');
    final List<InlineSpan> spans = [];

    final ayahStyle = QuranFonts.getFontStyle(
      fontFamily: 'Amiri Quran',
      fontSize: 28,
      height: 2.2,
      color: Theme.of(context).colorScheme.onSurface,
    );

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final bool hasSymbol = word.contains(widget.symbolChar);

      spans.add(
        TextSpan(
          text: word,
          style: hasSymbol
              ? ayahStyle.copyWith(
                  color: widget.highlightColor,
                  backgroundColor: widget.highlightColor.withValues(alpha: 0.1),
                )
              : ayahStyle,
        ),
      );

      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: ayahStyle));
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
        strutStyle: StrutStyle(
          fontFamily: QuranFonts.getFontFamilyName('Amiri Quran'),
          fontSize: 28,
          height: 2.2,
          forceStrutHeight: true,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context) {
    return BlocBuilder<ReciterManagerBloc, ReciterManagerState>(
      builder: (context, managerState) {
        return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            final isCurrentAyah =
                state.currentSurah == widget.example.surah &&
                state.currentAyah == widget.example.ayah;

            final isLoading =
                state.status == AudioStatus.loading && isCurrentAyah;
            final isPlaying =
                state.status == AudioStatus.playing && isCurrentAyah;

            return Row(
              children: [
                // Play/Pause Button
                IconButton.filledTonal(
                  onPressed: isLoading
                      ? null
                      : () {
                          final audioBloc = context.read<AudioPlayerBloc>();
                          if (isPlaying) {
                            audioBloc.add(const Pause());
                          } else if (state.status == AudioStatus.paused &&
                              isCurrentAyah) {
                            audioBloc.add(const Resume());
                          } else {
                            audioBloc.add(
                              PlayAyah(
                                surahNumber: widget.example.surah,
                                ayahNumber: widget.example.ayah,
                                reciter: managerState.currentReciter,
                              ),
                            );
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                ),

                // Stop Button
                if (isCurrentAyah &&
                    (isPlaying || state.status == AudioStatus.paused))
                  IconButton(
                    onPressed: () =>
                        context.read<AudioPlayerBloc>().add(const Stop()),
                    icon: const Icon(Icons.stop_rounded),
                    color: Theme.of(context).colorScheme.error,
                  ),

                const Spacer(),

                // Reciter Switcher
                TextButton.icon(
                  onPressed: () => _showReciterSelector(context),
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: Text(
                    managerState.currentReciter?.name ?? 'اختر القارئ',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReciterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AudioPlayerBloc>()),
          BlocProvider.value(value: context.read<ReciterManagerBloc>()),
        ],
        child: const Material(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ReciterSelector(),
        ),
      ),
    );
  }
}
