import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:google_fonts/google_fonts.dart';

class SurahHeader extends StatelessWidget {
  final Surah surah;

  const SurahHeader({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: GoogleFonts.amiri(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
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
                label: '${surah.numberOfAyahs} آية',
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<AudioBloc, AudioState>(
            builder: (context, state) {
              final isPlaying = state.isPlaying;
              final isLoading = state.isLoading;
              final isThisSurah = state.currentSurah == surah.number.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: 12),
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
