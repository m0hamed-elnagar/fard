import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/domain/models/surah.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';

class SurahDetailPage extends StatelessWidget {
  final Surah surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<QuranBloc>()..add(QuranEvent.loadSurahDetails(surah.number)),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surah.englishName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                surah.englishNameTranslation,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  surah.name,
                  style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingQuran,
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<QuranBloc>()
                            .add(QuranEvent.loadSurahDetails(surah.number)),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.selectedSurahDetail == null) {
              return const SizedBox.shrink();
            }

            final detail = state.selectedSurahDetail!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: detail.ayahs.length + (surah.number != 1 && surah.number != 9 ? 1 : 0),
              itemBuilder: (context, index) {
                // Show Bismillah for all surahs except Fatiha (1) and Tawbah (9)
                // Actually for Fatiha, the first ayah is Bismillah in many editions.
                // In alquran.cloud, if it's quran-uthmani, Bismillah is often part of the first ayah or separate.
                
                if (surah.number != 1 && surah.number != 9 && index == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final ayahIndex = (surah.number != 1 && surah.number != 9) ? index - 1 : index;
                final ayah = detail.ayahs[ayahIndex];
                
                // Clean Bismillah from the first ayah if we added it manually
                String ayahText = ayah.text;
                if (surah.number != 1 && surah.number != 9 && ayah.numberInSurah == 1) {
                  if (ayahText.startsWith('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')) {
                     ayahText = ayahText.replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '').trim();
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                            child: Text(
                              ayah.numberInSurah.toString(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ayahText,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.amiri(
                                fontSize: 24,
                                height: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
