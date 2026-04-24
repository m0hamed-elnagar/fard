import 'package:fard/core/di/injection.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

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
    final color = Color(int.parse(widget.symbol.color.replaceFirst('#', '0xFF')));

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
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        Text('القاعدة العامة', style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: Text(
                  'شرح مفصل من المصادر:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: widget.symbol.sources.map((s) => ButtonSegment(
                  value: s.name,
                  label: Text(s.name, style: const TextStyle(fontSize: 12)),
                  icon: Icon(_getSourceIcon(s.sourceType), size: 16),
                )).toList(),
                selected: {selectedSourceId},
                onSelectionChanged: (newVal) {
                  setState(() => selectedSourceId = newVal.first);
                },
              ),
              const SizedBox(height: 16),
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
              ...widget.symbol.examples.map((ex) => _SymbolExampleCard(
                example: ex,
                symbolChar: widget.symbol.char,
                highlightColor: color,
              )),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSourceIcon(String type) {
    switch (type) {
      case 'book': return Icons.menu_book_rounded;
      case 'website': return Icons.language_rounded;
      case 'video': return Icons.play_circle_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Widget _buildSourceContent(BuildContext context) {
    final source = widget.symbol.sources.firstWhere((s) => s.name == selectedSourceId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Text(
        source.content,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 14, height: 1.6),
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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ))
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
    final parts = text.split(widget.symbolChar);
    final List<InlineSpan> spans = [];
    
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(TextSpan(
          text: widget.symbolChar,
          style: TextStyle(
            color: widget.highlightColor,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ));
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          children: spans,
          style: GoogleFonts.amiri(
            fontSize: 24,
            height: 1.8,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final isCurrentAyah = state.currentSurah == widget.example.surah &&
            state.currentAyah == widget.example.ayah;
        
        final isLoading = state.status == AudioStatus.loading && isCurrentAyah;
        final isPlaying = state.status == AudioStatus.playing && isCurrentAyah;

        return Row(
          children: [
            // Play/Pause Button
            IconButton.filledTonal(
              onPressed: isLoading ? null : () {
                final audioBloc = context.read<AudioBloc>();
                if (isPlaying) {
                  audioBloc.add(AudioEvent.pause());
                } else if (state.status == AudioStatus.paused && isCurrentAyah) {
                  audioBloc.add(AudioEvent.resume());
                } else {
                  audioBloc.add(AudioEvent.playAyah(
                    surahNumber: widget.example.surah,
                    ayahNumber: widget.example.ayah,
                    reciter: state.currentReciter,
                  ));
                }
              },
              icon: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
            
            // Stop Button
            if (isCurrentAyah && (isPlaying || state.status == AudioStatus.paused))
              IconButton(
                onPressed: () => context.read<AudioBloc>().add(AudioEvent.stop()),
                icon: const Icon(Icons.stop_rounded),
                color: Theme.of(context).colorScheme.error,
              ),
            
            const Spacer(),
            
            // Reciter Switcher
            TextButton.icon(
              onPressed: () => _showReciterSelector(context),
              icon: const Icon(Icons.person_outline, size: 18),
              label: Text(
                state.currentReciter?.name ?? 'اختر القارئ',
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

