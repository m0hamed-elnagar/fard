import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';

/// Color picker widget for widget theme customization.
/// Shows a color swatch grid and custom color picker.
class WidgetColorPicker extends StatelessWidget {
  final String label;
  final String currentHex;
  final ValueChanged<String> onColorChanged;
  final List<String> presetColors;

  const WidgetColorPicker({
    super.key,
    required this.label,
    required this.currentHex,
    required this.onColorChanged,
    this.presetColors = const [
      '#2E7D32', '#1B5E20', '#388E3C', '#4CAF50', // Greens
      '#FFD54F', '#FFC107', '#FFB300', '#FFA000', // Golds
      '#0D1117', '#161B22', '#21262D', '#30363D', // Darks
      '#FFFFFF', '#F5F5F5', '#E0E0E0', '#BDBDBD', // Lights
      '#1976D2', '#0D47A1', '#7B1FA2', '#C2185B', // Blues/Purples/Pinks
      '#D32F2F', '#F57C00', '#FBC02D', '#388E3C', // Reds/Oranges/Yellows
    ],
  });

  @override
  Widget build(BuildContext context) {
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
          color: _hexToColor(currentHex),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      onTap: () => _showColorPickerDialog(context),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _ColorPickerDialog(
          label: label,
          currentHex: currentHex,
          presetColors: presetColors,
          onColorSelected: onColorChanged,
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

/// Color picker dialog with preset swatches and custom color picker.
class _ColorPickerDialog extends StatefulWidget {
  final String label;
  final String currentHex;
  final List<String> presetColors;
  final ValueChanged<String> onColorSelected;

  const _ColorPickerDialog({
    required this.label,
    required this.currentHex,
    required this.presetColors,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late String _selectedHex;

  @override
  void initState() {
    super.initState();
    _selectedHex = widget.currentHex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        l10n.pickColorTitle(widget.label),
        style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preset color swatches
              Text(
                l10n.presetColors,
                style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: widget.presetColors.map((hex) {
                  final isSelected = hex == _selectedHex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedHex = hex);
                      widget.onColorSelected(hex);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _hexToColor(hex),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Custom color picker button
              OutlinedButton.icon(
                onPressed: () => _showCustomColorPicker(context),
                icon: const Icon(Icons.colorize),
                label: Text(l10n.customColor),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.done),
        ),
      ],
    );
  }

  void _showCustomColorPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color initialColor = _hexToColor(_selectedHex);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.customColorTitle(widget.label)),
          content: SingleChildScrollView(
            child: ColorPickerField(
              initialColor: initialColor,
              onColorChanged: (color) {
                _selectedHex = _colorToHex(color);
                widget.onColorSelected(_selectedHex);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

/// Simple color picker field using Material color picker.
class ColorPickerField extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerField({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late Color _currentColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _hexController = TextEditingController(text: _colorToHex(_currentColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color preview
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              _colorToHex(_currentColor),
              style: TextStyle(
                color: _isLightColor(_currentColor) ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Hex input field
        TextField(
          controller: _hexController,
          decoration: InputDecoration(
            labelText: l10n.hexColor,
            hintText: '#RRGGBBAA or #RRGGBB',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.tag),
          ),
          onChanged: (val) {
            final color = _hexToColor(val);
            if (color != null) {
              setState(() {
                _currentColor = color;
              });
              widget.onColorChanged(color);
            }
          },
        ),
        const SizedBox(height: 16),

        // Material color slider
        Text(l10n.pickAColor, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // Use Flutter's built-in color picker via dialog
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _colorButton(Colors.red),
            _colorButton(Colors.pink),
            _colorButton(Colors.purple),
            _colorButton(Colors.deepPurple),
            _colorButton(Colors.indigo),
            _colorButton(Colors.blue),
            _colorButton(Colors.lightBlue),
            _colorButton(Colors.cyan),
            _colorButton(Colors.teal),
            _colorButton(Colors.green),
            _colorButton(Colors.lightGreen),
            _colorButton(Colors.lime),
            _colorButton(Colors.yellow),
            _colorButton(Colors.amber),
            _colorButton(Colors.orange),
            _colorButton(Colors.deepOrange),
            _colorButton(Colors.brown),
            _colorButton(Colors.grey),
            _colorButton(Colors.blueGrey),
            _colorButton(Colors.black),
            _colorButton(Colors.white),
          ],
        ),
      ],
    );
  }

  Widget _colorButton(Color color) {
    final isSelected = color.toARGB32() == _currentColor.toARGB32();
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentColor = color;
          _hexController.text = _colorToHex(color);
        });
        widget.onColorChanged(color);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Color? _hexToColor(String hex) {
    try {
      String cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      if (cleanHex.length != 8) return null;
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  bool _isLightColor(Color color) {
    // Calculate relative luminance
    final r = (color.r * 255.0).round().clamp(0, 255) / 255.0;
    final g = (color.g * 255.0).round().clamp(0, 255) / 255.0;
    final b = (color.b * 255.0).round().clamp(0, 255) / 255.0;
    final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    return luminance > 0.5;
  }
}
