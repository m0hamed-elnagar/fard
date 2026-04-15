package com.qada.fard

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import com.qada.fard.prayer.SettingsRepository
import com.qada.fard.widget.PrayerScheduleContent
import com.qada.fard.widget.PrayerScheduleData
import com.qada.fard.widget.PrayerData
import com.qada.fard.widget.WidgetTheme
import org.json.JSONObject

class PrayerWidget : GlanceAppWidget() {

    override val sizeMode: SizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        android.util.Log.d("WidgetDebug", "=== provideGlance CALLED for PrayerWidget ===")
        val repository = SettingsRepository(context)
        val prayerDataJson = repository.getPrayerDataJson()

        android.util.Log.d("WidgetDebug", "Prayer data JSON retrieved: ${prayerDataJson != null}")
        if (prayerDataJson != null) {
            android.util.Log.d("WidgetDebug", "JSON starts with: ${prayerDataJson.take(100)}...")
        }

        val widgetData = try {
            if (prayerDataJson != null) parseWidgetData(prayerDataJson) else null
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "Error parsing widget data: $e")
            null
        }

        android.util.Log.d("WidgetDebug", "Providing content with widgetData: ${widgetData != null}")
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

                android.util.Log.d("WidgetDebug", "Theme override detection: hasThemeOverride=$hasThemeOverride")
                android.util.Log.d("WidgetDebug", "Widget theme from SharedPreferences: $widgetTheme")

                val themeToUse = if (hasThemeOverride) {
                    android.util.Log.d("WidgetDebug", "Using OVERRIDE theme from SharedPreferences")
                    com.qada.fard.widget.WidgetTheme(
                        primaryColorHex = widgetTheme["primaryColorHex"] ?: widgetData.primaryColorHex,
                        accentColorHex = widgetTheme["accentColorHex"] ?: widgetData.accentColorHex,
                        backgroundColorHex = widgetTheme["backgroundColorHex"] ?: widgetData.backgroundColorHex,
                        surfaceColorHex = widgetTheme["surfaceColorHex"] ?: widgetData.surfaceColorHex,
                        textColorHex = widgetTheme["textColorHex"] ?: widgetData.textColorHex,
                        textSecondaryColorHex = widgetTheme["textSecondaryColorHex"] ?: widgetData.textSecondaryColorHex
                    )
                } else {
                    android.util.Log.d("WidgetDebug", "Using FALLBACK theme from prayer data JSON")
                    widgetData.toWidgetTheme()
                }

                android.util.Log.d("WidgetDebug", "Final primary color hex used: ${themeToUse.primaryColorHex}")
                
                PrayerScheduleContent(
                    data = widgetData.toPrayerScheduleData(),
                    theme = themeToUse,
                    isPreview = false
                )
            }
        }
    }

    private fun parseWidgetData(jsonString: String): WidgetData {
        val json = JSONObject(jsonString)
        android.util.Log.d("WidgetDebug", "=== PARSING WIDGET DATA ===")
        android.util.Log.d("WidgetDebug", "Full JSON contains backgroundColorHex: ${json.optString("backgroundColorHex", "NOT_FOUND")}")

        val prayersArray = json.getJSONArray("prayers")
        val prayers = mutableListOf<PrayerItem>()
        for (i in 0 until prayersArray.length()) {
            val item = prayersArray.getJSONObject(i)
            prayers.add(
                PrayerItem(
                    name = item.getString("name"),
                    time = item.getString("time")
                )
            )
        }

        val widgetData = WidgetData(
            gregorianDate = json.getString("gregorianDate"),
            hijriDate = json.getString("hijriDate"),
            dayOfWeek = json.getString("dayOfWeek"),
            sunrise = json.getString("sunrise"),
            isRtl = json.getBoolean("isRtl"),
            nextPrayerName = json.optString("nextPrayerName", ""),
            prayers = prayers,
            lastUpdated = json.getLong("lastUpdated"),
            primaryColorHex = json.optString("primaryColorHex", "#2E7D32"),
            accentColorHex = json.optString("accentColorHex", "#FFD54F"),
            backgroundColorHex = json.optString("backgroundColorHex", "#0D1117"),
            surfaceColorHex = json.optString("surfaceColorHex", "#161B22"),
            textColorHex = json.optString("textColorHex", "#FFFFFF"),
            textSecondaryColorHex = json.optString("textSecondaryColorHex", "#8B949E")
        )

        android.util.Log.d("WidgetDebug", "Parsed WidgetData - PrimaryHex: ${widgetData.primaryColorHex}")
        android.util.Log.d("WidgetDebug", "=== END PARSING ===")

        return widgetData
    }

    data class WidgetData(
        val gregorianDate: String,
        val hijriDate: String,
        val dayOfWeek: String,
        val sunrise: String,
        val isRtl: Boolean,
        val nextPrayerName: String,
        val prayers: List<PrayerItem>,
        val lastUpdated: Long,
        val primaryColorHex: String = "#2E7D32",
        val accentColorHex: String = "#FFD54F",
        val backgroundColorHex: String = "#0D1117",
        val surfaceColorHex: String = "#161B22",
        val textColorHex: String = "#FFFFFF",
        val textSecondaryColorHex: String = "#8B949E"
    ) {
        fun toPrayerScheduleData(): PrayerScheduleData = PrayerScheduleData(
            gregorianDate = gregorianDate,
            hijriDate = hijriDate,
            dayOfWeek = dayOfWeek,
            sunrise = sunrise,
            isRtl = isRtl,
            nextPrayerName = nextPrayerName,
            prayers = prayers.map { PrayerData(it.name, it.time) },
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

    data class PrayerItem(
        val name: String,
        val time: String
    )
}
