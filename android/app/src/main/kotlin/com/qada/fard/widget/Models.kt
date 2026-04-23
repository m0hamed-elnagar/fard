package com.qada.fard.widget

import androidx.compose.ui.graphics.Color

/**
 * Widget theme data class used by both preview and real widgets.
 * Contains 6 color fields for complete widget theming.
 */
data class WidgetTheme(
    val primaryColorHex: String = "#2E7D32",
    val accentColorHex: String = "#FFD54F",
    val backgroundColorHex: String = "#0D1117",
    val surfaceColorHex: String = "#161B22",
    val textColorHex: String = "#FFFFFF",
    val textSecondaryColorHex: String = "#8B949E"
) {
    fun toColors(): WidgetColors = WidgetColors(
        primary = ColorUtils.parseComposeColor(primaryColorHex, Color(0xFF2E7D32)),
        accent = ColorUtils.parseComposeColor(accentColorHex, Color(0xFFFFD54F)),
        background = ColorUtils.parseComposeColor(backgroundColorHex, Color(0xFF0D1117)),
        surface = ColorUtils.parseComposeColor(surfaceColorHex, Color(0xFF161B22)),
        text = ColorUtils.parseComposeColor(textColorHex, Color(0xFFFFFFFF)),
        textSecondary = ColorUtils.parseComposeColor(textSecondaryColorHex, Color(0xFF8B949E))
    )
}

/**
 * Resolved Color objects from hex strings.
 */
data class WidgetColors(
    val primary: Color,
    val accent: Color,
    val background: Color,
    val surface: Color,
    val text: Color,
    val textSecondary: Color
)

/**
 * Prayer data for widget display.
 */
data class PrayerData(
    val name: String,
    val time: String
)

/**
 * Complete data for Prayer Schedule widget.
 */
data class PrayerScheduleData(
    val gregorianDate: String,
    val hijriDate: String,
    val dayOfWeek: String,
    val sunrise: String,
    val isRtl: Boolean,
    val nextPrayerName: String,
    val prayers: List<PrayerData>,
    val lastUpdated: Long = 0
)

/**
 * Data for Next Prayer Countdown widget.
 */
data class CountdownData(
    val nextPrayerName: String,
    val nextPrayerTime: Long = 0,
    val isRtl: Boolean,
    val lastUpdated: Long = 0
)
