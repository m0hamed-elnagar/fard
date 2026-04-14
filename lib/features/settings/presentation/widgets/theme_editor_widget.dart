import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/l10n/app_localizations.dart';

import '../../domain/entities/theme_preset.dart';

/// A full-featured theme color editor as a bottom sheet.
///
/// Shows 8 color rows with swatch picker + hex input.
/// Auto-derives dependent colors when Primary or Accent changes.
class ThemeEditorWidget extends StatefulWidget {
  final Map<String, String> colors;
  final Map<String, String> labels;
  final AppLocalizations l10n;
  final bool isEditing;

  const ThemeEditorWidget({
    super.key,
    required this.colors,
    required this.labels,
    required this.l10n,
    required this.isEditing,
  });

  @override
  State<ThemeEditorWidget> createState() => _ThemeEditorWidgetState();
}

class _ThemeEditorWidgetState extends State<ThemeEditorWidget> {
  late final Map<String, TextEditingController> _hexControllers;

  @override
  void initState() {
    super.initState();
    _hexControllers = <String, TextEditingController>{};
    for (final entry in widget.colors.entries) {
      _hexControllers[entry.key] = TextEditingController(
        text: entry.value.substring(1),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _hexControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateColor(String key, Color color) {
    setState(() {
      widget.colors[key] = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      _hexControllers[key]!.text = widget.colors[key]!.substring(1);
    });
  }

  void _autoDeriveAll() {
    setState(() {
      final primary = Color(int.parse(widget.colors['primary']!.replaceFirst('#', '0xFF')));
      final accent = Color(int.parse(widget.colors['accent']!.replaceFirst('#', '0xFF')));
      final isDark = primary.computeLuminance() < 0.4;
      final brightness = isDark ? Brightness.dark : Brightness.light;

      final primaryScheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness);
      final accentScheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness);

      widget.colors['background'] = primaryScheme.surface.toHex();
      widget.colors['surface'] = primaryScheme.surfaceContainer.toHex();
      widget.colors['surfaceLight'] = primaryScheme.surfaceContainerHigh.toHex();
      widget.colors['text'] = primaryScheme.onSurface.toHex();
      widget.colors['textSecondary'] = primaryScheme.onSurfaceVariant.toHex();
      widget.colors['cardBorder'] = accentScheme.outline.withValues(alpha: 0.3).toHex();

      for (final key in ['background', 'surface', 'surfaceLight', 'text', 'textSecondary', 'cardBorder']) {
        _hexControllers[key]!.text = widget.colors[key]!.substring(1);
      }
    });
  }

  void _autoDeriveFromPrimary(String targetKey) {
    setState(() {
      final primary = Color(int.parse(widget.colors['primary']!.replaceFirst('#', '0xFF')));
      final isDark = primary.computeLuminance() < 0.4;
      final brightness = isDark ? Brightness.dark : Brightness.light;
      final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness);

      final colorMap = {
        'background': scheme.surface,
        'surface': scheme.surfaceContainer,
        'surfaceLight': scheme.surfaceContainerHigh,
        'text': scheme.onSurface,
        'textSecondary': scheme.onSurfaceVariant,
      };

      if (colorMap.containsKey(targetKey)) {
        widget.colors[targetKey] = colorMap[targetKey]!.toHex();
        _hexControllers[targetKey]!.text = widget.colors[targetKey]!.substring(1);
      }
    });
  }

  void _autoDeriveFromAccent() {
    setState(() {
      final accent = Color(int.parse(widget.colors['accent']!.replaceFirst('#', '0xFF')));
      final isDark = Color(int.parse(widget.colors['primary']!.replaceFirst('#', '0xFF'))).computeLuminance() < 0.4;
      final brightness = isDark ? Brightness.dark : Brightness.light;
      final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness);

      widget.colors['cardBorder'] = scheme.outline.withValues(alpha: 0.3).toHex();
      _hexControllers['cardBorder']!.text = widget.colors['cardBorder']!.substring(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceContainerColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle + header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.outlineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.isEditing ? widget.l10n.editTheme : widget.l10n.createNewTheme,
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    const Spacer(),
                    // Global auto-derive button for all colors
                    TextButton.icon(
                      onPressed: _autoDeriveAll,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(widget.l10n.autoDerive),
                      style: TextButton.styleFrom(foregroundColor: context.secondaryColor),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Color grid
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: widget.colors.entries.map((entry) {
                    final key = entry.key;
                    final hex = entry.value;
                    final currentColor = Color(
                      int.parse(hex.replaceFirst('#', '0xFF')),
                    );
                    // Auto buttons for derived colors (they derive from primary or accent)
                    final derivesFromPrimary = ['background', 'surface', 'surfaceLight', 'text', 'textSecondary'].contains(key);
                    final derivesFromAccent = key == 'cardBorder';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Color swatch
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDialog<Color>(
                                    context: context,
                                    builder: (d) {
                                      Color selectedColor = currentColor;
                                      return StatefulBuilder(
                                        builder: (context, setDialogState) {
                                          return AlertDialog(
                                            title: Text(widget.labels[key]!),
                                            content: SingleChildScrollView(
                                              child: ColorPicker(
                                                color: selectedColor,
                                                onColorChanged: (c) => setDialogState(() => selectedColor = c),
                                                showColorName: true,
                                                showColorCode: true,
                                                pickersEnabled: const {
                                                  ColorPickerType.primary: true,
                                                  ColorPickerType.wheel: true,
                                                },
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(d),
                                                child: Text(widget.l10n.cancel),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(d, selectedColor),
                                                child: Text(widget.l10n.select),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                  if (picked != null) _updateColor(key, picked);
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: currentColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.outlineColor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                    color: currentColor.computeLuminance() > 0.5
                                        ? Colors.black54
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Label
                              Expanded(
                                child: Text(
                                  widget.labels[key]!,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: context.onSurfaceColor,
                                  ),
                                ),
                              ),
                              // Auto buttons for derived colors
                              if (derivesFromPrimary)
                                IconButton(
                                  onPressed: () => _autoDeriveFromPrimary(key),
                                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                                  tooltip: 'Auto-derive from Primary color',
                                  color: context.secondaryColor,
                                ),
                              if (derivesFromAccent)
                                IconButton(
                                  onPressed: _autoDeriveFromAccent,
                                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                                  tooltip: 'Auto-derive from Accent color',
                                  color: context.secondaryColor,
                                ),
                              // Hex input
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _hexControllers[key],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: context.onSurfaceColor,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '#',
                                    prefixStyle: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: context.onSurfaceVariantColor,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val.length == 6 || val.length == 8) {
                                      try {
                                        Color(int.parse(val, radix: 16));
                                        setState(() {
                                          widget.colors[key] = '#$val';
                                        });
                                      } catch (_) {}
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Source hint for derived colors
                          if (derivesFromPrimary)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 60),
                              child: Text(
                                'Derived from: Primary',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: context.onSurfaceVariantColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (derivesFromAccent)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 60),
                              child: Text(
                                'Derived from: Accent',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: context.onSurfaceVariantColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        Map<String, String>.from(widget.colors),
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: Text(
                      widget.isEditing ? widget.l10n.updateTheme : widget.l10n.saveTheme,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.secondaryColor,
                      foregroundColor: context.theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
