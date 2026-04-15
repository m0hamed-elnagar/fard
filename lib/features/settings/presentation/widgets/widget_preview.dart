import 'package:flutter/material.dart';
import 'package:fard/features/settings/domain/entities/widget_preview_theme.dart';
import 'package:fard/core/l10n/app_localizations.dart';

/// Flutter-based widget preview that mimics the Android widget appearance.
/// This is simpler and more reliable than PlatformView + Compose.
class WidgetPreview extends StatelessWidget {
  final WidgetPreviewTheme theme;
  final WidgetPreviewType widgetType;
  final bool isRtl;

  const WidgetPreview({
    super.key,
    required this.theme,
    this.widgetType = WidgetPreviewType.prayerSchedule,
    this.isRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.toColors();
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      key: ValueKey('${widgetType.index}_${theme.hashCode}'),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: widgetType == WidgetPreviewType.prayerSchedule
          ? _buildPrayerSchedulePreview(colors, l10n)
          : _buildCountdownPreview(colors, l10n),
    );
  }

  Widget _buildPrayerSchedulePreview(WidgetColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          l10n.widgetPreviewDate,
          style: TextStyle(
            color: colors.accent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          l10n.widgetPreviewHijriDate,
          style: TextStyle(
            color: colors.text,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        
        // Divider
        Container(
          height: 1,
          color: colors.accent,
        ),
        const SizedBox(height: 6),
        
        // Prayer rows
        _buildPrayerRow(l10n.fajr, '05:30 AM', false, colors),
        _buildPrayerRow(l10n.sunrise, '06:15 AM', false, colors, isSecondary: true),
        _buildPrayerRow(l10n.dhuhr, '12:30 PM', false, colors),
        _buildPrayerRow(l10n.asr, '03:45 PM', true, colors), // Highlighted as next prayer
        const Spacer(),
      ],
    );
  }

  Widget _buildPrayerRow(
    String name,
    String time,
    bool isHighlighted,
    WidgetColors colors, {
    bool isSecondary = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: isRtl
            ? [
                Text(
                  time,
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : (isSecondary ? colors.textSecondary : colors.text),
                    fontSize: 11,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isHighlighted)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isHighlighted ? Colors.white : (isSecondary ? colors.textSecondary : colors.text),
                      fontSize: 11,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ]
            : [
                Text(
                  name,
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : (isSecondary ? colors.textSecondary : colors.text),
                    fontSize: 11,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isHighlighted)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  time,
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : (isSecondary ? colors.textSecondary : colors.text),
                    fontSize: 11,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildCountdownPreview(WidgetColors colors, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.nextPrayer,
          style: TextStyle(
            color: colors.text,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.asr,
          style: TextStyle(
            color: colors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 1,
          color: colors.accent,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.widgetPreviewCountdown,
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

