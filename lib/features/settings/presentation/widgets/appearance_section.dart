import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/custom_theme.dart';
import '../../domain/entities/theme_preset.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/theme_state.dart';
import 'theme_editor_widget.dart';

class AppearanceSection extends StatefulWidget {
  final bool initiallyExpanded;
  const AppearanceSection({super.key, this.initiallyExpanded = false});

  @override
  State<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<AppearanceSection> {
  late bool _isAppearanceExpanded;
  bool _isThemeListExpanded = false;

  @override
  void initState() {
    super.initState();
    _isAppearanceExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final cubit = context.read<ThemeCubit>();
        final presets = cubit.getAvailablePresets();
        final currentPresetId = state.themePresetId;
        final localeCode = state.locale.languageCode;
        final savedThemes = state.savedCustomThemes;

        return _buildExpandableSection(
          context,
          title: l10n.appearance,
          icon: Icons.palette_rounded,
          accentColor: context.primaryColor,
          isExpanded: _isAppearanceExpanded,
          onToggle: () => setState(() => _isAppearanceExpanded = !_isAppearanceExpanded),
          children: [
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: presets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final isSelected = preset.id == currentPresetId;
                  return _buildThemeCard(
                    context,
                    preset: preset,
                    isSelected: isSelected,
                    localeCode: localeCode,
                    onTap: () => cubit.selectThemePreset(preset.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showThemeEditorSheet(context, state, l10n, null),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: Text(l10n.createNewTheme),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.secondaryColor,
                  side: BorderSide(color: context.secondaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (savedThemes.isNotEmpty) ...[
              const SizedBox(height: 20),
              InkWell(
                onTap: () => setState(() => _isThemeListExpanded = !_isThemeListExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isThemeListExpanded ? l10n.hideSavedThemes : l10n.showSavedThemes(savedThemes.length),
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isThemeListExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: context.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: savedThemes.map((theme) {
                    final isActive = currentPresetId == 'custom' && state.activeCustomThemeId == theme.id;
                    return _buildSavedThemeCard(
                      context,
                      theme: theme,
                      isActive: isActive,
                      l10n: l10n,
                      onTap: () => cubit.activateCustomTheme(theme.id),
                      onEdit: () => _showThemeEditorSheet(context, state, l10n, theme),
                      onDelete: () => _confirmDeleteTheme(context, theme, l10n),
                    );
                  }).toList(),
                ),
                crossFadeState: _isThemeListExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
            if (currentPresetId != 'emerald') ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.restore, size: 18),
                  label: Text(l10n.resetToDefault),
                  onPressed: () => cubit.selectThemePreset('emerald'),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final effectiveAccentColor = accentColor ?? context.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.outlineColor.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: effectiveAccentColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.amiri(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.surfaceContainerHighestColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.onSurfaceVariantColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required ThemePreset preset,
    required bool isSelected,
    required String localeCode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        decoration: BoxDecoration(
          color: preset.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? preset.primaryColor : preset.cardBorderColor,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: preset.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      preset.primaryColor.withValues(alpha: 0.2),
                      preset.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(preset.icon, color: preset.primaryColor, size: 36),
                  const Spacer(),
                  Text(
                    localeCode == 'ar' ? preset.nameAr : preset.name,
                    style: GoogleFonts.outfit(
                      color: preset.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: preset.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: preset.accentColor,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isSelected)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: preset.primaryColor,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedThemeCard(
    BuildContext context, {
    required CustomTheme theme,
    required bool isActive,
    required AppLocalizations l10n,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? context.secondaryColor : context.outlineColor,
          width: isActive ? 3 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse(theme.primary.replaceFirst('#', '0xFF'))),
                        Color(int.parse(theme.accent.replaceFirst('#', '0xFF'))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              theme.name,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: context.onSurfaceColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            Icon(
                              Icons.check_circle_rounded,
                              color: context.secondaryColor,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _colorDot(context, theme.primary),
                          const SizedBox(width: 4),
                          _colorDot(context, theme.accent),
                          const SizedBox(width: 4),
                          _colorDot(context, theme.background),
                          const SizedBox(width: 4),
                          _colorDot(context, theme.surface),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: onEdit,
                  color: context.onSurfaceVariantColor,
                  tooltip: l10n.edit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: onDelete,
                  color: context.errorColor,
                  tooltip: l10n.delete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorDot(BuildContext context, String hex) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Color(int.parse(hex.replaceFirst('#', '0xFF'))),
        shape: BoxShape.circle,
        border: Border.all(color: context.outlineColor, width: 0.5),
      ),
    );
  }

  Future<void> _showThemeEditorSheet(
    BuildContext context,
    ThemeState state,
    AppLocalizations l10n,
    CustomTheme? existingTheme,
  ) async {
    final cubit = context.read<ThemeCubit>();
    final isEditing = existingTheme != null;

    final colors = isEditing
        ? existingTheme.toColorMap()
        : {
            'primary': '#2E7D32',
            'accent': '#FFD54F',
            'background': '#0D1117',
            'surface': '#161B22',
            'text': '#E6EDF3',
            'textSecondary': '#8B949E',
            'cardBorder': '#30363D',
            'surfaceLight': '#21262D',
          };

    final labels = {
      'primary': 'Primary',
      'accent': 'Accent',
      'background': 'Background',
      'surface': 'Surface',
      'text': 'Text',
      'textSecondary': 'Text Secondary',
      'cardBorder': 'Card Border',
      'surfaceLight': 'Surface Light',
    };

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ThemeEditorWidget(
          colors: colors,
          labels: labels,
          l10n: l10n,
          isEditing: isEditing,
        );
      },
    );

    if (result == null) return;

    if (isEditing) {
      cubit.updateCustomTheme(existingTheme.id, result);
    } else {
      if (!context.mounted) return;
      final name = await _showThemeNameDialog(context, l10n, state.savedCustomThemes);
      if (name == null) return;

      final theme = CustomTheme(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        primary: result['primary']!,
        accent: result['accent']!,
        background: result['background']!,
        surface: result['surface']!,
        text: result['text']!,
        textSecondary: result['textSecondary']!,
        cardBorder: result['cardBorder']!,
        surfaceLight: result['surfaceLight']!,
      );
      cubit.addCustomTheme(theme);
    }
  }

  Future<String?> _showThemeNameDialog(
    BuildContext context,
    AppLocalizations l10n,
    List<CustomTheme> existingThemes,
  ) async {
    String defaultName = 'My Theme';
    int counter = 2;
    while (existingThemes.any((t) => t.name == defaultName)) {
      defaultName = 'My Theme $counter';
      counter++;
    }

    final controller = TextEditingController(text: defaultName);
    final focusNode = FocusNode();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        });

        return AlertDialog(
          title: Text(l10n.nameYourTheme),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: l10n.themeNameHint,
              helperText: 'You can edit this name',
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                Navigator.pop(dialogContext, val.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: Text(l10n.saveTheme),
            ),
          ],
        );
      },
    );
    controller.dispose();
    focusNode.dispose();
    return result;
  }

  Future<void> _confirmDeleteTheme(
    BuildContext context,
    CustomTheme theme,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.deleteTheme),
        content: Text(l10n.deleteThemeConfirm(theme.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(d, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<ThemeCubit>().deleteCustomTheme(theme.id);
    }
  }
}
