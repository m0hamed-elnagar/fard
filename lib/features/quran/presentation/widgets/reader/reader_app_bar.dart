import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/reader_settings_sheet.dart';
import 'package:fard/features/quran/presentation/pages/scanned_mushaf_reader_page.dart';

class QuranReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuranReaderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: BlocBuilder<ReaderBloc, ReaderState>(
        builder: (context, state) {
          return state.maybeMap(
            loaded: (s) => Text(s.surah.name, style: GoogleFonts.amiri()),
            orElse: () => Text(l10n.quranReader),
          );
        },
      ),
      actions: [
        BlocBuilder<ReaderBloc, ReaderState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              tooltip: l10n.scannedMushaf,
              onPressed: () {
                int page = 1;
                state.maybeMap(
                  loaded: (s) {
                    final targetAyah =
                        s.highlightedAyah ??
                        s.lastReadAyah ??
                        s.surah.ayahs.firstOrNull;
                    if (targetAyah != null) {
                      page = quran.getPageNumber(
                        s.surah.number.value,
                        targetAyah.number.ayahNumberInSurah,
                      );
                    }
                  },
                  orElse: () {},
                );
                Navigator.pushReplacement(
                  context,
                  ScannedMushafReaderPage.route(pageNumber: page),
                );
              },
            );
          },
        ),
        BlocBuilder<ReaderBloc, ReaderState>(
          builder: (context, state) {
            final readerBloc = context.read<ReaderBloc>();
            return IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: state.maybeMap(
                loaded: (_) => () async {
                  // Note: Checking for _isSheetShowing is harder here as we are stateless.
                  // Relying on standard modal behavior.
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BlocProvider.value(
                      value: readerBloc,
                      child: const ReaderSettingsSheet(),
                    ),
                  );
                },
                orElse: () => null,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
