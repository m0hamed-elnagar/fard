import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

/// Dialog shown when user reaches ayah 6236 (end of Quran)
/// Offers 3 choices: Read doaa, Start new cycle, Stay here
class CycleCompletionDialog extends StatelessWidget {
  const CycleCompletionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration header with icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.15),
                    AppTheme.accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.4),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.cycleCompletionTitle,
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.cycleCompletionSubtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: Read doaa
            _buildOption(
              context,
              icon: Icons.menu_book_rounded,
              label: l10n.cycleCompletionReadDoaa,
              description: l10n.cycleCompletionReadDoaaDesc,
              color: AppTheme.accent,
              onTap: () => Navigator.of(context).pop('doaa'),
            ),
            const SizedBox(height: 10),

            // Option 2: Start new cycle (highlighted as recommended)
            _buildOption(
              context,
              icon: Icons.refresh_rounded,
              label: l10n.cycleCompletionRestart,
              description: l10n.cycleCompletionRestartDesc,
              color: AppTheme.primaryLight,
              highlighted: true,
              onTap: () => Navigator.of(context).pop('restart'),
            ),
            const SizedBox(height: 10),

            // Option 3: Stay here
            _buildOption(
              context,
              icon: Icons.place_rounded,
              label: l10n.cycleCompletionStay,
              description: l10n.cycleCompletionStayDesc,
              color: AppTheme.neutral,
              onTap: () => Navigator.of(context).pop('stay'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: highlighted
                ? color.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: highlighted
                  ? color.withValues(alpha: 0.4)
                  : AppTheme.cardBorder.withValues(alpha: 0.4),
              width: highlighted ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const CycleCompletionDialog(),
    );
  }
}
