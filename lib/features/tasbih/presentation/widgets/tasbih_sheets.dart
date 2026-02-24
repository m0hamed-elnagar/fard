import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionSheet extends StatelessWidget {
  final TasbihState state;
  final ScrollController scrollController;
  final String? Function(String id) getName;
  final String? Function(String id) getDesc;

  const CategorySelectionSheet({
    super.key,
    required this.state,
    required this.scrollController,
    required this.getName,
    required this.getDesc,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.selectDhikrCategory,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.data.categories.length,
            itemBuilder: (context, index) {
              final category = state.data.categories[index];
              final isSelected = category.id == state.currentCategory.id;
              final localizedName = getName(category.id) ?? category.name;
              final localizedDesc = getDesc(category.id) ?? category.description;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.cardBorder,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.check_rounded : Icons.category_rounded,
                      color: isSelected ? AppTheme.onPrimary : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    localizedName,
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    localizedDesc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 13),
                  ),
                  onTap: () {
                    context.read<TasbihBloc>().add(TasbihEvent.selectCategory(category.id));
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TasbihSettingsSheet extends StatelessWidget {
  const TasbihSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TasbihBloc, TasbihState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.tasbihSettings,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingToggle(
                context,
                icon: Icons.vibration_rounded,
                title: l10n.hapticFeedback,
                value: state.data.settings.hapticFeedback,
                onChanged: (_) => context.read<TasbihBloc>().add(const TasbihEvent.toggleVibration()),
              ),
              _buildSettingToggle(
                context,
                icon: Icons.translate_rounded,
                title: l10n.showTranslation,
                value: state.data.settings.showTranslation,
                onChanged: (_) => context.read<TasbihBloc>().add(const TasbihEvent.toggleTranslation()),
              ),
              _buildSettingToggle(
                context,
                icon: Icons.text_fields_rounded,
                title: l10n.showTransliteration,
                value: state.data.settings.showTransliteration,
                onChanged: (_) => context.read<TasbihBloc>().add(const TasbihEvent.toggleTransliteration()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? AppTheme.accent : AppTheme.textSecondary),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}


class DuaSelectionSheet extends StatelessWidget {
  final TasbihState state;

  const DuaSelectionSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tasbihBloc = context.read<TasbihBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.chooseCompletionDua,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.data.completionDuas.length,
              itemBuilder: (context, index) {
                final dua = state.data.completionDuas[index];
                final isSelected = dua.id == state.currentCompletionDua?.id;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                  title: Text(dua.title, style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  onTap: () {
                    tasbihBloc.add(TasbihEvent.selectCompletionDua(dua.id));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
