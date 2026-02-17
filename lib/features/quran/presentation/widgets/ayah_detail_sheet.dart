import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/usecases/get_tafsir.dart';
import 'package:fard/features/quran/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class AyahDetailSheet extends StatelessWidget {
  final Ayah ayah;

  const AyahDetailSheet({super.key, required this.ayah});

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
                  child: Row(
                    children: [
                      Text(
                        '${l10n.ayah} ${ayah.number.ayahNumberInSurah}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  tabs: [
                    const Tab(text: 'التفسير'), // Tafsir in Arabic
                    const Tab(text: 'Audio'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TafsirTab(ayah: ayah, controller: scrollController),
                      _AudioTab(ayah: ayah, controller: scrollController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TafsirTab extends StatelessWidget {
  final Ayah ayah;
  final ScrollController controller;

  const _TafsirTab({required this.ayah, required this.controller});

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getIt<GetTafsir>().call(GetTafsirParams(
        surahNumber: ayah.number.surahNumber,
        ayahNumber: ayah.number.ayahNumberInSurah,
        tafsirId: 16, // Tafsir Al-Jalalayn (Arabic)
      )).then((res) => res.fold((f) => 'خطأ في تحميل التفسير: ${f.message}', (d) => d)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final tafsir = snapshot.data ?? 'لا يوجد تفسير متاح';
        
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
             Text(
              _cleanHtml(tafsir),
              style: GoogleFonts.amiri(
                fontSize: 20,
                height: 1.8,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
            ),
          ],
        );
      },
    );
  }
}

class _AudioTab extends StatelessWidget {
  final Ayah ayah;
  final ScrollController controller;

  const _AudioTab({required this.ayah, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final status = state.maybeMap(
          loaded: (s) => s.status,
          orElse: () => AudioStatus.idle,
        );
        
        final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);
        final isPlaying = status == AudioStatus.playing;
        final isError = status == AudioStatus.error || state.maybeMap(error: (_) => true, orElse: () => false);

        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: Icon(Icons.headset, size: 64, color: AppTheme.accent),
            ),
            const SizedBox(height: 24),
            Text(
              isError ? 'خطأ في تشغيل الصوت' : 'Listen to Quran',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isError ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AudioButton(
                  icon: Icons.repeat_one_rounded,
                  label: 'Ayah',
                  onPressed: () {
                    context.read<AudioBloc>().add(AudioEvent.play(
                      ayah: ayah.number,
                      reciterId: '7',
                      audioUrl: ayah.audioUrl,
                      mode: AudioPlayMode.ayah,
                    ));
                  },
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isError ? Colors.red : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isError ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading 
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : IconButton(
                            icon: Icon(
                              isError ? Icons.refresh_rounded : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded), 
                              size: 48, 
                              color: Colors.white
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                context.read<AudioBloc>().add(const AudioEvent.pause());
                              } else if (status == AudioStatus.paused) {
                                context.read<AudioBloc>().add(const AudioEvent.resume());
                              } else {
                                context.read<AudioBloc>().add(AudioEvent.play(
                                  ayah: ayah.number,
                                  reciterId: '7',
                                  audioUrl: ayah.audioUrl,
                                  mode: AudioPlayMode.surah,
                                ));
                              }
                            },
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPlaying ? 'Pause' : 'Play Surah',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                _AudioButton(
                  icon: Icons.stop_rounded,
                  label: 'Stop',
                  onPressed: () {
                    context.read<AudioBloc>().add(const AudioEvent.stop());
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
            const ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Reciter'),
              subtitle: Text('Mishary Rashid Alafasy'),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        );
      },
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
