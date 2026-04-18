import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';

/// Color picker widget for widget theme customization.
/// Shows a color swatch grid and custom color picker.
class WidgetColorPicker extends StatelessWidget {
  final String label;
  final String currentHex;
  final ValueChanged<String> onColorChanged;

  const WidgetColorPicker({
    super.key,
    required this.label,
    required this.currentHex,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(currentHex);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: GoogleFonts.amiri(fontSize: 14),
      ),
      subtitle: Text(
        currentHex,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      onTap: () async {
        await showDialog<Color>(
          context: context,
          builder: (context) {
            Color selectedColor = color;
            final l10n = AppLocalizations.of(context)!;
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text(
                    l10n.pickColorTitle(label),
                    style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      color: selectedColor,
                      onColorChanged: (c) {
                        setDialogState(() => selectedColor = c);
                        onColorChanged(_colorToHex(c));
                      },
                      width: 40,
                      height: 40,
                      borderRadius: 12,
                      spacing: 10,
                      runSpacing: 10,
                      wheelDiameter: 165,
                      showColorName: true,
                      showColorCode: true,
                      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                        longPressMenu: true,
                      ),
                      pickersEnabled: const <ColorPickerType, bool>{
                        ColorPickerType.primary: true,
                        ColorPickerType.accent: false,
                        ColorPickerType.bw: true,
                        ColorPickerType.custom: true,
                        ColorPickerType.wheel: true,
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.done),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    String cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.parse(cleanHex, radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
