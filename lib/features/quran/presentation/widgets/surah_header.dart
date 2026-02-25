import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/extensions/number_extension.dart';

class SurahHeader extends StatelessWidget {
  final Surah surah;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const SurahHeader({
    super.key, 
    required this.surah,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (onPrevious != null && surah.number.value > 1)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  onPressed: onPrevious,
                  tooltip: 'السورة السابقة',
                )
              else
                const SizedBox(width: 48),
              
              Expanded(
                child: Text(
                  surah.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              if (onNext != null && surah.number.value < 114)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: onNext,
                  tooltip: 'السورة التالية',
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.place_outlined,
                label: surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.format_list_numbered,
                label: '${surah.numberOfAyahs.toArabicIndic()} آية',
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<AudioBloc, AudioState>(
            builder: (context, state) {
              final isPlaying = state.isPlaying;
              final isLoading = state.isLoading;
              final isThisSurah = state.currentSurah == surah.number.value;

              return Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (isPlaying && isThisSurah) {
                        context.read<AudioBloc>().add(AudioEvent.pause());
                      } else if (state.status == AudioStatus.paused && isThisSurah) {
                        context.read<AudioBloc>().add(AudioEvent.resume());
                      } else {
                        context.read<AudioBloc>().add(AudioEvent.playSurah(
                          surahNumber: surah.number.value,
                          ayahCount: surah.numberOfAyahs,
                          reciter: state.currentReciter,
                        ));
                      }
                    },
                    icon: isLoading && isThisSurah
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(isPlaying && isThisSurah ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    label: Text(isPlaying && isThisSurah ? 'إيقاف' : 'تشغيل السورة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(
                      state.currentReciter?.name.split(' ').first ?? 'القاريء'
                    ),
                    onPressed: () => _showReciterSelector(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReciterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AudioBloc>(),
        child: const Material(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ReciterSelector(),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
