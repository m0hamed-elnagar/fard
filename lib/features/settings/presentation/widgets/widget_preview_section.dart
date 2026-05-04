import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/widget_update_service.dart';
import '../../domain/entities/widget_preview_theme.dart';
import '../../domain/entities/theme_preset.dart';
import 'widget_preview.dart';
import 'widget_color_picker.dart';

class WidgetPreviewSection extends StatefulWidget {
  final bool initiallyExpanded;
  final String localeCode;
  final List<ThemePreset> presets;

  const WidgetPreviewSection({
    super.key,
    this.initiallyExpanded = false,
    required this.localeCode,
    required this.presets,
  });

  @override
  State<WidgetPreviewSection> createState() => _WidgetPreviewSectionState();
}

class _WidgetPreviewSectionState extends State<WidgetPreviewSection> {
  late bool _isExpanded;
  WidgetPreviewType _widgetPreviewType = WidgetPreviewType.prayerSchedule;
  WidgetPreviewTheme _widgetPreviewTheme = const WidgetPreviewTheme();
  bool _isApplyingWidgetTheme = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _loadSavedWidgetTheme();
  }

  Future<void> _loadSavedWidgetTheme() async {
    final themeMap = await getIt<WidgetUpdateService>().getWidgetTheme();
    if (themeMap != null && mounted) {
      setState(() {
        _widgetPreviewTheme = WidgetPreviewTheme.fromMap(themeMap);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _buildExpandableSection(
      context,
      title: l10n.widgetPreviewTitle,
      icon: Icons.widgets_rounded,
      accentColor: context.secondaryColor,
      isExpanded: _isExpanded,
      onToggle: () => setState(() => _isExpanded = !_isExpanded),
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<WidgetPreviewType>(
            segments: [
              ButtonSegment<WidgetPreviewType>(
                value: WidgetPreviewType.prayerSchedule,
                label: Text(l10n.prayerSchedule),
                icon: const Icon(Icons.calendar_view_month),
              ),
              ButtonSegment<WidgetPreviewType>(
                value: WidgetPreviewType.countdown,
                label: Text(l10n.countdown),
                icon: const Icon(Icons.timer_outlined),
              ),
            ],
            selected: {_widgetPreviewType},
            onSelectionChanged: (Set<WidgetPreviewType> newSelection) {
              setState(() {
                _widgetPreviewType = newSelection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: WidgetPreview(
              theme: _widgetPreviewTheme,
              widgetType: _widgetPreviewType,
              isRtl: widget.localeCode == 'ar',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.widgetStartFromPreset,
          style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.presets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = widget.presets[index];
              return _buildThemePresetCard(
                preset: preset,
                localeCode: widget.localeCode,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _widgetPreviewTheme = WidgetPreviewTheme.fromThemePreset(preset);
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Text(
              l10n.widgetThemeColorCustomization,
              style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.color_lens_rounded, color: Theme.of(context).colorScheme.primary),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    WidgetColorPicker(
                      label: l10n.widgetPrimaryColor,
                      currentHex: _widgetPreviewTheme.primaryColorHex,
                      onColorChanged: (hex) => setState(() {
                        _widgetPreviewTheme = _widgetPreviewTheme.copyWith(primaryColorHex: hex);
                      }),
                    ),
                    WidgetColorPicker(
                      label: l10n.widgetAccentColor,
                      currentHex: _widgetPreviewTheme.accentColorHex,
                      onColorChanged: (hex) => setState(() {
                        _widgetPreviewTheme = _widgetPreviewTheme.copyWith(accentColorHex: hex);
                      }),
                    ),
                    WidgetColorPicker(
                      label: l10n.widgetBackgroundColor,
                      currentHex: _widgetPreviewTheme.backgroundColorHex,
                      onColorChanged: (hex) => setState(() {
                        _widgetPreviewTheme = _widgetPreviewTheme.copyWith(backgroundColorHex: hex);
                      }),
                    ),
                    WidgetColorPicker(
                      label: l10n.widgetTextColor,
                      currentHex: _widgetPreviewTheme.textColorHex,
                      onColorChanged: (hex) => setState(() {
                        _widgetPreviewTheme = _widgetPreviewTheme.copyWith(textColorHex: hex);
                      }),
                    ),
                    WidgetColorPicker(
                      label: l10n.widgetSecondaryTextColor,
                      currentHex: _widgetPreviewTheme.textSecondaryColorHex,
                      onColorChanged: (hex) => setState(() {
                        _widgetPreviewTheme = _widgetPreviewTheme.copyWith(textSecondaryColorHex: hex);
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _widgetPreviewTheme = WidgetPreviewTheme.fromColorScheme(Theme.of(context).colorScheme);
                    });
                    try {
                      await getIt<WidgetUpdateService>().clearWidgetTheme();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.widgetThemeAppliedShortly)));
                      }
                    } catch (e) {
                      debugPrint('Error clearing widget theme: $e');
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: Text(
                    l10n.followAppTheme,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _isApplyingWidgetTheme
                      ? null
                      : () async {
                          setState(() => _isApplyingWidgetTheme = true);
                          try {
                            await getIt<WidgetUpdateService>().applyWidgetTheme(_widgetPreviewTheme.toMap());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.widgetThemeAppliedShortly), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.widgetThemeApplyFailed(e.toString())), backgroundColor: Theme.of(context).colorScheme.errorContainer),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isApplyingWidgetTheme = false);
                          }
                        },
                  child: _isApplyingWidgetTheme
                      ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                      : Text(
                          l10n.applyToWidget,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
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
        border: Border.all(color: context.outlineColor.withValues(alpha: 0.15), width: 1.0),
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
                    decoration: BoxDecoration(color: effectiveAccentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: effectiveAccentColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.amiri(fontSize: 19, fontWeight: FontWeight.bold, color: context.onSurfaceColor),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded),
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePresetCard({
    required ThemePreset preset,
    required String localeCode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: preset.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: preset.cardBorderColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(preset.icon, color: preset.primaryColor, size: 36),
              const Spacer(),
              Text(
                localeCode == 'ar' ? preset.nameAr : preset.name,
                style: GoogleFonts.outfit(color: preset.textColor, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: preset.primaryColor),
                  const SizedBox(width: 4),
                  CircleAvatar(radius: 6, backgroundColor: preset.accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
