import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return state.maybeMap(
          loaded: (s) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                  'Reader Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(Icons.format_size, size: 20),
                    const SizedBox(width: 12),
                    const Text('Text Size', style: TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text('${(s.textScale * 100).toInt()}%'),
                  ],
                ),
                Slider(
                  value: s.textScale,
                  min: 0.8,
                  max: 3.0,
                  divisions: 22,
                  onChanged: (value) {
                    context.read<ReaderBloc>().add(ReaderEvent.updateScale(value));
                  },
                ),
                const SizedBox(height: 16),
                // Add more settings here like theme, font, etc.
                const SizedBox(height: 24),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
