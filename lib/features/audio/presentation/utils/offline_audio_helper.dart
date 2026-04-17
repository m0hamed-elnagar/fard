import 'package:fard/core/blocs/connectivity/connectivity_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/download_center_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/repositories/audio_player_service.dart';

class OfflineAudioHelper {
  static Future<void> handlePlayRequest({
    required BuildContext context,
    required int surahNumber,
    required int startAyah,
    bool isDownloaded = false,
    bool forceDirectPlay = false,
  }) async {
    final connState = context.read<ConnectivityBloc>().state;
    final isConnected =
        connState is ConnectivityStatus ? connState.isConnected : true;

    final audioBloc = context.read<AudioBloc>();
    final audioState = audioBloc.state;
    final currentReciter = audioState.currentReciter;

    // Smart play/pause: If this surah is already active, toggle its state
    if (audioState.currentSurah == surahNumber) {
      if (audioState.isPlaying) {
        audioBloc.add(AudioEvent.pause());
        return;
      } else if (audioState.status == AudioStatus.paused) {
        audioBloc.add(AudioEvent.resume());
        return;
      }
    }

    // Real-time download check if caller didn't specify or passed false
    bool effectivelyDownloaded = isDownloaded;
    if (!effectivelyDownloaded && currentReciter != null) {
      final status = await getIt<AudioDownloadService>()
          .getSurahStatus(reciterId: currentReciter.identifier, surahNumber: surahNumber);
      effectivelyDownloaded = status.isDownloaded;
    }

    if (effectivelyDownloaded || isConnected) {
      audioBloc.add(
        AudioEvent.playSurah(surahNumber: surahNumber, startAyah: startAyah),
      );
      audioBloc.add(AudioEvent.showBanner());
      return;
    }

    // Offline and NOT downloaded: Look for alternatives
    final alternatives = await getIt<AudioDownloadService>()
        .getRecitersWithDownloadedSurah(surahNumber);

    if (alternatives.isNotEmpty) {
      if (context.mounted) {
        showAlternativeReciterDialog(
          context,
          surahNumber,
          startAyah,
          alternatives.first,
        );
      }
    } else {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.manageRecitersDesc),
            action: SnackBarAction(
              label: l10n.downloadCenterBtn,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const DownloadCenterSheet(),
                );
              },
            ),
          ),
        );
      }
    }
  }

  static void showAlternativeReciterDialog(
    BuildContext context,
    int surahNumber,
    int startAyah,
    Reciter alternative,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final audioBloc = context.read<AudioBloc>();
    final currentReciter = audioBloc.state.currentReciter;
    final isArabic = l10n.localeName == 'ar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.quranAudio,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isArabic
              ? "هذه السورة غير محملة للقارئ ${currentReciter?.name ?? ''}. هل تود الاستماع إليها بصوت ${alternative.name} المتاح بدون إنترنت؟"
              : "This surah is not downloaded for ${currentReciter?.englishName ?? ''}. Would you like to play it with ${alternative.englishName} instead?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              audioBloc.add(AudioEvent.selectReciter(alternative));
              audioBloc.add(
                AudioEvent.playSurah(
                  surahNumber: surahNumber,
                  startAyah: startAyah,
                ),
              );
              audioBloc.add(AudioEvent.showBanner());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: context.onSurfaceColor,
            ),
            child: Text(
              l10n.playSurahBtn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
