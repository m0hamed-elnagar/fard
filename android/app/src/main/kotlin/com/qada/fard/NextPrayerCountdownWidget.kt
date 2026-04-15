package com.qada.fard

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import com.qada.fard.prayer.SettingsRepository
import com.qada.fard.widget.CountdownContent
import com.qada.fard.widget.CountdownData
import com.qada.fard.widget.WidgetTheme
import org.json.JSONObject

class NextPrayerCountdownWidget : GlanceAppWidget() {

    override val sizeMode: SizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val repository = SettingsRepository(context)
        val prayerDataJson = repository.getPrayerDataJson()

        val widgetData = try {
            if (prayerDataJson != null) parseWidgetData(prayerDataJson) else null
        } catch (e: Exception) {
            null
        }

        provideContent {
            if (widgetData != null) {
                // Check for widget theme override from SharedPreferences
                val widgetTheme = repository.getWidgetTheme()
                
                // Get default values for comparison
                val defaults = mapOf(
                    "primaryColorHex" to "#2E7D32",
                    "accentColorHex" to "#FFD54F",
                    "backgroundColorHex" to "#0D1117",
                    "surfaceColorHex" to "#161B22",
                    "textColorHex" to "#FFFFFF",
                    "textSecondaryColorHex" to "#8B949E"
                )
                
                // Check if ANY color differs from its default
                val hasThemeOverride = widgetTheme.any { (key, value) ->
                    value.isNotEmpty() && value != defaults[key]
                }
                
                android.util.Log.d("WidgetDebug", "CountdownWidget Theme override detection: hasThemeOverride=$hasThemeOverride")
                
                val themeToUse = if (hasThemeOverride) {
                    android.util.Log.d("WidgetDebug", "CountdownWidget: Using OVERRIDE theme")
                    com.qada.fard.widget.WidgetTheme(
                        primaryColorHex = widgetTheme["primaryColorHex"] ?: widgetData.primaryColorHex,
                        accentColorHex = widgetTheme["accentColorHex"] ?: widgetData.accentColorHex,
                        backgroundColorHex = widgetTheme["backgroundColorHex"] ?: widgetData.backgroundColorHex,
                        surfaceColorHex = widgetTheme["surfaceColorHex"] ?: widgetData.surfaceColorHex,
                        textColorHex = widgetTheme["textColorHex"] ?: widgetData.textColorHex,
                        textSecondaryColorHex = widgetTheme["textSecondaryColorHex"] ?: widgetData.textSecondaryColorHex
                    )
                } else {
                    android.util.Log.d("WidgetDebug", "CountdownWidget: Using FALLBACK theme")
                    widgetData.toWidgetTheme()
                }
                
                android.util.Log.d("WidgetDebug", "CountdownWidget final primary color hex: ${themeToUse.primaryColorHex}")
                
                CountdownContent(
                    data = widgetData.toCountdownData(),
                    theme = themeToUse,
                    isPreview = false
                )
            }
        }
    }

    private fun parseWidgetData(jsonString: String): WidgetData {
        val json = JSONObject(jsonString)
        return WidgetData(
            nextPrayerName = json.optString("nextPrayerName", ""),
            nextPrayerTime = json.optLong("nextPrayerTime", 0L),
            isRtl = json.getBoolean("isRtl"),
            lastUpdated = json.getLong("lastUpdated"),
            primaryColorHex = json.optString("primaryColorHex", "#2E7D32"),
            accentColorHex = json.optString("accentColorHex", "#FFD54F"),
            backgroundColorHex = json.optString("backgroundColorHex", "#0D1117"),
            surfaceColorHex = json.optString("surfaceColorHex", "#161B22"),
            textColorHex = json.optString("textColorHex", "#FFFFFF"),
            textSecondaryColorHex = json.optString("textSecondaryColorHex", "#8B949E")
        )
    }

    data class WidgetData(
        val nextPrayerName: String,
        val nextPrayerTime: Long,
        val isRtl: Boolean,
        val lastUpdated: Long,
        val primaryColorHex: String = "#2E7D32",
        val accentColorHex: String = "#FFD54F",
        val backgroundColorHex: String = "#0D1117",
        val surfaceColorHex: String = "#161B22",
        val textColorHex: String = "#FFFFFF",
        val textSecondaryColorHex: String = "#8B949E"
    ) {
        fun toCountdownData(): CountdownData = CountdownData(
            nextPrayerName = nextPrayerName,
            nextPrayerTime = nextPrayerTime,
            isRtl = isRtl,
            lastUpdated = lastUpdated
        )

        fun toWidgetTheme(): WidgetTheme = WidgetTheme(
            primaryColorHex = primaryColorHex,
            accentColorHex = accentColorHex,
            backgroundColorHex = backgroundColorHex,
            surfaceColorHex = surfaceColorHex,
            textColorHex = textColorHex,
            textSecondaryColorHex = textSecondaryColorHex
        )
    }
}