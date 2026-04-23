package com.qada.fard.widget

import org.json.JSONObject
import android.util.Log

object WidgetParser {
    private const val TAG = "WidgetParser"

    fun parseCountdownData(jsonString: String): CountdownData? {
        return try {
            val json = JSONObject(jsonString)
            CountdownData(
                nextPrayerName = json.optString("nextPrayerName", ""),
                nextPrayerTime = json.optLong("nextPrayerTime", 0L),
                isRtl = json.optBoolean("isRtl", false),
                lastUpdated = json.optLong("lastUpdated", 0L)
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing countdown data: $e")
            null
        }
    }

    fun parsePrayerScheduleData(jsonString: String): PrayerScheduleData? {
        return try {
            val json = JSONObject(jsonString)
            val prayersArray = json.optJSONArray("prayers")
            val prayers = mutableListOf<PrayerData>()
            if (prayersArray != null) {
                for (i in 0 until prayersArray.length()) {
                    val item = prayersArray.optJSONObject(i) ?: continue
                    prayers.add(
                        PrayerData(
                            name = item.optString("name", ""),
                            time = item.optString("time", "")
                        )
                    )
                }
            }

            PrayerScheduleData(
                gregorianDate = json.optString("gregorianDate", ""),
                hijriDate = json.optString("hijriDate", ""),
                dayOfWeek = json.optString("dayOfWeek", ""),
                sunrise = json.optString("sunrise", ""),
                isRtl = json.optBoolean("isRtl", false),
                nextPrayerName = json.optString("nextPrayerName", ""),
                prayers = prayers,
                lastUpdated = json.optLong("lastUpdated", 0L)
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing prayer schedule data: $e")
            null
        }
    }

    fun parseTheme(jsonString: String): WidgetTheme {
        return try {
            val json = JSONObject(jsonString)
            WidgetTheme(
                primaryColorHex = json.optString("primaryColorHex", "#2E7D32"),
                accentColorHex = json.optString("accentColorHex", "#FFD54F"),
                backgroundColorHex = json.optString("backgroundColorHex", "#0D1117"),
                surfaceColorHex = json.optString("surfaceColorHex", "#161B22"),
                textColorHex = json.optString("textColorHex", "#FFFFFF"),
                textSecondaryColorHex = json.optString("textSecondaryColorHex", "#8B949E")
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing theme from JSON: $e")
            WidgetTheme() // Return defaults
        }
    }
}
