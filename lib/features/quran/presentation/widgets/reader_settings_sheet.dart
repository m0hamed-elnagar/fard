import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/domain/entities/reader_settings.dart';
import 'package:fard/features/quran/presentation/utils/quran_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  static const List<Map<String, String>> _availableFonts = [
    {'label': 'Amiri', 'value': 'Amiri'},
    {'label': 'Amiri Quran', 'value': 'Amiri Quran'},
    {'label': 'Noto Naskh Arabic', 'value': 'Noto Naskh Arabic'},
    {'label': 'Scheherazade New', 'value': 'Scheherazade New'},
    {'label': 'Lateef', 'value': 'Lateef'},
    {'label': 'Tajawal', 'value': 'Tajawal'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return state.maybeMap(
          loaded: (s) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.readerSettings,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Text Size Section
                Row(
                  children: [
                    const Icon(Icons.format_size, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      l10n.textSize,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text('${(s.textScale * 100).toInt()}%'),
                  ],
                ),
                Slider(
                  value: s.textScale.clamp(0.5, 3.0),
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  onChanged: (value) {
                    context.read<ReaderBloc>().add(
                      ReaderEvent.updateScale(value),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Separators Section
                Row(
                  children: [
                    const Icon(Icons.view_day_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      l10n.separators,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<ReaderSeparator>(
                      segments: [
                        ButtonSegment(
                          value: ReaderSeparator.none,
                          label: Text(l10n.none),
                        ),
                        ButtonSegment(
                          value: ReaderSeparator.page,
                          label: Text(l10n.page),
                        ),
                        ButtonSegment(
                          value: ReaderSeparator.juz,
                          label: Text(l10n.juzTab),
                        ),
                        ButtonSegment(
                          value: ReaderSeparator.hizb,
                          label: Text(l10n.hizbTab),
                        ),
                        ButtonSegment(
                          value: ReaderSeparator.quarter,
                          label: Text(l10n.quarter),
                        ),
                      ],
                      selected: {s.separator},
                      onSelectionChanged: (value) {
                        context.read<ReaderBloc>().add(
                          ReaderEvent.updateSeparator(value.first),
                        );
                      },
                      showSelectedIcon: false,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Font Family Section
                Text(
                  l10n.fontFamily,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableFonts.map((font) {
                    final isSelected = s.fontFamily == font['value'];
                    return ChoiceChip(
                      label: Text(
                        font['label']!,
                        style: QuranFonts.getFontStyle(
                          fontFamily: font['value'],
                          fontSize: 16,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<ReaderBloc>().add(
                            ReaderEvent.updateFontFamily(font['value']!),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
