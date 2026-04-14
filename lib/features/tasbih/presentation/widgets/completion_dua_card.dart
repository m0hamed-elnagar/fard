import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:fard/features/tasbih/presentation/widgets/tasbih_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletionDuaCard extends StatelessWidget {
  final TasbihState state;

  const CompletionDuaCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dua = state.currentCompletionDua!;

    return Card(
      color: context.primaryColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showDuaSelector(context, state),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    l10n.changeDua,
                    style: GoogleFonts.outfit(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(foregroundColor: context.secondaryColor),
                ),
                if (!state.duaRemembered)
                  TextButton.icon(
                    onPressed: () {
                      context.read<TasbihBloc>().add(
                        const TasbihEvent.rememberCompletionDua(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.duaSaved),
                          duration: const Duration(seconds: 2),
                          backgroundColor: context.primaryColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: Text(
                      l10n.rememberDua,
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: context.secondaryColor,
                    ),
                  )
                else
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.duaSaved,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.secondaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                dua.title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              dua.arabic,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.onSurfaceColor,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dua.transliteration,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: context.onSurfaceVariantColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.read<TasbihBloc>().add(const TasbihEvent.reset()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.secondaryColor,
                  foregroundColor: context.theme.colorScheme.onSecondary,
                ),
                child: Text(l10n.finishAndReset),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDuaSelector(BuildContext context, TasbihState state) {
    final tasbihBloc = context.read<TasbihBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceContainerColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: tasbihBloc,
          child: DuaSelectionSheet(state: state),
        );
      },
    );
  }
}
